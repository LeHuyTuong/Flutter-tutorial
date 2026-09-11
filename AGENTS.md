# AGENTS.md — Flutter-tutorial (`birdle`)

Bài tập Flutter: một biến thể Wordle tên `birdle`. Repo học, đúng **1 commit**, không phải sản phẩm.

**Tên thư mục và tên package lệch nhau**: thư mục là `Flutter-tutorial`, còn `pubspec.yaml` khai `name: birdle`. Mọi import nội bộ dùng `package:birdle/...`.

## Bố cục

Toàn bộ logic nằm trong hai file, tổng 509 dòng:

```
lib/main.dart   222 dòng — dựng app, bàn phím, vòng đời màn hình
lib/game.dart   287 dòng — luật chơi
```

Sáu thư mục nền tảng (`android`, `ios`, `web`, `macos`, `linux`, `windows`) đều là scaffold do `flutter create` sinh ra, chưa tuỳ biến. Dependency sản xuất: chỉ `flutter` sdk, không thêm gói nào.

## Chạy

```sh
flutter pub get
flutter run -d chrome
```

## Cần biết trước khi sửa

- **Không có thư mục `test/`.** Không có lưới an toàn nào; đổi luật chơi trong `game.dart` thì phải tự chạy thử.
- **Cây đang bẩn sẵn**: `lib/main.dart`, `pubspec.yaml`, `pubspec.lock` đã sửa so với commit duy nhất, cộng `.vscode/` chưa track. Đừng cho rằng `git status` sạch là mốc so sánh.
- Với 509 dòng và không test, sửa trực tiếp rẻ hơn nhiều so với dựng abstraction. Đừng áp kiến trúc tầng lớp lên một bài tập.
