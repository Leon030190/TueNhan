#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script build hoàn chỉnh Godot 4.7.2 iOS IPA trên GitHub Actions (macOS runner)
"""

import os
import sys
import subprocess
import urllib.request
import zlib
import zipfile
import shutil
import re

def main():
    print("=== [1/6] TẢI TEMPLATE GODOT 4.7.2 CHO IOS ===")
    tpz_url = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz"
    start_offset = 447028165
    payload_size = 198442872
    end_offset = start_offset + payload_size - 1

    ios_zip_path = "ios_template.zip"
    if not os.path.exists(ios_zip_path):
        print(f"Đang tải {payload_size / (1024*1024):.1f} MB template iOS...")
        req = urllib.request.Request(tpz_url)
        req.add_header("Range", f"bytes={start_offset}-{end_offset}")
        
        decompressor = zlib.decompressobj(-zlib.MAX_WBITS)
        with urllib.request.urlopen(req) as resp, open(ios_zip_path, "wb") as out_f:
            while True:
                chunk = resp.read(1024 * 1024 * 4)
                if not chunk:
                    break
                decompressed = decompressor.decompress(chunk)
                out_f.write(decompressed)
            out_f.write(decompressor.flush())
        print("Tải template iOS thành công!")

    print("=== [2/6] GIẢI NÉN TEMPLATE ===")
    work_dir = "build_ios_project"
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)
    os.makedirs(work_dir, exist_ok=True)

    with zipfile.ZipFile(ios_zip_path, "r") as z:
        z.extractall(work_dir)
    print("Giải nén template thành công!")

    print("=== [3/6] TẢI VÀ CHUẨN BỊ GÓI DỮ LIỆU TUỆ NHÃN PCK ===")
    pck_path = os.path.join(work_dir, "godot_apple_embedded.pck")
    if not os.path.exists("TueNhan.pck"):
        print("Đang tải TueNhan.pck từ GitHub Release v1.0.0...")
        subprocess.run(["gh", "release", "download", "v1.0.0", "-p", "TueNhan.pck", "--clobber"], check=True)
    
    shutil.copy2("TueNhan.pck", pck_path)
    shutil.copy2("TueNhan.pck", os.path.join(work_dir, "godot_apple_embedded", "godot_apple_embedded.pck"))
    shutil.copy2("TueNhan.pck", os.path.join(work_dir, "godot_apple_embedded", "data.pck"))

    print("=== [4/6] CẤU HÌNH DỰ ÁN XCODE VÀ THƯ VIỆN ĐỘNG CƠ C++ ===")
    # Đổi tên / sao chép libgodot.ios.release.xcframework thành godot_apple_embedded.xcframework
    framework_src = os.path.join(work_dir, "libgodot.ios.release.xcframework")
    framework_dest = os.path.join(work_dir, "godot_apple_embedded.xcframework")
    if os.path.exists(framework_dest):
        shutil.rmtree(framework_dest)
    shutil.copytree(framework_src, framework_dest)

    # Thay thế placeholders trong project.pbxproj
    pbxproj_path = os.path.join(work_dir, "godot_apple_embedded.xcodeproj", "project.pbxproj")
    with open(pbxproj_path, "r", encoding="utf-8") as f:
        pbx = f.read()

    pbx_subs = {
        "$binary": "godot_apple_embedded",
        "$name": "TueNhan",
        "$bundle_identifier": "com.tuenhan.game",
        "$version": "1.0.0",
        "$short_version": "1.0.0",
        "$targeted_device_family": "1,2",
        "$os_deployment_target": "IPHONEOS_DEPLOYMENT_TARGET = 14.0;",
        "$sdkroot": "iphoneos",
        "$valid_archs": "arm64",
        "$godot_archs": "arm64",
        "$code_sign_identity_debug": "",
        "$code_sign_identity_release": "",
        "$code_sign_style_debug": "Manual",
        "$code_sign_style_release": "Manual",
        "$team_id": '""',
        "$provisioning_profile_specifier_debug": "",
        "$provisioning_profile_specifier_release": "",
        "$provisioning_profile_uuid_debug": "",
        "$provisioning_profile_uuid_release": "",
        "$linker_flags": "-ObjC",
        "$modules_buildfile": "",
        "$modules_buildgrp": "",
        "$modules_buildphase": "",
        "$modules_fileref": "",
        "$moltenvk_buildfile": "",
        "$moltenvk_buildgrp": "",
        "$moltenvk_buildphase": "",
        "$moltenvk_fileref": "",
        "$additional_pbx_files": "",
        "$additional_pbx_frameworks_build": "",
        "$additional_pbx_frameworks_refs": "",
        "$additional_pbx_resources_build": "",
        "$additional_pbx_resources_refs": "",
        "$pbx_embeded_frameworks": "",
        "$pbx_launch_screen_build_phase": "",
        "$pbx_launch_screen_build_reference": "",
        "$pbx_launch_screen_copy_files": "",
        "$pbx_launch_screen_file_reference": "",
        "$pbx_locale_build_reference": "",
        "$pbx_locale_file_reference": ""
    }
    for k, v in pbx_subs.items():
        pbx = pbx.replace(k, v)

    with open(pbxproj_path, "w", encoding="utf-8") as f:
        f.write(pbx)

    # Thay thế placeholders trong godot_apple_embedded.xcscheme
    scheme_path = os.path.join(work_dir, "godot_apple_embedded.xcodeproj", "xcshareddata", "xcschemes", "godot_apple_embedded.xcscheme")
    if os.path.exists(scheme_path):
        with open(scheme_path, "r", encoding="utf-8") as f:
            sc_data = f.read()
        sc_data = sc_data.replace("$binary", "godot_apple_embedded")
        sc_data = sc_data.replace("$default_build_config", "Release")
        sc_data = sc_data.replace("A340BDFEBCA49239A941883D", "D0BCFE3318AEBDA2004A7AAE")
        with open(scheme_path, "w", encoding="utf-8") as f:
            f.write(sc_data)

    # Thay thế placeholders trong Info.plist
    plist_path = os.path.join(work_dir, "godot_apple_embedded", "godot_apple_embedded-Info.plist")
    with open(plist_path, "r", encoding="utf-8") as f:
        plist = f.read()

    plist_subs = {
        "$signature": "????",
        "$docs_in_place": "<false/>",
        "$docs_sharing": "<false/>",
        "$required_device_capabilities": "<string>arm64</string>",
        "$camera_usage_description": "Khong su dung",
        "$photolibrary_usage_description": "Khong su dung",
        "$microphone_usage_description": "Khong su dung",
        "$interface_orientations": "<string>UIInterfaceOrientationLandscapeLeft</string>\n\t\t<string>UIInterfaceOrientationLandscapeRight</string>",
        "$ipad_interface_orientations": "<string>UIInterfaceOrientationLandscapeLeft</string>\n\t\t<string>UIInterfaceOrientationLandscapeRight</string>",
        "$additional_plist_content": "<key>CFBundleSupportedPlatforms</key>\n\t<array>\n\t\t<string>iPhoneOS</string>\n\t</array>",
        "$plist_launch_screen_name": "<key>UILaunchStoryboardName</key>\n\t<string>Launch Screen</string>"
    }
    for k, v in plist_subs.items():
        plist = plist.replace(k, v)

    with open(plist_path, "w", encoding="utf-8") as f:
        f.write(plist)

    # Entitlements
    entitlements_path = os.path.join(work_dir, "godot_apple_embedded", "godot_apple_embedded.entitlements")
    with open(entitlements_path, "w", encoding="utf-8") as f:
        f.write("""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>get-task-allow</key>
    <true/>
</dict>
</plist>
""")

    # Sao chép Icons
    if os.path.exists("ios/Assets.xcassets/AppIcon.appiconset"):
        dest_icons = os.path.join(work_dir, "godot_apple_embedded", "Images.xcassets", "AppIcon.appiconset")
        if os.path.exists(dest_icons):
            shutil.rmtree(dest_icons)
        shutil.copytree("ios/Assets.xcassets/AppIcon.appiconset", dest_icons)

    print("=== [5/6] BIÊN DỊCH BẰNG XCODEBUILD BUILD ===")
    out_build_dir = os.path.abspath("build/Release-iphoneos")
    os.makedirs(out_build_dir, exist_ok=True)
    
    cmd = [
        "xcodebuild", "build",
        "-project", os.path.join(work_dir, "godot_apple_embedded.xcodeproj"),
        "-target", "godot_apple_embedded",
        "-configuration", "Release",
        "-sdk", "iphoneos",
        "-arch", "arm64",
        f"CONFIGURATION_BUILD_DIR={out_build_dir}",
        "CODE_SIGNING_ALLOWED=NO",
        "CODE_SIGNING_REQUIRED=NO"
    ]
    print(f"Đang chạy lệnh: {' '.join(cmd)}")
    subprocess.run(cmd, check=True)

    print("=== [6/6] ĐÓNG GÓI THÀNH FILE TUENHAN_PLAYABLE.IPA ===")
    payload_dir = os.path.abspath("build/Payload")
    os.makedirs(payload_dir, exist_ok=True)
    
    app_src = os.path.join(out_build_dir, "godot_apple_embedded.app")
    app_dest = os.path.join(payload_dir, "TueNhan.app")
    if os.path.exists(app_dest):
        shutil.rmtree(app_dest)
    shutil.copytree(app_src, app_dest)

    # Đảm bảo các bản sao của PCK nằm trong bundle để Godot luôn tìm thấy
    shutil.copy2("TueNhan.pck", os.path.join(app_dest, "godot_apple_embedded.pck"))
    shutil.copy2("TueNhan.pck", os.path.join(app_dest, "TueNhan.pck"))
    shutil.copy2("TueNhan.pck", os.path.join(app_dest, "data.pck"))

    # Đổi tên file thực thi chính thành TueNhan và đồng bộ Info.plist
    binary_orig = os.path.join(app_dest, "godot_apple_embedded")
    binary_dest = os.path.join(app_dest, "TueNhan")
    if os.path.exists(binary_orig):
        shutil.move(binary_orig, binary_dest)
        
    final_plist = os.path.join(app_dest, "Info.plist")
    if os.path.exists(final_plist):
        with open(final_plist, "r", encoding="utf-8") as f:
            p_data = f.read()
        p_data = p_data.replace("<string>godot_apple_embedded</string>", "<string>TueNhan</string>")
        with open(final_plist, "w", encoding="utf-8") as f:
            f.write(p_data)

    output_ipa = "TueNhan_Playable.ipa"
    print(f"Đang đóng gói {output_ipa}...")
    
    with zipfile.ZipFile(output_ipa, "w", zipfile.ZIP_DEFLATED) as zip_f:
        for root, dirs, files in os.walk(payload_dir):
            for fn in files:
                full_p = os.path.join(root, fn)
                rel_p = os.path.relpath(full_p, "build")
                zip_f.write(full_p, rel_p.replace(os.sep, "/"))

    size_mb = os.path.getsize(output_ipa) / (1024 * 1024)
    print(f"Build thành công! File: {output_ipa} ({size_mb:.2f} MB)")

if __name__ == "__main__":
    main()
