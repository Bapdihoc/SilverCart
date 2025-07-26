import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';

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
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        fullName: _fullNameController.text.trim(),
        gender: 'string',
        address: {
          'streetAddress': 'string',
          'wardCode': '510101',
          'districtId': 1566,
          'toDistrictName': 'string',
          'toProvinceName': 'string',
        },
        isGuardian: true,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/login/family');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thất bại: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Đăng ký tài khoản',
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

                  // Logo
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: ResponsiveHelper.getIconSize(context, 80),
                          height: ResponsiveHelper.getIconSize(context, 80),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getIconSize(context, 40),
                            ),
                          ),
                          child: Icon(
                            Icons.family_restroom,
                            size: ResponsiveHelper.getIconSize(context, 40),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                        Text(
                          'Đăng ký tài khoản',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Người thân quản lý',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                  // Full Name Field
                  TextFormField(
                    controller: _fullNameController,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                    ),
                    decoration: ResponsiveHelper.responsiveInputDecoration(
                      context: context,
                      labelText: 'Họ và tên',
                      hintText: 'Nhập họ và tên đầy đủ',
                      prefixIcon: Icon(
                        Icons.person_outlined,
                        size: ResponsiveHelper.getIconSize(context, 20),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
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
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                    ),
                    decoration: ResponsiveHelper.responsiveInputDecoration(
                      context: context,
                      labelText: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        size: ResponsiveHelper.getIconSize(context, 20),
                      ),
                    ),
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
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                    ),
                    decoration: ResponsiveHelper.responsiveInputDecoration(
                      context: context,
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu (ít nhất 6 ký tự)',
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        size: ResponsiveHelper.getIconSize(context, 20),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          size: ResponsiveHelper.getIconSize(context, 20),
                        ),
                        onPressed: _togglePasswordVisibility,
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

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                    ),
                    decoration: ResponsiveHelper.responsiveInputDecoration(
                      context: context,
                      labelText: 'Xác nhận mật khẩu',
                      hintText: 'Nhập lại mật khẩu',
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        size: ResponsiveHelper.getIconSize(context, 20),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          size: ResponsiveHelper.getIconSize(context, 20),
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                    ),
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

                  SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                  // Register Button
                  ResponsiveHelper.responsiveButton(
                    context: context,
                    onPressed: _isLoading ? null : _handleRegister,
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
                            'Đăng ký',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),

                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/login/family');
                        },
                        child: Text(
                          'Đăng nhập',
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