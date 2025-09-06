import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../network/service/auth_service.dart';

class ElderlyLoginPage extends StatefulWidget {
  const ElderlyLoginPage({super.key});

  @override
  State<ElderlyLoginPage> createState() => _ElderlyLoginPageState();
}

class _ElderlyLoginPageState extends State<ElderlyLoginPage> {
  bool _isScanning = false;
  bool _isLoading = false;
  bool _showTokenInput = false;
  bool _showQRScanner = false;
  final TextEditingController _tokenController = TextEditingController();
  MobileScannerController? _scannerController;
  final AuthService _authService = GetIt.instance<AuthService>();

  @override
  void dispose() {
    _tokenController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _startQRScan() async {
    // Request camera permission first
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần cấp quyền camera để quét mã QR'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _showQRScanner = true;
      _isScanning = true;
    });
    
    // Initialize the scanner controller
    _scannerController = MobileScannerController();
  }

  void _stopQRScan() {
    setState(() {
      _showQRScanner = false;
      _isScanning = false;
    });
    _scannerController?.dispose();
    _scannerController = null;
  }

  void _onQRDetect(BarcodeCapture barcodeCapture) {
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty && !_isLoading) {
      final code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        // Stop scanning and validate the token
        _validateTokenAndLogin(code);
      }
    }
  }

  Future<void> _validateTokenAndLogin(String token) async {
    setState(() {
      _isLoading = true;
      _isScanning = false;
    });

    try {
      // Get Firebase device ID
      final deviceId = await _getFirebaseDeviceId();
      
      // Call QR Login API with token and deviceId as query parameters
      final result = await _authService.qrLogin(token, deviceId);
      
      if (result.isSuccess) {
        // Token is valid, navigate to home
        if (mounted) {
          _stopQRScan();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/home?role=elderly');
        }
      } else {
        // Token is invalid
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Token không hợp lệ'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() {
            _isLoading = false;
            _isScanning = true; // Continue scanning
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xác thực token: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isLoading = false;
          _isScanning = true; // Continue scanning
        });
      }
    }
  }

  Future<void> _loginWithToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã token'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await _validateTokenAndLogin(token);
  }

  void _toggleTokenInput() {
    setState(() {
      _showTokenInput = !_showTokenInput;
      if (!_showTokenInput) {
        _tokenController.clear();
      }
    });
  }

  Future<String> _getFirebaseDeviceId() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      return token ?? '';
    } catch (e) {
      // Fallback to empty string if Firebase token fails
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () {
            if (_showQRScanner) {
              _stopQRScan();
            } else {
              context.go('/role-selection');
            }
          },
        ),
        title: Text(
          _showQRScanner ? 'Quét mã QR' : 'Đăng nhập',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            color: AppColors.text,
          ),
        ),
        actions: _showQRScanner ? [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.text),
            onPressed: _stopQRScan,
          ),
        ] : null,
      ),
      body: SafeArea(
        child: _showQRScanner ? _buildQRScanner() : ResponsiveHelper.responsiveContainer(
          context: context,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/elder2.jpg',
                        width: ResponsiveHelper.getIconSize(context, 200),
                        height: ResponsiveHelper.getIconSize(context, 200),
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context)),
                      
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Main Login Options
                ResponsiveHelper.responsiveCard(
                  context: context,
                  child: Column(
                    children: [
                      // QR Scan Option
                      if (!_showTokenInput) ...[
                        Icon(
                          Icons.qr_code_scanner,
                          size: ResponsiveHelper.getIconSize(context, 60),
                          color: _isScanning ? AppColors.secondary : AppColors.grey,
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          _isScanning ? 'Đang quét mã QR...' : 'Quét mã QR',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isScanning ? AppColors.secondary : AppColors.text,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        if (_isLoading)
                          Column(
                            children: [
                              SizedBox(
                                width: ResponsiveHelper.getIconSize(context, 20),
                                height: ResponsiveHelper.getIconSize(context, 20),
                                child: const CircularProgressIndicator(
                                  color: AppColors.secondary,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getSpacing(context)),
                              Text(
                                'Đang xác thực...',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          )
                        else
                          ResponsiveHelper.responsiveButton(
                            context: context,
                            onPressed: _isScanning ? _stopQRScan : _startQRScan,
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isScanning ? Icons.stop : Icons.qr_code_scanner,
                                  size: ResponsiveHelper.getIconSize(context, 18),
                                ),
                                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                                Text(
                                  _isScanning ? 'Dừng quét' : 'Bắt đầu quét',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],

                      // Token Input Option
                      if (_showTokenInput) ...[
                        Icon(
                          Icons.key,
                          size: ResponsiveHelper.getIconSize(context, 60),
                          color: AppColors.primary,
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Nhập mã token',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        TextField(
                          controller: _tokenController,
                          decoration: InputDecoration(
                            hintText: 'Nhập mã token từ người thân',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getBorderRadius(context),
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getSpacing(context),
                              vertical: ResponsiveHelper.getSpacing(context),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        if (_isLoading)
                          Column(
                            children: [
                              SizedBox(
                                width: ResponsiveHelper.getIconSize(context, 20),
                                height: ResponsiveHelper.getIconSize(context, 20),
                                child: const CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getSpacing(context)),
                              Text(
                                'Đang xác thực...',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          )
                        else
                          ResponsiveHelper.responsiveButton(
                            context: context,
                            onPressed: _loginWithToken,
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login,
                                  size: ResponsiveHelper.getIconSize(context, 18),
                                ),
                                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                                Text(
                                  'Đăng nhập',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],

                      SizedBox(height: ResponsiveHelper.getSpacing(context)),

                      // Toggle Button
                      TextButton(
                        onPressed: _toggleTokenInput,
                        child: Text(
                          _showTokenInput ? 'Quay lại quét QR' : 'Nhập token thay thế',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Compact Instructions
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: ResponsiveHelper.getIconSize(context, 18),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Hướng dẫn',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context)),
                      Text(
                        '• Quét mã QR từ người thân\n'
                        '• Hoặc nhập mã token được cung cấp\n',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRScanner() {
    return Column(
      children: [
        // Loading indicator and instructions
        if (_isLoading)
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            color: Colors.black87,
            child: Column(
              children: [
                SizedBox(
                  width: ResponsiveHelper.getIconSize(context, 24),
                  height: ResponsiveHelper.getIconSize(context, 24),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Đang xác thực token...',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        
        // QR Scanner
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _onQRDetect,
              ),
              // Custom overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Instructions
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          color: Colors.black87,
          child: Column(
            children: [
              Text(
                _isLoading ? 'Đang xác thực token...' : 'Đặt mã QR vào khung để quét',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
              Text(
                'Mã QR sẽ được tự động xác thực sau khi quét thành công',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 