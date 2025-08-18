import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../shopping/elderly_cart_page.dart';
import '../shopping/elderly_products_page.dart';
import '../../network/service/auth_service.dart';
import '../../network/service/category_service.dart';
import '../../models/user_detail_response.dart';
import '../../models/root_category_response.dart';
import '../../injection.dart';

class ElderlyHomePage extends StatefulWidget {
  const ElderlyHomePage({super.key});

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  int _selectedIndex = 0;
  
  // Services
  late final AuthService _authService;
  late final CategoryService _categoryService;
  
  // Categories data
  List<dynamic> _categories = []; // Will store either UserCategoryValue or RootCategory
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _categoryService = getIt<CategoryService>();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      // First try to get user detail to get user's category preferences
      final userId = await _authService.getUserId();
      if (userId != null && userId.isNotEmpty) {
        final userDetailResult = await _authService.getUserDetail(userId);
        
        if (userDetailResult.isSuccess && 
            userDetailResult.data != null && 
            userDetailResult.data!.data.categoryValues.isNotEmpty) {
          // User has category preferences
          setState(() {
            _categories = userDetailResult.data!.data.categoryValues;
            _isLoadingCategories = false;
          });
          return;
        }
      }
      
      // Fallback to root categories if user has no preferences
      final rootCategoriesResult = await _categoryService.getRootListValueCategory();
      if (rootCategoriesResult.isSuccess && rootCategoriesResult.data != null) {
        setState(() {
          _categories = rootCategoriesResult.data!.data;
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _isLoadingCategories = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(rootCategoriesResult.message ?? 'Không thể tải danh mục'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh mục: ${e.toString()}'),
            backgroundColor: AppColors.error,
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
                    Icons.logout_rounded,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                  onPressed: () async {
                    await _authService.signOut();
                    if (mounted) {
                      context.pushReplacement('/role-selection');
                    }
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
          // Container(
          //   margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          //   padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 1.5),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //     borderRadius: BorderRadius.circular(24),
          //     boxShadow: [
          //       BoxShadow(
          //         color: AppColors.primary.withOpacity(0.3),
          //         blurRadius: 24,
          //         offset: const Offset(0, 8),
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               'Xin chào! 👋',
          //               style: ResponsiveHelper.responsiveTextStyle(
          //                 context: context,
          //                 baseSize: 30, // chữ lớn hơn
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.white,
          //               ),
          //             ),
          //             SizedBox(height: ResponsiveHelper.getSpacing(context)),
          //             Text(
          //               'Bạn muốn mua gì hôm nay?',
          //               style: ResponsiveHelper.responsiveTextStyle(
          //                 context: context,
          //                 baseSize: 20, // chữ lớn hơn
          //                 color: Colors.white.withOpacity(0.95),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Container(
          //         width: ResponsiveHelper.getIconSize(context, 80),
          //         height: ResponsiveHelper.getIconSize(context, 80),
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.2),
          //           borderRadius: BorderRadius.circular(24),
          //         ),
          //         child: Icon(
          //           Icons.shopping_cart_rounded,
          //           size: ResponsiveHelper.getIconSize(context, 40),
          //           color: Colors.white,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Quick Categories
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Text(
              'Danh mục sản phẩm',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 26, // chữ lớn hơn
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Category Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: _isLoadingCategories 
                ? _buildCategoryLoadingGrid()
                : _buildDynamicCategoryGrid(),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildCategoryLoadingGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
      mainAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
      childAspectRatio: 1.1,
      children: List.generate(4, (index) => _buildCategoryLoadingCard()),
    );
  }

  Widget _buildCategoryLoadingCard() {
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
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            Container(
              width: 100,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicCategoryGrid() {
    if (_categories.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: ResponsiveHelper.getIconSize(context, 48),
                color: AppColors.grey,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
              Text(
                'Chưa có danh mục nào',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // 1 cột cho mobile, card 16:9
        mainAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
        childAspectRatio: 16 / 9,
      ),
      itemCount:  _categories.length, // Show max 4 categories
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _buildDynamicCategoryCard(category, index);
      },
    );
  }

  Widget _buildDynamicCategoryCard(dynamic category, int index) {
    // Get common properties from both UserCategoryValue and RootCategory
    final String id = category is UserCategoryValue ? category.id : (category as RootCategory).id;
    final String label = category is UserCategoryValue ? category.label : (category as RootCategory).label;
    final String description = category is UserCategoryValue ? category.description : (category as RootCategory).description;
    
    // Define colors and icons for different categories
    final List<Color> colors = [AppColors.primary, AppColors.secondary, AppColors.success, AppColors.error];
    final List<IconData> icons = [
      Icons.restaurant_rounded,
      Icons.medication_rounded,
      Icons.home_rounded,
      Icons.category_rounded,
    ];
    
    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];
    
    return _buildModernCategoryCard(
      icon: icon,
      title: label,
      subtitle: description.length > 20 ? '${description.substring(0, 20)}...' : description,
      color: color,
      onTap: () {
        // Navigate to elderly products page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElderlyProductsPage(
              categoryId: id,
              categoryName: label,
            ),
          ),
        );
      },
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.12), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getLargeSpacing(context) * 1.2,
            vertical: ResponsiveHelper.getLargeSpacing(context)),
          child: Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 70),
                height: ResponsiveHelper.getIconSize(context, 70),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: ResponsiveHelper.getIconSize(context, 36),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context) * 1.2),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 22, // chữ lớn hơn
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ).copyWith(height: 1.25),
                      softWrap: true,
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    Text(
                      subtitle,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 16, // chữ lớn hơn
                        color: AppColors.grey,
                      ).copyWith(height: 1.35),
                      softWrap: true,
                    ),
                  ],
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