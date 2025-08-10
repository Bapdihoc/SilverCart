import 'dart:async';
import 'dart:developer';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:google_speech/speech_client_authenticator.dart';
// import 'package:google_speech/speech_to_text.dart';
// import 'package:google_speech/google_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';

@singleton
class SpeechService {
  FlutterTts? _flutterTts;
  // SpeechToText? _speechToText;  // Commented out for now
  bool _isInitialized = false;
  // bool _isListening = false;   // Commented out for now
  // StreamController<String>? _speechController;

  // Initialize TTS and Speech Recognition
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize TTS
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage('vi-VN');
      await _flutterTts!.setSpeechRate(0.6); // Slower for elderly
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);

      // Initialize Speech Recognition (Optional - requires Google Cloud credentials)
      // _speechToText = SpeechToText.viaApiKey("YOUR_API_KEY");

      _isInitialized = true;
      log('Speech service initialized successfully');
    } catch (e) {
      log('Error initializing speech service: $e');
    }
  }

  // Text-to-Speech functionality
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _flutterTts?.speak(text);
    } catch (e) {
      log('Error speaking text: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts?.stop();
  }

  // Voice commands for specific actions
  Future<void> speakProductInfo(String productName, String price, String description) async {
    final text = 'Sản phẩm $productName. Giá $price đồng. $description';
    await speak(text);
  }

  Future<void> speakPriceInfo(String originalPrice, String discountedPrice, String discount) async {
    final text = 'Giá gốc $originalPrice đồng. Giá khuyến mãi $discountedPrice đồng. Giảm $discount phần trăm';
    await speak(text);
  }

  Future<void> speakQuantityInfo(int quantity) async {
    final text = 'Số lượng hiện tại: $quantity';
    await speak(text);
  }

  Future<void> speakStyleSelection(String styleName, String optionName) async {
    final text = 'Đã chọn $styleName: $optionName';
    await speak(text);
  }

  Future<void> speakCartAction(String productName, int quantity) async {
    final text = 'Đã thêm $quantity $productName vào giỏ hàng thành công';
    await speak(text);
  }

  Future<void> speakBuyNowAction() async {
    final text = 'Đang chuyển đến trang thanh toán';
    await speak(text);
  }

  Future<void> speakError(String error) async {
    final text = 'Có lỗi xảy ra: $error';
    await speak(text);
  }

  // Voice instructions for elderly users
  Future<void> speakInstructions() async {
    final text = '''
    Hướng dẫn sử dụng giọng nói:
    - Nói "tăng số lượng" để tăng số lượng sản phẩm
    - Nói "giảm số lượng" để giảm số lượng sản phẩm  
    - Nói "thêm vào giỏ" để thêm sản phẩm vào giỏ hàng
    - Nói "mua ngay" để mua sản phẩm ngay lập tức
    - Nói "đọc thông tin" để nghe thông tin sản phẩm
    - Nói "đọc giá" để nghe thông tin giá cả
    ''';
    await speak(text);
  }

  Future<void> speakWelcome() async {
    final text = 'Chào mừng đến với trang chi tiết sản phẩm. Nhấn nút trợ lý giọng nói để nghe hướng dẫn';
    await speak(text);
  }

  // Simple voice command processing (without Google Speech API)
  bool processVoiceCommand(String command) {
    final lowerCommand = command.toLowerCase().trim();
    
    // Command patterns for elderly users
    if (lowerCommand.contains('tăng') && lowerCommand.contains('số lượng')) {
      return true; // Increase quantity
    } else if (lowerCommand.contains('giảm') && lowerCommand.contains('số lượng')) {
      return true; // Decrease quantity  
    } else if (lowerCommand.contains('thêm') && lowerCommand.contains('giỏ')) {
      return true; // Add to cart
    } else if (lowerCommand.contains('mua ngay')) {
      return true; // Buy now
    } else if (lowerCommand.contains('đọc') && lowerCommand.contains('thông tin')) {
      return true; // Read product info
    } else if (lowerCommand.contains('đọc') && lowerCommand.contains('giá')) {
      return true; // Read price info
    }
    
    return false;
  }

  // Get voice command type
  String getCommandType(String command) {
    final lowerCommand = command.toLowerCase().trim();
    
    if (lowerCommand.contains('tăng') && lowerCommand.contains('số lượng')) {
      return 'increase_quantity';
    } else if (lowerCommand.contains('giảm') && lowerCommand.contains('số lượng')) {
      return 'decrease_quantity';
    } else if (lowerCommand.contains('thêm') && lowerCommand.contains('giỏ')) {
      return 'add_to_cart';
    } else if (lowerCommand.contains('mua ngay')) {
      return 'buy_now';
    } else if (lowerCommand.contains('đọc') && lowerCommand.contains('thông tin')) {
      return 'read_info';
    } else if (lowerCommand.contains('đọc') && lowerCommand.contains('giá')) {
      return 'read_price';
    } else if (lowerCommand.contains('hướng dẫn')) {
      return 'instructions';
    }
    
    return 'unknown';
  }

  // Check microphone permission
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.microphone.request();
      return result == PermissionStatus.granted;
    }
    return true;
  }

  // Cleanup
  void dispose() {
    _flutterTts?.stop();
    // _speechController?.close();
  }
}
