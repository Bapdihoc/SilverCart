# Agora Video Calling Setup Guide

## 🚀 Quick Setup cho Testing

### Bước 1: Tạo Agora Account
1. Truy cập [Agora Console](https://console.agora.io/)
2. Đăng ký tài khoản mới hoặc đăng nhập
3. Click **"Create Project"**
4. Chọn **"Video Call"** làm use case
5. Nhập tên project: "SilverCart Video Call"

### Bước 2: Lấy App ID
1. Sau khi tạo project, copy **App ID** 
2. Mở file `lib/network/service/agora_service.dart`
3. Thay thế `YOUR_APP_ID_HERE` bằng App ID thực tế:

```dart
static const String appId = 'your_actual_app_id_here';
```

### Bước 3: Generate Token (Cho Testing)
1. Trong Agora Console, click **"Generate Temp Token"**
2. Nhập Channel Name: `test_channel_123`
3. Chọn thời gian hết hạn: 24 hours
4. Copy token để test (optional - app có thể chạy không cần token cho testing)

## 📱 Testing Workflow

### Thiết bị 1:
1. Mở app → Vào trang chi tiết sản phẩm
2. Nhấn **"📞 Nhận tư vấn trực tiếp"**
3. Nhập Channel ID: `test_channel_123`
4. Nhấn **"Bắt đầu tư vấn"**

### Thiết bị 2:
1. Mở app → Vào trang chi tiết sản phẩm
2. Nhấn **"📞 Nhận tư vấn trực tiếp"**
3. Nhập **cùng** Channel ID: `test_channel_123`
4. Nhấn **"Bắt đầu tư vấn"**

### Kết quả:
- Cả 2 thiết bị sẽ thấy nhau qua video call
- Có thể tắt/bật camera, microphone
- Có thể chuyển đổi camera trước/sau
- Kết thúc cuộc gọi bằng nút đỏ

## 🔧 Features Implemented

### Video Call Page:
- ✅ Join channel với Channel ID
- ✅ Local và Remote video streams
- ✅ Audio/Video mute controls
- ✅ Camera switching
- ✅ End call functionality
- ✅ Real-time connection status
- ✅ Error handling với Vietnamese messages

### Product Detail Integration:
- ✅ Nút "Nhận tư vấn trực tiếp" trong bottom bar
- ✅ Navigation đến Video Call page
- ✅ Pass product name để context

### Permissions:
- ✅ Camera permission
- ✅ Microphone permission
- ✅ Automatic permission request

## 🛡️ Security Notes

### Development:
- App ID có thể hard-code cho testing
- Không cần token cho basic testing
- Channel ID có thể share qua text/QR

### Production:
- Implement Token Server
- Generate dynamic tokens
- Secure channel management
- User authentication integration

## 🎯 Testing Scenarios

1. **Basic Video Call**: 2 devices cùng channel
2. **Permission Handling**: Test camera/mic permissions
3. **Network Issues**: Test khi mất mạng
4. **Multiple Users**: Nhiều devices cùng channel
5. **UI Interactions**: Test tất cả buttons

## 📋 Troubleshooting

### Không thể kết nối:
- Kiểm tra App ID đúng
- Kiểm tra permissions đã grant
- Kiểm tra cùng Channel ID
- Kiểm tra internet connection

### Video không hiển thị:
- Kiểm tra camera permission
- Test camera switching
- Restart app

### Audio không nghe được:
- Kiểm tra microphone permission
- Test mute/unmute
- Kiểm tra volume device

## 🔗 References

- [Agora Flutter SDK Documentation](https://docs.agora.io/en/video-calling/get-started/get-started-sdk?platform=flutter)
- [Agora Console](https://console.agora.io/)
- [Permission Handler Documentation](https://pub.dev/packages/permission_handler)
