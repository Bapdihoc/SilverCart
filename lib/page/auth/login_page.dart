import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(
    text: 'silvercart@gmail.com',
  );
  final _passwordController = TextEditingController(text: '123456');
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.isSuccess && result.data != null) {
          // Login thành công
          final loginData = result.data!;

          // Token và user data đã được lưu tự động trong AuthService

          // Call API getMe to get userId
          try {
            final meResult = await _authService.getMe();
            if (meResult.isSuccess && meResult.data != null) {
              final userMe = meResult.data!;
              
              // Save userId to SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userId', userMe.userId);
              await prefs.setString('userName', userMe.userName);
              await prefs.setString('userRole', userMe.role);
              
              print('✅ User info saved: userId=${userMe.userId}, userName=${userMe.userName}, role=${userMe.role}');
            }
          } catch (e) {
            print('⚠️ Error getting user info: ${e.toString()}');
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginData.message),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate based on role
          final role = loginData.getRole()?.toLowerCase() ?? '';
          if (role == 'family' || role == 'guardian') {
            context.go('/home?role=family');
          } else if (role == 'elderly') {
            context.go('/home?role=elderly');
          } else {
            context.go('/home');
          }
        } else {
          // Login thất bại
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Đăng nhập thất bại'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
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
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context) * 0.5),
                  
                  // Modern Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
                        onPressed: () => context.go('/role-selection'),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                  // Modern Logo and Title Section
                  Center(
                    child: Column(
                      children: [
                        // Modern Logo Container
                        Container(
                          width: ResponsiveHelper.getIconSize(context, 100),
                          height: ResponsiveHelper.getIconSize(context, 100),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/volunteer.png',
                            width: ResponsiveHelper.getIconSize(context, 50),
                            height: ResponsiveHelper.getIconSize(context, 50),
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                        
                        // Title
                        Text(
                          'Đăng nhập',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        
                        // Subtitle
                        Text(
                          'Người thân quản lý',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                  // Modern Form Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                      child: Column(
                        children: [
                          // Email Field
                          _buildModernTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Nhập email của bạn',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              if (!RegExp(
                                r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                          // Password Field
                          _buildModernTextField(
                            controller: _passwordController,
                            label: 'Mật khẩu',
                            hint: 'Nhập mật khẩu của bạn',
                            icon: Icons.lock_outlined,
                            obscureText: !_isPasswordVisible,
                            enabled: !_isLoading,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                size: ResponsiveHelper.getIconSize(context, 20),
                                color: AppColors.grey,
                              ),
                              onPressed: _isLoading ? null : _togglePasswordVisibility,
                            ),
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

                          SizedBox(height: ResponsiveHelper.getSpacing(context)),

                          // Forgot Password
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     onPressed: () {
                          //       // TODO: Navigate to forgot password page
                          //     },
                          //     child: Text(
                          //       'Quên mật khẩu?',
                          //       style: ResponsiveHelper.responsiveTextStyle(
                          //         context: context,
                          //         baseSize: 14,
                          //         color: AppColors.primary,
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                          // Modern Login Button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveHelper.getLargeSpacing(context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Đăng nhập',
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Modern Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.grey.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getLargeSpacing(context),
                        ),
                        child: Text(
                          'hoặc',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.grey.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Modern Register Link
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.text,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getSpacing(context),
                              vertical: ResponsiveHelper.getSpacing(context) / 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Đăng ký ngay',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    bool enabled = true,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: enabled,
            validator: validator,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context)),
                child: Icon(
                  icon,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
