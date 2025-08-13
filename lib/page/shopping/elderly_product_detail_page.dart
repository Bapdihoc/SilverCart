import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

import '../../core/utils/responsive_helper.dart';
import '../../models/product_detail_response.dart';
import '../../models/cart_replace_request.dart';

import '../../network/service/product_service.dart';
import '../../network/service/cart_service.dart';
import '../../network/service/speech_service.dart';
import '../video_call/video_call_page.dart';
import '../../injection.dart';
import 'elderly_cart_page.dart';

class ElderlyProductDetailPage extends StatefulWidget {
  final String productId;

  const ElderlyProductDetailPage({super.key, required this.productId});

  @override
  State<ElderlyProductDetailPage> createState() => _ElderlyProductDetailPageState();
}

class _ElderlyProductDetailPageState extends State<ElderlyProductDetailPage>
    with TickerProviderStateMixin {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  int _selectedVariantIndex = 0;
  Map<String, String> _selectedStyles = {}; // Map of styleId -> optionId
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
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

  // Get current variant
  ProductVariant? get _currentVariant => 
      _productDetail?.productVariants != null && 
      _selectedVariantIndex >= 0 && 
      _selectedVariantIndex < _productDetail!.productVariants.length
          ? _productDetail!.productVariants[_selectedVariantIndex] 
          : null;









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
          
          // Auto-select first available variant for elderly users
          if (_productDetail!.productVariants.isNotEmpty) {
            final firstAvailableVariant = _productDetail!.productVariants
                .firstWhere((v) => v.isActive && v.stock > 0, 
                    orElse: () => _productDetail!.productVariants.first);
            
            _selectedVariantIndex = _productDetail!.productVariants.indexOf(firstAvailableVariant);
            
            // Reset image index safely for first variant
            _selectedImageIndex = firstAvailableVariant.productImages.isNotEmpty ? 0 : 0;
            
            // Set the styles for this variant
            for (final variantValue in firstAvailableVariant.productVariantValues) {
              for (final style in _productDetail!.styles) {
                for (final option in style.options) {
                  if (option.id == variantValue.valueId) {
                    _selectedStyles[style.listOfValueId] = option.id;
                    break;
                  }
                }
              }
            }
          }
        });
        
        if (_isSpeechEnabled) {
          await _speechService.speak('Chào mừng bạn đến với ${_productDetail!.name}');
        }
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
          '${_currentVariant!.originalPrice.toInt()}',
          '${_currentVariant!.discountedPrice.toInt()}',
          '${_currentVariant!.discount}',
        );
      } else {
        await _speechService.speak('Giá sản phẩm: ${_currentVariant!.discountedPrice.toInt()} đồng');
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
                'Đang tải thông tin sản phẩm...',
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
        ),
      );
    }

    if (_errorMessage != null || _productDetail == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildElderlyAppBar(),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 120),
                  height: ResponsiveHelper.getIconSize(context, 120),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: ResponsiveHelper.getIconSize(context, 60),
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 1.5),
                Text(
                  'Không thể tải thông tin sản phẩm',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 28,
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
                    baseSize: 20,
                    color: AppColors.grey,
                  ).copyWith(height: 1.4),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 2),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loadProductDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.getLargeSpacing(context) * 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Thử lại',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildElderlyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildElderlyImageSection(),
            _buildElderlyProductInfo(),
            _buildElderlyVariantSelection(),
            _buildElderlyQuantitySelector(),
            if (_isSpeechEnabled) _buildElderlyVoiceInstructions(),
            _buildElderlyDescription(),
            _buildElderlySpecifications(),
            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          ],
        ),
      ),
      bottomNavigationBar: _buildElderlyBottomBar(),
      floatingActionButton: _isSpeechEnabled ? _buildVoiceAssistantFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildElderlyAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: ResponsiveHelper.getIconSize(context, 80),
      leading: Container(
        margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.primary,
            size: ResponsiveHelper.getIconSize(context, 32),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        'Chi tiết sản phẩm',
        style: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
      centerTitle: false,
      actions: [
        // Shopping Cart Button
        Container(
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.shopping_cart_rounded,
              color: AppColors.primary,
              size: ResponsiveHelper.getIconSize(context, 28),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ElderlyCartPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildElderlyImageSection() {
    final images = _currentVariant?.productImages.isNotEmpty == true
        ? _currentVariant!.productImages.map((img) => img.url).toList()
        : [_getCategoryEmoji(_productDetail!.categories)];
    
    // Ensure selectedImageIndex is within bounds
    if (_selectedImageIndex >= images.length) {
      _selectedImageIndex = 0;
    }

    return Container(
      height: ResponsiveHelper.getIconSize(context, 300),
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main image
          Expanded(
            child: Container(
              margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: _currentVariant?.productImages.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          images[_selectedImageIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              _getCategoryEmoji(_productDetail!.categories),
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getIconSize(context, 100),
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        images[_selectedImageIndex],
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getIconSize(context, 100),
                        ),
                      ),
              ),
            ),
          ),
          
          // Image thumbnails (simplified for elderly)
          if (images.length > 1) ...[
            SizedBox(
              height: ResponsiveHelper.getIconSize(context, 80),
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
                      width: ResponsiveHelper.getIconSize(context, 80),
                      height: ResponsiveHelper.getIconSize(context, 80),
                      margin: EdgeInsets.only(
                        right: ResponsiveHelper.getSpacing(context),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: _currentVariant?.productImages.isNotEmpty == true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.network(
                                  images[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      _getCategoryEmoji(_productDetail!.categories),
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getIconSize(context, 30),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                images[index],
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getIconSize(context, 30),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildElderlyProductInfo() {
    if (_currentVariant == null) return SizedBox.shrink();

    final hasDiscount = _currentVariant!.discount > 0;
    final discountPercent = _currentVariant!.discount;

    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name - Large and bold for elderly
          Text(
            _productDetail!.name,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ).copyWith(height: 1.3),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context) * 1.5),
          
          // Brand info
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getSpacing(context) * 1.5,
              vertical: ResponsiveHelper.getSpacing(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Thương hiệu: ${_productDetail!.brand}',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Stock status - Large and clear
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getLargeSpacing(context),
              vertical: ResponsiveHelper.getSpacing(context),
            ),
            decoration: BoxDecoration(
              color: _currentVariant!.stock > 0
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _currentVariant!.stock > 0
                    ? AppColors.success
                    : AppColors.error,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _currentVariant!.stock > 0 ? Icons.check_circle : Icons.cancel,
                  color: _currentVariant!.stock > 0 ? AppColors.success : AppColors.error,
                  size: ResponsiveHelper.getIconSize(context, 24),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  _currentVariant!.stock > 0 ? 'Còn hàng' : 'Hết hàng',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    color: _currentVariant!.stock > 0 ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Price section - Very prominent for elderly
          if (hasDiscount) ...[
            Row(
              children: [
                Text(
                  'Giá gốc: ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  '${_currentVariant!.originalPrice.toInt()}đ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Giảm $discountPercent%',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
          ],
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Giá bán:',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                Text(
                  '${_currentVariant!.discountedPrice.toInt()}đ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create combined variant options for elderly users
  List<Map<String, dynamic>> _getCombinedVariantOptions() {
    if (_productDetail?.productVariants.isEmpty ?? true) return [];
    
    return _productDetail!.productVariants.where((variant) => variant.isActive && variant.stock > 0).map((variant) {
      // Combine all variant values into a single readable label
      final valueLabels = variant.productVariantValues.map((value) => value.valueLabel).toList();
      final combinedLabel = valueLabels.join(' - ');
      
      // Create a map of style selections for this variant
      final variantStyles = <String, String>{};
      for (final variantValue in variant.productVariantValues) {
        // Find the corresponding style for this value
        for (final style in _productDetail!.styles) {
          for (final option in style.options) {
            if (option.id == variantValue.valueId) {
              variantStyles[style.listOfValueId] = option.id;
              break;
            }
          }
        }
      }
      
      return {
        'variant': variant,
        'label': combinedLabel,
        'styles': variantStyles,
        'price': variant.discountedPrice,
        'originalPrice': variant.originalPrice,
        'stock': variant.stock,
      };
    }).toList();
  }

  Widget _buildElderlyVariantSelection() {
    if (_productDetail?.productVariants.isEmpty ?? true) return SizedBox.shrink();
    
    final combinedOptions = _getCombinedVariantOptions();
    if (combinedOptions.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎨 Chọn loại sản phẩm',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Chọn 1 trong các tùy chọn bên dưới:',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Combined variant options - one choice for elderly
          ...combinedOptions.map((optionData) {
            final variant = optionData['variant'] as ProductVariant;
            final label = optionData['label'] as String;
            final styles = optionData['styles'] as Map<String, String>;
            final price = optionData['price'] as double;
            final originalPrice = optionData['originalPrice'] as double;
            final stock = optionData['stock'] as int;
            
            // Check if this variant is currently selected
            final isSelected = _currentVariant?.id == variant.id;
            
            return Container(
              margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    // Set all the styles for this variant
                    _selectedStyles.clear();
                    _selectedStyles.addAll(styles);
                    
                    // Update current variant
                    _selectedVariantIndex = _productDetail!.productVariants.indexOf(variant);
                    
                    // Reset image index safely
                    _selectedImageIndex = variant.productImages.isNotEmpty ? 0 : 0;
                  });
                  
                  if (_isSpeechEnabled) {
                    await _speechService.speak('Đã chọn $label');
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : Colors.grey.withOpacity(0.2),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Selection indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                      
                      // Option details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : AppColors.text,
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                            Row(
                              children: [
                                Text(
                                  '${price.toStringAsFixed(0)}đ',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (originalPrice > price) ...[
                                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                                  Text(
                                    '${originalPrice.toStringAsFixed(0)}đ',
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 14,
                                      color: AppColors.grey,
                                    ).copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveHelper.getSpacing(context),
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Còn $stock',
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
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
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildElderlyQuantitySelector() {
    if (_currentVariant == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔢 Số lượng mua:',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Large quantity selector for elderly
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Decrease button - Large and clear
                Container(
                  width: ResponsiveHelper.getIconSize(context, 80),
                  height: ResponsiveHelper.getIconSize(context, 80),
                  decoration: BoxDecoration(
                    color: _quantity > 1 ? AppColors.error : AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.remove,
                      size: ResponsiveHelper.getIconSize(context, 36),
                      color: _quantity > 1 ? Colors.white : AppColors.grey,
                    ),
                    onPressed: _quantity > 1 ? () async {
                      _decreaseQuantity();
                      if (_isSpeechEnabled) {
                        await _speechService.speakQuantityInfo(_quantity);
                      }
                    } : null,
                  ),
                ),
                
                // Quantity display - Large and prominent
                Expanded(
                  child: Container(
                    height: ResponsiveHelper.getIconSize(context, 80),
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        '$_quantity',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Increase button - Large and clear
                Container(
                  width: ResponsiveHelper.getIconSize(context, 80),
                  height: ResponsiveHelper.getIconSize(context, 80),
                  decoration: BoxDecoration(
                    color: _quantity < _currentVariant!.stock ? AppColors.success : AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.add,
                      size: ResponsiveHelper.getIconSize(context, 36),
                      color: _quantity < _currentVariant!.stock ? Colors.white : AppColors.grey,
                    ),
                    onPressed: _quantity < _currentVariant!.stock ? () async {
                      _increaseQuantity();
                      if (_isSpeechEnabled) {
                        await _speechService.speakQuantityInfo(_quantity);
                      }
                    } : null,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Stock info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Còn lại: ${_currentVariant!.stock} sản phẩm',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderlyVoiceInstructions() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                decoration: BoxDecoration(
                  color: _isSpeakingInstructions 
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isSpeakingInstructions 
                        ? AppColors.primary
                        : AppColors.secondary,
                    width: 2,
                  ),
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (_isSpeechEnabled) {
                      setState(() {
                        _isSpeakingInstructions = true;
                      });
                      
                      await _speechService.speakInstructions();
                      
                      setState(() {
                        _isSpeakingInstructions = false;
                      });
                    }
                  },
                  child: Icon(
                    Icons.volume_up,
                    color: _isSpeakingInstructions ? AppColors.primary : AppColors.secondary,
                    size: ResponsiveHelper.getIconSize(context, 32),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: Text(
                  '🎤 Trợ lý giọng nói',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Nhấn nút trợ lý giọng nói để điều khiển bằng giọng nói. Bạn có thể nói:',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              color: AppColors.text,
            ).copyWith(height: 1.4),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Voice commands using Wrap for better layout
          Wrap(
            spacing: ResponsiveHelper.getSpacing(context),
            runSpacing: ResponsiveHelper.getSpacing(context),
            children: [
              _buildElderlyVoiceChip('Tăng số lượng'),
              _buildElderlyVoiceChip('Giảm số lượng'),
              _buildElderlyVoiceChip('Thêm vào giỏ'),
              _buildElderlyVoiceChip('Đọc thông tin'),
              _buildElderlyVoiceChip('Đọc giá'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElderlyVoiceChip(String text) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '"$text"',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildElderlyDescription() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
              baseSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _productDetail!.description,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                color: AppColors.text,
              ).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderlySpecifications() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
              baseSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Larger specification rows for elderly
          _buildElderlySpecRow('Thương hiệu', _productDetail!.brand),
          _buildElderlySpecRow('Trọng lượng', '${_productDetail!.weight}g'),
          _buildElderlySpecRow('Kích thước', '${_productDetail!.length} x ${_productDetail!.width} x ${_productDetail!.height} cm'),
          if (_productDetail!.categories.isNotEmpty)
            _buildElderlySpecRow('Danh mục', _productDetail!.categories.first.label),
          _buildElderlySpecRow(
            'Hạn sử dụng',
            '${_productDetail!.expirationDate.day}/${_productDetail!.expirationDate.month}/${_productDetail!.expirationDate.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildElderlySpecRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderlyBottomBar() {
    if (_currentVariant == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video consultation button - Prominent for elderly
          SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.getIconSize(context, 60),
            child: OutlinedButton(
              onPressed: _startVideoConsultation,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: BorderSide(color: AppColors.secondary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_call,
                    size: ResponsiveHelper.getIconSize(context, 28),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    '📞 Nhận tư vấn trực tiếp',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Single large add to cart button for elderly
          SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.getIconSize(context, 70),
            child: ElevatedButton(
              key: _addToCartButtonKey,
              onPressed: _currentVariant!.stock > 0 ? () async {
                await _addToCart();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    size: ResponsiveHelper.getIconSize(context, 32),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Thêm vào giỏ hàng',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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
      builder: (context) => AnimatedBuilder(
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
            'Đã thêm $_quantity ${_productDetail!.name} vào giỏ hàng! 🎉',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
            content: Text(
              'Vui lòng đăng nhập để thêm vào giỏ hàng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
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
            content: Text(
              errorMessage,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          content: Text(
            errorMessage,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
