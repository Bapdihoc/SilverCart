import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Test widget để kiểm tra microphone permission và status
class MicrophoneTest extends StatefulWidget {
  const MicrophoneTest({super.key});

  @override
  State<MicrophoneTest> createState() => _MicrophoneTestState();
}

class _MicrophoneTestState extends State<MicrophoneTest> {
  PermissionStatus _microphoneStatus = PermissionStatus.denied;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkMicrophoneStatus();
  }

  Future<void> _checkMicrophoneStatus() async {
    setState(() {
      _isChecking = true;
    });

    try {
      log('🔍 [MicrophoneTest] Checking microphone permission status...');
      final status = await Permission.microphone.status;
      log('📱 [MicrophoneTest] Microphone status: $status');
      
      setState(() {
        _microphoneStatus = status;
        _isChecking = false;
      });
    } catch (e) {
      log('❌ [MicrophoneTest] Error checking microphone status: $e');
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _requestMicrophonePermission() async {
    setState(() {
      _isChecking = true;
    });

    try {
      log('⚠️ [MicrophoneTest] Requesting microphone permission...');
      final result = await Permission.microphone.request();
      log('📱 [MicrophoneTest] Permission request result: $result');
      
      setState(() {
        _microphoneStatus = result;
        _isChecking = false;
      });
    } catch (e) {
      log('❌ [MicrophoneTest] Error requesting microphone permission: $e');
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> _openAppSettings() async {
    log('⚙️ [MicrophoneTest] Opening app settings...');
    await openAppSettings();
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '✅ Đã cấp quyền';
      case PermissionStatus.denied:
        return '❌ Bị từ chối';
      case PermissionStatus.restricted:
        return '🚫 Bị hạn chế';
      case PermissionStatus.limited:
        return '⚠️ Bị giới hạn';
      case PermissionStatus.permanentlyDenied:
        return '🚫 Bị từ chối vĩnh viễn';
      default:
        return '❓ Không xác định';
    }
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Microphone Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trạng thái Microphone:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _microphoneStatus == PermissionStatus.granted 
                              ? Icons.mic 
                              : Icons.mic_off,
                          color: _getStatusColor(_microphoneStatus),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusText(_microphoneStatus),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: _getStatusColor(_microphoneStatus),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Status: $_microphoneStatus',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hành động:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Check status button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isChecking ? null : _checkMicrophoneStatus,
                        icon: _isChecking 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(_isChecking ? 'Đang kiểm tra...' : 'Kiểm tra trạng thái'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Request permission button
                    if (_microphoneStatus != PermissionStatus.granted)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isChecking ? null : _requestMicrophonePermission,
                          icon: const Icon(Icons.mic),
                          label: const Text('Yêu cầu quyền Microphone'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // Open settings button
                    if (_microphoneStatus == PermissionStatus.permanentlyDenied)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openAppSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('Mở cài đặt ứng dụng'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('• Kiểm tra trạng thái quyền microphone'),
                    const Text('• Yêu cầu quyền nếu chưa được cấp'),
                    const Text('• Mở cài đặt nếu bị từ chối vĩnh viễn'),
                    const Text('• Quyền microphone cần thiết cho speech recognition'),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Console log button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  log('🎤 [MicrophoneTest] Manual log test - Microphone status: $_microphoneStatus');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã log trạng thái microphone: $_microphoneStatus'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.info),
                label: const Text('Test Console Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
