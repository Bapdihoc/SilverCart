import 'dart:developer';
import 'package:flutter/material.dart';
import 'speech_service.dart';

class SpeechTestPage extends StatefulWidget {
  @override
  _SpeechTestPageState createState() => _SpeechTestPageState();
}

class _SpeechTestPageState extends State<SpeechTestPage> {
  final SpeechService _speechService = SpeechService();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastCommand = '';
  String _lastError = '';
  List<String> _commandHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speechService.initialize();
      setState(() {
        _isInitialized = true;
      });
      log('✅ [SpeechTest] Speech service initialized');
    } catch (e) {
      log('❌ [SpeechTest] Failed to initialize speech service: $e');
      setState(() {
        _lastError = 'Failed to initialize: $e';
      });
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      setState(() {
        _lastError = 'Speech service not initialized';
      });
      return;
    }

    if (_isListening) {
      _speechService.stopListening();
      setState(() {
        _isListening = false;
      });
    } else {
      setState(() {
        _isListening = true;
        _lastError = '';
      });

      await _speechService.startListening(
        onResult: (transcript) {
          log('🎯 [SpeechTest] Command received: "$transcript"');
          final commandType = _speechService.getCommandType(transcript);
          
          setState(() {
            _lastCommand = '$transcript -> $commandType';
            _commandHistory.insert(0, '${DateTime.now().toString().substring(11, 19)}: $transcript ($commandType)');
            if (_commandHistory.length > 10) {
              _commandHistory.removeLast();
            }
          });

          // Auto-stop after command detection
          Future.delayed(Duration(seconds: 2), () {
            if (_isListening) {
              _speechService.stopListening();
              setState(() {
                _isListening = false;
              });
            }
          });
        },
        onError: (error) {
          log('❌ [SpeechTest] Error: $error');
          setState(() {
            _lastError = error;
            _isListening = false;
          });
        },
        onListeningComplete: () {
          log('✅ [SpeechTest] Listening completed');
          setState(() {
            _isListening = false;
          });
        },
      );
    }
  }

  void _testCommand(String command) {
    log('🧪 [SpeechTest] Testing command: "$command"');
    final commandType = _speechService.getCommandType(command);
    setState(() {
      _lastCommand = '$command -> $commandType';
      _commandHistory.insert(0, '${DateTime.now().toString().substring(11, 19)}: $command ($commandType)');
      if (_commandHistory.length > 10) {
        _commandHistory.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎤 Speech Recognition Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trạng thái',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text('Khởi tạo: ${_isInitialized ? "Thành công" : "Thất bại"}'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _isListening ? Icons.mic : Icons.mic_off,
                          color: _isListening ? Colors.red : Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text('Đang lắng nghe: ${_isListening ? "Có" : "Không"}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isInitialized ? _toggleListening : null,
                    icon: Icon(_isListening ? Icons.stop : Icons.mic),
                    label: Text(_isListening ? 'Dừng' : 'Bắt đầu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isInitialized ? () => _speechService.speakInstructions() : null,
                  icon: Icon(Icons.help),
                  label: Text('Hướng dẫn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Last Command/Error
            if (_lastCommand.isNotEmpty || _lastError.isNotEmpty)
              Card(
                color: _lastError.isNotEmpty ? Colors.red.shade50 : Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lastError.isNotEmpty ? 'Lỗi gần nhất:' : 'Lệnh gần nhất:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _lastError.isNotEmpty ? Colors.red : Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _lastError.isNotEmpty ? _lastError : _lastCommand,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),

            // Test Commands
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Commands',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Tăng số lượng',
                        'Giảm số lượng',
                        'Thêm vào giỏ',
                        'Mua ngay',
                        'Đọc thông tin',
                        'Đọc giá',
                        'Hướng dẫn',
                      ].map((command) => ElevatedButton(
                        onPressed: () => _testCommand(command),
                        child: Text(command),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Command History
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch sử lệnh',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: _commandHistory.isEmpty
                            ? Center(
                                child: Text(
                                  'Chưa có lệnh nào',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _commandHistory.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      _commandHistory[index],
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
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
