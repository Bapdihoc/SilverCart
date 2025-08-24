# 🎤 Hướng dẫn sử dụng Voice Detection trong SilverCart

## 📋 Tổng quan
Hướng dẫn sử dụng tính năng trợ lý giọng nói trong ứng dụng SilverCart với khả năng nhận diện lệnh tiếng Việt.

## 🎯 Các lệnh giọng nói được hỗ trợ

### 1. Điều khiển số lượng sản phẩm
- **Tăng số lượng**: `"tăng số lượng"`, `"tăng số"`, `"thêm số lượng"`, `"tăng lên"`, `"tăng thêm"`, `"cộng thêm"`
- **Giảm số lượng**: `"giảm số lượng"`, `"giảm số"`, `"bớt số lượng"`, `"giảm xuống"`, `"giảm đi"`, `"trừ đi"`

### 2. Thao tác giỏ hàng
- **Thêm vào giỏ**: `"thêm vào giỏ"`, `"thêm giỏ hàng"`, `"cho vào giỏ"`, `"bỏ vào giỏ"`, `"mua sản phẩm"`, `"đặt hàng"`
- **Mua ngay**: `"mua ngay"`, `"mua luôn"`, `"thanh toán ngay"`, `"mua ngay bây giờ"`

### 3. Đọc thông tin sản phẩm
- **Đọc thông tin**: `"đọc thông tin"`, `"thông tin sản phẩm"`, `"mô tả sản phẩm"`, `"chi tiết sản phẩm"`
- **Đọc giá**: `"đọc giá"`, `"giá bao nhiêu"`, `"giá sản phẩm"`, `"bao nhiêu tiền"`, `"giá cả"`

### 4. Hướng dẫn sử dụng
- **Hướng dẫn**: `"hướng dẫn"`, `"hướng dẫn sử dụng"`, `"cách sử dụng"`, `"trợ giúp"`, `"giúp đỡ"`

## 🎮 Cách sử dụng

### 1. Khởi động trợ lý giọng nói
1. Mở trang chi tiết sản phẩm
2. Nhấn nút trợ lý giọng nói (🎤) ở góc phải màn hình
3. Đợi thông báo "Tôi đang lắng nghe"

### 2. Nói lệnh
- Nói rõ ràng và chậm rãi
- Sử dụng một trong các lệnh được hỗ trợ
- Đợi phản hồi từ hệ thống

### 3. Dừng trợ lý
- Nhấn lại nút trợ lý giọng nói để dừng
- Hoặc đợi 30 giây để tự động dừng

## 🔧 Cấu hình Service Account

### 1. Cập nhật file service account
Thay thế nội dung file `assets/service_account.json` bằng service account thực tế:

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "your-private-key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_ACTUAL_PRIVATE_KEY\n-----END PRIVATE KEY-----\n",
  "client_email": "your-service-account@your-project.iam.gserviceaccount.com",
  "client_id": "your-client-id",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/your-service-account%40your-project.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
```

### 2. Kiểm tra quyền
- Đảm bảo service account có quyền "Cloud Speech-to-Text Admin"
- Enable Speech-to-Text API trong Google Cloud Console

## 🧪 Test Voice Detection

### 1. Sử dụng SpeechTestPage
Chạy `SpeechTestPage` để test voice detection:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SpeechTestPage()),
);
```

### 2. Test các lệnh
- Nhấn "Bắt đầu" để bắt đầu lắng nghe
- Nói các lệnh test
- Xem kết quả nhận diện trong "Lịch sử lệnh"

## 🚨 Troubleshooting

### Lỗi thường gặp

#### 1. "Speech service not initialized"
**Nguyên nhân**: Service account chưa được cấu hình đúng
**Giải pháp**:
- Kiểm tra file `assets/service_account.json`
- Đảm bảo có quyền truy cập internet
- Restart ứng dụng

#### 2. "Microphone permission required"
**Nguyên nhân**: Chưa cấp quyền microphone
**Giải pháp**:
- Vào Settings > Apps > SilverCart > Permissions
- Bật quyền Microphone
- Restart ứng dụng

#### 3. "Không nhận diện được lệnh"
**Nguyên nhân**: 
- Nói không rõ hoặc quá nhanh
- Môi trường xung quanh ồn
- Lệnh không nằm trong danh sách hỗ trợ

**Giải pháp**:
- Nói rõ ràng và chậm rãi
- Tìm nơi yên tĩnh
- Sử dụng đúng lệnh được hỗ trợ

#### 4. "Lỗi kết nối mạng"
**Nguyên nhân**: Không có internet hoặc API quota hết
**Giải pháp**:
- Kiểm tra kết nối internet
- Kiểm tra quota trong Google Cloud Console
- Thử lại sau vài phút

## 📊 Monitoring và Debug

### 1. Logs
Kiểm tra console logs để debug:
```
🎤 [Speech] Command received: "tăng số lượng"
🎯 [Voice] Executing: increase_quantity from command: "tăng số lượng"
```

### 2. Error Logs
```
❌ [Speech] Speech recognition error: Network error
❌ [Voice] Error: "Lỗi kết nối mạng. Vui lòng kiểm tra internet."
```

### 3. Performance Metrics
- Thời gian nhận diện: < 2 giây
- Độ chính xác: > 90% với lệnh chuẩn
- Timeout: 30 giây

## 🔄 Cập nhật và cải tiến

### Version 2.0 - Enhanced Voice Detection
- ✅ 50+ command patterns cho tiếng Việt
- ✅ Fuzzy matching với độ chính xác 70%
- ✅ Error handling chi tiết bằng tiếng Việt
- ✅ Real-time feedback cho người dùng
- ✅ Timeout protection (30 giây)
- ✅ Continuous listening mode

### Các cải tiến sắp tới
- [ ] Hỗ trợ lệnh phức tạp hơn
- [ ] Voice activity detection
- [ ] Offline fallback
- [ ] Multi-language support
- [ ] Custom wake word

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra logs trong console
2. Xem Google Cloud Console logs
3. Tạo issue trên GitHub repository
4. Liên hệ team development

## 🎯 Best Practices

### 1. Cho người dùng
- Nói rõ ràng và chậm rãi
- Sử dụng lệnh chuẩn
- Tìm nơi yên tĩnh
- Đợi phản hồi trước khi nói lệnh tiếp theo

### 2. Cho developers
- Test với nhiều accent khác nhau
- Monitor performance metrics
- Update command patterns định kỳ
- Backup service account credentials

### 3. Cho production
- Set up monitoring và alerting
- Implement rate limiting
- Monitor API usage và costs
- Regular security reviews
