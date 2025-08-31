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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              children: [
                SizedBox(
                  height: ResponsiveHelper.getExtraLargeSpacing(context) * 0.5,
                ),

                // Modern Logo Section
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
                          'assets/logo.png',
                          width: ResponsiveHelper.getIconSize(context, 50),
                          height: ResponsiveHelper.getIconSize(context, 50),
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getLargeSpacing(context),
                      ),

                      // App Title
                      Text(
                        'SilverCart',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      SizedBox(height: ResponsiveHelper.getSpacing(context)),

                      // Subtitle
                      Text(
                        'Chọn loại tài khoản để tiếp tục',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getExtraLargeSpacing(context),
                ),
                GestureDetector(
                  onTap: () => context.go('/login/family'),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      ResponsiveHelper.getLargeSpacing(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 1),
                      // gradient: LinearGradient(
                      //   colors: [
                      //     AppColors.primary,
                      //     AppColors.primary.withOpacity(0.8),
                      //   ],
                      //   begin: Alignment.topLeft,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/volunteer.png',
                            width: ResponsiveHelper.getIconSize(context, 150),
                            height: ResponsiveHelper.getIconSize(context, 150),
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getLargeSpacing(context),
                        ),
                        Text(
                          'Người thân',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: ResponsiveHelper.getExtraLargeSpacing(context),
                ),

                GestureDetector(
                  onTap: () => context.go('/login/elderly'),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      ResponsiveHelper.getLargeSpacing(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 1),
                      // gradient: LinearGradient(
                      //   colors: [
                      //     AppColors.primary,
                      //     AppColors.primary.withOpacity(0.8),
                      //   ],
                      //   begin: Alignment.topLeft,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/elder2.jpg',
                            width: ResponsiveHelper.getIconSize(context, 150),
                            height: ResponsiveHelper.getIconSize(context, 150),
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getLargeSpacing(context),
                        ),
                        Text(
                          'Người cao tuổi',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Family Member Card
                // _buildModernCard(
                //   context: context,
                //   title: 'Người thân',
                //   subtitle: 'Quản lý mua sắm cho người thân',
                //   icon: Icons.family_restroom_rounded,
                //   iconColor: AppColors.primary,
                //   gradientColors: [
                //     AppColors.primary.withOpacity(0.1),
                //     AppColors.primary.withOpacity(0.05),
                //   ],
                //   onTap: () => context.go('/login/family'),
                //   features: [
                //     'Quản lý danh sách người thân',
                //     'Theo dõi chi tiêu',
                //     'Duyệt đơn hàng',
                //   ],
                // ),

                // SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // // Elderly Card
                // _buildModernCard(
                //   context: context,
                //   title: 'Người cao tuổi',
                //   subtitle: 'Mua sắm trực tiếp',
                //   icon: Icons.qr_code_scanner_rounded,
                //   iconColor: AppColors.secondary,
                //   gradientColors: [
                //     AppColors.secondary.withOpacity(0.1),
                //     AppColors.secondary.withOpacity(0.05),
                //   ],
                //   onTap: () => context.go('/login/elderly'),
                //   features: [
                //     'Quét mã QR để đăng nhập',
                //     'Mua sắm trực tiếp',
                //     'Xem lịch sử đơn hàng',
                //   ],
                // ),

                SizedBox(
                  height: ResponsiveHelper.getExtraLargeSpacing(context),
                ),

                // Modern Register Link
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getLargeSpacing(context),
                  ),
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

                SizedBox(
                  height: ResponsiveHelper.getExtraLargeSpacing(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required List<String> features,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Icon and Title
              Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getIconSize(context, 60),
                    height: ResponsiveHelper.getIconSize(context, 60),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: ResponsiveHelper.getIconSize(context, 30),
                      color: iconColor,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getSpacing(context) / 2,
                        ),
                        Text(
                          subtitle,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: ResponsiveHelper.getIconSize(context, 20),
                    color: AppColors.grey,
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

              // Features List
              ...features
                  .map(
                    (feature) => Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveHelper.getSpacing(context),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          Expanded(
                            child: Text(
                              feature,
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 14,
                                color: AppColors.text.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
