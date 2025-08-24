import 'dart:developer';
import 'package:flutter/material.dart';
import 'speech_service.dart';

/// Demo widget để test Speech Recognition
class SpeechDemo extends StatefulWidget {
  const SpeechDemo({super.key});

  @override
  State<SpeechDemo> createState() => _SpeechDemoState();
}

class _SpeechDemoState extends State<SpeechDemo> {
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  String _lastCommand = '';
  String _status = 'Chưa khởi tạo';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    setState(() {
      _status = 'Đang khởi tạo...';
    });

    try {
      await _speechService.initialize();
      setState(() {
        _status = 'Đã khởi tạo thành công';
      });
    } catch (e) {
      setState(() {
        _status = 'Lỗi khởi tạo: $e';
      });
      log('Speech initialization error: $e');
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      _speechService.stopListening();
      setState(() {
        _isListening = false;
        _status = 'Đã dừng lắng nghe';
      });
    } else {
      setState(() {
        _isListening = true;
        _status = 'Đang lắng nghe...';
      });

      await _speechService.startListening(
        onResult: (transcript) {
          setState(() {
            _lastCommand = transcript;
            _status = 'Nhận diện thành công: $transcript';
          });
          log('Voice command: $transcript');
        },
        onError: (error) {
          setState(() {
            _status = 'Lỗi: $error';
          });
          log('Speech error: $error');
        },
        onListeningComplete: () {
          setState(() {
            _isListening = false;
            _status = 'Hoàn thành lắng nghe';
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Speech Recognition Demo'),
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
                      'Trạng thái:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: _status.contains('lỗi') ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Last command card
            if (_lastCommand.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lệnh cuối cùng:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastCommand,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Instructions card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hướng dẫn sử dụng:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Nhấn nút "Bắt đầu lắng nghe"'),
                    const Text('2. Nói một trong các lệnh:'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('• "Tăng số lượng"'),
                          Text('• "Giảm số lượng"'),
                          Text('• "Thêm vào giỏ"'),
                          Text('• "Mua ngay"'),
                          Text('• "Đọc thông tin"'),
                          Text('• "Đọc giá"'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleListening,
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    label: Text(_isListening ? 'Dừng lắng nghe' : 'Bắt đầu lắng nghe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Test buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _speechService.speak('Đây là test text-to-speech');
                    },
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Test TTS'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _speechService.speakInstructions();
                    },
                    icon: const Icon(Icons.help),
                    label: const Text('Hướng dẫn'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}
