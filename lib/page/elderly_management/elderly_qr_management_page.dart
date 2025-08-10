import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/models/elderly_model.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';

class ElderlyQRManagementPage extends StatefulWidget {
  final Elderly elderly;
  
  const ElderlyQRManagementPage({
    super.key,
    required this.elderly,
  });

  @override
  State<ElderlyQRManagementPage> createState() => _ElderlyQRManagementPageState();
}

class _ElderlyQRManagementPageState extends State<ElderlyQRManagementPage>
    with TickerProviderStateMixin {
  late QRCodeData? _currentQRCode;
  bool _isGenerating = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _selectedExpiryHours = 24; // Default 24 hours
  late final AuthService _authService;

  final List<int> _expiryOptions = [1, 6, 12, 24, 48, 72, 168]; // Hours

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _loadCurrentQRCode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentQRCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load current QR code from API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Mock data for demo
      if (widget.elderly.hasValidQRCode) {
        _currentQRCode = QRCodeData(
          elderlyId: widget.elderly.id,
          code: widget.elderly.currentQRCode!,
          expiresAt: widget.elderly.qrCodeExpiresAt!,
          generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          generatedBy: widget.elderly.managedBy,
        );
      } else {
        _currentQRCode = null;
      }
      
      if (_currentQRCode != null) {
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải QR code: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generateNewQRCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Call API to generate QR code
      final result = await _authService.generateQr(widget.elderly.id);
      
      if (result.isSuccess && result.data != null) {
        // Parse JWT token to get expiration time
        final token = result.data!.data.token;
        final expiresAt = _parseJwtExpiration(token);
        
        _currentQRCode = QRCodeData(
          elderlyId: widget.elderly.id,
          code: token, // Use the JWT token as QR code data
          expiresAt: expiresAt,
          generatedAt: DateTime.now(),
          generatedBy: widget.elderly.managedBy,
        );

        _animationController.reset();
        _animationController.forward();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.data!.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể tạo QR code'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo QR code: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  DateTime _parseJwtExpiration(String token) {
    try {
      // JWT tokens have 3 parts separated by dots
      final parts = token.split('.');
      if (parts.length != 3) {
        return DateTime.now().add(Duration(hours: _selectedExpiryHours));
      }

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed
      final paddedPayload = payload + '=' * (4 - payload.length % 4);
      
      // Decode base64
      final decoded = utf8.decode(base64Url.decode(paddedPayload));
      final payloadMap = json.decode(decoded);
      
      // Get expiration time
      final exp = payloadMap['exp'];
      if (exp != null) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      
      return DateTime.now().add(Duration(hours: _selectedExpiryHours));
    } catch (e) {
      // Fallback to default expiration
      return DateTime.now().add(Duration(hours: _selectedExpiryHours));
    }
  }

  Future<void> _shareQRCode() async {
    if (_currentQRCode == null) return;

    try {
      // Create QR code image
      final qrValidationResult = QrValidator.validate(
        data: _currentQRCode!.code,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: AppColors.text,
          gapless: false,
          embeddedImageStyle: null,
          embeddedImage: null,
        );

        final picData = await painter.toImageData(300);
        final buffer = picData!.buffer.asUint8List();

        await Share.shareXFiles(
          [
            XFile.fromData(
              buffer,
              name: 'qr_code_${widget.elderly.nickname}.png',
              mimeType: 'image/png',
            ),
          ],
          text: 'QR Code cho ${widget.elderly.nickname} - SilverCart\nHạn sử dụng: ${_currentQRCode!.timeRemaining}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chia sẻ QR code: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _copyQRCode() async {
    if (_currentQRCode == null) return;

    await Clipboard.setData(ClipboardData(text: _currentQRCode!.code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép mã QR vào clipboard'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _getExpiryText(int hours) {
    if (hours < 24) {
      return '$hours giờ';
    } else if (hours == 24) {
      return '1 ngày';
    } else if (hours < 168) {
      return '${hours ~/ 24} ngày';
    } else {
      return '1 tuần';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'QR Code - ${widget.elderly.nickname}',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _loadCurrentQRCode,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : ResponsiveHelper.responsiveContainer(
              context: context,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                    // Elderly Info Card
                    ResponsiveHelper.responsiveCard(
                      context: context,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: ResponsiveHelper.getIconSize(context, 30),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: widget.elderly.avatar != null
                                ? NetworkImage(widget.elderly.avatar!)
                                : null,
                            child: widget.elderly.avatar == null
                                ? Icon(
                                    Icons.person,
                                    size: ResponsiveHelper.getIconSize(context, 30),
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.elderly.fullName,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                                Text(
                                  '${widget.elderly.age} tuổi • ${widget.elderly.phone}',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 14,
                                    color: AppColors.grey,
                                  ),
                                ),
                                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveHelper.getSpacing(context),
                                    vertical: ResponsiveHelper.getSpacing(context) / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.elderly.isActive ? AppColors.success : AppColors.grey,
                                    borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                                  ),
                                  child: Text(
                                    widget.elderly.statusText,
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                    if (_currentQRCode != null) ...[
                      // QR Code Display
                      ResponsiveHelper.responsiveCard(
                        context: context,
                        child: Column(
                          children: [
                            Text(
                              'Mã QR đăng nhập',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                            // QR Code with Animation
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.grey.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: _currentQRCode!.code,
                                  version: QrVersions.auto,
                                  size: ResponsiveHelper.getIconSize(context, 200),
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.text,
                                ),
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                            // QR Code Info
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                              decoration: BoxDecoration(
                                color: _currentQRCode!.isExpired 
                                    ? AppColors.error.withOpacity(0.1)
                                    : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                                border: Border.all(
                                  color: _currentQRCode!.isExpired 
                                      ? AppColors.error.withOpacity(0.3)
                                      : AppColors.success.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _currentQRCode!.isExpired ? Icons.error : Icons.check_circle,
                                        color: _currentQRCode!.isExpired ? AppColors.error : AppColors.success,
                                        size: ResponsiveHelper.getIconSize(context, 20),
                                      ),
                                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                                      Text(
                                        _currentQRCode!.isExpired ? 'Đã hết hạn' : 'Còn hiệu lực',
                                        style: ResponsiveHelper.responsiveTextStyle(
                                          context: context,
                                          baseSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _currentQRCode!.isExpired ? AppColors.error : AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Thời gian còn lại:',
                                        style: ResponsiveHelper.responsiveTextStyle(
                                          context: context,
                                          baseSize: 14,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                      Text(
                                        _currentQRCode!.timeRemaining,
                                        style: ResponsiveHelper.responsiveTextStyle(
                                          context: context,
                                          baseSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Được tạo:',
                                        style: ResponsiveHelper.responsiveTextStyle(
                                          context: context,
                                          baseSize: 14,
                                          color: AppColors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${_currentQRCode!.generatedAt.day}/${_currentQRCode!.generatedAt.month}/${_currentQRCode!.generatedAt.year} ${_currentQRCode!.generatedAt.hour}:${_currentQRCode!.generatedAt.minute.toString().padLeft(2, '0')}',
                                        style: ResponsiveHelper.responsiveTextStyle(
                                          context: context,
                                          baseSize: 14,
                                          color: AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _shareQRCode,
                                    icon: Icon(
                                      Icons.share,
                                      size: ResponsiveHelper.getIconSize(context, 18),
                                    ),
                                    label: Text(
                                      'Chia sẻ',
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _copyQRCode,
                                    icon: Icon(
                                      Icons.copy,
                                      size: ResponsiveHelper.getIconSize(context, 18),
                                    ),
                                    label: Text(
                                      'Sao chép',
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.warning,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
                    ],

                    // Generate New QR Section
                    ResponsiveHelper.responsiveCard(
                      context: context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentQRCode == null ? 'Tạo mã QR mới' : 'Tạo lại mã QR',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),

                          SizedBox(height: ResponsiveHelper.getSpacing(context)),

                          Text(
                            _currentQRCode == null 
                                ? 'Tạo mã QR để ${widget.elderly.nickname} có thể đăng nhập vào ứng dụng.'
                                : 'Tạo mã QR mới sẽ vô hiệu hóa mã QR cũ.',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: AppColors.grey,
                            ),
                          ),

                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                          // Expiry Time Selection
                          Text(
                            'Thời gian hiệu lực:',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),

                          SizedBox(height: ResponsiveHelper.getSpacing(context)),

                          Wrap(
                            spacing: ResponsiveHelper.getSpacing(context),
                            runSpacing: ResponsiveHelper.getSpacing(context),
                            children: _expiryOptions.map((hours) {
                              final isSelected = _selectedExpiryHours == hours;
                              return ChoiceChip(
                                label: Text(
                                  _getExpiryText(hours),
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 14,
                                    color: isSelected ? Colors.white : AppColors.text,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedExpiryHours = hours;
                                    });
                                  }
                                },
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.grey.withOpacity(0.1),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                          // Generate Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isGenerating ? null : _generateNewQRCode,
                              icon: _isGenerating
                                  ? SizedBox(
                                      width: ResponsiveHelper.getIconSize(context, 16),
                                      height: ResponsiveHelper.getIconSize(context, 16),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.qr_code_2,
                                      size: ResponsiveHelper.getIconSize(context, 20),
                                    ),
                              label: Text(
                                _isGenerating 
                                    ? 'Đang tạo...' 
                                    : (_currentQRCode == null ? 'Tạo mã QR' : 'Tạo lại mã QR'),
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveHelper.getLargeSpacing(context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                    // Usage Instructions
                    ResponsiveHelper.responsiveCard(
                      context: context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.help_outline,
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
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: ResponsiveHelper.getSpacing(context)),

                          const Divider(),

                          SizedBox(height: ResponsiveHelper.getSpacing(context)),

                          _buildInstructionItem(
                            number: '1',
                            title: 'Tạo mã QR',
                            description: 'Nhấn "Tạo mã QR" để tạo mã đăng nhập cho ${widget.elderly.nickname}',
                          ),

                          SizedBox(height: ResponsiveHelper.getSpacing(context)),

                          _buildInstructionItem(
                            number: '2',
                            title: 'Chia sẻ với người thân',
                            description: 'Chia sẻ hoặc in mã QR để ${widget.elderly.nickname} có thể sử dụng',
                          ),

                          SizedBox(height: ResponsiveHelper.getSpacing(context)),

                          _buildInstructionItem(
                            number: '3',
                            title: 'Quét mã để đăng nhập',
                            description: '${widget.elderly.nickname} mở ứng dụng và quét mã QR để đăng nhập',
                          ),

                          SizedBox(height: ResponsiveHelper.getSpacing(context)),

                          _buildInstructionItem(
                            number: '4',
                            title: 'Theo dõi trạng thái',
                            description: 'Kiểm tra thời gian hiệu lực và tạo mã mới khi cần thiết',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInstructionItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: ResponsiveHelper.getIconSize(context, 24),
          height: ResponsiveHelper.getIconSize(context, 24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveHelper.getSpacing(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
              Text(
                description,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 13,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 