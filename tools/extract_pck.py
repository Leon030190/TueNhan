#!/usr/bin/env python3
# Script trích xuất tài nguyên từ file Godot PCK (Godot 4.x)
# Tự động giải mã Streamed Texture GST2 thành ảnh PNG chuẩn

import os
import struct
import io
import json
import shutil
from PIL import Image

def extract_godot_pck(pck_path, output_dir):
    with open(pck_path, 'rb') as f:
        magic = f.read(4)
        if magic != b'GDPC':
            raise ValueError("Không phải định dạng Godot PCK hợp lệ!")
        
        fmt_ver = struct.unpack('<I', f.read(4))[0]
        ver_major = struct.unpack('<I', f.read(4))[0]
        ver_minor = struct.unpack('<I', f.read(4))[0]
        ver_patch = struct.unpack('<I', f.read(4))[0]
        flags = struct.unpack('<I', f.read(4))[0]
        file_base = struct.unpack('<Q', f.read(8))[0]
        
        # Đọc offset danh mục ở cuối header
        # Với file TueNhan.pck (Godot 4.7):
        f.seek(0x20)
        dir_offset = struct.unpack('<Q', f.read(8))[0]
        f.seek(dir_offset)
        file_count = struct.unpack('<I', f.read(4))[0]
        
        print(f"Đang đọc {file_count} files từ {pck_path} (Godot {ver_major}.{ver_minor}.{ver_patch})...")
        
        entries = {}
        for _ in range(file_count):
            path_len = struct.unpack('<I', f.read(4))[0]
            rel_path = f.read(path_len).decode('utf-8', errors='replace').rstrip('\x00')
            offset = struct.unpack('<Q', f.read(8))[0]
            size = struct.unpack('<Q', f.read(8))[0]
            md5 = f.read(16)
            f_flags = struct.unpack('<I', f.read(4))[0]
            entries[rel_path] = (offset, size)
            
        # Trích xuất toàn bộ file
        for rel_path, (offset, size) in entries.items():
            clean_path = rel_path[6:] if rel_path.startswith('res://') else rel_path
            dest_path = os.path.join(output_dir, clean_path.replace('/', os.sep))
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)
            
            f.seek(file_base + offset)
            data = f.read(size)
            
            with open(dest_path, 'wb') as out_f:
                out_f.write(data)
                
        print(f"Đã trích xuất xong {len(entries)} file.")
        
        # Chuyển đổi các texture GST2 thành ảnh PNG
        print("Đang chuyển đổi texture sang PNG...")
        count = 0
        for rel_path, (offset, size) in entries.items():
            if rel_path.endswith('.png.import'):
                clean_orig = rel_path[:-7]
                if clean_orig.startswith('res://'):
                    clean_orig = clean_orig[6:]
                target_img = os.path.join(output_dir, clean_orig.replace('/', os.sep))
                
                f.seek(file_base + offset)
                imp_text = f.read(size).decode('utf-8', errors='ignore')
                ctex_res = None
                for line in imp_text.splitlines():
                    if 'path="res://' in line:
                        ctex_res = line.split('="res://')[1].strip('"')
                        break
                        
                if ctex_res and ctex_res in entries:
                    c_off, c_sz = entries[ctex_res]
                    f.seek(file_base + c_off)
                    c_data = f.read(c_sz)
                    riff_pos = c_data.find(b'RIFF')
                    if riff_pos != -1:
                        try:
                            im = Image.open(io.BytesIO(c_data[riff_pos:]))
                            im.save(target_img, format='PNG')
                            count += 1
                        except Exception:
                            pass
        print(f"Đã chuyển đổi thành công {count} ảnh PNG.")

if __name__ == '__main__':
    extract_godot_pck('TueNhan.pck', 'extracted_resources')
