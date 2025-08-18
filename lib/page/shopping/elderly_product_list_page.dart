import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';

class ElderlyProductListPage extends StatefulWidget {
  final String categoryTitle;
  final String categorySubtitle;
  final Color categoryColor;
  final IconData categoryIcon;
  final String? categoryId;

  const ElderlyProductListPage({
    super.key,
    required this.categoryTitle,
    required this.categorySubtitle,
    required this.categoryColor,
    required this.categoryIcon,
    this.categoryId,
  });

  @override
  State<ElderlyProductListPage> createState() => _ElderlyProductListPageState();
}

class _ElderlyProductListPageState extends State<ElderlyProductListPage> {
  String _searchQuery = '';
  String _selectedSort = 'Phổ biến';
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    // Hardcoded products based on category
    if (widget.categoryTitle == 'Thực phẩm') {
      _products = [
        {
          'id': 1,
          'name': 'Gạo tẻ thơm',
          'price': 45000,
          'originalPrice': 50000,
          'discount': 10,
          'rating': 4.8,
          'reviews': 1250,
          'image': '🍚',
          'description': 'Gạo tẻ thơm ngon, nấu cơm dẻo',
          'stock': 50,
        },
        {
          'id': 2,
          'name': 'Rau cải xanh',
          'price': 15000,
          'originalPrice': 18000,
          'discount': 17,
          'rating': 4.5,
          'reviews': 890,
          'image': '🥬',
          'description': 'Rau cải xanh tươi, giàu vitamin',
          'stock': 30,
        },
        {
          'id': 3,
          'name': 'Thịt heo ba chỉ',
          'price': 120000,
          'originalPrice': 140000,
          'discount': 14,
          'rating': 4.7,
          'reviews': 650,
          'image': '🥩',
          'description': 'Thịt heo ba chỉ tươi ngon',
          'stock': 20,
        },
        {
          'id': 4,
          'name': 'Cá basa phi lê',
          'price': 85000,
          'originalPrice': 95000,
          'discount': 11,
          'rating': 4.6,
          'reviews': 420,
          'image': '🐟',
          'description': 'Cá basa phi lê sạch, không xương',
          'stock': 25,
        },
        {
          'id': 5,
          'name': 'Trứng gà ta',
          'price': 35000,
          'originalPrice': 40000,
          'discount': 13,
          'rating': 4.9,
          'reviews': 2100,
          'image': '🥚',
          'description': 'Trứng gà ta tươi, giàu dinh dưỡng',
          'stock': 100,
        },
        {
          'id': 6,
          'name': 'Sữa tươi Vinamilk',
          'price': 28000,
          'originalPrice': 32000,
          'discount': 13,
          'rating': 4.4,
          'reviews': 1800,
          'image': '🥛',
          'description': 'Sữa tươi nguyên kem, bổ dưỡng',
          'stock': 80,
        },
      ];
    } else if (widget.categoryTitle == 'Thuốc') {
      _products = [
        {
          'id': 7,
          'name': 'Paracetamol 500mg',
          'price': 25000,
          'originalPrice': 30000,
          'discount': 17,
          'rating': 4.6,
          'reviews': 950,
          'image': '💊',
          'description': 'Thuốc giảm đau, hạ sốt',
          'stock': 200,
        },
        {
          'id': 8,
          'name': 'Vitamin C 1000mg',
          'price': 45000,
          'originalPrice': 55000,
          'discount': 18,
          'rating': 4.7,
          'reviews': 1200,
          'image': '🍊',
          'description': 'Vitamin C tăng cường miễn dịch',
          'stock': 150,
        },
        {
          'id': 9,
          'name': 'Omega 3',
          'price': 120000,
          'originalPrice': 150000,
          'discount': 20,
          'rating': 4.8,
          'reviews': 680,
          'image': '🐟',
          'description': 'Omega 3 tốt cho tim mạch',
          'stock': 80,
        },
        {
          'id': 10,
          'name': 'Canxi + Vitamin D',
          'price': 85000,
          'originalPrice': 100000,
          'discount': 15,
          'rating': 4.5,
          'reviews': 890,
          'image': '🦴',
          'description': 'Canxi và Vitamin D cho xương chắc khỏe',
          'stock': 120,
        },
      ];
    } else if (widget.categoryTitle == 'Gia dụng') {
      _products = [
        {
          'id': 11,
          'name': 'Dầu ăn Neptune',
          'price': 35000,
          'originalPrice': 42000,
          'discount': 17,
          'rating': 4.4,
          'reviews': 1100,
          'image': '🫒',
          'description': 'Dầu ăn tinh luyện, an toàn',
          'stock': 60,
        },
        {
          'id': 12,
          'name': 'Nước mắm Phú Quốc',
          'price': 45000,
          'originalPrice': 55000,
          'discount': 18,
          'rating': 4.7,
          'reviews': 850,
          'image': '🐟',
          'description': 'Nước mắm truyền thống Phú Quốc',
          'stock': 40,
        },
        {
          'id': 13,
          'name': 'Bột giặt Omo',
          'price': 55000,
          'originalPrice': 65000,
          'discount': 15,
          'rating': 4.3,
          'reviews': 1400,
          'image': '🧼',
          'description': 'Bột giặt thơm mát, sạch bẩn',
          'stock': 70,
        },
        {
          'id': 14,
          'name': 'Nước rửa chén Sunlight',
          'price': 28000,
          'originalPrice': 35000,
          'discount': 20,
          'rating': 4.5,
          'reviews': 950,
          'image': '🧽',
          'description': 'Nước rửa chén diệt khuẩn',
          'stock': 90,
        },
      ];
    } else {
      // Favorites category
      _products = [
        {
          'id': 1,
          'name': 'Gạo tẻ thơm',
          'price': 45000,
          'originalPrice': 50000,
          'discount': 10,
          'rating': 4.8,
          'reviews': 1250,
          'image': '🍚',
          'description': 'Gạo tẻ thơm ngon, nấu cơm dẻo',
          'stock': 50,
        },
        {
          'id': 7,
          'name': 'Paracetamol 500mg',
          'price': 25000,
          'originalPrice': 30000,
          'discount': 17,
          'rating': 4.6,
          'reviews': 950,
          'image': '💊',
          'description': 'Thuốc giảm đau, hạ sốt',
          'stock': 200,
        },
        {
          'id': 11,
          'name': 'Dầu ăn Neptune',
          'price': 35000,
          'originalPrice': 42000,
          'discount': 17,
          'rating': 4.4,
          'reviews': 1100,
          'image': '🫒',
          'description': 'Dầu ăn tinh luyện, an toàn',
          'stock': 60,
        },
      ];
    }
    _filteredProducts = _products;
  }

  void _filterProducts() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 product['description'].toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  void _sortProducts(String sortType) {
    setState(() {
      _selectedSort = sortType;
      switch (sortType) {
        case 'Giá thấp':
          _filteredProducts.sort((a, b) => a['price'].compareTo(b['price']));
          break;
        case 'Giá cao':
          _filteredProducts.sort((a, b) => b['price'].compareTo(a['price']));
          break;
        case 'Đánh giá':
          _filteredProducts.sort((a, b) => b['rating'].compareTo(a['rating']));
          break;
        case 'Phổ biến':
          _filteredProducts.sort((a, b) => b['reviews'].compareTo(a['reviews']));
          break;
      }
    });
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
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: ResponsiveHelper.getIconSize(context, 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          widget.categoryTitle,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
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
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart_rounded,
                color: AppColors.primary,
                size: ResponsiveHelper.getIconSize(context, 20),
              ),
              onPressed: () {
                // TODO: Navigate to cart
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Simple Search Bar
          Container(
            margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _filterProducts();
              },
              decoration: InputDecoration(
                hintText: '🔍 Tìm kiếm sản phẩm...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getLargeSpacing(context),
                  vertical: ResponsiveHelper.getLargeSpacing(context),
                ),
                hintStyle: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.grey,
                ),
              ),
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.text,
              ),
            ),
          ),

          // Simple Sort Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Row(
              children: [
                Text(
                  'Sắp xếp:',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                GestureDetector(
                  onTap: () => _showSimpleSortDialog(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getLargeSpacing(context),
                      vertical: ResponsiveHelper.getSpacing(context),
                    ),
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedSort,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.categoryColor,
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.getSpacing(context)),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: widget.categoryColor,
                          size: ResponsiveHelper.getIconSize(context, 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Products Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Row(
              children: [
                Text(
                  '${_filteredProducts.length} sản phẩm',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Products List (Single Column for Elderly)
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return _buildElderlyProductCard(_filteredProducts[index]);
                    },
                  ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 100),
            height: ResponsiveHelper.getIconSize(context, 100),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: ResponsiveHelper.getIconSize(context, 50),
              color: Colors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Không tìm thấy sản phẩm',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderlyProductCard(Map<String, dynamic> product) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
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
            // Product Image
            Container(
              width: ResponsiveHelper.getIconSize(context, 80),
              height: ResponsiveHelper.getIconSize(context, 80),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  product['image'],
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product['name'],
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),

                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: ResponsiveHelper.getIconSize(context, 20),
                        color: Colors.amber,
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Expanded(
                        child: Text(
                          '${product['rating']} (${product['reviews']} đánh giá)',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            color: AppColors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),

                  // Price
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          CurrencyUtils.formatVND(product['price']),
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.categoryColor,
                          ),
                        ),
                      ),
                      if ((product['discount'] ?? 0) > 0 && product['originalPrice'] != null) ...[
                        Text(
                          CurrencyUtils.formatVND(product['originalPrice']),
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ).copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Add to Cart Button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Container(
                          width: ResponsiveHelper.getIconSize(context, 24),
                          height: ResponsiveHelper.getIconSize(context, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: ResponsiveHelper.getIconSize(context, 16),
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.getSpacing(context)),
                        Text('Đã thêm ${product['name']} vào giỏ hàng'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  ),
                );
              },
              child: Container(
                width: ResponsiveHelper.getIconSize(context, 60),
                height: ResponsiveHelper.getIconSize(context, 60),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.categoryColor, widget.categoryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.categoryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_shopping_cart_rounded,
                  size: ResponsiveHelper.getIconSize(context, 28),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSimpleSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: ResponsiveHelper.getIconSize(context, 40),
                      height: ResponsiveHelper.getIconSize(context, 40),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [widget.categoryColor, widget.categoryColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sort_rounded,
                        size: ResponsiveHelper.getIconSize(context, 20),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Text(
                      'Sắp xếp sản phẩm',
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
                
                // Sort Options
                ...['Phổ biến', 'Giá thấp', 'Giá cao', 'Đánh giá'].map((option) {
                  final isSelected = _selectedSort == option;
                  return GestureDetector(
                    onTap: () {
                      _sortProducts(option);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                      decoration: BoxDecoration(
                        color: isSelected ? widget.categoryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? widget.categoryColor : Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: isSelected ? widget.categoryColor : Colors.grey,
                            size: ResponsiveHelper.getIconSize(context, 28),
                          ),
                          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                          Text(
                            option,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 18,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? widget.categoryColor : AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                
                // Cancel Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Hủy',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 