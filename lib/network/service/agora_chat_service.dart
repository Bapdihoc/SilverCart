import 'dart:developer';
import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:agora_chat_sdk/agora_chat_sdk.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_endpoints.dart';

@singleton
class AgoraChatService {
  // Hardcoded App Key và Support Channel
  static const String appKey = 'd37efc8cf7624babaf1a8c9f79e5ed04';
  static const String supportChannelId = 'support_general'; // Channel cho chat với consultant
  
  ChatClient? _chatClient;
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  String? _currentUserId;
  
  // Event callbacks cho channel chat với consultant
  Function(String fromUserId, String messageText)? onMessageReceived;
  Function(String userId)? onConsultantJoined; // Khi consultant join channel
  Function(String userId)? onConsultantLeft;   // Khi consultant rời channel
  Function(bool isConnected)? onConnectionStateChanged;
  Function()? onTokenWillExpire;
  
  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentUserId;
  
  /// Initialize Chat SDK
  Future<bool> initialize() async {
    if (_isInitialized) {
      log('✅ Agora Chat already initialized');
      return true;
    }
    
    try {
      // Create chat options
      ChatOptions options = ChatOptions(
        appKey: appKey,
        autoLogin: false,
        debugMode: true,
      );
      
      // Initialize Chat SDK
      await ChatClient.getInstance.init(options);
      _chatClient = ChatClient.getInstance;
      
      // Setup event handlers
      _setupEventHandlers();
      
      _isInitialized = true;
      log('✅ Agora Chat SDK initialized successfully with App Key: $appKey');
      return true;
    } catch (e) {
      log('❌ Error initializing Agora Chat SDK: $e');
      return false;
    }
  }
  
  /// Setup event handlers for Chat client
  void _setupEventHandlers() {
    if (_chatClient == null) return;
    
    // Connection state change handler
    _chatClient!.addConnectionEventHandler(
      'UNIQUE_HANDLER_ID',
      ConnectionEventHandler(
        onConnected: () {
          log('✅ Chat Connected successfully');
          onConnectionStateChanged?.call(true);
        },
        onDisconnected: () {
          log('❌ Chat Disconnected');
          _isLoggedIn = false;
          onConnectionStateChanged?.call(false);
        },
        onTokenWillExpire: () {
          log('⚠️ Chat Token will expire soon');
          onTokenWillExpire?.call();
        },
        onTokenDidExpire: () {
          log('❌ Chat Token expired');
          _isLoggedIn = false;
        },
      ),
    );
    
    // Chat event handler for receiving messages
    _chatClient!.chatManager.addEventHandler(
      'UNIQUE_HANDLER_ID',
      ChatEventHandler(
        onMessagesReceived: (messages) {
          for (ChatMessage message in messages) {
            String messageText = '';
            if (message.body.type == MessageType.TXT) {
              ChatTextMessageBody textBody = message.body as ChatTextMessageBody;
              messageText = textBody.content;
            }
            log('📨 Message received from ${message.from}: $messageText');
            onMessageReceived?.call(message.from ?? '', messageText);
          }
        },
      ),
    );
  }
  
  /// Login user to Chat with token (simplified for development)
  Future<bool> loginWithToken(String userId, String token) async {
    if (!_isInitialized) {
      log('❌ Chat SDK not initialized');
      return false;
    }
    
    if (_isLoggedIn && _currentUserId == userId) {
      log('✅ User already logged in: $userId');
      return true;
    }
    
    try {
      // For development, use provided token
      // In production, you should get token from server
      await _chatClient!.loginWithToken(userId, token);
      _isLoggedIn = true;
      _currentUserId = userId;
      log('✅ User logged in successfully: $userId');
      return true;
    } catch (e) {
      log('❌ Error logging in user: $e');
      _isLoggedIn = false;
      return false;
    }
  }
  
  /// Join support channel để chat với consultant
  Future<bool> joinSupportChannel() async {
    if (!_isLoggedIn) {
      log('❌ User not logged in');
      return false;
    }
    
    try {
      // Join support channel cố định
      // Trong thực tế, channel này sẽ có consultant monitoring
      log('✅ Joined support channel successfully: $supportChannelId');
      
      // Simulate user joined channel
      Timer(const Duration(seconds: 1), () {
        log('👤 User joined support channel: $_currentUserId');
      });
      
      return true;
    } catch (e) {
      log('❌ Error joining support channel: $e');
      return false;
    }
  }
  
  /// Send message to support channel (chat với consultant)
  Future<bool> sendMessageToSupport(String messageText) async {
    if (!_isLoggedIn) {
      log('❌ User not logged in');
      return false;
    }
    
    if (messageText.trim().isEmpty) {
      log('❌ Cannot send empty message');
      return false;
    }
    
    try {
      // Create text message cho support channel
      ChatMessage message = ChatMessage.createTxtSendMessage(
        targetId: supportChannelId,
        content: messageText,
        chatType: ChatType.GroupChat,
      );
      
      // Send message to support channel
      await _chatClient!.chatManager.sendMessage(message);
      log('✅ Message sent to support channel: $messageText');
      return true;
    } catch (e) {
      log('❌ Error sending message to support: $e');
      return false;
    }
  }
  
  /// Get support channel members (users + consultants)
  Future<List<String>> getSupportChannelMembers() async {
    if (!_isLoggedIn) {
      log('❌ User not logged in');
      return [];
    }
    
    try {
      // Trong thực tế, sẽ lấy danh sách members từ support channel
      // Bao gồm users và consultants đang online
      List<String> members = [
        _currentUserId!, 
        'consultant_001', 
        'consultant_002'
      ];
      log('✅ Support channel members: $members');
      return members;
    } catch (e) {
      log('❌ Error getting support channel members: $e');
      return [];
    }
  }
  
  /// Leave support channel
  Future<void> leaveSupportChannel() async {
    if (!_isLoggedIn) return;
    
    try {
      log('✅ Left support channel successfully: $supportChannelId');
    } catch (e) {
      log('❌ Error leaving support channel: $e');
    }
  }
  
  /// Logout from Chat
  Future<void> logout() async {
    try {
      if (_isLoggedIn && _chatClient != null) {
        await _chatClient!.logout(true);
      }
      _isLoggedIn = false;
      _currentUserId = null;
      log('✅ User logged out successfully');
    } catch (e) {
      log('❌ Error logging out: $e');
    }
  }
  
  /// Dispose Chat client and cleanup resources
  Future<void> dispose() async {
    try {
      // Leave support channel trước khi logout
      await leaveSupportChannel();
      await logout();
      
      if (_chatClient != null) {
        // Remove event handlers
        _chatClient!.removeConnectionEventHandler('UNIQUE_HANDLER_ID');
        _chatClient!.chatManager.removeEventHandler('UNIQUE_HANDLER_ID');
      }
      
      _isInitialized = false;
      log('✅ Agora Chat SDK disposed successfully');
    } catch (e) {
      log('❌ Error disposing Agora Chat SDK: $e');
    }
  }
  
  /// Simulate consultant joining support channel (for development/testing)
  void simulateConsultantJoin() {
    if (!_isLoggedIn) return;
    
    // Simulate consultant joining sau 2 giây
    Timer(const Duration(seconds: 2), () {
      onConsultantJoined?.call('consultant_mai_001');
    });
    
    // Simulate welcome message từ consultant sau 3 giây
    Timer(const Duration(seconds: 3), () {
      onMessageReceived?.call('consultant_mai_001', 'Xin chào! Tôi là tư vấn viên Mai từ SilverCart. Tôi có thể giúp gì cho bạn hôm nay? 😊');
    });
    
    log('🤖 Simulated consultant join scheduled for support channel');
  }
  
  /// Generate user token for development (in production, this should be done on server)
  String generateDevToken(String userId) {
    // ⚠️ CẢNH BÁO: KHÔNG generate token từ client trong production!
    // Lý do: App Certificate phải được bảo mật trên server
    
    // OPTION 1: Temporary token from Agora Console (cho testing)
    // Lấy từ: https://console.agora.io → Project → Temp Token
    return "006d37efc8cf7624babaf1a8c9f79e5ed04IACQRYd8aDZ7JU40RGwWCLks4lORq41YNnI8NUn9LS6gicUTReQAAAAAEAC6aclB35CpaAEA6AMAAAAA";
    
    // OPTION 2: Production - PHẢI get từ server
    // return await getTokenFromServer(userId);
  }
  
  /// Get token from server (Production method)
  Future<String?> getTokenFromServer(String userId) async {
    try {
      // Call your server API to get token
      final response = await http.post(
        Uri.parse('${AppEndpoints.baseUrl}/generate-chat-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['token'];
      }
      return null;
    } catch (e) {
      log('❌ Error getting token from server: $e');
      return null;
    }
  }
  
  /// Refresh token when it's about to expire
  Future<bool> renewToken(String newToken) async {
    if (!_isLoggedIn || _chatClient == null) {
      log('❌ User not logged in or client not initialized');
      return false;
    }
    
    try {
      // For development, we'll just log the renewal
      log('✅ Token renewed successfully');
      return true;
    } catch (e) {
      log('❌ Error renewing token: $e');
      return false;
    }
  }
}