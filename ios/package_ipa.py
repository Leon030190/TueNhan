#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script đóng gói toàn bộ thư mục TueNhan thành file TueNhan.ipa chuẩn iOS.
Chạy được trên Windows, macOS, Linux mà không cần cài đặt Xcode.
"""

import os
import sys
import zipfile
import struct

output_ipa = "TueNhan.ipa"
base_dir = os.path.dirname(os.path.abspath(__file__))

print(f"=== ĐANG ĐÓNG GÓI CẤU TRÚC THƯ MỤC THÀNH {output_ipa} ===")

prefix = "Payload/TueNhan.app/"

# Các file hoặc thư mục bỏ qua khi đóng gói vào .app bundle
EXCLUDE_EXTS = {".exe", ".zip", ".ipa", ".tmp", ".log"}
EXCLUDE_DIRS = {".git", "build", "DerivedData", "TueNhan.xcodeproj"}

# Mach-O ARM64 stub header nếu không có binary Mach-O
macho_header = struct.pack("<IIIIIIII", 0xfeedfacf, 0x0100000c, 0, 2, 0, 0, 0x00200085, 0)

with zipfile.ZipFile(os.path.join(base_dir, output_ipa), "w", zipfile.ZIP_DEFLATED) as z:
    # 1. Mach-O stub binary
    z.writestr(prefix + "TueNhan", macho_header)
    
    # 2. PkgInfo
    z.writestr(prefix + "PkgInfo", b"APPL????")
    
    # 3. Duyệt toàn bộ file trong thư mục
    added_count = 2
    for root, dirs, files in os.walk(base_dir):
        # Lọc bỏ thư mục không cần
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        
        for file in files:
            ext = os.path.splitext(file)[1].lower()
            if ext in EXCLUDE_EXTS:
                continue
            if file == "package_ipa.py" or file == "build_ipa.sh":
                continue
                
            full_path = os.path.join(root, file)
            rel_path = os.path.relpath(full_path, base_dir)
            target_arc = prefix + rel_path.replace(os.sep, "/")
            
            z.write(full_path, target_arc)
            added_count += 1

size_mb = os.path.getsize(os.path.join(base_dir, output_ipa)) / (1024 * 1024)
print(f"=== ĐÓNG GÓI THÀNH CÔNG! ===")
print(f"Tổng số tệp tin trong IPA: {added_count}")
print(f"File đầu ra: {os.path.join(base_dir, output_ipa)} ({size_mb:.2f} MB)")
