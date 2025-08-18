import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../network/service/product_service.dart';
import '../../models/product_search_request.dart';
import '../../injection.dart';
import 'elderly_product_detail_page.dart';

class ElderlyProductsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ElderlyProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ElderlyProductsPage> createState() => _ElderlyProductsPageState();
}

class _ElderlyProductsPageState extends State<ElderlyProductsPage> {
  late final ProductService _productService;
  
  List<Map<String, dynamic>> _products = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _productService = getIt<ProductService>();
    _searchProductsByCategory();
  }

  Future<void> _searchProductsByCategory() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      // Create search request similar to product_catalog_page.dart
      final searchRequest = ProductSearchRequest(
        categoryIds: [widget.categoryId],
        page: 1,
        pageSize: 20,
      );

      // Call search API
      final searchedProducts = await _productService.searchProductsForUI(searchRequest);
      
      setState(() {
        _products = searchedProducts;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tìm kiếm sản phẩm: ${e.toString()}'),
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
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              size: ResponsiveHelper.getIconSize(context, 28),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          widget.categoryName,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoadingProducts 
          ? _buildElderlyLoadingState()
          : _products.isEmpty 
              ? _buildElderlyEmptyState()
              : _buildElderlyProductList(),
    );
  }

  Widget _buildElderlyLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 100),
            height: ResponsiveHelper.getIconSize(context, 100),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 6,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Đang tìm sản phẩm...',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Vui lòng đợi trong giây lát',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderlyEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 120),
              height: ResponsiveHelper.getIconSize(context, 120),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: ResponsiveHelper.getIconSize(context, 60),
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 1.5),
            Text(
              'Không có sản phẩm nào',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              'Danh mục "${widget.categoryName}" hiện chưa có sản phẩm nào.',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 20,
                color: AppColors.grey,
              ).copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 2),
            
            // Retry button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchProductsByCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Thử lại',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElderlyProductList() {
    return RefreshIndicator(
      onRefresh: _searchProductsByCategory,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
            child: _buildElderlyProductCard(product),
          );
        },
      ),
    );
  }

  Widget _buildElderlyProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product image section
          Container(
            width: double.infinity,
            height: ResponsiveHelper.getIconSize(context, 120),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Center(
              child: Text(
                product['image'] ?? product['emoji'] ?? '📦',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getIconSize(context, 60),
                ),
              ),
            ),
          ),
          
          // Product info section
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product name
                Text(
                  product['name'] ?? 'Sản phẩm',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ).copyWith(height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                
                // Rating row
                if (product['rating'] != null) ...[
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getSpacing(context),
                          vertical: ResponsiveHelper.getSpacing(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: ResponsiveHelper.getIconSize(context, 18),
                              color: Colors.amber,
                            ),
                            SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                            Text(
                              '${product['rating']}',
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
                      if (product['reviews'] != null) ...[
                        SizedBox(width: ResponsiveHelper.getSpacing(context)),
                        Text(
                          '(${product['reviews']})',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                ],
                
                // Description (if exists) - simplified
                if (product['description'] != null) ...[
                  Text(
                    product['description'],
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.grey,
                    ).copyWith(height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                ],
                
                // Price and action section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Price column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product['originalPrice'] != null) ...[
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
                            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                          ],
                          Text(
                            CurrencyUtils.formatVND(product['price']),
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    
                    // View button - compact
                    Container(
                      width: ResponsiveHelper.getIconSize(context, 60),
                      height: ResponsiveHelper.getIconSize(context, 60),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Navigate to ProductDetailPage like family role
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ElderlyProductDetailPage(
                                  productId: product['id'] ?? '',
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Icon(
                            Icons.visibility_rounded,
                            size: ResponsiveHelper.getIconSize(context, 28),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
