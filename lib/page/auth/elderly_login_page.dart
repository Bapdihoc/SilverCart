import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class ElderlyLoginPage extends StatefulWidget {
  const ElderlyLoginPage({super.key});

  @override
  State<ElderlyLoginPage> createState() => _ElderlyLoginPageState();
}

class _ElderlyLoginPageState extends State<ElderlyLoginPage> {
  bool _isScanning = false;
  bool _isLoading = false;

  Future<void> _startQRScan() async {
    setState(() {
      _isScanning = true;
    });

    // Simulate QR scanning
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    // Simulate authentication
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Navigate to elderly home page with role parameter
    if (mounted) {
      context.go('/home?role=elderly');
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
          onPressed: () => context.go('/role-selection'),
        ),
        title: Text(
          'Đăng nhập',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            color: AppColors.text,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveHelper.responsiveContainer(
          context: context,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: ResponsiveHelper.getIconSize(context, 120),
                        height: ResponsiveHelper.getIconSize(context, 120),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getIconSize(context, 60),
                          ),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: ResponsiveHelper.getIconSize(context, 60),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                      Text(
                        'Đăng nhập',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context)),
                      Text(
                        'Người cao tuổi',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                // QR Scanner Area
                ResponsiveHelper.responsiveCard(
                  context: context,
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: ResponsiveHelper.getIconSize(context, 80),
                        color: _isScanning ? AppColors.secondary : AppColors.grey,
                      ),
                      SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                      Text(
                        _isScanning ? 'Đang quét mã QR...' : 'Quét mã QR để đăng nhập',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _isScanning ? AppColors.secondary : AppColors.text,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                      Text(
                        _isScanning 
                            ? 'Vui lòng đặt mã QR vào khung hình'
                            : 'Nhấn nút bên dưới để bắt đầu quét mã QR từ thiết bị của người thân',
                        textAlign: TextAlign.center,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
                      
                      if (_isLoading)
                        Column(
                          children: [
                            SizedBox(
                              width: ResponsiveHelper.getIconSize(context, 24),
                              height: ResponsiveHelper.getIconSize(context, 24),
                              child: const CircularProgressIndicator(
                                color: AppColors.secondary,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                            Text(
                              'Đang xác thực...',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        )
                      else
                        ResponsiveHelper.responsiveButton(
                          context: context,
                          onPressed: _isScanning ? null : _startQRScan,
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isScanning ? Icons.stop : Icons.qr_code_scanner,
                                size: ResponsiveHelper.getIconSize(context, 20),
                              ),
                              SizedBox(width: ResponsiveHelper.getSpacing(context)),
                              Text(
                                _isScanning ? 'Dừng quét' : 'Bắt đầu quét',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                // Instructions
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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
                            size: ResponsiveHelper.getIconSize(context, 20),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Hướng dẫn sử dụng',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context)),
                      Text(
                        '• Yêu cầu người thân tạo mã QR từ ứng dụng\n'
                        '• Đặt mã QR vào khung hình khi quét\n'
                        '• Mã QR sẽ tự động hết hạn sau 5 phút\n'
                        '• Chỉ sử dụng mã QR từ người thân đáng tin cậy',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Alternative login option
                TextButton(
                  onPressed: () {
                    // TODO: Show alternative login options (if any)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Liên hệ người thân để được hỗ trợ đăng nhập'),
                        backgroundColor: AppColors.warning,
                      ),
                    );
                  },
                  child: Text(
                    'Cần hỗ trợ?',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 