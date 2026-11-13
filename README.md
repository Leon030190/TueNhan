# Tuệ Nhãn: Thức Anh Hùng (TueNhan) · Demo v1.0.0

Kho tài nguyên đầy đủ của trò chơi **Tuệ Nhãn: Thức Anh Hùng** (bản demo v1.0.0), phát triển trên nền tảng **Godot Engine 4.7**.

Game chiến lược theo lượt về nghệ thuật nhìn người: bạn mang Đôi Mắt Thẩm Định, tìm những viên ngọc thô còn vô danh, nuôi dạy họ, rồi tiến cử vào triều đình năm nước.

---

## 📱 Phân tích kỹ thuật: Có thể build thành file `.ipa` (iOS) được không?

### ❌ Kết luận: **KHÔNG THỂ build trực tiếp từ gói phát hành này**

Thư mục gốc `TueNhan` phân phối dưới dạng bản build hoàn chỉnh cho hệ điều hành Windows (`TueNhan.exe` x86_64 và `TueNhan.pck`), **không phải là thư mục mã nguồn mở (Godot Source Project)**.

### 🔍 Các rào cản và điều kiện tiên quyết để tạo file `.ipa`:
1. **Thiếu mã nguồn gốc (Source Code)**:
   - Toàn bộ logic game viết bằng GDScript đã bị biên dịch thành bytecode Godot 4.7 (`.gdc` tokenized binary) và các scene bị đóng gói nhị phân (`.scn`).
   - Cần công cụ dịch ngược (như GDRE Tools) tương thích với phiên bản Godot 4.7 để khôi phục các file `.gd` dạng văn bản rõ và tái lập file `project.godot`.
2. **Yêu cầu môi trường macOS & Xcode**:
   - Định dạng `.ipa` là gói ứng dụng iOS chứa mã máy ARM64 Mach-O.
   - Apple bắt buộc phải sử dụng **Xcode**, **iOS SDK** và **Clang/LLVM** trên hệ điều hành **macOS** (hoặc thông qua máy ảo / dịch vụ CI/CD như GitHub Actions `macos-latest`) để biên dịch template xuất bản iOS của Godot. Hệ điều hành Windows không hỗ trợ biên dịch trực tiếp ra `.ipa`.
3. **Chứng chỉ ký ứng dụng (Code Signing & Provisioning Profile)**:
   - iOS yêu cầu ứng dụng phải được ký số điện tử bằng chứng chỉ Apple Developer hợp lệ (hoặc ký tự do qua AltStore / Sideloadly / TrollStore) kèm cấu hình Bundle Identifier.
4. **Tương thích giao diện & điều khiển (UI/UX Touch)**:
   - Bản gốc được thiết kế tối ưu cho màn hình ngang tỷ lệ 1600×900 trên máy tính với thao tác rê chuột (hover tooltip) và phím bấm vật lý (Space, +, -, Esc).
   - Khi chuyển sang iOS cần điều chỉnh lại bố cục responsive cho iPhone/iPad và chuyển đổi cơ chế hover sang chạm giữ / popover cảm ứng.

---

## 📂 Cấu trúc tài nguyên game trong Repository

Toàn bộ tài nguyên bên trong gói `TueNhan.pck` đã được trích xuất và giải mã sang định dạng chuẩn để có thể **duyệt, đọc và xem trực tiếp trên GitHub**:

```
TueNhan/
├── README.md                          # Tài liệu kỹ thuật và phân tích
├── DOC_TRUOC.txt                      # Hướng dẫn chơi gốc của tác giả
├── CREDITS.txt                        # Ghi công và bản quyền tài nguyên
├── LICENSE_GODOT.txt                  # Giấy phép MIT của Godot Engine
├── LICENSE_PlayfairDisplay_OFL.txt    # Giấy phép SIL Open Font của phông chữ
├── icon.png                           # Biểu tượng trò chơi
├── project.binary                     # Cấu hình dự án Godot đã biên dịch
│
├── data/                              # 📜 CƠ SỞ DỮ LIỆU GAME (JSON rõ, đọc trực tiếp)
│   ├── world.json                     # Bản đồ 5 nước, thành trì, lãnh địa
│   ├── talents.json                   # Hệ thống thiên phú và thuộc tính
│   ├── traits.json                    # Mệnh cách, tính cách nhân vật
│   ├── events.json                    # Các biến cố, sự kiện triều chính
│   ├── prof_tree.json                 # Cây chức nghiệp quan lộ và sĩ phu
│   └── names.json                     # Kho từ điển họ tên nhân vật ngũ quốc
│
├── assets/                            # 🎨 TÀI NGUYÊN ĐỒ HỌA & ÂM THANH
│   ├── art/
│   │   ├── portraits/                 # 532+ tranh chân dung nhân vật (.png)
│   │   ├── map/                       # Tranh bản đồ thế giới, thành trì, quan ải (.png)
│   │   ├── ui/                        # Nút bấm, khung thẻ, divider, biểu tượng chỉ số (.png)
│   │   └── promo/                     # Video giới thiệu intro.ogv và banner capsule
│   ├── audio/                         # Các bản nhạc nền cổ phong (Pixabay Content License)
│   └── fonts/                         # Phông chữ Playfair Display
│
├── game/                              # 💻 HỆ THỐNG MÃ NGUỒN BIÊN DỊCH
│   ├── core/                          # 26 module lõi (appointment, crisis, sim, war,...)
│   └── scenes/                        # 15 scene giao diện và điều khiển logic
│
└── tools/                             # 🛠️ CÔNG CỤ TRÍCH XUẤT
    └── extract_pck.py                 # Script Python trích xuất PCK và chuyển đổi Texture
```

---

## 🎨 Điểm nổi bật của tài nguyên

- **Tranh minh họa**: 532 ảnh chân dung và các cảnh thành trì được tạo bằng Google Gemini và hậu kỳ riêng, đã được giải mã từ `GST2` sang định dạng `.png` chuẩn để hiển thị trực quan trong trình duyệt GitHub.
- **Dữ liệu game dạng JSON**: Toàn bộ hệ thống cơ chế game, họ tên theo 5 quốc gia giả tưởng (Đại Hạ, Đông Hải, Bắc Địch, Tây Vực, Nam Man), danh sách tài năng, sự kiện đều được định dạng JSON dễ đọc và dễ chỉnh sửa.

---

## ⚖️ Giấy phép & Ghi công

- **Godot Engine 4.7**: Giấy phép MIT.
- **Phông chữ Playfair Display**: SIL Open Font License 1.1.
- **Âm nhạc**: Pixabay Content License (Joyvideo123, SoundsByAmelia, Vadim_Makes_Sound, Guzheng-Soundtrack, kaazoom, OpenMindAudio,...).
