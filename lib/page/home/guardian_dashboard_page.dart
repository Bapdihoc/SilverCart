import 'package:flutter/material.dart';
import 'package:silvercart/page/elderly_management/elderly_list_page.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../shopping/product_catalog_page.dart';
import '../budget/budget_overview_page.dart';

class GuardianDashboardPage extends StatefulWidget {
  const GuardianDashboardPage({super.key});

  @override
  State<GuardianDashboardPage> createState() => _GuardianDashboardPageState();
}

class _GuardianDashboardPageState extends State<GuardianDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildQuickStats(),
              _buildQuickActions(),
              _buildRecentActivities(),
              _buildUpcomingReminders(),
              SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Row(
        children: [
          // Avatar tròn với gradient
          Container(
            width: ResponsiveHelper.getIconSize(context, 50),
            height: ResponsiveHelper.getIconSize(context, 50),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 25)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: ResponsiveHelper.getIconSize(context, 25),
              color: Colors.white,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào! 👋',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  'Chào mừng bạn trở lại',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Notification icon tròn với animation
          Container(
            width: ResponsiveHelper.getIconSize(context, 50),
            height: ResponsiveHelper.getIconSize(context, 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    size: ResponsiveHelper.getIconSize(context, 24),
                    color: AppColors.primary,
                  ),
                ),
                // Notification badge
                Positioned(
                  top: ResponsiveHelper.getSpacing(context),
                  right: ResponsiveHelper.getSpacing(context),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Thống kê nhanh',
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
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.people_rounded,
                  title: 'Người thân',
                  value: '3',
                  color: AppColors.primary,
                  gradient: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_)=> ElderlyListPage()));
                  },
                ),
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.shopping_cart_rounded,
                  title: 'Đơn hàng',
                  value: '12',
                  color: AppColors.secondary,
                  gradient: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.pending_actions_rounded,
                  title: 'Chờ xử lý',
                  value: '2',
                  color: AppColors.warning,
                  gradient: [AppColors.warning, AppColors.warning.withOpacity(0.7)],
                ),
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              Expanded(
                child: _buildModernStatCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Hoàn thành',
                  value: '10',
                  color: AppColors.success,
                  gradient: [AppColors.success, AppColors.success.withOpacity(0.7)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required List<Color> gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon tròn với background
            Container(
              width: ResponsiveHelper.getIconSize(context, 50),
              height: ResponsiveHelper.getIconSize(context, 50),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 25)),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, 28),
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              value,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Thao tác nhanh',
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
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
            mainAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
            childAspectRatio: 1.1,
            children: [
              _buildModernActionCard(
                icon: Icons.person_add_rounded,
                title: 'Thêm người thân',
                subtitle: '',
                color: AppColors.primary,
                onTap: () {
                  // TODO: Add family member
                },
              ),
              _buildModernActionCard(
                icon: Icons.qr_code_rounded,
                title: 'Tạo mã QR',
                subtitle: 'Cho đăng nhập',
                color: AppColors.secondary,
                onTap: () {
                  // TODO: Generate QR code
                },
              ),
              _buildModernActionCard(
                icon: Icons.shopping_bag_rounded,
                title: 'Đặt hàng',
                subtitle: 'Mua sắm ngay',
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductGuardianPage(),
                    ),
                  );
                },
              ),
              _buildModernActionCard(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Ngân sách',
                subtitle: 'Quản lý chi tiêu',
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetOverviewPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon tròn với gradient
            Container(
              width: ResponsiveHelper.getIconSize(context, 60),
              height: ResponsiveHelper.getIconSize(context, 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 30)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, 30),
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.warning],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Hoạt động gần đây',
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
          _buildModernActivityCard(
            icon: Icons.shopping_cart_rounded,
            title: 'Đơn hàng mới',
            subtitle: 'Bà Nguyễn Thị A đã đặt hàng',
            time: '5 phút trước',
            color: AppColors.primary,
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          _buildModernActivityCard(
            icon: Icons.local_shipping_rounded,
            title: 'Đơn hàng đang giao',
            subtitle: 'Đơn hàng DH001 đang được giao',
            time: '30 phút trước',
            color: AppColors.warning,
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          _buildModernActivityCard(
            icon: Icons.check_circle_rounded,
            title: 'Đơn hàng hoàn thành',
            subtitle: 'Đơn hàng DH002 đã giao thành công',
            time: '2 giờ trước',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildModernActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
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
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon tròn với background
          Container(
            width: ResponsiveHelper.getIconSize(context, 50),
            height: ResponsiveHelper.getIconSize(context, 50),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 25)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: ResponsiveHelper.getIconSize(context, 24),
              color: Colors.white,
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
                    baseSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getSpacing(context),
              vertical: ResponsiveHelper.getSpacing(context) / 2,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              time,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReminders() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning, AppColors.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Nhắc nhở sắp tới',
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
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withOpacity(0.1),
                  AppColors.warning.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon tròn với background
                Container(
                  width: ResponsiveHelper.getIconSize(context, 50),
                  height: ResponsiveHelper.getIconSize(context, 50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning,
                        AppColors.warning.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 25)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: ResponsiveHelper.getIconSize(context, 24),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thuốc sắp hết',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Thuốc cảm của bà A sắp hết, cần mua thêm',
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
                  size: ResponsiveHelper.getIconSize(context, 16),
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 