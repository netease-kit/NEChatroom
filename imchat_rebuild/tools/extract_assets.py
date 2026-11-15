#!/usr/bin/env python3
"""Extract only Flutter app assets from an APK/APKS supplied by the developer."""
import argparse
import os
import zipfile
from pathlib import Path

KEEP = ("icons/", "images/", "fonts/", "lottie/", "sounds/", "videos/")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("apks", help="Path to Im Chat .apks or .apk file")
    parser.add_argument("--out", default="assets/original", help="Output directory")
    args = parser.parse_args()
    source = Path(args.apks)
    output = Path(args.out)
    output.mkdir(parents=True, exist_ok=True)
    count = 0
    total = 0
    with zipfile.ZipFile(source) as bundle:
        apk_name = "base.apk" if "base.apk" in bundle.namelist() else None
        if apk_name is None:
            raise SystemExit("APKS archive does not contain base.apk")
        apk_bytes = bundle.read(apk_name)
    import io
    with zipfile.ZipFile(io.BytesIO(apk_bytes)) as apk:
        prefix = "assets/flutter_assets/assets/"
        for item in apk.infolist():
            if not item.filename.startswith(prefix) or item.is_dir():
                continue
            relative = item.filename[len(prefix):]
            if not relative.startswith(KEEP):
                continue
            target = output / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            data = apk.read(item)
            target.write_bytes(data)
            count += 1
            total += len(data)
    print(f"Extracted {count} files ({total:,} bytes) to {output}")

if __name__ == "__main__":
    main()
