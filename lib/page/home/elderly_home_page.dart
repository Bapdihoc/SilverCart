import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class ElderlyHomePage extends StatefulWidget {
  const ElderlyHomePage({super.key});

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        elevation: 0,
        title: Text(
          'SilverCart',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              size: ResponsiveHelper.getIconSize(context, 24),
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person_outline,
              size: ResponsiveHelper.getIconSize(context, 24),
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Show profile
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildShoppingPage(),
          _buildOrdersPage(),
          _buildHelpPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 14,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Mua sắm',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.help_outline,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Trợ giúp',
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingPage() {
    return ResponsiveHelper.responsiveContainer(
      context: context,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

            // Welcome Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào!',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Bạn muốn mua gì hôm nay?',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

            // Quick Actions
            Text(
              'Thao tác nhanh',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),

            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

            // Quick Action Buttons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
              crossAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
              mainAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  icon: Icons.shopping_basket,
                  title: 'Thực phẩm',
                  color: AppColors.primary,
                  onTap: () {
                    // TODO: Navigate to food category
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.medication,
                  title: 'Thuốc',
                  color: AppColors.secondary,
                  onTap: () {
                    // TODO: Navigate to medicine category
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.local_grocery_store,
                  title: 'Gia dụng',
                  color: AppColors.success,
                  onTap: () {
                    // TODO: Navigate to household category
                  },
                ),
                _buildQuickActionCard(
                  icon: Icons.favorite,
                  title: 'Yêu thích',
                  color: AppColors.error,
                  onTap: () {
                    // TODO: Navigate to favorites
                  },
                ),
              ],
            ),

            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

            // Recent Orders
            Text(
              'Đơn hàng gần đây',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),

            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

            // Recent Orders List
            _buildRecentOrderCard(
              orderNumber: 'DH001',
              date: 'Hôm nay',
              status: 'Đang giao',
              items: ['Gạo, Rau cải, Thịt heo'],
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            _buildRecentOrderCard(
              orderNumber: 'DH002',
              date: 'Hôm qua',
              status: 'Hoàn thành',
              items: ['Thuốc cảm, Nước muối'],
            ),

            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 60),
              height: ResponsiveHelper.getIconSize(context, 60),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 30)),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, 30),
                color: color,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard({
    required String orderNumber,
    required String date,
    required String status,
    required List<String> items,
  }) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng $orderNumber',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: status == 'Đang giao' ? AppColors.warning : AppColors.success,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                ),
                child: Text(
                  status,
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
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            date,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            items.join(', '),
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersPage() {
    return ResponsiveHelper.responsiveContainer(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          Text(
            'Đơn hàng của tôi',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

          Expanded(
            child: ListView(
              children: [
                _buildOrderCard(
                  orderNumber: 'DH001',
                  date: 'Hôm nay, 14:30',
                  status: 'Đang giao',
                  total: '150.000đ',
                  items: ['Gạo 5kg', 'Rau cải 1kg', 'Thịt heo 500g'],
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildOrderCard(
                  orderNumber: 'DH002',
                  date: 'Hôm qua, 09:15',
                  status: 'Hoàn thành',
                  total: '85.000đ',
                  items: ['Thuốc cảm', 'Nước muối sinh lý'],
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildOrderCard(
                  orderNumber: 'DH003',
                  date: '2 ngày trước',
                  status: 'Hoàn thành',
                  total: '200.000đ',
                  items: ['Dầu ăn', 'Nước mắm', 'Bột giặt'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required String orderNumber,
    required String date,
    required String status,
    required String total,
    required List<String> items,
  }) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng $orderNumber',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: status == 'Đang giao' 
                      ? AppColors.warning 
                      : status == 'Hoàn thành' 
                          ? AppColors.success 
                          : AppColors.grey,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                ),
                child: Text(
                  status,
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
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            date,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context) / 2),
            child: Text(
              '• $item',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.text,
              ),
            ),
          )),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng:',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                total,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpPage() {
    return ResponsiveHelper.responsiveContainer(
      context: context,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

            Text(
              'Trợ giúp',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),

            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

            // Emergency Contact
            ResponsiveHelper.responsiveCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emergency,
                        color: AppColors.error,
                        size: ResponsiveHelper.getIconSize(context, 24),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Text(
                        'Liên hệ khẩn cấp',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildContactItem(
                    icon: Icons.phone,
                    title: 'Gọi người thân',
                    subtitle: 'Liên hệ người thân để được hỗ trợ',
                    onTap: () {
                      // TODO: Call family member
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  _buildContactItem(
                    icon: Icons.support_agent,
                    title: 'Hỗ trợ khách hàng',
                    subtitle: '1900-xxxx',
                    onTap: () {
                      // TODO: Call customer support
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

            // Help Topics
            Text(
              'Hướng dẫn sử dụng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),

            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

            _buildHelpItem(
              icon: Icons.shopping_cart,
              title: 'Cách đặt hàng',
              onTap: () {
                // TODO: Show order guide
              },
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            _buildHelpItem(
              icon: Icons.payment,
              title: 'Cách thanh toán',
              onTap: () {
                // TODO: Show payment guide
              },
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            _buildHelpItem(
              icon: Icons.local_shipping,
              title: 'Theo dõi đơn hàng',
              onTap: () {
                // TODO: Show tracking guide
              },
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            _buildHelpItem(
              icon: Icons.undo,
              title: 'Đổi trả hàng',
              onTap: () {
                // TODO: Show return guide
              },
            ),

            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        child: Row(
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 40),
              height: ResponsiveHelper.getIconSize(context, 40),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 20)),
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, 20),
                color: AppColors.primary,
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
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
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
              Icons.arrow_forward_ios,
              size: ResponsiveHelper.getIconSize(context, 16),
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ResponsiveHelper.responsiveCard(
      context: context,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          child: Row(
            children: [
              Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.primary,
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              Expanded(
                child: Text(
                  title,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.text,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 