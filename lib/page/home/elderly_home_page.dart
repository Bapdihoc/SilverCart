import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../shopping/elderly_product_list_page.dart';
import '../shopping/elderly_cart_page.dart';

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
              Icons.person_rounded,
              color: AppColors.primary,
              size: ResponsiveHelper.getIconSize(context, 20),
            ),
            onPressed: () {
              // TODO: Show profile
            },
          ),
        ),
        title: Text(
          'SilverCart',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          // Cart Button
          Container(
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
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_rounded,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ElderlyCartPage(),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Notifications Button
          Container(
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
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_rounded,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                  onPressed: () {
                    // TODO: Show notifications
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildModernShoppingPage(),
          _buildCompactOrdersPage(),
          _buildCompactHelpPage(),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNavigation(),
    );
  }

  Widget _buildModernBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 90,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getLargeSpacing(context),
            vertical: ResponsiveHelper.getSpacing(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildElderlyNavItem(
                icon: Icons.shopping_bag_rounded, 
                label: 'Mua sắm', 
                index: 0,
                color: AppColors.primary,
              ),
              _buildElderlyNavItem(
                icon: Icons.receipt_rounded, 
                label: 'Đơn hàng', 
                index: 1,
                color: AppColors.success,
              ),
              _buildElderlyNavItem(
                icon: Icons.help_rounded, 
                label: 'Trợ giúp', 
                index: 2,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElderlyNavItem({
    required IconData icon, 
    required String label, 
    required int index,
    required Color color,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: 100,
        height: 70,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 32),
              height: ResponsiveHelper.getIconSize(context, 32),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, 20),
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernShoppingPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Welcome Section
          Container(
            margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào! 👋',
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
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: ResponsiveHelper.getIconSize(context, 60),
                  height: ResponsiveHelper.getIconSize(context, 60),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    size: ResponsiveHelper.getIconSize(context, 30),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Quick Categories
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Text(
              'Danh mục nhanh',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Category Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
              mainAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
              childAspectRatio: 1.1,
              children: [
                _buildModernCategoryCard(
                  icon: Icons.restaurant_rounded,
                  title: 'Thực phẩm',
                  subtitle: 'Gạo, rau, thịt...',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ElderlyProductListPage(
                          categoryTitle: 'Thực phẩm',
                          categorySubtitle: 'Gạo, rau, thịt và các loại thực phẩm tươi ngon',
                          categoryColor: AppColors.primary,
                          categoryIcon: Icons.restaurant_rounded,
                        ),
                      ),
                    );
                  },
                ),
                _buildModernCategoryCard(
                  icon: Icons.medication_rounded,
                  title: 'Thuốc',
                  subtitle: 'Thuốc, vitamin...',
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ElderlyProductListPage(
                          categoryTitle: 'Thuốc',
                          categorySubtitle: 'Thuốc, vitamin và các loại thực phẩm chức năng',
                          categoryColor: AppColors.secondary,
                          categoryIcon: Icons.medication_rounded,
                        ),
                      ),
                    );
                  },
                ),
                _buildModernCategoryCard(
                  icon: Icons.home_rounded,
                  title: 'Gia dụng',
                  subtitle: 'Dầu ăn, bột giặt...',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ElderlyProductListPage(
                          categoryTitle: 'Gia dụng',
                          categorySubtitle: 'Dầu ăn, bột giặt và các sản phẩm gia dụng',
                          categoryColor: AppColors.success,
                          categoryIcon: Icons.home_rounded,
                        ),
                      ),
                    );
                  },
                ),
                _buildModernCategoryCard(
                  icon: Icons.favorite_rounded,
                  title: 'Yêu thích',
                  subtitle: 'Sản phẩm đã lưu',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ElderlyProductListPage(
                          categoryTitle: 'Yêu thích',
                          categorySubtitle: 'Các sản phẩm bạn đã yêu thích và lưu lại',
                          categoryColor: AppColors.error,
                          categoryIcon: Icons.favorite_rounded,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

          // Recent Orders
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: ResponsiveHelper.getIconSize(context, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Đơn hàng gần đây',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Recent Orders List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              children: [
                _buildModernOrderCard(
                  orderNumber: 'DH001',
                  date: 'Hôm nay',
                  status: 'Đang giao',
                  items: ['Gạo, Rau cải, Thịt heo'],
                  total: '150.000đ',
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildModernOrderCard(
                  orderNumber: 'DH002',
                  date: 'Hôm qua',
                  status: 'Hoàn thành',
                  items: ['Thuốc cảm, Nước muối'],
                  total: '85.000đ',
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildModernCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 50),
                height: ResponsiveHelper.getIconSize(context, 50),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: ResponsiveHelper.getIconSize(context, 24),
                  color: Colors.white,
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
      ),
    );
  }

  Widget _buildModernOrderCard({
    required String orderNumber,
    required String date,
    required String status,
    required List<String> items,
    required String total,
  }) {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.receipt_rounded,
                        size: ResponsiveHelper.getIconSize(context, 16),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Text(
                      'Đơn hàng $orderNumber',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Đang giao' ? AppColors.warning : AppColors.success,
                    borderRadius: BorderRadius.circular(12),
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
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng:',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.grey,
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
      ),
    );
  }

  Widget _buildCompactOrdersPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: ResponsiveHelper.getIconSize(context, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Đơn hàng của tôi',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              children: [
                _buildModernOrderCard(
                  orderNumber: 'DH001',
                  date: 'Hôm nay, 14:30',
                  status: 'Đang giao',
                  items: ['Gạo 5kg', 'Rau cải 1kg', 'Thịt heo 500g'],
                  total: '150.000đ',
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildModernOrderCard(
                  orderNumber: 'DH002',
                  date: 'Hôm qua, 09:15',
                  status: 'Hoàn thành',
                  items: ['Thuốc cảm', 'Nước muối sinh lý'],
                  total: '85.000đ',
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildModernOrderCard(
                  orderNumber: 'DH003',
                  date: '2 ngày trước',
                  status: 'Hoàn thành',
                  items: ['Dầu ăn', 'Nước mắm', 'Bột giặt'],
                  total: '200.000đ',
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildCompactHelpPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: ResponsiveHelper.getIconSize(context, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Trợ giúp',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

          // Emergency Contact
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: ResponsiveHelper.getIconSize(context, 32),
                          height: ResponsiveHelper.getIconSize(context, 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.emergency_rounded,
                            size: ResponsiveHelper.getIconSize(context, 16),
                            color: Colors.white,
                          ),
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
                    _buildModernContactItem(
                      icon: Icons.phone_rounded,
                      title: 'Gọi người thân',
                      subtitle: 'Liên hệ người thân để được hỗ trợ',
                      onTap: () {
                        // TODO: Call family member
                      },
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    _buildModernContactItem(
                      icon: Icons.support_agent_rounded,
                      title: 'Hỗ trợ khách hàng',
                      subtitle: '1900-xxxx',
                      onTap: () {
                        // TODO: Call customer support
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Help Topics
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: ResponsiveHelper.getIconSize(context, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Hướng dẫn sử dụng',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              children: [
                _buildModernHelpItem(
                  icon: Icons.shopping_cart_rounded,
                  title: 'Cách đặt hàng',
                  onTap: () {
                    // TODO: Show order guide
                  },
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildModernHelpItem(
                  icon: Icons.payment_rounded,
                  title: 'Cách thanh toán',
                  onTap: () {
                    // TODO: Show payment guide
                  },
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildModernHelpItem(
                  icon: Icons.local_shipping_rounded,
                  title: 'Theo dõi đơn hàng',
                  onTap: () {
                    // TODO: Show tracking guide
                  },
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                _buildModernHelpItem(
                  icon: Icons.undo_rounded,
                  title: 'Đổi trả hàng',
                  onTap: () {
                    // TODO: Show return guide
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildModernContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        decoration: BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        child: Row(
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
                icon,
                size: ResponsiveHelper.getIconSize(context, 20),
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
              Icons.arrow_forward_ios_rounded,
              size: ResponsiveHelper.getIconSize(context, 16),
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHelpItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          child: Row(
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
                  icon,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: Colors.white,
                ),
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
                Icons.arrow_forward_ios_rounded,
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