import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final _emailController = TextEditingController(text: 'set_your_own_mail_in_db4@gmail.com');
  final _passwordController = TextEditingController(text: 'String@111');
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
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate based on role
          final role = loginData.role.toLowerCase();
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
                  
                  // Logo and Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: ResponsiveHelper.getIconSize(context, 100),
                          height: ResponsiveHelper.getIconSize(context, 100),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getIconSize(context, 50),
                            ),
                          ),
                          child: Icon(
                            Icons.family_restroom,
                            size: ResponsiveHelper.getIconSize(context, 50),
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
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Người thân quản lý',
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

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                    ),
                    decoration: ResponsiveHelper.responsiveInputDecoration(
                      context: context,
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        size: ResponsiveHelper.getIconSize(context, 20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    enabled: !_isLoading,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                    ),
                    decoration: ResponsiveHelper.responsiveInputDecoration(
                      context: context,
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        size: ResponsiveHelper.getIconSize(context, 20),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          size: ResponsiveHelper.getIconSize(context, 20),
                        ),
                        onPressed: _isLoading ? null : _togglePasswordVisibility,
                      ),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password page
                      },
                      child: Text(
                        'Quên mật khẩu?',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                  // Login Button
                  ResponsiveHelper.responsiveButton(
                    context: context,
                    onPressed: _isLoading ? null : _handleLogin,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: _isLoading
                        ? SizedBox(
                            width: ResponsiveHelper.getIconSize(context, 24),
                            height: ResponsiveHelper.getIconSize(context, 24),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Đăng nhập',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getLargeSpacing(context),
                        ),
                        child: Text(
                          'hoặc',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Register Link
                  Row(
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
                      TextButton(
                        onPressed: () {
                          context.go('/register');
                        },
                        child: Text(
                          'Đăng ký ngay',
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

                  SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 