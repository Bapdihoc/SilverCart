import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silvercart/page/shopping/product_detail_page.dart';
import 'package:silvercart/page/shopping/shopping_cart_page.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _selectedElderly = 'Tất cả';
  String _sortBy = 'Mới nhất';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  OverlayEntry? _overlayEntry;
  final GlobalKey _cartIconKey = GlobalKey();
  final Map<String, GlobalKey> _productButtonKeys = {};

  final List<String> _categories = [
    'Tất cả',
    '🍎 Thực phẩm',
    '💊 Thuốc & Sức khỏe',
    '🧴 Chăm sóc cá nhân',
    '🏠 Gia dụng',
    '👕 Quần áo',
    '📱 Điện tử',
  ];

  final List<String> _elderlyList = [
    'Tất cả',
    'Bà Nguyễn Thị A',
    'Ông Trần Văn B',
    'Bà Lê Thị C',
  ];

  final List<String> _sortOptions = [
    'Mới nhất',
    'Giá thấp - cao',
    'Giá cao - thấp',
    'Bán chạy',
    'Đánh giá cao',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.9, curve: Curves.easeInCubic),
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeInCubic),
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text(
          '🛍️ Mua sắm',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          IconButton(
            key: _cartIconKey,
            icon: Stack(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: ResponsiveHelper.getIconSize(context, 24),
                  color: AppColors.primary,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '3',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingCartPage()),
              );
              // TODO: Navigate to cart
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildFilterSection(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context) * 1.5,
                ),
                border: Border.all(
                  color: AppColors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.grey,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context),
                    vertical: ResponsiveHelper.getLargeSpacing(context),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search
                },
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: Colors.white,
                size: ResponsiveHelper.getIconSize(context, 20),
              ),
              onPressed: () {
                _showFilterDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      color: Colors.white,
      child: Column(
        children: [
          // Categories
          Row(
            children: [
              Text(
                '🏷️ Danh mục:',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _categories.map((category) {
                          bool isSelected = _selectedCategory == category;
                          return Container(
                            margin: EdgeInsets.only(
                              right: ResponsiveHelper.getSpacing(context),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveHelper.getLargeSpacing(
                                    context,
                                  ),
                                  vertical:
                                      ResponsiveHelper.getSpacing(context) / 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getBorderRadius(context) *
                                        2,
                                  ),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : AppColors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 12,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppColors.text,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          // Elderly selection
          Row(
            children: [
              Text(
                '👥 Mua cho:',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _elderlyList.map((elderly) {
                          bool isSelected = _selectedElderly == elderly;
                          return Container(
                            margin: EdgeInsets.only(
                              right: ResponsiveHelper.getSpacing(context),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedElderly = elderly;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveHelper.getLargeSpacing(
                                    context,
                                  ),
                                  vertical:
                                      ResponsiveHelper.getSpacing(context) / 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.secondary
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    ResponsiveHelper.getBorderRadius(context) *
                                        2,
                                  ),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.secondary
                                            : AppColors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  elderly,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 12,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppColors.text,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
        crossAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
        mainAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
        childAspectRatio: 0.75,
      ),
      itemCount: _getFilteredProducts().length,
      itemBuilder: (context, index) {
        final product = _getFilteredProducts()[index];
        return GestureDetector(
          onTap: () {
            log('message');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          },
          child: _buildProductCard(product),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // Create or get the GlobalKey for this product
    final String productId = product['id'];
    if (!_productButtonKeys.containsKey(productId)) {
      _productButtonKeys[productId] = GlobalKey();
    }
    final GlobalKey buttonKey = _productButtonKeys[productId]!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.grey.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
            // TODO: Navigate to product detail
          },
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context) * 1.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        ResponsiveHelper.getBorderRadius(context) * 1.2,
                      ),
                      topRight: Radius.circular(
                        ResponsiveHelper.getBorderRadius(context) * 1.2,
                      ),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          product['emoji'],
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getIconSize(context, 48),
                          ),
                        ),
                      ),
                      if (product['discount'] != null)
                        Positioned(
                          top: ResponsiveHelper.getSpacing(context),
                          right: ResponsiveHelper.getSpacing(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getSpacing(context),
                              vertical:
                                  ResponsiveHelper.getSpacing(context) / 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getBorderRadius(context),
                              ),
                            ),
                            child: Text(
                              '-${product['discount']}%',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: ResponsiveHelper.getSpacing(context),
                        left: ResponsiveHelper.getSpacing(context),
                        child: Container(
                          padding: EdgeInsets.all(
                            ResponsiveHelper.getSpacing(context) / 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            size: ResponsiveHelper.getIconSize(context, 16),
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Product Info
              Padding(
                padding: EdgeInsets.all(
                  ResponsiveHelper.getLargeSpacing(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product['name'],
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: ResponsiveHelper.getIconSize(context, 12),
                          color: Colors.amber,
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getSpacing(context) / 2,
                        ),
                        Text(
                          '${product['rating']}',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                        Text(
                          ' (${product['reviews']})',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product['originalPrice'] != null)
                                Text(
                                  '${product['originalPrice']}đ',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 12,
                                    color: AppColors.grey,
                                  ).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '${product['price']}đ',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context),
                            ),
                          ),
                          child: IconButton(
                            key: buttonKey,
                            icon: Icon(
                              Icons.add_shopping_cart,
                              size: ResponsiveHelper.getIconSize(context, 16),
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _addToCart(product, buttonKey);
                            },
                            padding: EdgeInsets.all(
                              ResponsiveHelper.getSpacing(context),
                            ),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
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

  List<Map<String, dynamic>> _getFilteredProducts() {
    // Sample product data
    List<Map<String, dynamic>> products = [
      {
        'id': '1',
        'name': 'Gạo ST25 cao cấp 5kg',
        'emoji': '🌾',
        'price': 125000,
        'originalPrice': 150000,
        'discount': 17,
        'rating': 4.8,
        'reviews': 123,
        'category': '🍎 Thực phẩm',
      },
      {
        'id': '2',
        'name': 'Thuốc hạ huyết áp',
        'emoji': '💊',
        'price': 85000,
        'rating': 4.9,
        'reviews': 89,
        'category': '💊 Thuốc & Sức khỏe',
      },
      {
        'id': '3',
        'name': 'Dầu gội đầu dành cho người già',
        'emoji': '🧴',
        'price': 45000,
        'originalPrice': 55000,
        'discount': 18,
        'rating': 4.6,
        'reviews': 67,
        'category': '🧴 Chăm sóc cá nhân',
      },
      {
        'id': '4',
        'name': 'Nồi cơm điện cao cấp',
        'emoji': '🍚',
        'price': 1250000,
        'rating': 4.7,
        'reviews': 234,
        'category': '🏠 Gia dụng',
      },
      {
        'id': '5',
        'name': 'Áo len dành cho người cao tuổi',
        'emoji': '👕',
        'price': 320000,
        'rating': 4.5,
        'reviews': 45,
        'category': '👕 Quần áo',
      },
      {
        'id': '6',
        'name': 'Máy đo huyết áp tự động',
        'emoji': '📱',
        'price': 850000,
        'originalPrice': 1000000,
        'discount': 15,
        'rating': 4.9,
        'reviews': 178,
        'category': '📱 Điện tử',
      },
    ];

    if (_selectedCategory != 'Tất cả') {
      products =
          products.where((p) => p['category'] == _selectedCategory).toList();
    }

    return products;
  }

  void _startFlyToCartAnimation(Map<String, dynamic> product, GlobalKey buttonKey) {
    // Get the RenderBox of the add to cart button
    final RenderBox? buttonBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cartBox = _cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (buttonBox == null || cartBox == null) return;

    // Get button and cart positions relative to the screen
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;
    final Offset cartPosition = cartBox.localToGlobal(Offset.zero);
    final Size cartSize = cartBox.size;
    
    // Calculate start position (center of button)
    final double startX = buttonPosition.dx + buttonSize.width / 2;
    final double startY = buttonPosition.dy + buttonSize.height / 2;
    
    // Calculate end position (center of cart icon)
    final double endX = cartPosition.dx + cartSize.width / 2;
    final double endY = cartPosition.dy + cartSize.height / 2;
    
    // Calculate distance
    final double deltaX = endX - startX;
    final double deltaY = endY - startY;

    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Calculate current position using curve
          final double progress = _animationController.value;
          final double currentX = startX + (deltaX * progress);
          final double currentY = startY + (deltaY * progress) - (80 * (1 - progress) * progress * 4); // Parabolic arc
          
          return Positioned(
            left: currentX - 30, // Center the widget
            top: currentY - 30,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: progress * 2, // Add rotation effect
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        product['emoji'],
                        style: TextStyle(
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Start animation
    _animationController.forward().then((_) {
      // Remove overlay after animation completes
      _overlayEntry?.remove();
      _overlayEntry = null;
      _animationController.reset();
      
      // Show success message after animation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã thêm ${product['name']} vào giỏ hàng! 🎉',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context),
            ),
          ),
          action: SnackBarAction(
            label: 'Xem giỏ hàng',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingCartPage()),
              );
            },
          ),
        ),
      );
    });
  }

  void _addToCart(Map<String, dynamic> product, GlobalKey buttonKey) {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Start the fly to cart animation
    _startFlyToCartAnimation(product, buttonKey);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context) * 1.2,
              ),
            ),
            title: Text(
              '🔧 Bộ lọc & Sắp xếp',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sắp xếp theo:',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                ..._sortOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(
                      option,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: AppColors.text,
                      ),
                    ),
                    value: option,
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                      Navigator.of(context).pop();
                    },
                    activeColor: AppColors.primary,
                  );
                }).toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Đóng',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
 