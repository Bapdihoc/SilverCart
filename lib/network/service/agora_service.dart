import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:injectable/injectable.dart';

@singleton
class AgoraService {
  // Replace with your actual App ID from Agora Console
  static const String appId = 'd37efc8cf7624babaf1a8c9f79e5ed04';
  
  RtcEngine? _engine;
  bool _isEngineInitialized = false;
  
  // Getters
  RtcEngine? get engine => _engine;
  bool get isInitialized => _isEngineInitialized;
  
  // Initialize Agora Engine
  Future<bool> initialize() async {
    try {
      // Request permissions
      final permissionStatus = await _requestPermissions();
      if (!permissionStatus) {
        log('❌ Permissions denied for Agora');
        return false;
      }
      
      // Create RTC Engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(appId: appId));
      
      // Enable audio and video
      await _engine!.enableAudio();
      await _engine!.enableVideo();
      await _engine!.startPreview();
      
      // Audio settings for better quality (especially for elderly users)
      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming,
      );
      
      // Enable audio volume indication
      await _engine!.enableAudioVolumeIndication(
        interval: 200,
        smooth: 3,
        reportVad: true,
      );
      
      _isEngineInitialized = true;
      log('✅ Agora engine initialized successfully');
      return true;
    } catch (e) {
      log('❌ Error initializing Agora engine: $e');
      return false;
    }
  }
  
  // Register event handler
  void registerEventHandler(RtcEngineEventHandler eventHandler) {
    _engine?.registerEventHandler(eventHandler);
  }
  
  // Join channel
  Future<bool> joinChannel({
    required String channelName,
    String? token,
    int uid = 0,
  }) async {
    if (!_isEngineInitialized || _engine == null) {
      log('❌ Agora engine not initialized');
      return false;
    }
    
    try {
      await _engine!.joinChannel(
        token: token ?? '007eJxTYDg4dbJmkpRO1N0fM6Mibqy/tK3J1W3y9VcM/dUNj+7mpUkqMKQYm6emJVskp5mbGZkkJSYlphkmWiRbpplbppqmphiYFHLMymgIZGRwKFnGzMgAgSA+J0NJanFJfEFGYgkDAwCBmiMv',
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      
      log('✅ Joined channel: $channelName');
      return true;
    } catch (e) {
      log('❌ Error joining channel: $e');
      return false;
    }
  }
  
  // Leave channel
  Future<void> leaveChannel() async {
    try {
      await _engine?.leaveChannel();
      log('✅ Left channel');
    } catch (e) {
      log('❌ Error leaving channel: $e');
    }
  }
  
  // Switch camera
  Future<void> switchCamera() async {
    try {
      await _engine?.switchCamera();
    } catch (e) {
      log('❌ Error switching camera: $e');
    }
  }
  
  // Mute/unmute microphone
  Future<void> muteLocalAudio(bool mute) async {
    try {
      await _engine?.muteLocalAudioStream(mute);
      log('✅ Mute local audio: $mute');
    } catch (e) {
      log('❌ Error muting audio: $e');
    }
  }
  
  // Enable/disable video
  Future<void> muteLocalVideo(bool mute) async {
    try {
      await _engine?.muteLocalVideoStream(mute);
    } catch (e) {
      log('❌ Error muting video: $e');
    }
  }
  
  // Request permissions
  Future<bool> _requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();
      
      bool allGranted = statuses.values.every(
        (status) => status == PermissionStatus.granted,
      );
      
      return allGranted;
    } catch (e) {
      log('❌ Error requesting permissions: $e');
      return false;
    }
  }
  
  // Dispose resources
  Future<void> dispose() async {
    try {
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      await _engine?.release();
      _engine = null;
      _isEngineInitialized = false;
      log('✅ Agora engine disposed');
    } catch (e) {
      log('❌ Error disposing Agora engine: $e');
    }
  }
}
