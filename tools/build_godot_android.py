#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script build hoàn chỉnh Godot 4.7.2 Android APK trên GitHub Actions (Ubuntu runner) & Local
Tự động tạo Release Keystore, thiết lập Export Templates và ký chứng chỉ APK đa phiên bản (v1, v2, v3).
Cho phép cài đặt từ Android 5.0 (API 21) đời cũ đến Android 15 (API 35) mới nhất trên mọi kiến trúc CPU (arm64, armv7, x86_64, x86).
"""

import os
import sys
import subprocess
import urllib.request
import zlib
import zipfile
import shutil
import glob
import re

TPZ_URL = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz"
# Byte offsets in export_templates.tpz
DEBUG_START = 85
DEBUG_END = 125834960
RELEASE_START = 125835048
RELEASE_END = 229784647

LINUX_GODOT_URL = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip"
WIN_GODOT_URL = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip"

KEYSTORE_PATH = "release.keystore"
KEYSTORE_ALIAS = "tuenhan"
KEYSTORE_PASS = "tuenhan_secret_2026"

def download_range(url, start, end, out_path, desc=""):
    if os.path.exists(out_path) and os.path.getsize(out_path) > 1000000:
        print(f"File đã tồn tại: {out_path} ({os.path.getsize(out_path)} bytes)")
        return
    print(f"Đang tải {desc} ({((end - start + 1) / (1024*1024)):.1f} MB)...")
    req = urllib.request.Request(url)
    req.add_header("Range", f"bytes={start}-{end}")
    decompressor = zlib.decompressobj(-zlib.MAX_WBITS)
    with urllib.request.urlopen(req) as resp, open(out_path, "wb") as f:
        while True:
            chunk = resp.read(1024 * 1024 * 4)
            if not chunk:
                break
            f.write(decompressor.decompress(chunk))
        f.write(decompressor.flush())
    print(f"Tải thành công: {out_path} ({os.path.getsize(out_path)} bytes)")

def ensure_keystore():
    if os.path.exists(KEYSTORE_PATH) and os.path.getsize(KEYSTORE_PATH) > 0:
        print(f"Đã có Release Keystore: {KEYSTORE_PATH}")
        return
    print("=== TẠO CHỨNG CHỈ SỐ RELEASE KEYSTORE CHO ANDROID ===")
    keytool = "keytool"
    if sys.platform == "win32":
        jdk_keytool = r"C:\Program Files\Java\jdk-21.0.2\bin\keytool.exe"
        if os.path.exists(jdk_keytool):
            keytool = jdk_keytool

    cmd = [
        keytool,
        "-genkeypair", "-v",
        "-keystore", KEYSTORE_PATH,
        "-alias", KEYSTORE_ALIAS,
        "-keyalg", "RSA",
        "-keysize", "2048",
        "-validity", "10000",
        "-storepass", KEYSTORE_PASS,
        "-keypass", KEYSTORE_PASS,
        "-dname", "CN=TueNhan, OU=ThucAnhHung, O=TueNhan Studio, L=Hanoi, ST=Hanoi, C=VN"
    ]
    subprocess.run(cmd, check=True)
    print("Đã tạo Release Keystore thành công với thời hạn 10.000 ngày!")

def find_android_tools():
    sdk_root = os.environ.get("ANDROID_HOME") or os.environ.get("ANDROID_SDK_ROOT")
    possible_roots = [
        sdk_root,
        "/usr/local/lib/android/sdk",
        "/usr/lib/android-sdk",
        os.path.expanduser("~/Android/Sdk"),
        os.path.expanduser("~/AppData/Local/Android/Sdk")
    ]
    apksigner = None
    zipalign = None
    actual_sdk = None

    for root in possible_roots:
        if not root or not os.path.exists(root):
            continue
        bt_dir = os.path.join(root, "build-tools")
        if not os.path.exists(bt_dir):
            continue
        actual_sdk = root
        versions = sorted(os.listdir(bt_dir), reverse=True)
        for v in versions:
            as_path = os.path.join(bt_dir, v, "apksigner.bat" if sys.platform == "win32" else "apksigner")
            za_path = os.path.join(bt_dir, v, "zipalign.exe" if sys.platform == "win32" else "zipalign")
            if os.path.exists(as_path):
                apksigner = as_path
            if os.path.exists(za_path):
                zipalign = za_path
            if apksigner and zipalign:
                break
        if apksigner and zipalign:
            break

    if not apksigner:
        apksigner = shutil.which("apksigner")
    if not zipalign:
        zipalign = shutil.which("zipalign")

    return actual_sdk, apksigner, zipalign

def setup_godot_engine():
    is_linux = sys.platform.startswith("linux")
    godot_cmd = "godot"
    if is_linux:
        local_bin = os.path.abspath("godot_bin/godot")
        if not os.path.exists(local_bin):
            os.makedirs("godot_bin", exist_ok=True)
            print("Đang tải Godot 4.7.2 Linux binary...")
            zip_path = "godot_linux.zip"
            urllib.request.urlretrieve(LINUX_GODOT_URL, zip_path)
            with zipfile.ZipFile(zip_path, "r") as z:
                z.extractall("godot_bin")
            extracted = glob.glob("godot_bin/Godot*")
            if extracted:
                shutil.move(extracted[0], local_bin)
            os.chmod(local_bin, 0o755)
        godot_cmd = local_bin
    else:
        # Windows
        local_bin = os.path.abspath("godot_bin/godot.exe")
        if not os.path.exists(local_bin):
            os.makedirs("godot_bin", exist_ok=True)
            print("Đang tải Godot 4.7.2 Windows binary...")
            zip_path = "godot_win.zip"
            urllib.request.urlretrieve(WIN_GODOT_URL, zip_path)
            with zipfile.ZipFile(zip_path, "r") as z:
                z.extractall("godot_bin")
            extracted = glob.glob("godot_bin/Godot*.exe")
            if extracted:
                shutil.move(extracted[0], local_bin)
        godot_cmd = local_bin

    return godot_cmd

def setup_export_templates(sdk_path):
    os.makedirs("build_android/templates", exist_ok=True)
    rel_apk = os.path.abspath("build_android/templates/android_release.apk")
    dbg_apk = os.path.abspath("build_android/templates/android_debug.apk")

    download_range(TPZ_URL, RELEASE_START, RELEASE_END, rel_apk, "Android Release Template")
    download_range(TPZ_URL, DEBUG_START, DEBUG_END, dbg_apk, "Android Debug Template")

    # Install into Godot standard export templates directory
    if sys.platform.startswith("linux"):
        tpl_dir = os.path.expanduser("~/.local/share/godot/export_templates/4.7.2.stable")
        cfg_dir = os.path.expanduser("~/.config/godot")
    else:
        appdata = os.environ.get("APPDATA", "")
        tpl_dir = os.path.join(appdata, "Godot", "export_templates", "4.7.2.stable")
        cfg_dir = os.path.join(appdata, "Godot")

    os.makedirs(tpl_dir, exist_ok=True)
    os.makedirs(cfg_dir, exist_ok=True)

    shutil.copy2(rel_apk, os.path.join(tpl_dir, "android_release.apk"))
    shutil.copy2(dbg_apk, os.path.join(tpl_dir, "android_debug.apk"))
    with open(os.path.join(tpl_dir, "version.txt"), "w", encoding="utf-8") as f:
        f.write("4.7.2.stable\n")

    # Setup editor_settings-4.tres
    settings_file = os.path.join(cfg_dir, "editor_settings-4.tres")
    java_home = os.environ.get("JAVA_HOME", "")
    ks_abs = os.path.abspath(KEYSTORE_PATH).replace('\\', '/')
    content = f'''[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "{sdk_path or ''}"
export/android/java_sdk_path = "{java_home}"
export/android/debug_keystore = "{ks_abs}"
export/android/debug_keystore_user = "{KEYSTORE_ALIAS}"
export/android/debug_keystore_pass = "{KEYSTORE_PASS}"
'''
    with open(settings_file, "w", encoding="utf-8") as f:
        f.write(content)
    print("Đã thiết lập Godot Export Templates & Editor Settings!")

    return rel_apk, dbg_apk

def write_export_presets(rel_apk, dbg_apk):
    dbg_clean = dbg_apk.replace('\\', '/')
    rel_clean = rel_apk.replace('\\', '/')
    ks_clean = os.path.abspath(KEYSTORE_PATH).replace('\\', '/')

    preset_content = f'''[preset.0]

name="Android"
platform="Android"
runnable=true
advanced_options=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="TueNhan.apk"
patches=PackedStringArray()
encryption_include_filters=""
encryption_exclude_filters=""
seed=0
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug="{dbg_clean}"
custom_template/release="{rel_clean}"
gradle_build/use_gradle_build=false
architectures/arm64-v8a=true
architectures/armeabi-v7a=true
architectures/x86=true
architectures/x86_64=true
package/unique_name="com.tuenhan.thucanhhung"
package/name="Tuệ Nhãn: Thức Anh Hùng"
package/signed=true
keystore/release="{ks_clean}"
keystore/release_user="{KEYSTORE_ALIAS}"
keystore/release_password="{KEYSTORE_PASS}"
version/code=1
version/name="1.0.0"
package/min_sdk="21"
package/target_sdk="34"
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
user_data_backup/allow=false
'''
    with open("export_presets.cfg", "w", encoding="utf-8") as f:
        f.write(preset_content)
    print("Đã tạo cấu hình export_presets.cfg cho Android!")

def build_direct_apk(rel_template, out_apk, pck_path, apksigner, zipalign):
    print("=== TIẾN HÀNH ĐÓNG GÓI APK TRỰC TIẾP ===")
    tmp_unaligned = "TueNhan_unaligned.apk"
    if os.path.exists(tmp_unaligned):
        os.remove(tmp_unaligned)
    if os.path.exists(out_apk):
        os.remove(out_apk)

    # Đọc template và sao chép vào unaligned
    shutil.copy2(rel_template, tmp_unaligned)

    # Thêm PCK vào assets/data.pck, assets/TueNhan.pck và commandline args
    with zipfile.ZipFile(tmp_unaligned, "a", compression=zipfile.ZIP_STORED) as z:
        print(f"Đang nhúng {pck_path} vào APK...")
        z.write(pck_path, "assets/data.pck")
        z.write(pck_path, "assets/TueNhan.pck")
        z.writestr("assets/_cmdline", "--main-pack\nassets/TueNhan.pck\n")

    # Zipalign 4 bytes
    if zipalign:
        print("Đang căn lề bộ nhớ 4-byte bằng zipalign...")
        subprocess.run([zipalign, "-f", "-p", "4", tmp_unaligned, out_apk], check=True)
        if os.path.exists(tmp_unaligned):
            os.remove(tmp_unaligned)
    else:
        shutil.move(tmp_unaligned, out_apk)

    # Ký bằng apksigner
    if apksigner:
        print("Đang ký APK bằng apksigner (v1, v2, v3)...")
        sign_cmd = [
            apksigner, "sign",
            "--ks", KEYSTORE_PATH,
            "--ks-key-alias", KEYSTORE_ALIAS,
            "--ks-pass", f"pass:{KEYSTORE_PASS}",
            "--key-pass", f"pass:{KEYSTORE_PASS}",
            "--min-sdk-version", "21",
            "--v1-signing-enabled", "true",
            "--v2-signing-enabled", "true",
            "--v3-signing-enabled", "true",
            out_apk
        ]
        subprocess.run(sign_cmd, check=True)

        print("Xác minh chữ ký số:")
        subprocess.run([apksigner, "verify", "--verbose", out_apk], check=True)
    else:
        # Fallback jarsigner
        print("Đang ký APK bằng jarsigner (v1)...")
        jarsigner = "jarsigner"
        if sys.platform == "win32":
            jdk_js = r"C:\Program Files\Java\jdk-21.0.2\bin\jarsigner.exe"
            if os.path.exists(jdk_js):
                jarsigner = jdk_js
        subprocess.run([
            jarsigner,
            "-keystore", KEYSTORE_PATH,
            "-storepass", KEYSTORE_PASS,
            "-keypass", KEYSTORE_PASS,
            out_apk,
            KEYSTORE_ALIAS
        ], check=True)

    print(f"Đóng gói hoàn tất: {out_apk} ({os.path.getsize(out_apk) / (1024*1024):.2f} MB)")

def main():
    print("==================================================")
    print("  BẮT ĐẦU QUY TRÌNH BUILD ANDROID APK TUỆ NHÃN   ")
    print("==================================================")

    # 1. Chuẩn bị Keystore
    ensure_keystore()

    # 2. Tìm Android SDK & Tools
    sdk_path, apksigner, zipalign = find_android_tools()
    print(f"Android SDK: {sdk_path}")
    print(f"apksigner: {apksigner}")
    print(f"zipalign: {zipalign}")

    # 3. Tải Export Templates
    rel_apk, dbg_apk = setup_export_templates(sdk_path)

    # 4. Thiết lập Godot Engine CLI
    godot_cmd = setup_godot_engine()
    print(f"Godot binary: {godot_cmd}")

    # 5. Thiết lập export_presets.cfg
    write_export_presets(rel_apk, dbg_apk)

    # 6. Chuẩn bị PCK (Export từ source hoặc tải về)
    pck_path = "TueNhan.pck"
    if not os.path.exists(pck_path) or os.path.getsize(pck_path) < 1000000:
        print("Đang export PCK mới nhất từ project...")
        try:
            res = subprocess.run([godot_cmd, "--headless", "--export-pack", "Android", pck_path], capture_output=True, text=True)
            print(res.stdout[-500:] if len(res.stdout) > 500 else res.stdout)
            if not os.path.exists(pck_path) or os.path.getsize(pck_path) < 1000000:
                print("Export pack thất bại, tải từ GitHub Releases v1.0.0...")
                subprocess.run(["gh", "release", "download", "v1.0.0", "-p", "TueNhan.pck", "--clobber", "--repo", "Leon030190/TueNhan"], check=True)
        except Exception as e:
            print("Lỗi khi export pack:", e)
            print("Tải TueNhan.pck từ GitHub Release v1.0.0...")
            subprocess.run(["gh", "release", "download", "v1.0.0", "-p", "TueNhan.pck", "--clobber", "--repo", "Leon030190/TueNhan"], check=True)

    # 7. Thử xuất bằng Godot CLI
    out_apk = "TueNhan.apk"
    export_ok = False
    try:
        print("Đang chạy lệnh: godot --headless --export-release Android TueNhan.apk...")
        res = subprocess.run([godot_cmd, "--headless", "--export-release", "Android", out_apk], capture_output=True, text=True)
        print("Godot Output:", res.stdout[-1000:] if len(res.stdout) > 1000 else res.stdout)
        if res.stderr:
            print("Godot Error:", res.stderr[-1000:] if len(res.stderr) > 1000 else res.stderr)
        if os.path.exists(out_apk) and os.path.getsize(out_apk) > 10000000:
            print("Godot export thành công!")
            export_ok = True
    except Exception as e:
        print("Lỗi khi chạy Godot export:", e)

    # 8. Nếu Godot CLI không tạo ra APK, chạy direct injection builder
    if not export_ok:
        print("Chuyển sang cơ chế đóng gói và ký trực tiếp chuẩn Android...")
        build_direct_apk(rel_apk, out_apk, pck_path, apksigner, zipalign)

    # 9. Đảm bảo APK được ký đầy đủ và căn lề bộ nhớ
    if apksigner and os.path.exists(out_apk):
        print("Kiểm tra trạng thái chữ ký APK:")
        verify_res = subprocess.run([apksigner, "verify", "--verbose", out_apk], capture_output=True, text=True)
        print(verify_res.stdout)
        if "DOES NOT VERIFY" in verify_res.stdout or verify_res.returncode != 0:
            print("Thực hiện ký bổ sung...")
            subprocess.run([
                apksigner, "sign",
                "--ks", KEYSTORE_PATH,
                "--ks-key-alias", KEYSTORE_ALIAS,
                "--ks-pass", f"pass:{KEYSTORE_PASS}",
                "--key-pass", f"pass:{KEYSTORE_PASS}",
                "--min-sdk-version", "21",
                "--v1-signing-enabled", "true",
                "--v2-signing-enabled", "true",
                "--v3-signing-enabled", "true",
                out_apk
            ], check=True)
            print("Ký bổ sung thành công!")

    print(f"\n✅ ĐÃ TẠO THÀNH CÔNG FILE APK CHƠI ĐƯỢC: {out_apk} ({os.path.getsize(out_apk) / (1024*1024):.2f} MB)")

if __name__ == "__main__":
    main()
