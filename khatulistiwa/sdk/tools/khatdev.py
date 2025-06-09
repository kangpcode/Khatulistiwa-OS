#!/usr/bin/env python3
"""
============================================================================
khatdev.py - Khatulistiwa OS Development Tools Suite
Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
============================================================================

Comprehensive development tools untuk Khatulistiwa OS dengan fitur:
1. Project creation dengan template budaya Indonesia
2. Application building dan packaging
3. Cultural validation dan testing
4. Deployment tools
5. Documentation generation
"""

import os
import sys
import json
import argparse
import subprocess
import shutil
from pathlib import Path
from datetime import datetime
import zipfile
import hashlib

class KhatDev:
    def __init__(self):
        self.version = "1.0.0"
        self.sdk_path = Path(__file__).parent.parent
        self.templates_path = self.sdk_path / "templates"
        self.tools_path = self.sdk_path / "tools"
        self.cultural_path = self.sdk_path / "cultural"
        
        # Cultural themes
        self.batik_themes = [
            "parang", "kawung", "mega_mendung", "ceplok", "nitik", 
            "truntum", "sogan", "sekar_jagad", "sido_mukti", "wahyu_tumurun"
        ]
        
        # Indonesian colors
        self.cultural_colors = {
            "merah_delima": "#DC143C",
            "kuning_emas": "#FFD700", 
            "hijau_daun": "#228B22",
            "biru_laut": "#006994",
            "coklat_tanah": "#8B4513",
            "putih_kapas": "#F8F8FF",
            "hitam_arang": "#2F2F2F"
        }

    def create_project(self, name, template="basic", cultural_theme="parang"):
        """Create new Khatulistiwa OS project"""
        print(f"🚀 Creating Khatulistiwa OS project: {name}")
        print(f"📋 Template: {template}")
        print(f"🎨 Cultural theme: {cultural_theme}")
        
        project_path = Path(name)
        if project_path.exists():
            print(f"❌ Error: Directory {name} already exists")
            return False
            
        # Create project structure
        self._create_project_structure(project_path, template, cultural_theme)
        
        # Copy template files
        self._copy_template_files(project_path, template)
        
        # Generate manifest
        self._generate_manifest(project_path, name, cultural_theme)
        
        # Generate cultural assets
        self._generate_cultural_assets(project_path, cultural_theme)
        
        # Create build script
        self._create_build_script(project_path)
        
        print(f"✅ Project {name} created successfully!")
        print(f"📁 Location: {project_path.absolute()}")
        print(f"🔧 Next steps:")
        print(f"   cd {name}")
        print(f"   khatdev build")
        
        return True

    def _create_project_structure(self, project_path, template, cultural_theme):
        """Create project directory structure"""
        dirs = [
            "src",
            "resources/icons",
            "resources/sounds", 
            "resources/themes",
            "cultural/batik",
            "cultural/ornaments",
            "cultural/sounds",
            "tests",
            "docs"
        ]
        
        for dir_name in dirs:
            (project_path / dir_name).mkdir(parents=True, exist_ok=True)

    def _copy_template_files(self, project_path, template):
        """Copy template files to project"""
        template_path = self.templates_path / template
        
        if not template_path.exists():
            template_path = self.templates_path / "basic"
            
        if template_path.exists():
            for file_path in template_path.rglob("*"):
                if file_path.is_file():
                    relative_path = file_path.relative_to(template_path)
                    dest_path = project_path / relative_path
                    dest_path.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(file_path, dest_path)

    def _generate_manifest(self, project_path, name, cultural_theme):
        """Generate application manifest"""
        manifest = {
            "name": name,
            "version": "1.0.0",
            "description": f"Aplikasi Khatulistiwa OS dengan tema {cultural_theme}",
            "author": "Developer Nusantara",
            "category": "application",
            "type": "user_application",
            "cultural": {
                "indonesian_elements": True,
                "batik_theme": cultural_theme,
                "garuda_animations": True,
                "traditional_sounds": True,
                "cultural_colors": {
                    "primary": self.cultural_colors["merah_delima"],
                    "secondary": self.cultural_colors["kuning_emas"],
                    "accent": self.cultural_colors["hijau_daun"],
                    "background": self.cultural_colors["putih_kapas"]
                }
            },
            "permissions": [
                "basic_ui",
                "cultural_assets_access",
                "audio_playback"
            ],
            "dependencies": [
                "khatui_runtime.khat",
                "khatcore_runtime.khat"
            ],
            "min_os_version": "1.0.0",
            "ui_framework": "KhatUI",
            "build_date": datetime.now().isoformat(),
            "cultural_compliance": True
        }
        
        with open(project_path / "manifest.json", "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=2, ensure_ascii=False)

    def _generate_cultural_assets(self, project_path, cultural_theme):
        """Generate cultural assets for project"""
        # Generate batik pattern config
        batik_config = {
            "theme": cultural_theme,
            "primary_pattern": f"{cultural_theme}_primary",
            "secondary_pattern": f"{cultural_theme}_secondary",
            "colors": {
                "primary": self.cultural_colors["merah_delima"],
                "secondary": self.cultural_colors["kuning_emas"],
                "background": self.cultural_colors["putih_kapas"]
            },
            "ornaments": [
                f"ornamen_{cultural_theme}_1",
                f"ornamen_{cultural_theme}_2",
                f"ornamen_{cultural_theme}_3"
            ]
        }
        
        with open(project_path / "cultural/batik/theme.json", "w", encoding="utf-8") as f:
            json.dump(batik_config, f, indent=2, ensure_ascii=False)
            
        # Generate sound config
        sound_config = {
            "cultural_sounds": {
                "button_click": "gamelan_click.ogg",
                "notification": "gong_notification.ogg", 
                "success": "gamelan_success.ogg",
                "error": "gong_error.ogg"
            },
            "volume_levels": {
                "ui_sounds": 0.7,
                "notifications": 0.8,
                "cultural_music": 0.6
            }
        }
        
        with open(project_path / "cultural/sounds/config.json", "w", encoding="utf-8") as f:
            json.dump(sound_config, f, indent=2, ensure_ascii=False)

    def _create_build_script(self, project_path):
        """Create build script for project"""
        build_script = '''#!/usr/bin/env python3
"""
Build script for Khatulistiwa OS application
"""

import sys
import subprocess
from pathlib import Path

def build():
    """Build the application"""
    print("🔨 Building Khatulistiwa OS application...")
    
    # Run khatdev build
    result = subprocess.run([
        sys.executable, "-m", "khatdev", "build", "."
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✅ Build successful!")
        print(result.stdout)
    else:
        print("❌ Build failed!")
        print(result.stderr)
        return False
    
    return True

def test():
    """Run tests"""
    print("🧪 Running tests...")
    
    # Run khatdev test
    result = subprocess.run([
        sys.executable, "-m", "khatdev", "test", "."
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✅ All tests passed!")
        print(result.stdout)
    else:
        print("❌ Tests failed!")
        print(result.stderr)
        return False
    
    return True

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1] == "test":
            test()
        else:
            build()
    else:
        build()
'''
        
        with open(project_path / "build.py", "w", encoding="utf-8") as f:
            f.write(build_script)
        
        # Make executable on Unix systems
        if os.name != 'nt':
            os.chmod(project_path / "build.py", 0o755)

    def build_project(self, project_path="."):
        """Build Khatulistiwa OS project"""
        project_path = Path(project_path)
        
        print(f"🔨 Building project: {project_path.name}")
        
        # Validate project structure
        if not self._validate_project(project_path):
            return False
            
        # Load manifest
        manifest_path = project_path / "manifest.json"
        if not manifest_path.exists():
            print("❌ Error: manifest.json not found")
            return False
            
        with open(manifest_path, "r", encoding="utf-8") as f:
            manifest = json.load(f)
        
        # Validate cultural compliance
        if not self._validate_cultural_compliance(project_path, manifest):
            return False
            
        # Build application package
        output_path = project_path / "dist" / f"{manifest['name']}.khapp"
        if not self._build_khapp_package(project_path, output_path, manifest):
            return False
            
        print(f"✅ Build successful!")
        print(f"📦 Package: {output_path}")
        
        return True

    def _validate_project(self, project_path):
        """Validate project structure"""
        required_files = ["manifest.json", "src"]
        
        for file_name in required_files:
            if not (project_path / file_name).exists():
                print(f"❌ Error: Required file/directory {file_name} not found")
                return False
                
        return True

    def _validate_cultural_compliance(self, project_path, manifest):
        """Validate cultural compliance"""
        print("🎨 Validating cultural compliance...")
        
        cultural_config = manifest.get("cultural", {})
        
        # Check for Indonesian elements
        if not cultural_config.get("indonesian_elements", False):
            print("⚠️  Warning: No Indonesian elements specified")
            
        # Check for batik theme
        batik_theme = cultural_config.get("batik_theme")
        if batik_theme and batik_theme not in self.batik_themes:
            print(f"⚠️  Warning: Unknown batik theme: {batik_theme}")
            
        # Check for cultural assets
        cultural_path = project_path / "cultural"
        if not cultural_path.exists():
            print("⚠️  Warning: No cultural assets directory found")
            
        print("✅ Cultural compliance validated")
        return True

    def _build_khapp_package(self, project_path, output_path, manifest):
        """Build .khapp package"""
        print("📦 Creating .khapp package...")
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # Add manifest
            zipf.write(project_path / "manifest.json", "manifest.json")
            
            # Add source files
            src_path = project_path / "src"
            if src_path.exists():
                for file_path in src_path.rglob("*"):
                    if file_path.is_file():
                        arcname = "src" / file_path.relative_to(src_path)
                        zipf.write(file_path, arcname)
            
            # Add resources
            resources_path = project_path / "resources"
            if resources_path.exists():
                for file_path in resources_path.rglob("*"):
                    if file_path.is_file():
                        arcname = "resources" / file_path.relative_to(resources_path)
                        zipf.write(file_path, arcname)
            
            # Add cultural assets
            cultural_path = project_path / "cultural"
            if cultural_path.exists():
                for file_path in cultural_path.rglob("*"):
                    if file_path.is_file():
                        arcname = "cultural" / file_path.relative_to(cultural_path)
                        zipf.write(file_path, arcname)
        
        # Generate checksum
        checksum = self._calculate_checksum(output_path)
        checksum_path = output_path.with_suffix(".khapp.sha256")
        with open(checksum_path, "w") as f:
            f.write(f"{checksum}  {output_path.name}\n")
        
        print(f"📋 Checksum: {checksum}")
        return True

    def _calculate_checksum(self, file_path):
        """Calculate SHA256 checksum"""
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                sha256_hash.update(chunk)
        return sha256_hash.hexdigest()

    def test_project(self, project_path="."):
        """Test Khatulistiwa OS project"""
        project_path = Path(project_path)
        
        print(f"🧪 Testing project: {project_path.name}")
        
        # Load manifest
        manifest_path = project_path / "manifest.json"
        if not manifest_path.exists():
            print("❌ Error: manifest.json not found")
            return False
            
        with open(manifest_path, "r", encoding="utf-8") as f:
            manifest = json.load(f)
        
        # Run cultural compliance tests
        if not self._test_cultural_compliance(project_path, manifest):
            return False
            
        # Run unit tests if available
        tests_path = project_path / "tests"
        if tests_path.exists():
            if not self._run_unit_tests(tests_path):
                return False
        
        print("✅ All tests passed!")
        return True

    def _test_cultural_compliance(self, project_path, manifest):
        """Test cultural compliance"""
        print("🎨 Testing cultural compliance...")
        
        cultural_config = manifest.get("cultural", {})
        
        # Test Indonesian elements
        if cultural_config.get("indonesian_elements"):
            print("  ✅ Indonesian elements: Present")
        else:
            print("  ❌ Indonesian elements: Missing")
            return False
        
        # Test batik theme
        batik_theme = cultural_config.get("batik_theme")
        if batik_theme in self.batik_themes:
            print(f"  ✅ Batik theme: {batik_theme}")
        else:
            print(f"  ❌ Batik theme: Invalid or missing")
            return False
        
        # Test cultural colors
        cultural_colors = cultural_config.get("cultural_colors", {})
        if len(cultural_colors) >= 4:
            print("  ✅ Cultural colors: Complete")
        else:
            print("  ❌ Cultural colors: Incomplete")
            return False
        
        return True

    def _run_unit_tests(self, tests_path):
        """Run unit tests"""
        print("🔬 Running unit tests...")
        
        test_files = list(tests_path.glob("test_*.py"))
        if not test_files:
            print("  ⚠️  No test files found")
            return True
        
        for test_file in test_files:
            print(f"  Running {test_file.name}...")
            result = subprocess.run([
                sys.executable, str(test_file)
            ], capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"  ❌ {test_file.name} failed")
                print(result.stderr)
                return False
            else:
                print(f"  ✅ {test_file.name} passed")
        
        return True

def main():
    parser = argparse.ArgumentParser(description="Khatulistiwa OS Development Tools")
    parser.add_argument("--version", action="version", version=f"KhatDev {KhatDev().version}")
    
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # Create command
    create_parser = subparsers.add_parser("create", help="Create new project")
    create_parser.add_argument("name", help="Project name")
    create_parser.add_argument("--template", default="basic", help="Project template")
    create_parser.add_argument("--theme", default="parang", help="Cultural theme")
    
    # Build command
    build_parser = subparsers.add_parser("build", help="Build project")
    build_parser.add_argument("path", nargs="?", default=".", help="Project path")
    
    # Test command
    test_parser = subparsers.add_parser("test", help="Test project")
    test_parser.add_argument("path", nargs="?", default=".", help="Project path")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    khatdev = KhatDev()
    
    if args.command == "create":
        khatdev.create_project(args.name, args.template, args.theme)
    elif args.command == "build":
        khatdev.build_project(args.path)
    elif args.command == "test":
        khatdev.test_project(args.path)

if __name__ == "__main__":
    main()
