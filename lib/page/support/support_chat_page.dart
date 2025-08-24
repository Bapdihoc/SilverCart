import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../network/service/agora_chat_service.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late final AgoraChatService _chatService;
  late final AuthService _authService;
  
  List<SupportChatMessage> _messages = [];
  bool _isConnecting = true;
  bool _isConnected = false;
  bool _isSending = false;
  String? _currentUserId;

  

  
  @override
  void initState() {
    super.initState();
    _chatService = getIt<AgoraChatService>();
    _authService = getIt<AuthService>();
    _initializeChat();
  }
  
  Future<void> _initializeChat() async {
    try {
      // Get current user ID
      _currentUserId = await _authService.getUserId();
      if (_currentUserId == null) {
        _showError('Không thể xác định người dùng. Vui lòng đăng nhập lại.');
        return;
      }
      
      // Initialize Chat service
      final initialized = await _chatService.initialize();
      if (!initialized) {
        _showError('Không thể khởi tạo dịch vụ chat');
        return;
      }
      
      // Setup event handlers
      _setupEventHandlers();
      
      // Get token from server (production) or generate dev token
      String? token;
      try {
        // Try to get token from server first (production)
        token = await _chatService.getTokenFromServer(_currentUserId!);
      } catch (e) {
        log('⚠️ Failed to get token from server, using dev token: $e');
      }
      
      // Fallback to dev token if server token fails
      token ??= _chatService.generateDevToken(_currentUserId!);
      
      // Login user with token
      final loggedIn = await _chatService.loginWithToken(_currentUserId!, token);
      if (!loggedIn) {
        _showError('Không thể đăng nhập vào hệ thống chat');
        return;
      }
      
      // Join support channel để chat với consultant
      final joinedChannel = await _chatService.joinSupportChannel();
      if (!joinedChannel) {
        _showError('Không thể kết nối đến kênh hỗ trợ');
        return;
      }
      
      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });
      
      // Send welcome message
      _addSystemMessage('Chào mừng bạn đến với kênh hỗ trợ SilverCart! 👋\nTư vấn viên sẽ hỗ trợ bạn trong giây lát.');
      
      // Simulate consultant joining for testing (remove in production)
      _chatService.simulateConsultantJoin();
      
      // Real agents will join automatically when available
      
    } catch (e) {
      _showError('Lỗi kết nối: ${e.toString()}');
    }
  }
  
  void _setupEventHandlers() {
    _chatService.onMessageReceived = (fromUserId, messageText) {
      if (mounted && fromUserId != _currentUserId) {
        _addMessage(SupportChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: fromUserId,
          senderName: _getSenderName(fromUserId),
          message: messageText,
          timestamp: DateTime.now(),
          isFromCurrentUser: false,
          messageType: SupportChatMessageType.text,
        ));
      }
    };
    
    _chatService.onConsultantJoined = (userId) {
      if (mounted) {
        _addSystemMessage('${_getConsultantName(userId)} đã tham gia kênh hỗ trợ');
        _addSystemMessage('Tư vấn viên đã sẵn sàng hỗ trợ bạn! 🎧');
      }
    };
    
    _chatService.onConsultantLeft = (userId) {
      if (mounted) {
        _addSystemMessage('${_getConsultantName(userId)} đã rời khỏi kênh hỗ trợ');
        _addSystemMessage('Cuộc trò chuyện đã kết thúc. Cảm ơn bạn đã sử dụng dịch vụ!');
      }
    };
    
    _chatService.onConnectionStateChanged = (isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    };
    
    _chatService.onTokenWillExpire = () {
      if (mounted) {
        // In production, get new token from server and renew
        final newToken = _chatService.generateDevToken(_currentUserId!);
        _chatService.renewToken(newToken);
      }
    };
  }
  

  
  String _getSenderName(String userId) {
    if (_isConsultant(userId)) {
      return _getConsultantName(userId);
    }
    return userId == _currentUserId ? 'Bạn' : userId;
  }
  
  bool _isConsultant(String userId) {
    return userId.startsWith('consultant_');
  }
  
  String _getConsultantName(String userId) {
    // Map consultant IDs to friendly names
    switch (userId) {
      case 'consultant_mai_001':
        return 'Tư vấn viên Mai';
      case 'consultant_nam_002':
        return 'Tư vấn viên Nam';
      case 'consultant_linh_003':
        return 'Tư vấn viên Linh';
      default:
        return 'Tư vấn viên';
    }
  }
  
  void _addMessage(SupportChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
    
    // Haptic feedback for incoming messages
    if (!message.isFromCurrentUser) {
      HapticFeedback.lightImpact();
    }
  }
  
  void _addSystemMessage(String message) {
    _addMessage(SupportChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'system',
      senderName: 'Hệ thống',
      message: message,
      timestamp: DateTime.now(),
      isFromCurrentUser: false,
      messageType: SupportChatMessageType.system,
    ));
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending || !_isConnected) return;
    
    setState(() {
      _isSending = true;
    });
    
    try {
      // Add message to UI immediately
      final chatMessage = SupportChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _currentUserId!,
        senderName: 'Bạn',
        message: message,
        timestamp: DateTime.now(),
        isFromCurrentUser: true,
        messageType: SupportChatMessageType.text,
      );
      
      _addMessage(chatMessage);
      _messageController.clear();
      
      // Send message to support channel
      final success = await _chatService.sendMessageToSupport(message);
      if (!success) {
        _showError('Không thể gửi tin nhắn. Vui lòng thử lại.');
      }
      
      // Real consultant will respond through support channel
      
    } catch (e) {
      _showError('Lỗi gửi tin nhắn: ${e.toString()}');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
  

  
  void _showError(String message) {
    if (mounted) {
      setState(() {
        _isConnecting = false;
        _isConnected = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildConnectionStatus(),
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 40),
            height: ResponsiveHelper.getIconSize(context, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: ResponsiveHelper.getIconSize(context, 20),
              color: Colors.white,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat với tư vấn viên',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  _isConnected ? '🟢 Đang hoạt động' : '🔴 Đang kết nối...',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 12,
                    color: _isConnected ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
            onPressed: () {
              // Could integrate with video call feature
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng gọi điện sẽ sớm được cập nhật!'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildConnectionStatus() {
    if (_isConnecting) {
      return Container(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        color: AppColors.warning.withOpacity(0.1),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.warning,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text(
              'Đang kết nối đến kênh hỗ trợ...',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    if (!_isConnected) {
      return Container(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        color: AppColors.error.withOpacity(0.1),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 16),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Expanded(
              child: Text(
                'Kết nối thất bại. Vui lòng thử lại.',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _initializeChat,
              child: Text(
                'Thử lại',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildMessagesList() {
    if (_messages.isEmpty && !_isConnecting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 80),
              height: ResponsiveHelper.getIconSize(context, 80),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: ResponsiveHelper.getIconSize(context, 40),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            Text(
              'Chat với tư vấn viên',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              'Tư vấn viên SilverCart sẵn sàng hỗ trợ bạn 24/7\nBắt đầu cuộc trò chuyện ngay!',
              textAlign: TextAlign.center,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }
  
  Widget _buildMessageBubble(SupportChatMessage message) {
    final isCurrentUser = message.isFromCurrentUser;
    final isSystem = message.messageType == SupportChatMessageType.system;
    
    if (isSystem) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSpacing(context) / 2),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getSpacing(context),
              vertical: ResponsiveHelper.getSpacing(context) / 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.message,
              textAlign: TextAlign.center,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
    
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getSpacing(context),
        left: isCurrentUser ? ResponsiveHelper.getIconSize(context, 50) : 0,
        right: isCurrentUser ? 0 : ResponsiveHelper.getIconSize(context, 50),
      ),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: ResponsiveHelper.getIconSize(context, 32),
              height: ResponsiveHelper.getIconSize(context, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: Colors.white,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              decoration: BoxDecoration(
                gradient: isCurrentUser
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      )
                    : null,
                color: isCurrentUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context) / 2),
                      child: Text(
                        message.senderName,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  Text(
                    message.message,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 15,
                      color: isCurrentUser ? Colors.white : AppColors.text,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                  Text(
                    _formatTime(message.timestamp),
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 10,
                      color: isCurrentUser 
                          ? Colors.white.withOpacity(0.7) 
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
            Container(
              width: ResponsiveHelper.getIconSize(context, 32),
              height: ResponsiveHelper.getIconSize(context, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_rounded,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: AppColors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getLargeSpacing(context),
                      vertical: ResponsiveHelper.getSpacing(context),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: ResponsiveHelper.getIconSize(context, 20),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isConnected && !_isSending ? _sendMessage : null,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: ResponsiveHelper.getIconSize(context, 48),
                    height: ResponsiveHelper.getIconSize(context, 48),
                    child: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            size: ResponsiveHelper.getIconSize(context, 20),
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Support Chat Message model
class SupportChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromCurrentUser;
  final SupportChatMessageType messageType;
  
  SupportChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromCurrentUser,
    required this.messageType,
  });
}

enum SupportChatMessageType {
  text,
  system,
  image,
  file,
}
