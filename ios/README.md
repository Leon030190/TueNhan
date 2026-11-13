# Cấu trúc dự án iOS & Hướng dẫn build file .ipa (Tuệ Nhãn)

Thư mục này chứa toàn bộ cấu trúc dự án iOS chuẩn của trò chơi **Tuệ Nhãn: Thức Anh Hùng** sẵn sàng để build thành file `.ipa` thông qua Xcode trên macOS hoặc đóng gói trực tiếp bằng Python.

---

## 📁 Cấu trúc thư mục iOS

```
ios/
├── TueNhan.xcodeproj/                 # Dự án Xcode (project.pbxproj & schemes)
├── Info.plist                         # Cấu hình bundle iOS, xoay màn hình ngang, icon
├── main.m                             # Điểm khởi chạy Objective-C
├── AppDelegate.h / AppDelegate.m      # Quản lý vòng đời ứng dụng iOS
├── ViewController.h / ViewController.m # View Controller hiển thị game
├── LaunchScreen.storyboard            # Màn hình chờ khởi động
├── Assets.xcassets/                   # Bộ Asset Catalog chứa đầy đủ icon iPhone/iPad
│   └── AppIcon.appiconset/
├── export_options.plist               # Cấu hình xuất file IPA
├── build_ipa.sh                       # Script build tự động bằng Xcode Command Line
└── package_ipa.py                     # Script Python đóng gói trực tiếp ra .ipa
```

---

## 🚀 Cách 1: Đóng gói nhanh ra file .ipa (Không cần macOS/Xcode)

Chạy script Python `package_ipa.py` (chạy được trên mọi hệ điều hành: Windows, macOS, Linux):

```bash
python package_ipa.py
```

Script sẽ gom toàn bộ các file cấu hình, icon, tài nguyên (`assets/`, `data/`, `game/`) và file `TueNhan.pck` thành file **`TueNhan.ipa`** theo đúng cấu trúc `Payload/TueNhan.app/`.

---

## 🍎 Cách 2: Biên dịch qua Xcode trên macOS

1. Mở file `TueNhan.xcodeproj` bằng **Xcode 14+**.
2. Chọn thiết bị đích là **Any iOS Device (arm64)**.
3. Trong tab **Signing & Capabilities**, chọn Team lập trình viên của bạn.
4. Chọn menu **Product** -> **Archive**.
5. Sau khi hoàn thành, chọn **Distribute App** -> **Ad Hoc** hoặc **Development** để xuất file **`.ipa`**.

Hoặc chạy lệnh tự động trong terminal:
```bash
bash build_ipa.sh
```
