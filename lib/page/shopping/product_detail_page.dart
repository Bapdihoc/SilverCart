import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:silvercart/page/shopping/shopping_cart_page.dart';
import '../../core/constants/app_colors.dart';

import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/product_detail_response.dart';
import '../../models/product_search_request.dart';
import '../../models/cart_replace_request.dart';

import '../../network/service/product_service.dart';
import '../../network/service/cart_service.dart';
import '../../network/service/speech_service.dart';
import '../video_call/video_call_page.dart';
import '../../injection.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  int _quantity = 1;
  String _selectedElderly = 'Bà Nguyễn Thị A';
  int _selectedImageIndex = 0;
  int _selectedVariantIndex = 0;
  Map<String, String> _selectedStyles = {}; // Map of styleId -> optionId
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // late Animation<Offset> _positionAnimation;
  late Animation<double> _opacityAnimation;
  OverlayEntry? _overlayEntry;
  final GlobalKey _addToCartButtonKey = GlobalKey();

  // API data
  ProductDetailData? _productDetail;
  bool _isLoading = true;
  String? _errorMessage;
  late final ProductService _productService;
  late final CartService _cartService;
  late final SpeechService _speechService;

  // Speech states
  bool _isSpeechEnabled = false;
  bool _isListening = false;
  bool _isSpeakingInstructions = false;

  // Related products (Similar products)
  bool _isLoadingRelated = false;
  String? _relatedErrorMessage;
  List<Map<String, dynamic>> _relatedProducts = [];

  final List<String> _elderlyList = [
    'Bà Nguyễn Thị A',
    'Ông Trần Văn B',
    'Bà Lê Thị C',
  ];

  // Get current variant
  ProductVariant? get _currentVariant => 
      _filteredVariants.isNotEmpty == true 
          ? _filteredVariants[_selectedVariantIndex] 
          : null;

  // Get filtered variants based on selected styles
  List<ProductVariant> get _filteredVariants {
    if (_productDetail == null || _selectedStyles.isEmpty) {
      return _productDetail?.productVariants ?? [];
    }

    return _productDetail!.productVariants.where((variant) {
      // Check if variant has all selected style values
    for (final entry in _selectedStyles.entries) {
      final selectedOptionId = entry.value;
        
        // Check if this variant has the selected option for this style
        final hasSelectedOption = variant.productVariantValues.any((value) {
          return value.valueId == selectedOptionId;
        });
        
        if (!hasSelectedOption) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Check if a style option is available based on current selections
  bool _isStyleOptionAvailable(String styleId, String optionId) {
    if (_productDetail == null) return false;

    // If this is the style being changed, always allow it
    // This allows users to switch between different style options
    if (_selectedStyles.containsKey(styleId)) {
      return true;
    }

    // Create a copy of current selections
    final testSelections = Map<String, String>.from(_selectedStyles);
    testSelections[styleId] = optionId;

    // Check if any variant exists with these selections
    final hasMatchingVariant = _productDetail!.productVariants.any((variant) {
      // Check if variant has all selected style values
        for (final entry in testSelections.entries) {
          final selectedOptionId = entry.value;
        
        // Check if this variant has the selected option for this style
        final hasSelectedOption = variant.productVariantValues.any((value) {
          return value.valueId == selectedOptionId;
        });
        
        if (!hasSelectedOption) {
          return false;
        }
      }
      return true;
    });

    return hasMatchingVariant;
  }

  // Get available variants count for a style option
  int _getAvailableVariantsCount(String styleId, String optionId) {
    if (_productDetail == null) return 0;

    // Create a copy of current selections
    final testSelections = Map<String, String>.from(_selectedStyles);
    testSelections[styleId] = optionId;

    // Count variants that match these selections
    return _productDetail!.productVariants.where((variant) {
      // Check if variant has all selected style values
      for (final entry in testSelections.entries) {
        final selectedOptionId = entry.value;
        
        // Check if this variant has the selected option for this style
        final hasSelectedOption = variant.productVariantValues.any((value) {
          return value.valueId == selectedOptionId;
        });
        
        if (!hasSelectedOption) {
          return false;
        }
      }
      return true;
    }).length;
  }

  // Check if all required styles are selected
  bool get _areAllStylesSelected {
    if (_productDetail == null || _productDetail!.styles.isEmpty) {
      // No styles required, so it's valid
      return true;
    }
    
    // Check if all styles have been selected
    for (final style in _productDetail!.styles) {
      if (!_selectedStyles.containsKey(style.listOfValueId) || 
          _selectedStyles[style.listOfValueId] == null ||
          _selectedStyles[style.listOfValueId]!.isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  // Check if add to cart button should be enabled
  bool get _canAddToCart {
    return _currentVariant != null && 
           _currentVariant!.stock > 0 && 
           _areAllStylesSelected;
  }

  // Clear style selections that are no longer valid after changing a style
  void _clearInvalidStyleSelections(String changedStyleId, String newOptionId) {
    if (_productDetail == null) return;

    // Create a copy of current selections with the new option
    final testSelections = Map<String, String>.from(_selectedStyles);
    testSelections[changedStyleId] = newOptionId;

    // Check each other style selection
    final stylesToRemove = <String>[];
    
    for (final entry in _selectedStyles.entries) {
      final styleId = entry.key;
      final _ = entry.value; // value not needed here
      
      // Skip the style that was just changed
      if (styleId == changedStyleId) continue;

      // Test if this selection is still valid
      final isValid = _productDetail!.productVariants.any((variant) {
        // Check if variant has all selected style values
        for (final testEntry in testSelections.entries) {
          final _ = testEntry.key; // key not used in check
          final testOptionId = testEntry.value;
          
          final hasSelectedOption = variant.productVariantValues.any((value) {
            return value.valueId == testOptionId;
          });
          
          if (!hasSelectedOption) {
            return false;
          }
        }
        return true;
      });

      // If this selection is no longer valid, mark it for removal
      if (!isValid) {
        stylesToRemove.add(styleId);
      }
    }

    // Remove invalid selections
    for (final styleId in stylesToRemove) {
      _selectedStyles.remove(styleId);
    }
  }

  @override
  void initState() {
    super.initState();
    _productService = getIt<ProductService>();
    _cartService = getIt<CartService>();
    _speechService = getIt<SpeechService>();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.9, curve: Curves.easeInCubic),
      ),
    );

    // Unused: reserved for future animation use

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInCubic),
      ),
    );

    _loadProductDetail();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speechService.initialize();
      setState(() {
        _isSpeechEnabled = true;
      });
      
      // Welcome message for elderly users
      await Future.delayed(Duration(seconds: 1));
      await _speechService.speakWelcome();
    } catch (e) {
      log('Failed to initialize speech service: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _productService.getProductDetail(widget.productId);
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _productDetail = result.data!.data;
          _isLoading = false;
        });
        // Load related products after we have category info
        _loadRelatedProducts();
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải thông tin sản phẩm';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải thông tin sản phẩm: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRelatedProducts() async {
    if (_productDetail == null || _productDetail!.categories.isEmpty) return;
    setState(() {
      _isLoadingRelated = true;
      _relatedErrorMessage = null;
    });

    try {
      // Dùng toàn bộ danh mục của sản phẩm hiện tại (mảng ID)
      final List<String> categoryIds = _productDetail!.categories.map((c) => c.id).toList();
      final request = ProductSearchRequest(
        categoryIds: categoryIds,
        page: 1,
        pageSize: 10,
      );

      final results = await _productService.searchProductsForUI(request);

      setState(() {
        // Optionally filter out current product
        _relatedProducts = results.where((p) => p['id'] != _productDetail!.id).toList();
        _isLoadingRelated = false;
      });
    } catch (e) {
      setState(() {
        _relatedErrorMessage = 'Không thể tải sản phẩm tương tự: ${e.toString()}';
        _isLoadingRelated = false;
      });
    }
  }

  String _getCategoryEmoji(List<ProductDetailCategory> categories) {
    if (categories.isEmpty) return '📦';

    final categoryName = categories.first.label.toLowerCase();

    if (categoryName.contains('di chuyển') || categoryName.contains('mobility'))
      return '🦯';
    if (categoryName.contains('thuốc') ||
        categoryName.contains('medicine') ||
        categoryName.contains('sức khỏe'))
      return '💊';
    if (categoryName.contains('chăm sóc') || categoryName.contains('care'))
      return '🧴';
    if (categoryName.contains('gia dụng') || categoryName.contains('household'))
      return '🏠';
    if (categoryName.contains('quần áo') || categoryName.contains('clothing'))
      return '👕';
    if (categoryName.contains('điện tử') || categoryName.contains('electronic'))
      return '📱';
    if (categoryName.contains('thực phẩm') || categoryName.contains('food'))
      return '🍎';

    return '📦';
  }

  // Voice control functions
  Future<void> _handleVoiceCommand(String command) async {
    if (!_isSpeechEnabled) return;

    final commandType = _speechService.getCommandType(command);
    
    switch (commandType) {
      case 'increase_quantity':
        _increaseQuantity();
        await _speechService.speakQuantityInfo(_quantity);
        break;
      case 'decrease_quantity':
        _decreaseQuantity();
        await _speechService.speakQuantityInfo(_quantity);
        break;
      case 'add_to_cart':
        await _addToCart();
        break;
      case 'buy_now':
        _buyNow();
        await _speechService.speakBuyNowAction();
        break;
      case 'read_info':
        await _readProductInfo();
        break;
      case 'read_price':
        await _readPriceInfo();
        break;
      case 'instructions':
        await _speechService.speakInstructions();
        break;
      default:
        await _speechService.speak('Xin lỗi, tôi không hiểu lệnh này. Vui lòng thử lại.');
    }
  }

  void _increaseQuantity() {
    if (_currentVariant != null && _quantity < _currentVariant!.stock) {
      setState(() {
        _quantity++;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _readProductInfo() async {
    if (_productDetail != null && _currentVariant != null) {
      await _speechService.speakProductInfo(
        _productDetail!.name,
        '${_currentVariant!.discountedPrice.toInt()}',
        _productDetail!.description,
      );
    }
  }

  Future<void> _readPriceInfo() async {
    if (_currentVariant != null) {
      final hasDiscount = _currentVariant!.discount > 0;
      if (hasDiscount) {
          await _speechService.speakPriceInfo(
          CurrencyUtils.formatVND(_currentVariant!.originalPrice, withSymbol: false),
          CurrencyUtils.formatVND(_currentVariant!.discountedPrice, withSymbol: false),
          '${_currentVariant!.discount}',
        );
      } else {
        await _speechService.speak('Giá sản phẩm: ${CurrencyUtils.formatVND(_currentVariant!.discountedPrice)}');
      }
    }
  }

  Future<void> _toggleVoiceAssistant() async {
    if (!_isSpeechEnabled) return;

    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // Start listening for voice commands
      await _speechService.speak('Tôi đang lắng nghe. Vui lòng nói lệnh của bạn.');
      
      // Simulate voice command (in real app, you would use speech recognition)
      _showVoiceCommandDialog();
    } else {
      // Stop listening
      await _speechService.speak('Đã dừng lắng nghe.');
    }
  }

  void _showVoiceCommandDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '🎤 Trợ lý giọng nói',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Các lệnh bạn có thể nói:',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
              ..._buildVoiceCommands(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isListening = false;
                });
              },
              child: Text('Đóng'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _speechService.speakInstructions();
                setState(() {
                  _isListening = false;
                });
              },
              child: Text('Nghe hướng dẫn'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Demo voice command
                await _handleVoiceCommand('đọc thông tin');
                setState(() {
                  _isListening = false;
                });
              },
              child: Text('Demo'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildVoiceCommands() {
    final commands = [
      {'text': '• "Tăng số lượng" - Tăng số lượng sản phẩm', 'command': 'tăng số lượng'},
      {'text': '• "Giảm số lượng" - Giảm số lượng sản phẩm', 'command': 'giảm số lượng'},
      {'text': '• "Thêm vào giỏ" - Thêm vào giỏ hàng', 'command': 'thêm vào giỏ'},
      {'text': '• "Mua ngay" - Mua sản phẩm ngay', 'command': 'mua ngay'},
      {'text': '• "Đọc thông tin" - Nghe thông tin sản phẩm', 'command': 'đọc thông tin'},
      {'text': '• "Đọc giá" - Nghe thông tin giá cả', 'command': 'đọc giá'},
    ];

    return commands.map((commandData) => Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context) / 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              commandData['text']!,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.text,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleVoiceCommand(commandData['command']!);
              setState(() {
                _isListening = false;
              });
            },
            child: Text(
              'Test',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildVoiceAssistantFAB() {
    return FloatingActionButton(
      onPressed: _toggleVoiceAssistant,
      backgroundColor: _isListening ? AppColors.error : AppColors.secondary,
      foregroundColor: Colors.white,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
          key: ValueKey(_isListening),
          size: ResponsiveHelper.getIconSize(context, 24),
        ),
      ),
      elevation: 6,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              Text(
                'Đang tải thông tin sản phẩm...',
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

    if (_errorMessage != null || _productDetail == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: ResponsiveHelper.getIconSize(context, 80),
                color: AppColors.error,
              ),
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              Text(
                'Không thể tải thông tin sản phẩm',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
              Text(
                _errorMessage ?? 'Đã xảy ra lỗi không xác định',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              ElevatedButton(
                onPressed: _loadProductDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context) * 2,
                    vertical: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                  ),
                ),
                child: Text(
                  'Thử lại',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProductInfo(),
                // _buildElderlySelection(),
                _buildQuantitySelector(),
                if (_isSpeechEnabled) _buildVoiceInstructions(),
                _buildDescription(),
                _buildSpecifications(),
                _buildReviews(),
                _buildRelatedProducts(),
                SizedBox(
                  height: ResponsiveHelper.getExtraLargeSpacing(context),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: _isSpeechEnabled ? _buildVoiceAssistantFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSliverAppBar() {
    final images = _currentVariant?.productImages.isNotEmpty == true
        ? _currentVariant!.productImages.map((img) => img.url).toList()
        : [_getCategoryEmoji(_productDetail!.categories)];

    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      expandedHeight: 300,
      leading: Container(
        margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        // Container(
        //   margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(
        //       ResponsiveHelper.getBorderRadius(context),
        //     ),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.1),
        //         blurRadius: 10,
        //         offset: const Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: IconButton(
        //     icon: Icon(
        //       Icons.favorite_border,
        //       color: AppColors.error,
        //       size: ResponsiveHelper.getIconSize(context, 20),
        //     ),
        //     onPressed: () {
        //       // TODO: Add to favorites
        //     },
        //   ),
        // ),
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
                // Positioned(
                //   right: 8,
                //   top: 8,
                //   child: Container(
                //     padding: const EdgeInsets.all(2),
                //     decoration: BoxDecoration(
                //       color: AppColors.error,
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     constraints: const BoxConstraints(
                //       minWidth: 16,
                //       minHeight: 16,
                //     ),
                //     child: Text(
                //       '3',
                //       style: ResponsiveHelper.responsiveTextStyle(
                //         context: context,
                //         baseSize: 10,
                //         color: Colors.white,
                //         fontWeight: FontWeight.bold,
                //       ),
                //       textAlign: TextAlign.center,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        // // Voice Assistant Button
        // if (_isSpeechEnabled)
        //   Container(
        //     margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        //     decoration: BoxDecoration(
        //       color: _isListening ? AppColors.primary : Colors.white,
        //       borderRadius: BorderRadius.circular(
        //         ResponsiveHelper.getBorderRadius(context),
        //       ),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.1),
        //           blurRadius: 10,
        //           offset: const Offset(0, 2),
        //         ),
        //       ],
        //     ),
        //     child: IconButton(
        //       icon: Icon(
        //         _isListening ? Icons.mic : Icons.mic_none,
        //         color: _isListening ? Colors.white : AppColors.secondary,
        //         size: ResponsiveHelper.getIconSize(context, 20),
        //       ),
        //       onPressed: _toggleVoiceAssistant,
        //     ),
        //   ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: kToolbarHeight + MediaQuery.of(context).padding.top,
              ),
              Expanded(child: _buildImageGallery(images)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context) * 1.2,
              ),
            ),
            child: Center(
              child: _currentVariant?.productImages.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context) * 1.2,
                      ),
                      child: Image.network(
                        images[_selectedImageIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            _getCategoryEmoji(_productDetail!.categories),
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getIconSize(
                                context,
                                120,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      images[_selectedImageIndex],
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getIconSize(context, 120),
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getLargeSpacing(context),
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              bool isSelected = index == _selectedImageIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImageIndex = index;
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.only(
                    right: ResponsiveHelper.getSpacing(context),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _currentVariant?.productImages.isNotEmpty == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context),
                            ),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  _getCategoryEmoji(_productDetail!.categories),
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getIconSize(
                                      context,
                                      24,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            images[index],
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getIconSize(
                                context,
                                24,
                              ),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceInstructions() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.2,
        ),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Tooltip(
                message: 'Nhấn để nghe hướng dẫn sử dụng',
                child: GestureDetector(
                  onTap: () async {
                    if (_isSpeechEnabled) {
                      // Visual feedback
                      setState(() {
                        _isSpeakingInstructions = true;
                      });
                      
                      await _speechService.speakInstructions();
                      
                      // Reset after speaking
                      setState(() {
                        _isSpeakingInstructions = false;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context) / 2),
                    decoration: BoxDecoration(
                      color: _isSpeakingInstructions 
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context),
                      ),
                      border: Border.all(
                        color: _isSpeakingInstructions 
                            ? AppColors.primary.withOpacity(0.5)
                            : AppColors.secondary.withOpacity(0.3),
                        width: _isSpeakingInstructions ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      Icons.volume_up,
                      color: _isSpeakingInstructions ? AppColors.primary : AppColors.secondary,
                      size: ResponsiveHelper.getIconSize(context, 24),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                '🎤 Trợ lý giọng nói ',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Nhấn nút trợ lý giọng nói để điều khiển bằng giọng nói. Bạn có thể nói:',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Wrap(
            spacing: ResponsiveHelper.getSpacing(context),
            runSpacing: ResponsiveHelper.getSpacing(context) / 2,
            children: [
              _buildVoiceChip('Tăng số lượng'),
              _buildVoiceChip('Giảm số lượng'),
              _buildVoiceChip('Thêm vào giỏ'),
              _buildVoiceChip('Mua ngay'),
              _buildVoiceChip('Đọc thông tin'),
              _buildVoiceChip('Đọc giá'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context) / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '"$text"',
        style: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 12,
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    if (_currentVariant == null) return SizedBox.shrink();

    final hasDiscount = _currentVariant!.discount > 0;
    final discountPercent = _currentVariant!.discount;

    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _productDetail!.name,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Thương hiệu: ${_productDetail!.brand}',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          _buildStyleSelection(),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          // _buildVariantSelection(),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),

          Row(
            children: [
              Icon(
                Icons.star,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: Colors.amber,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
              Text(
                '4.5', // TODO: Get from API
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                ' (0 đánh giá)', // TODO: Get from API
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color:
                      _currentVariant!.stock > 0
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context),
                  ),
                ),
                child: Text(
                  _currentVariant!.stock > 0 ? 'Còn hàng' : 'Hết hàng',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 12,
                    color:
                        _currentVariant!.stock > 0
                            ? AppColors.success
                            : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          if (hasDiscount) ...[
            Row(
              children: [
                Text(
                  CurrencyUtils.formatVND(_currentVariant!.originalPrice),
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                  ),
                  child: Text(
                    '-$discountPercent%',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
          ],
          Text(
            CurrencyUtils.formatVND(_currentVariant!.discountedPrice),
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'ID: ${_productDetail!.id}',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelection() {
    if (_productDetail?.styles.isEmpty ?? true) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _productDetail!.styles.map((style) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              '${style.label}:',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Wrap(
              spacing: ResponsiveHelper.getSpacing(context),
              runSpacing: ResponsiveHelper.getSpacing(context),
              children: style.options.map((option) {
                final isSelected = _selectedStyles[style.listOfValueId] == option.id;
                final isAvailable = _isStyleOptionAvailable(style.listOfValueId, option.id);
                
                return GestureDetector(
                  onTap: isAvailable ? () async {
                    setState(() {
                      _selectedStyles[style.listOfValueId] = option.id;
                      
                      // Clear other style selections that are no longer valid
                      _clearInvalidStyleSelections(style.listOfValueId, option.id);
                      
                      // Reset variant selection when style changes
                      _selectedVariantIndex = 0;
                      _selectedImageIndex = 0;
                    });
                    
                    // Voice feedback
                    if (_isSpeechEnabled) {
                      await _speechService.speakStyleSelection(style.label, option.label);
                    }
                  } : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getLargeSpacing(context),
                      vertical: ResponsiveHelper.getSpacing(context),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isAvailable
                              ? AppColors.grey.withOpacity(0.1)
                              : AppColors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context) * 2,
                      ),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary 
                            : isAvailable
                                ? Colors.transparent
                                : AppColors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          option.label,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected 
                                ? Colors.white 
                                : isAvailable
                                    ? AppColors.text
                                    : AppColors.grey,
                          ),
                        ),
                        if (isAvailable) ...[
                          SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getSpacing(context) / 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.white.withOpacity(0.2)
                                  : AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_getAvailableVariantsCount(style.listOfValueId, option.id)}',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected 
                                    ? Colors.white
                                    : AppColors.success,
                              ),
                            ),
                          ),
                        ] else ...[
                          SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getSpacing(context) / 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.close,
                                  size: ResponsiveHelper.getIconSize(context, 8),
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '0',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ignore: unused_element
  Widget _buildVariantSelection() {
    if (_filteredVariants.length <= 1) return SizedBox.shrink();

    return Wrap(
      spacing: ResponsiveHelper.getSpacing(context),
      runSpacing: ResponsiveHelper.getSpacing(context),
      children: _filteredVariants.asMap().entries.map((entry) {
        final index = entry.key;
        final variant = entry.value;
        bool isSelected = _selectedVariantIndex == index;

        // Get variant values for display
        final colorValue = variant.productVariantValues
            .where((v) => v.valueCode.contains('red') || v.valueCode.contains('green') || v.valueCode.contains('blue'))
            .firstOrNull;
        final sizeValue = variant.productVariantValues
            .where((v) => v.valueCode.contains('S') || v.valueCode.contains('M') || v.valueCode.contains('L'))
            .firstOrNull;

        String displayText = '';
        if (colorValue != null && sizeValue != null) {
          displayText = '${colorValue.valueLabel} - ${sizeValue.valueLabel}';
        } else if (colorValue != null) {
          displayText = colorValue.valueLabel;
        } else if (sizeValue != null) {
          displayText = sizeValue.valueLabel;
        } else {
          displayText = 'Phiên bản ${index + 1}';
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedVariantIndex = index;
              _selectedImageIndex = 0; // Reset to first image
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getLargeSpacing(context),
              vertical: ResponsiveHelper.getSpacing(context),
            ),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context) * 2,
              ),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              displayText,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.text,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ignore: unused_element
  Widget _buildElderlySelection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👥 Mua cho người thân',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Wrap(
            spacing: ResponsiveHelper.getSpacing(context),
            runSpacing: ResponsiveHelper.getSpacing(context),
            children:
                _elderlyList.map((elderly) {
                  bool isSelected = _selectedElderly == elderly;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedElderly = elderly;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getLargeSpacing(context),
                        vertical: ResponsiveHelper.getSpacing(context),
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.secondary
                                : AppColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context) * 2,
                        ),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.secondary
                                  : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        elderly,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    if (_currentVariant == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '🔢 Số lượng:',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    size: ResponsiveHelper.getIconSize(context, 20),
                    color: _quantity > 1 ? AppColors.primary : AppColors.grey,
                  ),
                  onPressed:
                      _quantity > 1
                          ? () async {
                            _decreaseQuantity();
                            if (_isSpeechEnabled) {
                              await _speechService.speakQuantityInfo(_quantity);
                            }
                          }
                          : null,
                ),
                Container(
                  width: 50,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    size: ResponsiveHelper.getIconSize(context, 20),
                    color: AppColors.primary,
                  ),
                  onPressed:
                      _quantity <= _currentVariant!.stock
                          ? () async {
                            _increaseQuantity();
                            if (_isSpeechEnabled) {
                              await _speechService.speakQuantityInfo(_quantity);
                            }
                          }
                          : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 Mô tả sản phẩm',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            _productDetail!.description,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚙️ Thông số kỹ thuật',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          _buildSpecRow('Thương hiệu', _productDetail!.brand),
          _buildSpecRow('Trọng lượng', '${_productDetail!.weight}g'),
          _buildSpecRow('Chiều cao', '${_productDetail!.height}cm'),
          _buildSpecRow('Chiều dài', '${_productDetail!.length}cm'),
          _buildSpecRow('Chiều rộng', '${_productDetail!.width}cm'),
          if (_productDetail!.categories.isNotEmpty)
            _buildSpecRow(
              'Danh mục',
              _productDetail!.categories.first.label,
            ),
          _buildSpecRow(
            'Ngày sản xuất',
            '${_productDetail!.manufactureDate.day}/${_productDetail!.manufactureDate.month}/${_productDetail!.manufactureDate.year}',
          ),
          _buildSpecRow(
            'Hạn sử dụng',
            '${_productDetail!.expirationDate.day}/${_productDetail!.expirationDate.month}/${_productDetail!.expirationDate.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '⭐ Đánh giá',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Show all reviews
                },
                child: Text(
                  'Xem tất cả',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: ResponsiveHelper.getIconSize(context, 64),
                  color: AppColors.grey,
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Chưa có đánh giá nào',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Hãy là người đầu tiên đánh giá sản phẩm này!',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔗 Sản phẩm tương tự',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          if (_isLoadingRelated)
            Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              ),
            )
          else if (_relatedErrorMessage != null)
            Center(
              child: Text(
                _relatedErrorMessage!,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.error,
                ),
              ),
            )
          else if (_relatedProducts.isEmpty)
            Center(
              child: Text(
                'Chưa có sản phẩm tương tự',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.grey,
                ),
              ),
            )
          else
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context)),
                itemCount: _relatedProducts.length,
                separatorBuilder: (_, __) => SizedBox(width: ResponsiveHelper.getSpacing(context)),
                itemBuilder: (context, index) {
                  final item = _relatedProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(productId: item['id']),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image area
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              color: AppColors.grey.withOpacity(0.08),
                              child: item['imageUrl'] != null && (item['imageUrl'] as String).isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item['imageUrl'],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Center(
                                        child: Icon(Icons.info_outline_rounded, color: AppColors.grey),
                                      ),
                                    )
                                  : Center(
                                      child: Icon(Icons.info_outline_rounded, color: AppColors.grey),
                                    ),
                            ),
                          ),
                          // Info area
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    CurrencyUtils.formatVND((item['price'] ?? 0) as int),
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_currentVariant == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show message when styles are not fully selected
          if (!_areAllStylesSelected && _productDetail?.styles.isNotEmpty == true)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context),
                ),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.secondary,
                    size: ResponsiveHelper.getIconSize(context, 16),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Expanded(
                    child: Text(
                      'Vui lòng chọn đầy đủ các tùy chọn sản phẩm để thêm vào giỏ hàng',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Video consultation button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startVideoConsultation,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: BorderSide(color: AppColors.secondary),
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.getSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_call,
                    size: ResponsiveHelper.getIconSize(context, 18),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                  Text(
                    '📞 Nhận tư vấn trực tiếp',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          // Add to cart and buy now buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: _addToCartButtonKey,
                  onPressed:
                      _canAddToCart
                          ? () async {
                           log('Add to cart');
                            await _addToCart();
                          }
                          : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _canAddToCart ? AppColors.primary : AppColors.grey,
                    side: BorderSide(color: _canAddToCart ? AppColors.primary : AppColors.grey),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getLargeSpacing(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart,
                        size: ResponsiveHelper.getIconSize(context, 20),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Text(
                        'Thêm vào giỏ',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              // Expanded(
              //   child: ElevatedButton(
              //     onPressed:
              //         _currentVariant!.stock > 0
              //             ? () {
              //               _buyNow();
              //             }
              //             : null,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.primary,
              //       foregroundColor: Colors.white,
              //       padding: EdgeInsets.symmetric(
              //         vertical: ResponsiveHelper.getLargeSpacing(context),
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(
              //           ResponsiveHelper.getBorderRadius(context),
              //         ),
              //       ),
              //       elevation: 0,
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(
              //           Icons.flash_on,
              //           size: ResponsiveHelper.getIconSize(context, 20),
              //         ),
              //         SizedBox(width: ResponsiveHelper.getSpacing(context)),
              //         Text(
              //           'Mua ngay',
              //           style: ResponsiveHelper.responsiveTextStyle(
              //             context: context,
              //             baseSize: 16,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  void _startFlyToCartAnimation() {
    // Get the RenderBox of the add to cart button
    final RenderBox? buttonBox =
        _addToCartButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;

    // Get button position relative to the screen
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;

    // Calculate start position (center of button)
    final double startX = buttonPosition.dx + buttonSize.width / 2;
    final double startY = buttonPosition.dy + buttonSize.height / 2;

    // Cart icon position (approximate - top right)
    final double endX = MediaQuery.of(context).size.width - 60;
    final double endY = MediaQuery.of(context).padding.top + kToolbarHeight / 2;

    // Calculate distance
    final double deltaX = endX - startX;
    final double deltaY = endY - startY;

    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder:
          (context) => AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Calculate current position using curve
              final double progress = _animationController.value;
              final double currentX = startX + (deltaX * progress);
              final double currentY =
                  startY +
                  (deltaY * progress) -
                  (100 * (1 - progress) * progress * 4); // Parabolic arc

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
                            _getCategoryEmoji(_productDetail!.categories),
                            style: TextStyle(fontSize: 28),
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
            'Đã thêm $_quantity ${_productDetail!.name} vào giỏ hàng cho $_selectedElderly! 🎉',
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
              // TODO: Navigate to cart
            },
          ),
        ),
      );
    });
  }

  Future<void> _addToCart() async {
    if (_currentVariant == null) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng đăng nhập để thêm vào giỏ hàng'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Step 1: Load current cart
      log('Loading current cart for user: $userId');
      final cartResult = await _cartService.getCartByCustomerId(userId, 0);
      
      List<CartItem> updatedItems = [];
      
      if (cartResult.isSuccess && cartResult.data != null) {
        // Convert existing cart items to CartItem format
        updatedItems = cartResult.data!.data.items.map((item) => 
          CartItem(
            productVariantId: item.productVariantId,
            quantity: item.quantity,
          )
        ).toList();
        
        log('Current cart has ${updatedItems.length} items');
      } else {
        log('No existing cart found, starting fresh');
      }

      // Step 2: Check if product already exists in cart
      final existingItemIndex = updatedItems.indexWhere(
        (item) => item.productVariantId == _currentVariant!.id
      );

      if (existingItemIndex != -1) {
        // Product exists, update quantity
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = CartItem(
          productVariantId: existingItem.productVariantId,
          quantity: existingItem.quantity + _quantity,
        );
        log('Updated existing item quantity: ${existingItem.quantity} + $_quantity = ${existingItem.quantity + _quantity}');
      } else {
        // Product doesn't exist, add new item
        updatedItems.add(CartItem(
          productVariantId: _currentVariant!.id,
          quantity: _quantity,
        ));
        log('Added new item: ${_currentVariant!.id} with quantity: $_quantity');
      }

      // Step 3: Create updated cart request
      final cartRequest = CartReplaceRequest(
        customerId: userId,
        items: updatedItems,
      );
      
      log('Sending updated cart with ${updatedItems.length} items:');
      log(jsonEncode(cartRequest));

      // Step 4: Call API to update cart
      final result = await _cartService.replaceAllCart(cartRequest);
      
      if (result.isSuccess) {
        log('Cart updated successfully');
        
        // Voice feedback for successful cart addition
        if (_isSpeechEnabled && _productDetail != null) {
          await _speechService.speakCartAction(_productDetail!.name, _quantity);
        }
        
        // Start the fly to cart animation
        _startFlyToCartAnimation();
      } else {
        log('Failed to update cart: ${result.message}');
        final errorMessage = result.message ?? 'Không thể thêm vào giỏ hàng';
        
        if (_isSpeechEnabled) {
          await _speechService.speakError(errorMessage);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      log('Error adding to cart: ${e.toString()}');
      final errorMessage = 'Lỗi: ${e.toString()}';
      
      if (_isSpeechEnabled) {
        await _speechService.speakError(errorMessage);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _buyNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Chuyển đến thanh toán...',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context),
          ),
        ),
      ),
    );
  }

  void _startVideoConsultation() {
    if (_productDetail != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoCallPage(
            productName: _productDetail!.name,
          ),
        ),
      );
    }
  }
}
