#!/usr/bin/env python3
"""
============================================================================
KhApp Builder - Package Builder untuk Khatulistiwa OS Applications
Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
============================================================================
"""

import os
import sys
import json
import hashlib
import struct
import time
from typing import Dict, List, Any, Optional

class KhappBuilder:
    """Builder untuk membuat paket .khapp"""

    def __init__(self):
        self.version = "1.0.0"
        self.magic_number = b'KHAP'
        self.format_version = 1

    def build_package(self, source_dir: str, output_path: str) -> bool:
        """Build paket .khapp dari direktori sumber"""

        print(f"Building .khapp package from {source_dir}")
        print("=" * 60)

        try:
            # Validasi direktori sumber
            if not os.path.exists(source_dir):
                print(f"Error: Source directory tidak ditemukan: {source_dir}")
                return False

            # Load manifest
            manifest_path = os.path.join(source_dir, "manifest.json")
            if not os.path.exists(manifest_path):
                print(f"Error: manifest.json tidak ditemukan di {source_dir}")
                return False

            with open(manifest_path, 'r', encoding='utf-8') as f:
                manifest = json.load(f)

            print(f"Package: {manifest.get('name', 'Unknown')}")
            print(f"Version: {manifest.get('version', '1.0.0')}")
            print(f"Author: {manifest.get('author', 'Unknown')}")

            # Validasi manifest
            if not self.validate_manifest(manifest):
                print("Error: Manifest tidak valid")
                return False

            # Compile executable
            executable_data = self.compile_executable(source_dir, manifest)
            if executable_data is None:
                print("Error: Gagal mengcompile executable")
                return False

            # Collect assets
            assets = self.collect_assets(source_dir, manifest)
            print(f"Assets collected: {len(assets)} files")

            # Collect localization
            localization = self.collect_localization(source_dir, manifest)
            print(f"Localization files: {len(localization)} languages")

            # Generate metadata
            metadata = self.generate_metadata(manifest, source_dir)

            # Create signature
            signature = self.create_signature(manifest, executable_data, assets)

            # Write .khapp file
            if self.write_khapp_file(manifest, executable_data, assets,
                                   localization, metadata, signature, output_path):
                print(f"Package berhasil dibuat: {output_path}")
                if os.path.exists(output_path):
                    print(f"Size: {os.path.getsize(output_path)} bytes")
                return True
            else:
                print("Error: Gagal menulis file .khapp")
                return False

        except Exception as e:
            print(f"Error: {str(e)}")
            return False

    def validate_manifest(self, manifest: Dict[str, Any]) -> bool:
        """Validasi manifest aplikasi"""
        required_fields = ['name', 'version', 'description', 'author']

        for field in required_fields:
            if field not in manifest:
                print(f"Error: Field '{field}' wajib ada dalam manifest")
                return False

        return True

    def compile_executable(self, source_dir: str, manifest: Dict[str, Any]) -> Optional[bytes]:
        """Compile executable dari source code"""

        # Cari file source utama
        main_files = [
            f"{manifest['name'].lower()}.khat",
            "main.khat",
            "app.khat"
        ]

        main_file = None
        for filename in main_files:
            filepath = os.path.join(source_dir, filename)
            if os.path.exists(filepath):
                main_file = filepath
                break

        if main_file is None:
            print("Warning: Tidak ada source file ditemukan, menggunakan placeholder")
            return b"KHAT_PLACEHOLDER_EXECUTABLE"

        print(f"Compiling: {os.path.basename(main_file)}")

        with open(main_file, 'rb') as f:
            source_data = f.read()

        # Add header untuk executable
        header = struct.pack('<4sI', b'KHAT', len(source_data))
        return header + source_data

    def collect_assets(self, source_dir: str, manifest: Dict[str, Any]) -> Dict[str, bytes]:
        """Collect semua asset files"""
        assets = {}
        asset_dirs = ['resources', 'assets', 'cultural']

        for asset_dir in asset_dirs:
            asset_path = os.path.join(source_dir, asset_dir)
            if os.path.exists(asset_path):
                self._collect_files_recursive(asset_path, assets, asset_dir)

        return assets

    def _collect_files_recursive(self, directory: str, assets: Dict[str, bytes], prefix: str):
        """Collect files secara recursive"""
        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                relative_path = os.path.relpath(file_path, directory)
                asset_key = f"{prefix}/{relative_path}".replace('\\', '/')

                try:
                    with open(file_path, 'rb') as f:
                        assets[asset_key] = f.read()
                except Exception as e:
                    print(f"Warning: Gagal membaca {file_path}: {e}")

    def collect_localization(self, source_dir: str, manifest: Dict[str, Any]) -> Dict[str, bytes]:
        """Collect localization files"""
        localization = {}

        # Default Indonesian locale
        default_locale = {
            "app_name": manifest.get('name', 'Unknown App'),
            "app_description": manifest.get('description', 'No description'),
            "language": "Bahasa Indonesia"
        }
        localization['id_ID'] = json.dumps(default_locale, ensure_ascii=False).encode('utf-8')

        return localization

    def generate_metadata(self, manifest: Dict[str, Any], source_dir: str) -> Dict[str, Any]:
        """Generate metadata untuk package"""
        metadata = {
            'build_time': int(time.time()),
            'build_version': self.version,
            'package_format': self.format_version,
            'cultural_elements': manifest.get('cultural', {}).get('indonesian_elements', False),
            'ui_framework': manifest.get('ui_framework', 'KhatUI'),
            'min_os_version': manifest.get('min_os_version', '1.0.0')
        }
        return metadata

    def create_signature(self, manifest: Dict[str, Any], executable: bytes,
                        assets: Dict[str, bytes]) -> bytes:
        """Create digital signature untuk package"""
        content_hash = hashlib.sha256()
        content_hash.update(json.dumps(manifest, sort_keys=True).encode('utf-8'))
        content_hash.update(executable)

        for key in sorted(assets.keys()):
            content_hash.update(key.encode('utf-8'))
            content_hash.update(assets[key])

        signature_data = {
            'algorithm': 'SHA256',
            'hash': content_hash.hexdigest(),
            'timestamp': int(time.time()),
            'signer': 'KhatSDK'
        }

        return json.dumps(signature_data).encode('utf-8')

    def write_khapp_file(self, manifest: Dict[str, Any], executable: bytes,
                        assets: Dict[str, bytes], localization: Dict[str, bytes],
                        metadata: Dict[str, Any], signature: bytes, output_path: str) -> bool:
        """Write package ke file .khapp"""
        try:
            with open(output_path, 'wb') as f:
                # Magic number
                f.write(self.magic_number)

                # Format version
                f.write(struct.pack('<I', self.format_version))

                # Manifest section
                manifest_data = json.dumps(manifest, ensure_ascii=False).encode('utf-8')
                f.write(struct.pack('<I', len(manifest_data)))
                f.write(manifest_data)

                # Executable section
                f.write(struct.pack('<I', len(executable)))
                f.write(executable)

                # Assets section
                f.write(struct.pack('<I', len(assets)))
                for asset_name, asset_data in assets.items():
                    name_data = asset_name.encode('utf-8')
                    f.write(struct.pack('<I', len(name_data)))
                    f.write(name_data)
                    f.write(struct.pack('<I', len(asset_data)))
                    f.write(asset_data)

                # Localization section
                f.write(struct.pack('<I', len(localization)))
                for locale_name, locale_data in localization.items():
                    name_data = locale_name.encode('utf-8')
                    f.write(struct.pack('<I', len(name_data)))
                    f.write(name_data)
                    f.write(struct.pack('<I', len(locale_data)))
                    f.write(locale_data)

                # Metadata section
                metadata_data = json.dumps(metadata).encode('utf-8')
                f.write(struct.pack('<I', len(metadata_data)))
                f.write(metadata_data)

                # Signature section
                f.write(struct.pack('<I', len(signature)))
                f.write(signature)

            return True

        except Exception as e:
            print(f"Error writing .khapp file: {e}")
            return False

def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("KhApp Builder - Khatulistiwa OS Application Builder")
        print("Usage: python3 khapp_builder.py <source_dir> [options]")
        print("Options:")
        print("  -o, --output <file>     Output .khapp file")
        print("Example:")
        print("  python3 khapp_builder.py apps/myapp -o myapp.khapp")
        return 1

    source_dir = sys.argv[1]
    output_path = None

    # Parse arguments
    i = 2
    while i < len(sys.argv):
        if sys.argv[i] in ['-o', '--output']:
            if i + 1 < len(sys.argv):
                output_path = sys.argv[i + 1]
                i += 2
            else:
                print("Error: --output requires a filename")
                return 1
        else:
            print(f"Error: Unknown option {sys.argv[i]}")
            return 1

    # Default output path
    if output_path is None:
        app_name = os.path.basename(source_dir.rstrip('/\\'))
        output_path = f"{app_name}.khapp"

    # Build package
    builder = KhappBuilder()
    success = builder.build_package(source_dir, output_path)

    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())