import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_speech/speech_client_authenticator.dart';
import 'package:google_speech/speech_to_text.dart';
import 'package:google_speech/google_speech.dart';
import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pbgrpc.dart' as grpc;
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';

@singleton
class SpeechService {
  FlutterTts? _flutterTts;
  SpeechToText? _speechToText;
  bool _isInitialized = false;
  bool _isListening = false;
  StreamController<String>? _speechController;
  StreamSubscription<grpc.StreamingRecognizeResponse>? _recognitionSubscription;
  
  // Real microphone recording with platform channels
  static const MethodChannel _microphoneChannel = MethodChannel('microphone_channel');
  static const EventChannel _audioDataChannel = EventChannel('audio_data_channel');
  
  // Audio simulation for testing (remove in production)
  Timer? _audioSimulationTimer;
  bool _isSimulatingAudio = false;
  
  // Manual mode for testing
  bool _isManualMode = false; // Set to false for real speech recognition
  Timer? _manualDetectionTimer;
  
  // Real-time audio processing
  StreamController<List<int>>? _realAudioStream;
  bool _isRealAudioActive = false;
  
  // Audio data subscription with correct type
  StreamSubscription<dynamic>? _audioDataSubscription;
  
  // Disable simulation mode completely
  bool _enableSimulation = false; // Set to false to disable all simulation

  // Enhanced command detection
  final Map<String, List<String>> _commandPatterns = {
    'increase_quantity': [
      'tăng số lượng',
      'tăng số',
      'thêm số lượng',
      'tăng lên',
      'tăng thêm',
      'cộng thêm',
      'tăng một',
      'tăng hai',
      'tăng ba',
      'tăng bốn',
      'tăng năm',
    ],
    'decrease_quantity': [
      'giảm số lượng',
      'giảm số',
      'bớt số lượng',
      'giảm xuống',
      'giảm đi',
      'trừ đi',
      'giảm một',
      'giảm hai',
      'giảm ba',
      'giảm bốn',
      'giảm năm',
    ],
    'add_to_cart': [
      'thêm vào giỏ',
      'thêm giỏ hàng',
      'cho vào giỏ',
      'bỏ vào giỏ',
      'thêm vào giỏ hàng',
      'mua sản phẩm',
      'thêm sản phẩm',
      'đặt hàng',
    ],
    'buy_now': [
      'mua ngay',
      'mua luôn',
      'mua ngay lập tức',
      'thanh toán ngay',
      'mua ngay bây giờ',
      'đặt mua ngay',
    ],
    'read_info': [
      'đọc thông tin',
      'thông tin sản phẩm',
      'mô tả sản phẩm',
      'chi tiết sản phẩm',
      'thông tin chi tiết',
      'đọc mô tả',
      'thông tin gì',
    ],
    'read_price': [
      'đọc giá',
      'giá bao nhiêu',
      'giá sản phẩm',
      'giá tiền',
      'bao nhiêu tiền',
      'giá cả',
      'đọc giá cả',
    ],
    'instructions': [
      'hướng dẫn',
      'hướng dẫn sử dụng',
      'cách sử dụng',
      'trợ giúp',
      'giúp đỡ',
      'hướng dẫn giọng nói',
      'cách dùng',
    ],
  };

  // Initialize TTS and Speech Recognition
  Future<void> initialize() async {
    log('🎤 [Speech] initialize() called');
    
    if (_isInitialized) {
      log('✅ [Speech] Already initialized, skipping');
      return;
    }

    try {
      log('🔄 [Speech] Starting initialization...');
      
      // Initialize TTS
      log('🔊 [Speech] Initializing TTS...');
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage('vi-VN');
      await _flutterTts!.setSpeechRate(0.6); // Slower for elderly
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
      log('✅ [Speech] TTS initialized successfully');

      // Initialize microphone recorder
      log('🎤 [Speech] Initializing microphone recorder...');
      
      // Check microphone permission
      if (!await checkMicrophonePermission()) {
        log('❌ [Speech] Microphone permission not granted');
        return;
      }
      log('✅ [Speech] Microphone recorder initialized');

      // Initialize Speech Recognition
      log('🎯 [Speech] Initializing Speech Recognition...');
      await _initializeSpeechRecognition();

      _isInitialized = true;
      log('🎉 [Speech] Speech service fully initialized');
    } catch (e) {
      log('❌ [Speech] Error during initialization: $e');
      log('❌ [Speech] Stack trace: ${StackTrace.current}');
    }
  }

  // Initialize Google Speech Recognition
  Future<void> _initializeSpeechRecognition() async {
    log('🔧 [Speech] _initializeSpeechRecognition() called');
    
    try {
      // Check microphone permission first
      log('🔍 [Speech] Checking microphone permission...');
      if (!await checkMicrophonePermission()) {
        log('❌ [Speech] Microphone permission not granted');
        return;
      }
      log('✅ [Speech] Microphone permission granted');

      // Create speech client using service account (recommended for production)
      try {
        log('📁 [Speech] Loading service account from assets...');
        
        // Option 1: Use service account from assets (recommended)
        final serviceAccountJson = await rootBundle.loadString('assets/service_account.json');
        log('📄 [Speech] Service account JSON loaded, length: ${serviceAccountJson.length}');
        
        // Check if service account is properly configured
        if (serviceAccountJson.contains('YOUR_PRIVATE_KEY_HERE') || 
            serviceAccountJson.contains('your_private_key_id')) {
          log('⚠️ [Speech] Service account appears to be template - using fallback mode');
          throw Exception('Service account not properly configured');
        }
        
        final serviceAccount = ServiceAccount.fromString(serviceAccountJson);
        log('✅ [Speech] Service account parsed successfully');
        
        _speechToText = SpeechToText.viaServiceAccount(serviceAccount);
        log('✅ [Speech] SpeechToText client created with service account');
        
        log('🎉 [Speech] Speech recognition initialized successfully with service account');
      } catch (e) {
        log('❌ [Speech] Error creating speech client: $e');
        log('❌ [Speech] Stack trace: ${StackTrace.current}');
        log('Please check assets/service_account.json file - it should contain real credentials');
        
        // Fallback: Enable simulation mode for testing
        log('🔄 [Speech] Enabling simulation mode for testing...');
        _enableSimulation = true;
        _speechToText = null;
      }
    } catch (e) {
      log('❌ [Speech] Error initializing speech recognition: $e');
      log('❌ [Speech] Stack trace: ${StackTrace.current}');
    }
  }

  // Start listening for voice commands
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    required VoidCallback onListeningComplete,
  }) async {
    log('🎤 [Speech] startListening() called');
    
    if (!_isInitialized) {
      log('❌ [Speech] Service not initialized');
      onError('Speech service not initialized');
      return;
    }

    if (_isListening) {
      log('⚠️ [Speech] Already listening, cannot start again');
      onError('Already listening');
      return;
    }

    try {
      log('🔍 [Speech] Checking microphone permission...');
      // Check permission again
      if (!await checkMicrophonePermission()) {
        log('❌ [Speech] Microphone permission denied');
        onError('Microphone permission required');
        return;
      }
      log('✅ [Speech] Microphone permission granted');

      _setListeningState(true);
      log('🎯 [Speech] Set listening state to true');

      // Check if we have real Google Speech API client
      if (_speechToText != null && !_enableSimulation) {
        await _startRealSpeechRecognition(onResult, onError, onListeningComplete);
      } else if (_enableSimulation) {
        // Use simulation mode for testing (disabled by default)
        await _startSimulatedSpeechRecognition(onResult, onError, onListeningComplete);
      } else {
        // No Google Speech API and simulation disabled
        onError('Speech recognition not available. Please check Google Cloud configuration.');
        _setListeningState(false);
      }

    } catch (e) {
      log('❌ [Speech] Error starting speech recognition: $e');
      log('❌ [Speech] Stack trace: ${StackTrace.current}');
      onError('Lỗi khởi động nhận diện giọng nói: $e');
      _setListeningState(false);
    }
  }

  // Start real Google Speech API recognition
  Future<void> _startRealSpeechRecognition(
    Function(String) onResult,
    Function(String) onError,
    VoidCallback onListeningComplete,
  ) async {
    log('🚀 [Speech] Starting real Google Speech API recognition...');
    
    // Configure recognition using the correct types
    log('⚙️ [Speech] Configuring recognition...');
    final config = StreamingRecognitionConfig(
      config: RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 16000,
        languageCode: 'vi-VN', // Vietnamese
        maxAlternatives: 3, // Get multiple alternatives for better accuracy
        enableWordTimeOffsets: false,
      ),
      interimResults: true, // Get interim results for better UX
      singleUtterance: false, // Allow continuous listening
    );
    log('✅ [Speech] Recognition config created');

    // Create audio stream for real microphone input
    log('🎵 [Speech] Creating audio stream...');
    final audioStream = StreamController<List<int>>();
    log('✅ [Speech] Audio stream created');
    
    // Start listening
    log('🚀 [Speech] Starting streamingRecognize...');
    final responseStream = _speechToText!.streamingRecognize(config, audioStream.stream);
    log('✅ [Speech] streamingRecognize started successfully');
    
    _recognitionSubscription = responseStream.listen(
      (response) {
        log('📡 [Speech] Received response: ${response.toString()}');
        if (response.results.isNotEmpty) {
          final result = response.results.first;
          log('🎯 [Speech] First result: isFinal=${result.isFinal}, alternatives=${result.alternatives.length}');
          
          // Process all alternatives for better accuracy
          for (final alternative in result.alternatives) {
            final transcript = alternative.transcript.trim();
            final confidence = alternative.confidence;
            
            log('🎯 [Speech] Alternative: "$transcript" (confidence: ${(confidence * 100).toStringAsFixed(1)}%)');
            
            // Check if this is a valid command
            final commandType = _detectCommand(transcript);
            if (commandType != 'unknown') {
              log('🎉 [Speech] Valid command detected: $commandType from "$transcript"');
              onResult(transcript);
              return; // Stop processing alternatives
            }
          }
          
          // If final result and no valid command found, report unknown command
          if (result.isFinal) {
            final transcript = result.alternatives.first.transcript.trim();
            log('❓ [Speech] No valid command found in: "$transcript"');
            onError('Không nhận diện được lệnh: "$transcript". Vui lòng thử lại.');
          }
        } else {
          log('⚠️ [Speech] Response has no results');
        }
      },
      onError: (error) {
        log('❌ [Speech] Speech recognition error: $error');
        log('❌ [Speech] Error type: ${error.runtimeType}');
        
        // Provide more specific error messages
        String errorMessage = 'Không thể nhận diện giọng nói';
        if (error.toString().contains('network')) {
          errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
        } else if (error.toString().contains('permission')) {
          errorMessage = 'Không có quyền truy cập microphone. Vui lòng cấp quyền.';
        } else if (error.toString().contains('timeout')) {
          errorMessage = 'Hết thời gian chờ. Vui lòng thử lại.';
        } else if (error.toString().contains('quota')) {
          errorMessage = 'Đã hết hạn sử dụng API. Vui lòng thử lại sau.';
        }
        
        onError(errorMessage);
        stopListening();
        onListeningComplete();
      },
      onDone: () {
        log('✅ [Speech] Speech recognition stream completed');
        // Only call onListeningComplete if we're still listening
        if (_isListening) {
          stopListening();
          onListeningComplete();
        }
      },
    );

    log('🎤 [Speech] Successfully started real speech recognition');
    
    // Start real microphone recording instead of simulation
    await _startRealMicrophoneRecording(audioStream);
  }

  // Enhanced command detection with fuzzy matching
  String _detectCommand(String transcript) {
    final lowerTranscript = transcript.toLowerCase().trim();
    log('🔍 [Speech] Detecting command in: "$lowerTranscript"');
    
    // Check each command pattern
    for (final entry in _commandPatterns.entries) {
      final commandType = entry.key;
      final patterns = entry.value;
      
      for (final pattern in patterns) {
        // Exact match
        if (lowerTranscript == pattern) {
          log('✅ [Speech] Exact match found: $pattern -> $commandType');
          return commandType;
        }
        
        // Contains match
        if (lowerTranscript.contains(pattern)) {
          log('✅ [Speech] Contains match found: $pattern in "$lowerTranscript" -> $commandType');
          return commandType;
        }
        
        // Fuzzy match for common variations
        if (_fuzzyMatch(lowerTranscript, pattern)) {
          log('✅ [Speech] Fuzzy match found: $pattern ~ "$lowerTranscript" -> $commandType');
          return commandType;
        }
      }
    }
    
    log('❌ [Speech] No command pattern matched: "$lowerTranscript"');
    return 'unknown';
  }

  // Fuzzy matching for Vietnamese commands
  bool _fuzzyMatch(String input, String pattern) {
    // Remove common Vietnamese variations
    final normalizedInput = _normalizeVietnamese(input);
    final normalizedPattern = _normalizeVietnamese(pattern);
    
    // Check if normalized strings match
    if (normalizedInput.contains(normalizedPattern) || 
        normalizedPattern.contains(normalizedInput)) {
      return true;
    }
    
    // Check for common typos/variations
    final inputWords = normalizedInput.split(' ');
    final patternWords = normalizedPattern.split(' ');
    
    // If at least 70% of words match, consider it a match
    int matchCount = 0;
    for (final inputWord in inputWords) {
      for (final patternWord in patternWords) {
        if (inputWord == patternWord || 
            inputWord.contains(patternWord) || 
            patternWord.contains(inputWord)) {
          matchCount++;
          break;
        }
      }
    }
    
    final matchRatio = matchCount / math.max(inputWords.length, patternWords.length);
    return matchRatio >= 0.7;
  }

  // Normalize Vietnamese text for better matching
  String _normalizeVietnamese(String text) {
    return text
        .replaceAll('à', 'a').replaceAll('á', 'a').replaceAll('ả', 'a').replaceAll('ã', 'a').replaceAll('ạ', 'a')
        .replaceAll('ă', 'a').replaceAll('ằ', 'a').replaceAll('ắ', 'a').replaceAll('ẳ', 'a').replaceAll('ẵ', 'a').replaceAll('ặ', 'a')
        .replaceAll('â', 'a').replaceAll('ầ', 'a').replaceAll('ấ', 'a').replaceAll('ẩ', 'a').replaceAll('ẫ', 'a').replaceAll('ậ', 'a')
        .replaceAll('è', 'e').replaceAll('é', 'e').replaceAll('ẻ', 'e').replaceAll('ẽ', 'e').replaceAll('ẹ', 'e')
        .replaceAll('ê', 'e').replaceAll('ề', 'e').replaceAll('ế', 'e').replaceAll('ể', 'e').replaceAll('ễ', 'e').replaceAll('ệ', 'e')
        .replaceAll('ì', 'i').replaceAll('í', 'i').replaceAll('ỉ', 'i').replaceAll('ĩ', 'i').replaceAll('ị', 'i')
        .replaceAll('ò', 'o').replaceAll('ó', 'o').replaceAll('ỏ', 'o').replaceAll('õ', 'o').replaceAll('ọ', 'o')
        .replaceAll('ô', 'o').replaceAll('ồ', 'o').replaceAll('ố', 'o').replaceAll('ổ', 'o').replaceAll('ỗ', 'o').replaceAll('ộ', 'o')
        .replaceAll('ơ', 'o').replaceAll('ờ', 'o').replaceAll('ớ', 'o').replaceAll('ở', 'o').replaceAll('ỡ', 'o').replaceAll('ợ', 'o')
        .replaceAll('ù', 'u').replaceAll('ú', 'u').replaceAll('ủ', 'u').replaceAll('ũ', 'u').replaceAll('ụ', 'u')
        .replaceAll('ư', 'u').replaceAll('ừ', 'u').replaceAll('ứ', 'u').replaceAll('ử', 'u').replaceAll('ữ', 'u').replaceAll('ự', 'u')
        .replaceAll('ỳ', 'y').replaceAll('ý', 'y').replaceAll('ỷ', 'y').replaceAll('ỹ', 'y').replaceAll('ỵ', 'y')
        .replaceAll('đ', 'd')
        .toLowerCase();
  }

  // Start simulated speech recognition for testing
  Future<void> _startSimulatedSpeechRecognition(
    Function(String) onResult,
    Function(String) onError,
    VoidCallback onListeningComplete,
  ) async {
    log('🎭 [Speech] Starting simulated speech recognition...');
    
    if (_isManualMode) {
      log('🎮 [Speech] Manual mode enabled - waiting for manual trigger');
      return; // Don't auto-detect in manual mode
    }
    
    // Simulate speech recognition with predefined commands
    final commands = [
      'Tăng số lượng',
      'Giảm số lượng', 
      'Thêm vào giỏ',
      'Mua ngay',
      'Đọc thông tin',
      'Đọc giá',
      'Hướng dẫn',
    ];
    
    // Simulate detection after 3 seconds (only once)
    Future.delayed(const Duration(seconds: 3), () {
      if (_isListening) {
        final randomCommand = commands[DateTime.now().millisecondsSinceEpoch % commands.length];
        log('🎭 [Speech] Simulated command detected: "$randomCommand"');
        onResult(randomCommand);
        
        // Don't continue automatically - wait for user to speak again
        log('🎭 [Speech] Simulation completed, waiting for real input...');
      }
    });
    
    log('🎭 [Speech] Simulated speech recognition started (will detect once after 3s)');
  }

  // Manual trigger for testing (call this when you want to simulate detection)
  void triggerManualDetection(Function(String) onResult) {
    if (!_isListening || !_isManualMode) return;
    
    log('🎮 [Speech] Manual detection triggered');
    
    final commands = [
      'Tăng số lượng',
      'Giảm số lượng', 
      'Thêm vào giỏ',
      'Mua ngay',
      'Đọc thông tin',
      'Đọc giá',
      'Hướng dẫn',
    ];
    
    final randomCommand = commands[DateTime.now().millisecondsSinceEpoch % commands.length];
    log('🎭 [Speech] Manual command detected: "$randomCommand"');
    onResult(randomCommand);
  }

  // Toggle manual mode
  void toggleManualMode() {
    _isManualMode = !_isManualMode;
    log('🎮 [Speech] Manual mode ${_isManualMode ? 'enabled' : 'disabled'}');
  }

  // Get current mode
  bool get isManualMode => _isManualMode;
  
  // Toggle simulation mode (for development/testing only)
  void toggleSimulationMode() {
    _enableSimulation = !_enableSimulation;
    log('🎭 [Speech] Simulation mode ${_enableSimulation ? 'enabled' : 'disabled'}');
  }
  
  // Get simulation mode status
  bool get isSimulationEnabled => _enableSimulation;

  // Start audio simulation for testing
  void _startAudioSimulation(StreamController<List<int>> audioStream) {
    if (_isSimulatingAudio) return;
    
    _isSimulatingAudio = true;
    log('🎵 [Speech] Starting audio simulation...');
    
    // Simulate audio data every 100ms
    _audioSimulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isListening || !_isSimulatingAudio) {
        timer.cancel();
        _isSimulatingAudio = false;
        return;
      }
      
      // Generate simulated audio data (16-bit PCM, 16kHz)
      final audioData = _generateSimulatedAudioData();
      audioStream.add(audioData);
      
      // Log only occasionally to avoid spam
      if (DateTime.now().millisecondsSinceEpoch % 1000 < 100) {
        log('🎵 [Speech] Sending simulated audio data: ${audioData.length} bytes');
      }
    });
  }

  // Generate simulated audio data
  List<int> _generateSimulatedAudioData() {
    // Generate 800 samples (50ms at 16kHz) of simulated audio
    final samples = <int>[];
    final sampleCount = 800;
    
    for (int i = 0; i < sampleCount; i++) {
      // Generate a simple sine wave pattern
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final frequency = 440.0; // A4 note
      final amplitude = 0.3; // Reduced amplitude
      
      final sample = (amplitude * 32767 * (0.5 + 0.5 * math.sin(time * frequency))).round();
      
      // Convert to 16-bit little-endian
      samples.add(sample & 0xFF);
      samples.add((sample >> 8) & 0xFF);
    }
    
    return samples;
  }

  // Stop listening
  void stopListening() {
    if (!_isListening) return;

    try {
      log('🛑 [Speech] Stopping speech recognition...');
      
      // Stop real recognition
      _recognitionSubscription?.cancel();
      _recognitionSubscription = null;
      
      // Stop real microphone recording
      _stopRealMicrophoneRecording();
      
      // Stop audio simulation (fallback)
      _audioSimulationTimer?.cancel();
      _isSimulatingAudio = false;
      
      _setListeningState(false);
      
      log('✅ [Speech] Speech recognition stopped successfully');
      
    } catch (e) {
      log('❌ [Speech] Error stopping: $e');
    }
  }

  // Check if currently listening
  bool get isListening => _isListening;

  // Set listening state
  void _setListeningState(bool listening) {
    _isListening = listening;
    log('🔄 [Speech] Listening state changed to: $listening');
  }

  // Text-to-Speech functionality
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    
    try {
      log('🔊 [Speech] Speaking: "$text"');
      await _flutterTts?.speak(text);
    } catch (e) {
      log('❌ [Speech] Error speaking text: $e');
    }
  }

  Future<void> stop() async {
    try {
      log('🔇 [Speech] Stopping TTS...');
      await _flutterTts?.stop();
      log('✅ [Speech] TTS stopped');
    } catch (e) {
      log('❌ [Speech] Error stopping TTS: $e');
    }
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

  // Enhanced voice command processing
  bool processVoiceCommand(String command) {
    final commandType = _detectCommand(command);
    return commandType != 'unknown';
  }

  // Get voice command type with enhanced detection
  String getCommandType(String command) {
    return _detectCommand(command);
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

  // Start real microphone recording
  Future<void> _startRealMicrophoneRecording(StreamController<List<int>> audioStream) async {
    try {
      log('🎤 [Speech] Starting real microphone recording...');
      
      // Start recording via platform channel
      await _microphoneChannel.invokeMethod('startRecording');
      log('✅ [Speech] Microphone recording started');
      
      // Listen to audio data stream with proper type handling
      _audioDataSubscription = _audioDataChannel.receiveBroadcastStream().listen(
        (data) {
          if (data is List<int>) {
            audioStream.add(data);
            log('🎵 [Speech] Real audio data: ${data.length} bytes');
          } else if (data is List) {
            // Convert List<dynamic> to List<int> if needed
            try {
              final intList = data.cast<int>();
              audioStream.add(intList);
              log('🎵 [Speech] Converted audio data: ${intList.length} bytes');
            } catch (e) {
              log('❌ [Speech] Error converting audio data: $e');
            }
          } else {
            log('⚠️ [Speech] Unexpected audio data type: ${data.runtimeType}');
          }
        },
        onError: (error) {
          log('❌ [Speech] Error receiving audio data: $error');
        },
      );
      
      _isRealAudioActive = true;
      log('🎤 [Speech] Real microphone recording active');
      
    } catch (e) {
      log('❌ [Speech] Error starting microphone recording: $e');
      log('❌ [Speech] Stack trace: ${StackTrace.current}');
      
      // Fallback to simulation if real recording fails
      log('🔄 [Speech] Falling back to audio simulation...');
      _startAudioSimulation(audioStream);
    }
  }

  // Stop real microphone recording
  Future<void> _stopRealMicrophoneRecording() async {
    if (!_isRealAudioActive) return;
    
    try {
      log('🛑 [Speech] Stopping real microphone recording...');
      
      // Stop recording via platform channel
      await _microphoneChannel.invokeMethod('stopRecording');
      
      // Cancel audio data subscription
      _audioDataSubscription?.cancel();
      _audioDataSubscription = null;
      
      _isRealAudioActive = false;
      log('✅ [Speech] Real microphone recording stopped');
      
    } catch (e) {
      log('❌ [Speech] Error stopping microphone recording: $e');
    }
  }

  // Convert real amplitude to audio data (placeholder for now)
  List<int> _convertAmplitudeToRealAudio(dynamic amplitude) {
    // Placeholder - will be implemented when we have real amplitude data
    final samples = <int>[];
    final sampleCount = 800; // 50ms at 16kHz
    
    for (int i = 0; i < sampleCount; i++) {
      // Generate placeholder audio data
      final sample = (math.Random().nextDouble() * 65535 - 32767).round();
      
      // Convert to 16-bit little-endian
      samples.add(sample & 0xFF);
      samples.add((sample >> 8) & 0xFF);
    }
    
    return samples;
  }

  // Cleanup
  void dispose() {
    log('🧹 [Speech] Disposing SpeechService...');
    
    _flutterTts?.stop();
    _recognitionSubscription?.cancel();
    _speechController?.close();
    _audioSimulationTimer?.cancel();
    
    // Cleanup microphone recorder
    _stopRealMicrophoneRecording();
    _audioDataSubscription?.cancel();
    
    log('✅ [Speech] SpeechService disposed');
  }
}
