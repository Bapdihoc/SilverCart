import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  
  const OtpVerificationPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  int _countdown = 60;
  bool _canResend = false;
  bool _isLoading = false;
  Timer? _timer;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    _checkOtpComplete();
  }

  void _checkOtpComplete() {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      _verifyOtp(otp);
    }
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the actual verify OTP API
      final result = await _authService.verifyOTP(otp);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getIconSize(context, 24),
                    height: ResponsiveHelper.getIconSize(context, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: ResponsiveHelper.getIconSize(context, 16),
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  const Text('Xác thực thành công!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            ),
          );
          
          // Navigate to success page or home
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getIconSize(context, 24),
                    height: ResponsiveHelper.getIconSize(context, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.error_rounded,
                      size: ResponsiveHelper.getIconSize(context, 16),
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(result.message ?? 'Mã OTP không đúng'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the actual sendOTP API
      final result = await _authService.sendOTP(widget.email);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.isSuccess) {
          // Clear OTP fields
          for (var controller in _otpControllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getIconSize(context, 24),
                    height: ResponsiveHelper.getIconSize(context, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.email_rounded,
                      size: ResponsiveHelper.getIconSize(context, 16),
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  const Text('Đã gửi lại mã OTP'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            ),
          );

          _startCountdown();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể gửi lại OTP'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: ResponsiveHelper.getIconSize(context, 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Xác thực OTP',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

              // Header Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xác thực email',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    Text(
                      'Nhập mã 6 số đã gửi đến email của bạn',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 16,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Email Info Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: ResponsiveHelper.getIconSize(context, 40),
                          height: ResponsiveHelper.getIconSize(context, 40),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
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
                                'Đã gửi mã OTP',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              Text(
                                'Mã xác thực đã được gửi đến:',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                      decoration: BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Text(
                        widget.email,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

              // OTP Input Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: ResponsiveHelper.getIconSize(context, 40),
                          height: ResponsiveHelper.getIconSize(context, 40),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.security_rounded,
                            size: ResponsiveHelper.getIconSize(context, 20),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Nhập mã OTP',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                    
                    // OTP Input Fields
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              height: ResponsiveHelper.getIconSize(context, 60),
                              decoration: BoxDecoration(
                                color: Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _focusNodes[index].hasFocus 
                                      ? AppColors.primary 
                                      : Colors.grey.withOpacity(0.3),
                                  width: _focusNodes[index].hasFocus ? 2 : 1,
                                ),
                              ),
                              child: TextFormField(
                                controller: _otpControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) => _onOtpChanged(value, index),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

              // Resend Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                child: Center(
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: ResponsiveHelper.getIconSize(context, 20),
                              height: ResponsiveHelper.getIconSize(context, 20),
                              child: const CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: ResponsiveHelper.getSpacing(context)),
                            Text(
                              'Đang gửi lại...',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: _canResend ? _resendOtp : null,
                          child: Text(
                            _canResend 
                                ? 'Gửi lại mã OTP'
                                : 'Gửi lại sau $_countdown giây',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: _canResend ? FontWeight.w600 : FontWeight.w400,
                              color: _canResend ? AppColors.primary : AppColors.grey,
                            ),
                          ),
                        ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
            ],
          ),
        ),
      ),
    );
  }
} 