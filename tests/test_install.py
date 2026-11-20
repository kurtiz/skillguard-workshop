"""Maintainer tests only. Participants do not need Python."""
import hashlib
import io
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipIf(os.name == 'nt', 'POSIX installer fixtures; Windows has its own native CI check')
class InstallContracts(unittest.TestCase):
    def fixture(self, system='Darwin', architecture='arm64', kind='regular'):
        temporary = tempfile.TemporaryDirectory(prefix='skillguard workshop ')
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name)
        (root/'scripts').mkdir()
        (root/'release').mkdir()
        shutil.copyfile(ROOT/'scripts/install.sh', root/'scripts/install.sh')
        (root/'release/version.txt').write_text('0.17.0\n')
        data = b'#!/bin/sh\nprintf "%s\\n" "skillguard version 0.17.0"\n'
        archive = root/'offline release.tar.gz'
        with tarfile.open(archive,'w:gz') as tar:
            entry = tarfile.TarInfo('skillguard' if kind!='traversal' else '../outside')
            entry.mode=0o755
            if kind=='symlink':
                entry.type=tarfile.SYMTYPE
                entry.linkname='/outside'
                tar.addfile(entry)
            else:
                entry.size=len(data)
                tar.addfile(entry,io.BytesIO(data))
        digest=hashlib.sha256(archive.read_bytes()).hexdigest()
        os_name={'Darwin':'darwin','Linux':'linux'}.get(system,'unsupported')
        asset=f'skillguard_0.17.0_{os_name}_{architecture}.tar.gz'
        (root/'release/checksums.txt').write_text(f'{digest}  {asset}\n')
        fake=root/'test-bin';fake.mkdir()
        uname=fake/'uname'
        uname.write_text('#!/bin/sh\ncase "$1" in -s) printf "%s\\n" "$TEST_OS" ;; -m) printf "%s\\n" "$TEST_ARCH" ;; esac\n')
        uname.chmod(0o755)
        env=dict(os.environ,PATH=str(fake)+os.pathsep+os.environ['PATH'],TEST_OS=system,TEST_ARCH=architecture)
        return root,archive,env

    def run_install(self,root,archive,env):
        return subprocess.run(['sh',str(root/'scripts/install.sh'),'--archive',str(archive)],env=env,text=True,capture_output=True,timeout=20)

    def test_supported_posix_platforms_and_paths_with_spaces(self):
        for system in ['Darwin','Linux']:
            for arch in ['amd64','arm64']:
                with self.subTest(system=system,arch=arch):
                    root,archive,env=self.fixture(system,arch)
                    result=self.run_install(root,archive,env)
                    self.assertEqual(result.returncode,0,result.stderr)
                    self.assertIn('Verified SHA-256',result.stdout)
                    self.assertTrue((root/'.tools/skillguard').is_file())
                    self.assertFalse(list((root/'.tools').glob('download.*')))

    def test_corrupt_archive_preserves_previous_install(self):
        root,archive,env=self.fixture()
        (root/'.tools').mkdir()
        binary=root/'.tools/skillguard';binary.write_text('previous installation')
        archive.write_bytes(archive.read_bytes()+b'tampered')
        result=self.run_install(root,archive,env)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('SHA-256 mismatch',result.stderr)
        self.assertEqual(binary.read_text(),'previous installation')
        self.assertFalse(list((root/'.tools').glob('download.*')))

    def test_missing_or_duplicate_pin_is_rejected(self):
        for content in ['', 'a'*64+'  skillguard_0.17.0_darwin_arm64.tar.gz\n'+'b'*64+'  skillguard_0.17.0_darwin_arm64.tar.gz\n']:
            root,archive,env=self.fixture()
            (root/'release/checksums.txt').write_text(content)
            result=self.run_install(root,archive,env)
            self.assertNotEqual(result.returncode,0)
            self.assertFalse((root/'.tools/skillguard').exists())

    def test_symlink_and_traversal_archives_are_rejected(self):
        for kind in ['symlink','traversal']:
            root,archive,env=self.fixture(kind=kind)
            result=self.run_install(root,archive,env)
            self.assertNotEqual(result.returncode,0)
            self.assertFalse((root/'.tools/skillguard').exists())
            self.assertFalse((root/'outside').exists())

    def test_install_directory_symlink_is_rejected(self):
        root,archive,env=self.fixture()
        outside=root/'outside';outside.mkdir();(root/'.tools').symlink_to(outside,target_is_directory=True)
        result=self.run_install(root,archive,env)
        self.assertNotEqual(result.returncode,0)
        self.assertFalse(list(outside.iterdir()))
