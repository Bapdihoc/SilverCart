
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:silvercart/page/shopping/product_detail_page.dart';
import 'package:silvercart/page/shopping/shopping_cart_page.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../injection.dart';
import '../../models/root_category_response.dart';
import '../../models/product_search_request.dart';
import '../../models/product_search_response.dart';
import '../../network/service/product_service.dart';
import '../../network/service/category_service.dart';

class ProductGuardianPage extends StatefulWidget {
  const ProductGuardianPage({super.key});

  @override
  State<ProductGuardianPage> createState() => _ProductGuardianPageState();
}

class _ProductGuardianPageState extends State<ProductGuardianPage> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _selectedSubCategory = '';
  String _sortBy = 'Mới nhất';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  OverlayEntry? _overlayEntry;
  final GlobalKey _cartIconKey = GlobalKey();
  final Map<String, GlobalKey> _productButtonKeys = {};

  // API products - using SearchProductItem structure
  List<SearchProductItem> _products = [];
  List<SearchProductItem> _filteredProducts = [];
  bool _isLoadingProducts = false;

  // API categories - now multi-level
  List<RootCategory> _rootCategories = [];
  List<RootCategory> _currentSubCategories = [];
  List<RootCategory> _categoryPath = []; // Breadcrumb path
  bool _isLoadingCategories = false;
  bool _isLoadingSubCategories = false;
  late final CategoryService _categoryService;
  late final ProductService _productService;

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
    _categoryService = getIt<CategoryService>();
    _productService = getIt<ProductService>();
    
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

    _loadCategories();
    _searchProductsByCategory(); // Load all products initially
  }

  // Consistent image error/empty placeholder with info icon
  Widget _buildImageErrorPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.grey.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.info_outline_rounded,
          color: AppColors.grey,
          size: ResponsiveHelper.getIconSize(context, 36),
        ),
      ),
    );
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final result = await _categoryService.getRootListValueCategory();
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _rootCategories = result.data!.data;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể tải danh mục'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh mục: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _loadSubCategories(String parentId) async {
    setState(() {
      _isLoadingSubCategories = true;
    });

    try {
      final result = await _categoryService.getListValueCategoryById(parentId);
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _currentSubCategories = result.data!.data;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể tải danh mục con'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh mục con: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSubCategories = false;
        });
      }
    }
  }

  void _navigateToCategory(RootCategory category) {
    setState(() {
      _categoryPath.add(category);
      _selectedCategory = category.label;
    });

    if (category.childrenId != null) {
      // Load subcategories
      _loadSubCategories(category.childrenId!);
    } else {
      // End category, search products
      _currentSubCategories.clear();
      _searchProductsByCategory(categoryId: category.id);
    }
  }

  void _navigateBack() {
    if (_categoryPath.isEmpty) return;

    setState(() {
      _categoryPath.removeLast();
      
      if (_categoryPath.isEmpty) {
        // Back to root
        _selectedCategory = 'Tất cả';
        _currentSubCategories.clear();
        _searchProductsByCategory(); // Load all products
      } else {
        // Back to parent category
        final parentCategory = _categoryPath.last;
        _selectedCategory = parentCategory.label;
        
        if (parentCategory.childrenId != null) {
          _loadSubCategories(parentCategory.childrenId!);
        } else {
          _currentSubCategories.clear();
          _searchProductsByCategory(categoryId: parentCategory.id);
        }
      }
    });
  }

  Future<void> _searchProductsByCategory({String? categoryId, String? keyword}) async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      // Create search request
      final searchRequest = ProductSearchRequest(
        keyword: keyword,
        categoryIds: categoryId != null ? [categoryId] : null,
        page: 1,
        pageSize: 20,
      );

      // Call search API
      final result = await _productService.searchProducts(searchRequest);
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _products = result.data!.data.items;
          _filteredProducts = List.from(_products);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể tải sản phẩm'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        // Fallback to hardcoded products if API fails
        _loadHardCodeProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tìm kiếm sản phẩm: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      // Fallback to hardcoded products if API fails
      _loadHardCodeProducts();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  void _loadHardCodeProducts() {
    // Convert hardcoded data to SearchProductItem format for consistency
    setState(() {
      _products = [
        SearchProductItem(
          id: '1',
          name: 'Táo đỏ Mỹ',
          brand: 'Fresh Fruits',
          price: 85000,
          description: 'Táo đỏ Mỹ tươi ngon, giòn ngọt, giàu vitamin',
          imageUrl: '', // Empty for hardcoded fallback
          categories: [
            SearchProductCategory(
              id: '1',
              code: '',
              description: '',
              label: '🍎 Thực phẩm',
              type: 0,
              listOfValueId: '',
            ),
          ],
        ),
        SearchProductItem(
          id: '2',
          name: 'Vitamin D3 1000IU',
          brand: 'Health Plus',
          price: 180000,
          description: 'Vitamin D3 hỗ trợ xương khớp, tăng cường miễn dịch',
          imageUrl: '',
          categories: [
            SearchProductCategory(
              id: '2',
              code: '',
              description: '',
              label: '💊 Thuốc & Sức khỏe',
              type: 0,
              listOfValueId: '',
            ),
          ],
        ),
        SearchProductItem(
          id: '3',
          name: 'Kem dưỡng ẩm',
          brand: 'Beauty Care',
          price: 250000,
          description: 'Kem dưỡng ẩm cho da khô, chống lão hóa',
          imageUrl: '',
          categories: [
            SearchProductCategory(
              id: '3',
              code: '',
              description: '',
              label: '🧴 Chăm sóc cá nhân',
              type: 0,
              listOfValueId: '',
            ),
          ],
        ),
        SearchProductItem(
          id: '4',
          name: 'Nồi cơm điện',
          brand: 'HomeTech',
          price: 1200000,
          description: 'Nồi cơm điện thông minh, tiết kiệm điện',
          imageUrl: '',
          categories: [
            SearchProductCategory(
              id: '4',
              code: '',
              description: '',
              label: '🏠 Gia dụng',
              type: 0,
              listOfValueId: '',
            ),
          ],
        ),
        SearchProductItem(
          id: '5',
          name: 'Áo thun cotton',
          brand: 'Fashion Style',
          price: 150000,
          description: 'Áo thun cotton mềm mại, thoáng mát',
          imageUrl: '',
          categories: [
            SearchProductCategory(
              id: '5',
              code: '',
              description: '',
              label: '👕 Quần áo',
              type: 0,
              listOfValueId: '',
            ),
          ],
        ),
        SearchProductItem(
          id: '6',
          name: 'Điện thoại Samsung',
          brand: 'Samsung',
          price: 8500000,
          description: 'Điện thoại thông minh, camera chất lượng cao',
          imageUrl: '',
          categories: [
            SearchProductCategory(
              id: '6',
              code: '',
              description: '',
              label: '📱 Điện tử',
              type: 0,
              listOfValueId: '',
            ),
          ],
        ),
        SearchProductItem(
          id: '7',
          name: 'Cam sành',
          brand: 'Fresh Fruits',
          price: 45000,
          description: 'Cam sành ngọt mát, giàu vitamin C',
          imageUrl: '',
          categories: [
            SearchProductCategory(
              id: '7',
              code: '',
              description: '',
              label: '🍎 Thực phẩm',
              type: 0,
              listOfValueId: '',
            ),
          ],
        ),
        SearchProductItem(
          id: '8',
          name: 'Thuốc cảm cúm',
          brand: 'PharmaCare',
          price: 35000,
          description: 'Thuốc điều trị cảm cúm, giảm sốt',
          imageUrl: '',
          categories: [
            SearchProductCategory(
              id: '8',
              code: '',
              description: '',
              label: '💊 Thuốc & Sức khỏe',
              type: 0,
              listOfValueId: '',
            ),
          ],
        ),
      ];
      _filteredProducts = List.from(_products);
    });
  }

  void _applyFilters() {
    setState(() {
      var filtered = _products;
      
      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        filtered = filtered.where((product) {
          final name = product.name.toLowerCase();
          final description = product.description.toLowerCase();
          final query = _searchController.text.toLowerCase();
          return name.contains(query) || description.contains(query);
        }).toList();
      }
      
      // Apply category filter
      if (_selectedCategory != 'Tất cả') {
        filtered = filtered.where((product) {
          return product.categories.any((cat) => cat.label.contains(_selectedCategory));
        }).toList();
      }
      
      // Apply sub-category filter
      if (_selectedSubCategory.isNotEmpty && _selectedSubCategory != 'Tất cả') {
        filtered = filtered.where((product) {
          return product.categories.any((cat) => cat.label.contains(_selectedSubCategory));
        }).toList();
      }
      
      // Apply sorting
      filtered = _sortProducts(filtered);
      
      _filteredProducts = filtered;
    });
  }

  List<SearchProductItem> _sortProducts(List<SearchProductItem> products) {
    switch (_sortBy) {
      case 'Giá thấp - cao':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá cao - thấp':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Đánh giá cao':
        // For now, keep original order since we don't have rating in API
        break;
      case 'Bán chạy':
        // For now, keep original order since we don't have sales data in API
        break;
      default: // 'Mới nhất'
        // Keep original order for demo
        break;
    }
    return products;
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Mua sắm',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                IconButton(
                  key: _cartIconKey,
                  icon: Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShoppingCartPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModernSearchSection(),
          _buildCategoryHeaderSection(),
          Expanded(child: _buildModernProductGrid()),
        ],
      ),
    );
  }

  Widget _buildModernSearchSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  hintStyle: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.grey,
                  ),
                  prefixIcon: Container(
                    margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context) / 2),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context) / 2,
                  ),
                ),
                onChanged: (value) {
                  // Search with keyword
                  if (value.trim().isNotEmpty) {
                    _searchProductsByCategory(keyword: value.trim());
                  } else {
                    // If search is empty, reload by current category
                    if (_selectedCategory == 'Tất cả') {
                      _searchProductsByCategory();
                    } else {
                      final selectedCategoryData = _rootCategories.firstWhere(
                        (cat) => cat.label == _selectedCategory,
                        orElse: () => _rootCategories.first,
                      );
                      _searchProductsByCategory(categoryId: selectedCategoryData.id);
                    }
                  }
                },
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                _showModernFilterDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeaderSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context) * 0.5,
      ),
      child: Row(
        children: [
          // Category selector button
          GestureDetector(
            onTap: _showCategoryPopup,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Danh mục',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Breadcrumb navigation (if has path)
          if (_categoryPath.isNotEmpty)
            Expanded(child: _buildClickableBreadcrumb()),
        ],
      ),
    );
  }

  Widget _buildModernProductGrid() {
    if (_isLoadingProducts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: ResponsiveHelper.getIconSize(context, 40),
              height: ResponsiveHelper.getIconSize(context, 40),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            Text(
              'Đang tải sản phẩm...',
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

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 80),
              height: ResponsiveHelper.getIconSize(context, 80),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: ResponsiveHelper.getIconSize(context, 40),
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            Text(
              'Không tìm thấy sản phẩm nào',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              'Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
        crossAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
        mainAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        
        // Create or get the GlobalKey for this product
        final String productId = product.id;
        if (!_productButtonKeys.containsKey(productId)) {
          _productButtonKeys[productId] = GlobalKey();
        }
        final GlobalKey buttonKey = _productButtonKeys[productId]!;
        
        return _buildModernProductCard(product, buttonKey);
      },
    );
  }

  Widget _buildModernProductCard(SearchProductItem product, GlobalKey buttonKey) {
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
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(productId: product.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
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
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Product Image with proper handling
                      if (product.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: AppColors.grey.withOpacity(0.1),
                              child: Center(
                                child: SizedBox(
                                  width: ResponsiveHelper.getIconSize(context, 32),
                                  height: ResponsiveHelper.getIconSize(context, 32),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildImageErrorPlaceholder(context),
                          ),
                        )
                      else
                        _buildImageErrorPlaceholder(context),
                      
                      // Favorite button
                      Positioned(
                        top: ResponsiveHelper.getSpacing(context),
                        left: ResponsiveHelper.getSpacing(context),
                        child: Container(
                          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context) / 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite_border_rounded,
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
                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
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
                    
                    // Brand
                    if (product.brand.isNotEmpty)
                      Text(
                        product.brand,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                CurrencyUtils.formatVND(product.price),
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

  // Helper method to get category emoji for fallback
  String _getCategoryEmoji(List<SearchProductCategory> categories) {
    if (categories.isEmpty) return '📦';
    
    final categoryName = categories.first.label.toLowerCase();
    if (categoryName.contains('thực phẩm') || categoryName.contains('trái cây')) return '🍎';
    if (categoryName.contains('thuốc') || categoryName.contains('sức khỏe')) return '💊';
    if (categoryName.contains('chăm sóc') || categoryName.contains('cá nhân')) return '🧴';
    if (categoryName.contains('gia dụng') || categoryName.contains('nhà bếp')) return '🏠';
    if (categoryName.contains('quần áo') || categoryName.contains('áo')) return '👕';
    if (categoryName.contains('điện tử') || categoryName.contains('điện thoại')) return '📱';
    
    return '📦';
  }

  void _startFlyToCartAnimation(SearchProductItem product, GlobalKey buttonKey) {
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

    // Get category emoji for animation
    final categoryEmoji = _getCategoryEmoji(product.categories);

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
                        categoryEmoji,
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
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: Text(
                  'Đã thêm ${product.name} vào giỏ hàng! 🎉',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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

  // ignore: unused_element
  void _addToCart(SearchProductItem product, GlobalKey buttonKey) {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Start the fly to cart animation
    _startFlyToCartAnimation(product, buttonKey);
  }

  void _showModernFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getIconSize(context, 40),
                    height: ResponsiveHelper.getIconSize(context, 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: ResponsiveHelper.getIconSize(context, 20),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Bộ lọc & Sắp xếp',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              
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
                return Container(
                  margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                  child: RadioListTile<String>(
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
                      _applyFilters();
                      Navigator.of(context).pop();
                    },
                    activeColor: AppColors.secondary,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
              
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.grey,
                        side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSpacing(context)),
                      ),
                      child: Text('Đóng'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCompactHeader() {
    if (_categoryPath.isEmpty) {
      // Root level - minimal title
      return Container(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          'Danh mục',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      );
    } else {
      // Navigation level - compact breadcrumb
      return Container(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Compact back button
            GestureDetector(
              onTap: _navigateBack,
              child: Container(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 8),
            
            // Simplified breadcrumb
            Expanded(
              child: Text(
                _buildSimpleBreadcrumbText(),
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildClickableBreadcrumb() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Home breadcrumb
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = 'Tất cả';
                _categoryPath.clear();
                _currentSubCategories.clear();
              });
              _searchProductsByCategory();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _categoryPath.isEmpty ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Tất cả',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 12,
                  fontWeight: _categoryPath.isEmpty ? FontWeight.w600 : FontWeight.w500,
                  color: _categoryPath.isEmpty ? AppColors.primary : AppColors.grey,
                ),
              ),
            ),
          ),
          
          // Category path
          ..._categoryPath.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isLast = index == _categoryPath.length - 1;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 12,
                    color: AppColors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: isLast ? null : () {
                    // Navigate back to this level
                    setState(() {
                      _categoryPath.removeRange(index + 1, _categoryPath.length);
                      if (_categoryPath.isNotEmpty) {
                        _selectedCategory = _categoryPath.last.label;
                        if (_categoryPath.last.childrenId != null) {
                          _loadSubCategories(_categoryPath.last.childrenId!);
                        } else {
                          _currentSubCategories.clear();
                        }
                      } else {
                        _selectedCategory = 'Tất cả';
                        _currentSubCategories.clear();
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLast ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category.label,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 12,
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                        color: isLast ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showCategoryPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Chọn danh mục',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Categories content
                Expanded(
                  child: _buildCategoryPopupContent(scrollController, setModalState),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPopupContent(ScrollController scrollController, StateSetter setModalState) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb in popup (if navigated)
          if (_categoryPath.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigateBackInPopup(setModalState),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildSimpleBreadcrumbText(),
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          
          // Current level categories
          if (_isLoadingCategories || _isLoadingSubCategories)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            _categoryPath.isEmpty 
                ? _buildPopupRootCategories(setModalState) 
                : _buildPopupCurrentSubCategories(setModalState),
                
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToCategoryInPopup(RootCategory category, StateSetter setModalState) {
    // Check if this is a fresh selection from root or continuing current path
    final isNewRootSelection = _categoryPath.isEmpty || 
        (_categoryPath.isNotEmpty && _categoryPath.first.id != category.id && _rootCategories.any((cat) => cat.id == category.id));

    // Update main page state
    setState(() {
      if (isNewRootSelection) {
        // Fresh selection from root - reset path
        _categoryPath.clear();
        _currentSubCategories.clear();
        _categoryPath.add(category);
      } else {
        // Continuing current path - add to existing path
        _categoryPath.add(category);
      }
      _selectedCategory = category.label;
    });

    // Update popup state
    setModalState(() {
      // Sync with main page state
    });

    // Load subcategories if available
    if (category.childrenId != null) {
      _loadSubCategoriesInPopup(category.childrenId!, setModalState);
    } else {
      // End category - close popup and search products
      _searchProductsByCategory(categoryId: category.id);
      Navigator.pop(context);
    }
  }

  void _navigateBackInPopup(StateSetter setModalState) {
    if (_categoryPath.isEmpty) return;

    // Remove current level from path
    _categoryPath.removeLast();

    // Update main page state
    setState(() {
      if (_categoryPath.isEmpty) {
        // Back to root level
        _selectedCategory = 'Tất cả';
        _currentSubCategories.clear();
      } else {
        // Back to parent level - keep parent as selected
        _selectedCategory = _categoryPath.last.label;
        
        // Load parent's subcategories if needed
        if (_categoryPath.last.childrenId != null) {
          _loadSubCategoriesInPopup(_categoryPath.last.childrenId!, setModalState);
        } else {
          _currentSubCategories.clear();
        }
      }
    });

    // Update popup state
    setModalState(() {
      // State already updated above
    });
  }

  Future<void> _loadSubCategoriesInPopup(String parentId, StateSetter setModalState) async {
    setModalState(() {
      _isLoadingSubCategories = true;
    });

    try {
      final result = await _categoryService.getListValueCategoryById(parentId);
      if (result.isSuccess && result.data != null) {
        setModalState(() {
          _currentSubCategories = result.data!.data;
          _isLoadingSubCategories = false;
        });
        
        // Also update main page state
        setState(() {
          _currentSubCategories = result.data!.data;
          _isLoadingSubCategories = false;
        });
      } else {
        setModalState(() {
          _isLoadingSubCategories = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể tải danh mục con'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setModalState(() {
        _isLoadingSubCategories = false;
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

  String _buildSimpleBreadcrumbText() {
    List<String> breadcrumbItems = ['Danh mục'];
    breadcrumbItems.addAll(_categoryPath.map((cat) => cat.label));
    return breadcrumbItems.join(' › ');
  }

  // ignore: unused_element
  List<Widget> _buildBreadcrumbItems() {
    List<Widget> items = [];
    
    // Add "Danh mục" as root
    items.add(_buildBreadcrumbItem('Danh mục', false, () {
      setState(() {
        _selectedCategory = 'Tất cả';
        _categoryPath.clear();
        _currentSubCategories.clear();
      });
      _searchProductsByCategory();
    }));
    
    // Add category path
    for (int i = 0; i < _categoryPath.length; i++) {
      final category = _categoryPath[i];
      final isLast = i == _categoryPath.length - 1;
      
      items.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 10,
            color: AppColors.grey,
          ),
        ),
      );
      
      items.add(_buildBreadcrumbItem(category.label, isLast, () {
        if (!isLast) {
          // Navigate back to this level
          setState(() {
            _categoryPath.removeRange(i + 1, _categoryPath.length);
            if (_categoryPath.last.childrenId != null) {
              _loadSubCategories(_categoryPath.last.childrenId!);
            } else {
              _currentSubCategories.clear();
            }
          });
        }
      }));
    }
    
    return items;
  }

  Widget _buildBreadcrumbItem(String label, bool isLast, VoidCallback onTap) {
    return GestureDetector(
      onTap: isLast ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isLast ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 12,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
            color: isLast ? AppColors.primary : AppColors.grey,
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCurrentCategoryContent() {
    if (_isLoadingCategories) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: _categoryPath.isEmpty 
          ? _buildRootCategories() 
          : _buildCurrentSubCategoriesOld(),
    );
  }

  Widget _buildRootCategories() {
    return Column(
      children: [
        // "Tất cả" option
        _buildSimpleCategory('Tất cả', _selectedCategory == 'Tất cả', () {
          setState(() {
            _selectedCategory = 'Tất cả';
            _categoryPath.clear();
            _currentSubCategories.clear();
          });
          _searchProductsByCategory();
        }),
        
        // Root categories
        ..._rootCategories.map((category) {
          final isSelected = _selectedCategory == category.label;
          return _buildSimpleCategory(
            category.label, 
            isSelected, 
            () {
              setState(() {
                _categoryPath.clear();
                _currentSubCategories.clear();
              });
              _navigateToCategory(category);
            },
            hasChildren: category.childrenId != null,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPopupRootCategories(StateSetter setModalState) {
    return Column(
      children: [
        // "Tất cả" option
        _buildPopupCategory('Tất cả', _selectedCategory == 'Tất cả' && _categoryPath.isEmpty, () {
          setState(() {
            _selectedCategory = 'Tất cả';
            _categoryPath.clear();
            _currentSubCategories.clear();
          });
          _searchProductsByCategory();
          Navigator.pop(context);
        }),
        
        // Root categories
        ..._rootCategories.map((category) {
          // Check if this category is currently selected (either directly or as part of path)
          final isSelected = _categoryPath.isNotEmpty 
              ? _categoryPath.first.id == category.id
              : _selectedCategory == category.label;
              
          return _buildPopupCategory(
            category.label, 
            isSelected, 
            () => _navigateToCategoryInPopup(category, setModalState),
            hasChildren: category.childrenId != null,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPopupCurrentSubCategories(StateSetter setModalState) {
    if (_isLoadingSubCategories) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Column(
      children: [
        // "Tất cả" option for current parent category
        _buildPopupCategory('Tất cả', 
          _categoryPath.isNotEmpty && _selectedCategory == _categoryPath.last.label && 
          _currentSubCategories.every((sub) => _selectedCategory != sub.label), 
          () {
            final parentCategory = _categoryPath.isNotEmpty ? _categoryPath.last : null;
            if (parentCategory != null) {
              setState(() {
                _selectedCategory = parentCategory.label;
              });
              _searchProductsByCategory(categoryId: parentCategory.id);
              Navigator.pop(context);
            }
          }
        ),
        
        // Current level subcategories
        ..._currentSubCategories.map((subCategory) {
          final isSelected = _selectedCategory == subCategory.label;
          return _buildPopupCategory(
            subCategory.label,
            isSelected,
            () => _navigateToCategoryInPopup(subCategory, setModalState),
            hasChildren: subCategory.childrenId != null,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPopupCategory(String label, bool isSelected, VoidCallback onTap, {bool hasChildren = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Category indicator dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 14),
            
            // Category label
            Expanded(
              child: Text(
                label,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
            
            // Arrow for expandable categories
            if (hasChildren)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubCategoriesOld() {
    if (_isLoadingSubCategories) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Tất cả" option for current parent category
        _buildSimpleCategory('Tất cả', true, () {
          final parentCategory = _categoryPath.isNotEmpty ? _categoryPath.last : null;
          if (parentCategory != null) {
            _searchProductsByCategory(categoryId: parentCategory.id);
          }
        }),
        
        // Current level subcategories
        ..._currentSubCategories.map((subCategory) {
          return _buildSimpleCategory(
            subCategory.label,
            false,
            () => _navigateToCategory(subCategory),
            hasChildren: subCategory.childrenId != null,
          );
        }).toList(),
        
        // Add bottom padding for better scrolling
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSimpleCategory(String label, bool isSelected, VoidCallback onTap, {bool hasChildren = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Category indicator dot
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            
            // Category label
            Expanded(
              child: Text(
                label,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
            
            // Arrow for expandable categories
            if (hasChildren)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.6),
              ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSimpleSubCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoadingSubCategories)
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              // "Tất cả" option for subcategories
              _buildSimpleCategory('Tất cả', true, () {
                final parentCategory = _categoryPath.isNotEmpty ? _categoryPath.last : null;
                if (parentCategory != null) {
                  _searchProductsByCategory(categoryId: parentCategory.id);
                }
              }),
              
              // Subcategories
              ..._currentSubCategories.map((subCategory) {
                return _buildSimpleCategory(
                  subCategory.label,
                  false,
                  () => _navigateToCategory(subCategory),
                  hasChildren: subCategory.childrenId != null,
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildSubCategoryChip(String label, bool isPrimary, VoidCallback onTap, {bool hasChildren = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary.withOpacity(0.1) : AppColors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isPrimary ? AppColors.primary.withOpacity(0.3) : AppColors.secondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 11,
                fontWeight: FontWeight.w500,
                color: isPrimary ? AppColors.primary : AppColors.secondary,
              ),
            ),
            if (hasChildren) ...[
              SizedBox(width: 3),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 7,
                color: isPrimary ? AppColors.primary : AppColors.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildBreadcrumb() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context) / 2,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _navigateBack,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context)),
          
          // Breadcrumb path
          Expanded(
            child: SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryPath.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.grey,
                  ),
                ),
                itemBuilder: (context, index) {
                  final category = _categoryPath[index];
                  final isLast = index == _categoryPath.length - 1;
                  
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLast ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLast ? AppColors.primary.withOpacity(0.3) : AppColors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      category.label,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 12,
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
                        color: isLast ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSubCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
          child: Text(
            'Danh mục con',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
        
        if (_isLoadingSubCategories)
          Center(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
              itemCount: _currentSubCategories.length + 1, // +1 for "Tất cả"
              separatorBuilder: (context, index) => SizedBox(width: ResponsiveHelper.getSpacing(context)),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "Tất cả" option
                  return GestureDetector(
                    onTap: () {
                      // Search with parent category ID
                      final parentCategory = _categoryPath.isNotEmpty ? _categoryPath.last : null;
                      if (parentCategory != null) {
                        _searchProductsByCategory(categoryId: parentCategory.id);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getSpacing(context),
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Tất cả',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                
                final subCategory = _currentSubCategories[index - 1];
                
                return GestureDetector(
                  onTap: () => _navigateToCategory(subCategory),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getSpacing(context),
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subCategory.label,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (subCategory.childrenId != null) ...[
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
 