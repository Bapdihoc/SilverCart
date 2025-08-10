# Tích hợp Google Speech cho Người Cao Tuổi

## Tổng quan
Tích hợp Google Speech API và Flutter TTS vào trang chi tiết sản phẩm để hỗ trợ người cao tuổi sử dụng ứng dụng bằng giọng nói.

## Các tính năng đã tích hợp

### 1. Text-to-Speech (TTS)
- **Package**: `flutter_tts: ^4.2.3`
- **Chức năng**: Đọc thông tin sản phẩm bằng tiếng Việt
- **Tốc độ**: Được điều chỉnh chậm (0.6) phù hợp với người cao tuổi

#### Các thông tin được đọc:
- Thông tin sản phẩm (tên, giá, mô tả)
- Thông tin giá cả và khuyến mãi
- Số lượng sản phẩm hiện tại
- Phản hồi khi chọn style/variant
- Thông báo thành công/lỗi khi thêm vào giỏ hàng
- Hướng dẫn sử dụng voice commands

### 2. Voice Commands (Lệnh giọng nói)
- **Chức năng**: Điều khiển ứng dụng bằng giọng nói
- **Các lệnh hỗ trợ**:
  - `"Tăng số lượng"` - Tăng số lượng sản phẩm
  - `"Giảm số lượng"` - Giảm số lượng sản phẩm
  - `"Thêm vào giỏ"` - Thêm sản phẩm vào giỏ hàng
  - `"Mua ngay"` - Mua sản phẩm ngay lập tức
  - `"Đọc thông tin"` - Nghe thông tin chi tiết sản phẩm
  - `"Đọc giá"` - Nghe thông tin giá cả

### 3. Google Speech API (Tùy chọn)
- **Package**: `google_speech: ^5.3.0`
- **Trạng thái**: Được comment để sử dụng sau khi có Google Cloud credentials
- **Chức năng**: Speech Recognition thực tế thay vì dialog hiện tại

## Vị trí tích hợp trong ProductDetailPage

### 1. AppBar Actions
- Thêm nút Voice Assistant bên cạnh shopping cart
- Hiển thị trạng thái listening với animation

### 2. Voice Instructions Panel
- Hiển thị hướng dẫn voice commands
- Thiết kế gradient với màu sắc nổi bật
- Các chip hiển thị examples commands

### 3. Floating Action Button
- Extended FAB với icon microphone
- Hiển thị trạng thái listening/not listening
- Vị trí centerFloat để dễ tiếp cận

### 4. Interactive Elements với Voice Feedback
- **Quantity Selector**: Voice feedback khi tăng/giảm
- **Style Selection**: Voice announcement khi chọn style
- **Add to Cart**: Voice confirmation khi thêm thành công
- **Error Handling**: Voice announcement cho các lỗi

## Luồng hoạt động

### 1. Khởi tạo
```dart
@override
void initState() {
  // ...
  _speechService = getIt<SpeechService>();
  _initializeSpeech();
}

Future<void> _initializeSpeech() async {
  await _speechService.initialize();
  setState(() => _isSpeechEnabled = true);
  await _speechService.speakWelcome(); // Chào mừng
}
```

### 2. Voice Commands Processing
```dart
Future<void> _handleVoiceCommand(String command) async {
  final commandType = _speechService.getCommandType(command);
  
  switch (commandType) {
    case 'increase_quantity':
      _increaseQuantity();
      await _speechService.speakQuantityInfo(_quantity);
      break;
    // ... other commands
  }
}
```

### 3. Voice Feedback Integration
- Tất cả các thao tác chính đều có voice feedback
- Error messages được đọc bằng tiếng Việt
- Success confirmations có voice announcement

## Cấu hình cho Google Speech API (Tương lai)

### 1. Yêu cầu
- Google Cloud Platform account
- Speech-to-Text API enabled
- Service Account credentials

### 2. Setup
```dart
// Uncomment khi có credentials
final serviceAccount = ServiceAccount.fromString(
  '${(await rootBundle.loadString('assets/service_account.json'))}'
);
final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
```

### 3. Configuration
```dart
final config = RecognitionConfig(
  encoding: AudioEncoding.LINEAR16,
  model: RecognitionModel.basic,
  enableAutomaticPunctuation: true,
  sampleRateHertz: 16000,
  languageCode: 'vi-VN' // Tiếng Việt
);
```

## UI/UX cho Người Cao Tuổi

### 1. Thiết kế thân thiện
- **Font size lớn**: Responsive typography
- **Màu sắc nổi bật**: High contrast colors
- **Buttons lớn**: Easy-to-tap interface
- **Clear instructions**: Hướng dẫn rõ ràng

### 2. Voice Instructions
- Hiển thị commands examples
- Test buttons cho từng command
- Demo functionality
- Audio instructions

### 3. Feedback rõ ràng
- Visual indicators (colors, animations)
- Audio feedback cho mọi action
- Error messages bằng voice và text
- Success confirmations

## Permissions

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice commands</string>
```

## Dependencies
```yaml
dependencies:
  google_speech: ^5.3.0          # Speech Recognition
  flutter_tts: ^4.2.3            # Text-to-Speech
  permission_handler: ^12.0.1    # Microphone permissions
```

## Testing Voice Commands

### Cách test hiện tại:
1. Nhấn nút "🎤 Trợ lý giọng nói"
2. Chọn "Test" bên cạnh command muốn thử
3. Hoặc chọn "Demo" để test "đọc thông tin"

### Cách test với Google Speech (tương lai):
1. Cấu hình Google Cloud credentials
2. Uncomment Google Speech code
3. Test với voice recognition thực tế

## Lợi ích cho Người Cao Tuổi

1. **Accessibility**: Dễ sử dụng hơn cho người có vấn đề về thị lực
2. **Convenience**: Không cần nhập text phức tạp
3. **Natural interaction**: Giao tiếp tự nhiên bằng giọng nói
4. **Audio feedback**: Xác nhận mọi thao tác bằng voice
5. **Error prevention**: Voice guidance giảm thiểu lỗi sử dụng
6. **Independence**: Tăng tính độc lập khi mua sắm online
