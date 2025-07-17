import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getIconSize(context, 60),
                          ),
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          size: ResponsiveHelper.getIconSize(context, 60),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                      Text(
                        'SilverCart',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context)),
                      Text(
                        'Chọn loại tài khoản đăng nhập',
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

                // Family Member Login Card
                ResponsiveHelper.responsiveCard(
                  context: context,
                  child: InkWell(
                    onTap: () => context.go('/login/family'),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                      child: Column(
                        children: [
                          Container(
                            width: ResponsiveHelper.getIconSize(context, 80),
                            height: ResponsiveHelper.getIconSize(context, 80),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getIconSize(context, 40),
                              ),
                            ),
                            child: Icon(
                              Icons.family_restroom,
                              size: ResponsiveHelper.getIconSize(context, 40),
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                          Text(
                            'Người thân',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Quản lý mua sắm cho người thân',
                            textAlign: TextAlign.center,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: AppColors.grey,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone, 
                                size: ResponsiveHelper.getIconSize(context, 16), 
                                color: AppColors.grey
                              ),
                              SizedBox(width: ResponsiveHelper.getSpacing(context)),
                              Text(
                                'Số điện thoại + Mật khẩu',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Elderly Login Card
                ResponsiveHelper.responsiveCard(
                  context: context,
                  child: InkWell(
                    onTap: () => context.go('/login/elderly'),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                      child: Column(
                        children: [
                          Container(
                            width: ResponsiveHelper.getIconSize(context, 80),
                            height: ResponsiveHelper.getIconSize(context, 80),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getIconSize(context, 40),
                              ),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              size: ResponsiveHelper.getIconSize(context, 40),
                              color: AppColors.secondary,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                          Text(
                            'Người cao tuổi',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Mua sắm trực tiếp',
                            textAlign: TextAlign.center,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: AppColors.grey,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code, 
                                size: ResponsiveHelper.getIconSize(context, 16), 
                                color: AppColors.grey
                              ),
                              SizedBox(width: ResponsiveHelper.getSpacing(context)),
                              Text(
                                'Quét mã QR',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

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
    );
  }
} 