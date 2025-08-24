import 'package:flutter/material.dart';
import 'package:silvercart/network/service/speech_service.dart';
import 'package:silvercart/injection.dart';

class SpeechTestPopup extends StatefulWidget {
  const SpeechTestPopup({super.key});

  @override
  State<SpeechTestPopup> createState() => _SpeechTestPopupState();
}

class _SpeechTestPopupState extends State<SpeechTestPopup> {
  final SpeechService _speechService = getIt<SpeechService>();
  
  bool _isListening = false;
  String _currentText = '';
  String _finalText = '';
  List<String> _detectedCommands = [];

  @override
  void dispose() {
    if (_isListening) {
      _speechService.stopListening();
    }
    super.dispose();
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
      _currentText = '🎤 Đang lắng nghe...';
      _finalText = '';
    });

    await _speechService.startListening(
      onResult: (transcript) {
        setState(() {
          _finalText = transcript;
          _detectedCommands.add(transcript);
          _currentText = '';
        });
      },
      onError: (error) {
        setState(() {
          _currentText = '❌ Lỗi: $error';
          _isListening = false;
        });
      },
      onListeningComplete: () {
        setState(() {
          _isListening = false;
          if (_currentText == '🎤 Đang lắng nghe...') {
            _currentText = '✅ Hoàn thành lắng nghe';
          }
        });
      },
    );
  }

  void _stopListening() {
    _speechService.stopListening();
    setState(() {
      _isListening = false;
      _currentText = '🛑 Đã dừng lắng nghe';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '🎤 Test Nhận Diện Giọng Nói',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Current status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isListening ? Colors.red[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isListening ? Colors.red : Colors.grey,
                  width: 2,
                ),
              ),
              child: Text(
                _currentText.isEmpty ? 'Nhấn nút để bắt đầu lắng nghe' : _currentText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isListening ? Colors.red[800] : Colors.grey[700],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Final detected text
            if (_finalText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎯 Đã nhận diện:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _finalText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
              ),
            
            if (_finalText.isNotEmpty) const SizedBox(height: 20),
            
            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isListening ? _stopListening : _startListening,
                    icon: Icon(_isListening ? Icons.stop : Icons.play_arrow),
                    label: Text(_isListening ? 'Dừng' : 'Bắt đầu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // History of detected commands
            if (_detectedCommands.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Lịch sử nhận diện:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_detectedCommands.reversed.take(5).map((cmd) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $cmd',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
