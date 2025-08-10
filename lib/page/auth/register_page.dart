import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';
import 'otp_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the actual registration API
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        fullName: _fullNameController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Send OTP after successful registration
        final otpResult = await _authService.sendOTP(_emailController.text.trim());
        if (!otpResult.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(otpResult.message ?? 'Không thể gửi OTP'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        
        // Navigate to OTP verification page
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: _emailController.text.trim(),
            ),
          ),
        );

        // If OTP verification successful, show success message
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/login/family');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Extract error message
      String errorMessage = 'Đăng ký thất bại';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().split('Exception: ').last;
      } else {
        errorMessage = e.toString();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
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
            onPressed: () => context.pop(),
          ),
        ),
        title: Text(
          'Đăng ký',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Form Section
                Container(
                  margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                    child: Column(
                      children: [
                        // Full Name Field
                        _buildModernTextField(
                          controller: _fullNameController,
                          label: 'Họ và tên',
                          hint: 'Nhập họ và tên đầy đủ',
                          icon: Icons.person_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập họ và tên';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                        // Email Field
                        _buildModernTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Nhập email của bạn',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                        // Phone Field
                        _buildModernTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          hint: 'Nhập số điện thoại',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                        // Password Field
                        _buildModernPasswordField(
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          hint: 'Nhập mật khẩu (ít nhất 6 ký tự)',
                          isVisible: _isPasswordVisible,
                          onToggle: _togglePasswordVisibility,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                        // Confirm Password Field
                        _buildModernPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Xác nhận mật khẩu',
                          hint: 'Nhập lại mật khẩu',
                          isVisible: _isConfirmPasswordVisible,
                          onToggle: _toggleConfirmPasswordVisibility,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng xác nhận mật khẩu';
                            }
                            if (value != _passwordController.text) {
                              return 'Mật khẩu không khớp';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Register Button
                Container(
                  margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: ResponsiveHelper.getIconSize(context, 24),
                            height: ResponsiveHelper.getIconSize(context, 24),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_rounded,
                                size: ResponsiveHelper.getIconSize(context, 24),
                              ),
                              SizedBox(width: ResponsiveHelper.getSpacing(context)),
                              Text(
                                'Đăng ký tài khoản',
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
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Login Link
                Container(
                  margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                  padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          color: AppColors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/login/family');
                        },
                        child: Text(
                          'Đăng nhập ngay',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 32),
              height: ResponsiveHelper.getIconSize(context, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: Colors.white,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text(
              label,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: Color(0xFFF8F9FA),
            contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildModernPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 32),
              height: ResponsiveHelper.getIconSize(context, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lock_rounded,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: Colors.white,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text(
              label,
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
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: Color(0xFFF8F9FA),
            contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            suffixIcon: Container(
              margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.grey,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
} 