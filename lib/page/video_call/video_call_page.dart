import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../network/service/agora_service.dart';
import '../../injection.dart';

class VideoCallPage extends StatefulWidget {
  final String productName;
  
  const VideoCallPage({
    super.key,
    required this.productName,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final TextEditingController _channelController = TextEditingController();
  final AgoraService _agoraService = getIt<AgoraService>();
  
  String? _channelName;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;
  bool _isConnecting = false;
  bool _isSpeaking = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAgora();
    
    // Set default channel name
    _channelController.text = 'test_phat';
  }
  
  @override
  void dispose() {
    _agoraService.dispose();
    _channelController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeAgora() async {
    // Initialize Agora engine
    final initialized = await _agoraService.initialize();
    if (!initialized) {
      _showErrorSnackBar('Không thể khởi tạo video call. Vui lòng kiểm tra quyền camera và microphone.');
      return;
    }
    
    // Register event handlers
    _agoraService.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        log('✅ Joined channel: ${connection.channelId}');
        setState(() {
          _localUserJoined = true;
          _isConnecting = false;
        });
        _showSuccessSnackBar('Đã kết nối thành công!');
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        log('👤 Remote user joined: $remoteUid');
        setState(() {
          _remoteUid = remoteUid;
        });
        _showSuccessSnackBar('Chuyên viên tư vấn đã tham gia cuộc gọi');
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        log('👤 Remote user left: $remoteUid, reason: $reason');
        setState(() {
          _remoteUid = null;
        });
        _showInfoSnackBar('Chuyên viên tư vấn đã rời khỏi cuộc gọi');
      },
      onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
        log('🔗 Connection state changed: $state, reason: $reason');
        if (state == ConnectionStateType.connectionStateFailed) {
          _showErrorSnackBar('Kết nối thất bại. Vui lòng thử lại.');
          setState(() {
            _isConnecting = false;
          });
        }
      },
      onError: (ErrorCodeType err, String msg) {
        log('❌ Agora error: $err, message: $msg');
        _showErrorSnackBar('Lỗi video call: $msg');
        setState(() {
          _isConnecting = false;
        });
      },
      onAudioVolumeIndication: (RtcConnection connection, List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
        for (AudioVolumeInfo speaker in speakers) {
          if (speaker.uid == 0) { // Local user
            setState(() {
              _isSpeaking = speaker.volume! > 5; // Threshold for speaking detection
            });
            break;
          }
        }
      },
    ));
  }
  
  Future<void> _joinChannel() async {
    if (_channelController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập Channel ID');
      return;
    }
    
    setState(() {
      _channelName = _channelController.text.trim();
      _isConnecting = true;
    });
    
    final success = await _agoraService.joinChannel(
      channelName: _channelName!,
    );
    
    if (!success) {
      setState(() {
        _isConnecting = false;
      });
      _showErrorSnackBar('Không thể tham gia kênh. Vui lòng thử lại.');
    }
  }
  
  Future<void> _leaveChannel() async {
    await _agoraService.leaveChannel();
    setState(() {
      _channelName = null;
      _localUserJoined = false;
      _remoteUid = null;
      _isConnecting = false;
    });
  }
  
  Future<void> _toggleAudio() async {
    setState(() {
      _isAudioMuted = !_isAudioMuted;
    });
    await _agoraService.muteLocalAudio(_isAudioMuted);
    HapticFeedback.lightImpact();
  }
  
  Future<void> _toggleVideo() async {
    setState(() {
      _isVideoMuted = !_isVideoMuted;
    });
    await _agoraService.muteLocalVideo(_isVideoMuted);
    HapticFeedback.lightImpact();
  }
  
  Future<void> _switchCamera() async {
    await _agoraService.switchCamera();
    HapticFeedback.lightImpact();
  }
  
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _channelName == null 
              ? 'Tư vấn sản phẩm' 
              : 'Đang tư vấn: ${widget.productName}',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text),
          onPressed: () async {
            if (_channelName != null) {
              await _leaveChannel();
            }
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (_channelName != null)
            IconButton(
              icon: Icon(Icons.call_end, color: AppColors.error),
              onPressed: _leaveChannel,
            ),
        ],
      ),
      body: _channelName == null ? _buildJoinChannelUI() : _buildVideoCallUI(),
    );
  }
  
  Widget _buildJoinChannelUI() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_call,
              size: ResponsiveHelper.getIconSize(context, 80),
              color: AppColors.primary,
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            Text(
              '📞 Tư vấn sản phẩm trực tiếp',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              'Sản phẩm: ${widget.productName}',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 2),
            
            // Channel ID Input
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context) * 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Channel ID để kết nối:',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  TextField(
                    controller: _channelController,
                    decoration: InputDecoration(
                      hintText: 'Nhập Channel ID từ chuyên viên tư vấn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context),
                        ),
                        borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context),
                        ),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      prefixIcon: Icon(Icons.link, color: AppColors.primary),
                    ),
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Row(
                    children: [
                      Icon(Icons.copy, size: 16, color: AppColors.grey),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _channelController.text));
                          _showSuccessSnackBar('Đã copy Channel ID');
                        },
                        child: Text(
                          'Copy để chia sẻ với chuyên viên',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 2),
            
            // Join Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _joinChannel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                  ),
                  elevation: 0,
                ),
                child: _isConnecting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Đang kết nối...',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_call, size: 24),
                          SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Bắt đầu tư vấn',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Instructions
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Hướng dẫn sử dụng:',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                  Text(
                    '1. Nhập Channel ID được cung cấp bởi chuyên viên\n2. Nhấn "Bắt đầu tư vấn"\n3. Chờ chuyên viên tham gia cuộc gọi\n4. Bắt đầu nhận tư vấn trực tiếp',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 12,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVideoCallUI() {
    return Stack(
      children: [
        // Main video view (remote or local)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: _remoteUid != null
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _agoraService.engine!,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(channelId: _channelName!),
                  ),
                )
              : _localUserJoined
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _agoraService.engine!,
                        canvas: const VideoCanvas(uid: 0),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Đang thiết lập kết nối...',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
        
        // Local video view (picture in picture when remote is connected)
        if (_remoteUid != null && _localUserJoined)
          Positioned(
            top: ResponsiveHelper.getLargeSpacing(context),
            right: ResponsiveHelper.getLargeSpacing(context),
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context),
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context),
                ),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _agoraService.engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),
        
        // Status indicator
        Positioned(
          top: ResponsiveHelper.getLargeSpacing(context),
          left: ResponsiveHelper.getLargeSpacing(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getSpacing(context),
              vertical: ResponsiveHelper.getSpacing(context) / 2,
            ),
            decoration: BoxDecoration(
              color: _remoteUid != null ? AppColors.success : AppColors.warning,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  _remoteUid != null ? 'Đang tư vấn' : 'Chờ chuyên viên',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Control buttons
        Positioned(
          bottom: ResponsiveHelper.getLargeSpacing(context) * 2,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Audio toggle with speaking indicator
              _buildControlButton(
                icon: _isAudioMuted ? Icons.mic_off : (_isSpeaking ? Icons.mic : Icons.mic),
                isActive: !_isAudioMuted,
                onPressed: _toggleAudio,
                showSpeakingIndicator: _isSpeaking && !_isAudioMuted,
              ),
              
              // Video toggle
              _buildControlButton(
                icon: _isVideoMuted ? Icons.videocam_off : Icons.videocam,
                isActive: !_isVideoMuted,
                onPressed: _toggleVideo,
              ),
              
              // Switch camera
              _buildControlButton(
                icon: Icons.cameraswitch,
                isActive: true,
                onPressed: _switchCamera,
              ),
              
              // End call
              _buildControlButton(
                icon: Icons.call_end,
                isActive: true,
                backgroundColor: AppColors.error,
                onPressed: _leaveChannel,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? backgroundColor,
    bool showSpeakingIndicator = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isActive ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        // Speaking indicator border
        border: showSpeakingIndicator 
            ? Border.all(color: AppColors.success, width: 3)
            : null,
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(
              icon,
              color: backgroundColor != null 
                  ? Colors.white 
                  : (isActive ? AppColors.text : Colors.white),
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            onPressed: onPressed,
          ),
          // Speaking pulse indicator
          if (showSpeakingIndicator)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
