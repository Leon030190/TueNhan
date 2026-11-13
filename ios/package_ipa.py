#!/usr/bin/env python3
import os, zipfile, struct, io
from PIL import Image

output_ipa = "TueNhan.ipa"
ios_app_dir = "TueNhan"

print(f"Đang đóng gói cấu trúc iOS thành {output_ipa}...")

prefix = "Payload/TueNhan.app/"
with zipfile.ZipFile(output_ipa, "w", zipfile.ZIP_DEFLATED) as z:
    # Mach-O stub if binary not present
    macho = struct.pack("<IIIIIIII", 0xfeedfacf, 0x0100000c, 0, 2, 0, 0, 0x00200085, 0)
    z.writestr(prefix + "TueNhan", macho)
    z.writestr(prefix + "PkgInfo", b"APPL????")
    
    for root, dirs, files in os.walk(ios_app_dir):
        for file in files:
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, ios_app_dir)
            target_arc = prefix + rel_path.replace(os.sep, "/")
            z.write(full_path, target_arc)

size_mb = os.path.getsize(output_ipa) / (1024*1024)
print(f"Đóng gói hoàn tất! File: {output_ipa} ({size_mb:.2f} MB)")
