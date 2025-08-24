import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silvercart/page/home.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/cart_get_response.dart';
import '../../models/cart_replace_request.dart';
import '../../models/user_detail_response.dart';
import '../../models/elder_list_response.dart';
import '../../network/service/cart_service.dart';
import '../../network/service/auth_service.dart';
import '../../network/service/elder_service.dart';
import '../../network/service/order_service.dart';
import '../../network/service/promotion_service.dart';
import '../../network/service/wallet_service.dart';
import '../../network/service/shipping_service.dart';
import '../../models/create_order_request.dart';
import '../../models/create_order_response.dart';
import '../../models/promotion_response.dart';
import '../../core/models/base_response.dart';
import '../../injection.dart';
import 'package:url_launcher/url_launcher.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  int _currentStep = 0;
  String? _selectedAddressId;
  String? _selectedElderlyId;
  String _paymentMethod = 'Wallet';

  // Helper method to get effective payment method (auto-switch if wallet insufficient)
  String get _effectivePaymentMethod {
    if (_paymentMethod == 'Wallet' && !_hasEnoughWalletBalance) {
      return 'VNPay'; // Auto fallback to VNPay
    }
    return _paymentMethod;
  }
  String _note = '';

  // API data
  CartGetData? _cartData;
  bool _isLoading = true;
  String? _errorMessage;
  late final CartService _cartService;
  late final AuthService _authService;
  late final ElderService _elderService;
  late final OrderService _orderService;
  late final PromotionService _promotionService;
  late final WalletService _walletService;
  late final ShippingService _shippingService;

  // Address and elderly data
  List<UserDetailAddress> _userAddresses = [];
  List<ElderData> _elderlyList = [];
  Map<String, List<ElderAddressData>> _elderlyAddresses = {};
  bool _isLoadingAddresses = false;
  String? _addressErrorMessage;

  // Promotion data
  List<PromotionData> _promotions = [];
  bool _isLoadingPromotions = false;
  String? _promotionErrorMessage;
  String? _selectedPromotionId;

  // Wallet data
  double _walletBalance = 0;
  bool _isLoadingWallet = false;
  String? _walletErrorMessage;
  
  // Shipping data
  double _shippingFee = 20000; // Default shipping fee
  bool _isLoadingShipping = false;
  String? _shippingErrorMessage;

  // Convert API data to UI format
  List<Map<String, dynamic>> get _cartItems {
    if (_cartData?.items == null) return [];

    return _cartData!.items
        .map(
          (item) => {
            'id': item.productVariantId,
            'name': item.productName,
            'emoji': _getProductEmoji(item.productName),
            'price': item.productPrice,
            'quantity': item.quantity,
            'elderly': _getSelectedElderlyName(),
            'imageUrl': item.imageUrl,
          },
        )
        .toList();
  }

  // Helper method to get product emoji
  String _getProductEmoji(String productName) {
    final name = productName.toLowerCase();

    if (name.contains('gạo') || name.contains('rice')) return '🌾';
    if (name.contains('thuốc') || name.contains('medicine')) return '💊';
    if (name.contains('dầu gội') || name.contains('shampoo')) return '🧴';
    if (name.contains('gậy') || name.contains('cane')) return '🦯';
    if (name.contains('máy đo') || name.contains('monitor')) return '📊';
    if (name.contains('áo') || name.contains('shirt')) return '👕';
    if (name.contains('quần') || name.contains('pants')) return '👖';
    if (name.contains('giày') || name.contains('shoes')) return '👟';
    if (name.contains('mũ') || name.contains('hat')) return '🧢';
    if (name.contains('túi') || name.contains('bag')) return '👜';

    return '📦'; // Default emoji
  }

  // Helper methods for getting selected data
  String _getSelectedElderlyName() {
    if (_selectedElderlyId == null) return 'Chọn người nhận';
    final elder = _elderlyList.firstWhere(
      (elder) => elder.id == _selectedElderlyId,
      orElse:
          () => ElderData(
            id: '',
            fullName: 'Không xác định',
            userName: '',
            birthDate: DateTime.now(),
            spendLimit: 0,
            emergencyPhoneNumber: '',
            relationShip: '',
            isDelete: false,
            gender: 0,
            addresses: [],
            categories: [],
          ),
    );
    return elder.fullName;
  }

  String _getSelectedAddressText() {
    if (_selectedAddressId == null) return 'Chọn địa chỉ giao hàng';

    // Check user addresses first
    for (final address in _userAddresses) {
      if (address.id == _selectedAddressId) {
        return '🏠 ${address.streetAddress}, ${address.wardName}, ${address.districtName}, ${address.provinceName}';
      }
    }

    // Check elderly addresses with owner info
    for (final entry in _elderlyAddresses.entries) {
      final elderId = entry.key;
      final addresses = entry.value;

      for (final address in addresses) {
        if (address.id == _selectedAddressId) {
          final elder = _elderlyList.firstWhere((e) => e.id == elderId);
          return '👤 ${elder.fullName}\n🏠 ${address.streetAddress}, ${address.wardName}, ${address.districtName}, ${address.provinceName}';
        }
      }
    }

    return 'Địa chỉ không tìm thấy';
  }

  void _updateAddressForSelectedElderly() {
    if (_selectedElderlyId == null) return;

    // Check if selected elderly has addresses
    final elderlyAddresses = _elderlyAddresses[_selectedElderlyId];

    if (elderlyAddresses != null && elderlyAddresses.isNotEmpty) {
      // Auto-select first address of the selected elderly
      _selectedAddressId = elderlyAddresses.first.id;
    } else {
      // Fallback to user's first address if elderly has no address
      if (_userAddresses.isNotEmpty) {
        _selectedAddressId = _userAddresses.first.id;
      } else {
        // No addresses available
        _selectedAddressId = null;
      }
    }
    
    // Load shipping fee for the new address
    if (_selectedAddressId != null) {
      _loadShippingFee();
    }
  }

  @override
  void initState() {
    super.initState();
    _cartService = getIt<CartService>();
    _authService = getIt<AuthService>();
    _elderService = getIt<ElderService>();
    _orderService = getIt<OrderService>();
    _promotionService = getIt<PromotionService>();
    _walletService = getIt<WalletService>();
    _shippingService = getIt<ShippingService>();
    _loadCartData();
    _loadAddressData();
    _loadPromotions();
    _loadWalletBalance();
  }

  Future<void> _loadCartData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        setState(() {
          _errorMessage = 'Vui lòng đăng nhập để xem giỏ hàng';
          _isLoading = false;
        });
        return;
      }

      // Call API to get cart data
      final result = await _cartService.getCartByCustomerId(userId, 0);

      if (result.isSuccess && result.data != null) {
        setState(() {
          _cartData = result.data!.data;
          log('Test Cart: ${_cartData?.cartId}');
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải giỏ hàng';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải giỏ hàng: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAddressData() async {
    setState(() {
      _isLoadingAddresses = true;
      _addressErrorMessage = null;
    });

    try {
      // Get current user ID
      final userId = await _authService.getUserId();
      if (userId == null) {
        setState(() {
          _addressErrorMessage = 'Vui lòng đăng nhập để xem địa chỉ';
          _isLoadingAddresses = false;
        });
        return;
      }

      // Load user addresses and elderly data in parallel
      final userDetailResult = _authService.getUserDetail(userId);
      final elderlyResult = _elderService.getMyElders();

      final results = await Future.wait([userDetailResult, elderlyResult]);
      final userDetailResponse = results[0];
      final elderlyResponse = results[1];

      if (userDetailResponse.isSuccess && userDetailResponse.data != null) {
        final userData = userDetailResponse.data as UserDetailResponse;
        _userAddresses = userData.data.addresses;
      }

      if (elderlyResponse.isSuccess && elderlyResponse.data != null) {
        final elderlyData = elderlyResponse.data as ElderListResponse;
        _elderlyList = elderlyData.data;

        // Extract addresses from each elderly
        _elderlyAddresses.clear();
        for (final elder in _elderlyList) {
          if (elder.addresses.isNotEmpty) {
            _elderlyAddresses[elder.id] = elder.addresses;
          }
        }

        // Set default elderly selection if available
        if (_elderlyList.isNotEmpty && _selectedElderlyId == null) {
          _selectedElderlyId = _elderlyList.first.id;
        }
      }

      // Update address based on selected elderly, or set default
      if (_selectedElderlyId != null) {
        _updateAddressForSelectedElderly();
      } else {
        // Set default address selection if no elderly selected
        if (_userAddresses.isNotEmpty && _selectedAddressId == null) {
          _selectedAddressId = _userAddresses.first.id;
        } else if (_elderlyAddresses.isNotEmpty && _selectedAddressId == null) {
          final firstElderlyAddresses = _elderlyAddresses.values.first;
          if (firstElderlyAddresses.isNotEmpty) {
            _selectedAddressId = firstElderlyAddresses.first.id;
          }
        }
      }

      setState(() {
        _isLoadingAddresses = false;
      });
      
      // Load shipping fee for the default address
      if (_selectedAddressId != null) {
        _loadShippingFee();
      }
    } catch (e) {
      setState(() {
        _addressErrorMessage = 'Lỗi tải địa chỉ: ${e.toString()}';
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _loadPromotions() async {
    setState(() {
      _isLoadingPromotions = true;
      _promotionErrorMessage = null;
    });

    try {
      final result = await _promotionService.getAllPromotions();
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _promotions = result.data!.data
              .where((promo) => promo.isValidAndActive)
              .toList();
          _isLoadingPromotions = false;
        });
      } else {
        setState(() {
          _promotionErrorMessage = result.message ?? 'Không thể tải mã giảm giá';
          _isLoadingPromotions = false;
        });
      }
    } catch (e) {
      setState(() {
        _promotionErrorMessage = 'Lỗi tải mã giảm giá: ${e.toString()}';
        _isLoadingPromotions = false;
      });
    }
  }

  Future<void> _loadWalletBalance() async {
    setState(() {
      _isLoadingWallet = true;
      _walletErrorMessage = null;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        setState(() {
          _walletBalance = 0;
          _isLoadingWallet = false;
        });
        return;
      }

      final result = await _walletService.getWalletAmount(userId);
      if (result.isSuccess && result.data != null) {
        setState(() {
          _walletBalance = result.data!.data.amount;
          _isLoadingWallet = false;
        });
      } else {
        setState(() {
          _walletErrorMessage = result.message ?? 'Không thể tải số dư ví';
          _walletBalance = 0;
          _isLoadingWallet = false;
        });
      }
    } catch (e) {
      setState(() {
        _walletErrorMessage = 'Lỗi tải số dư ví: ${e.toString()}';
        _walletBalance = 0;
        _isLoadingWallet = false;
      });
    }
  }

  Future<void> _loadShippingFee() async {
    if (_selectedAddressId == null) return;
    
    setState(() {
      _isLoadingShipping = true;
      _shippingErrorMessage = null;
    });

    try {
      final result = await _shippingService.recalcShippingFee(_selectedAddressId!);
      if (result.isSuccess && result.data != null) {
        setState(() {
          _shippingFee = result.data!.data.fee;
          _isLoadingShipping = false;
        });
      } else {
        setState(() {
          _shippingErrorMessage = result.message ?? 'Không thể tải phí vận chuyển';
          _isLoadingShipping = false;
        });
      }
    } catch (e) {
      setState(() {
        _shippingErrorMessage = 'Lỗi tải phí vận chuyển: ${e.toString()}';
        _isLoadingShipping = false;
      });
    }
  }

  // Helper method to check if wallet has enough balance
  bool get _hasEnoughWalletBalance {
    if (_isLoadingWallet) return false;
    
    double subtotal = _cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
    double shipping = 20000;
    
    // Calculate discount from selected promotion
    double discount = 0;
    if (_selectedPromotionId != null) {
      final selectedPromo = _promotions.firstWhere(
        (promo) => promo.id == _selectedPromotionId,
        orElse: () => _promotions.first,
      );
      discount = subtotal * (selectedPromo.discountPercent / 100);
    }
    
    double total = subtotal + shipping - discount;
    return _walletBalance >= total;
  }

  Future<void> _removeItemFromCart(int index) async {
    if (_cartData?.items == null || index >= _cartData!.items.length) return;

    try {
      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Create updated cart items (remove the item at index)
      final updatedItems = <CartItem>[];
      for (int i = 0; i < _cartData!.items.length; i++) {
        if (i != index) {
          updatedItems.add(
            CartItem(
              productVariantId: _cartData!.items[i].productVariantId,
              quantity: _cartData!.items[i].quantity,
            ),
          );
        }
      }

      // Create cart request
      final cartRequest = CartReplaceRequest(
        customerId: userId,
        items: updatedItems,
      );

      // Call API to update cart
      final result = await _cartService.replaceAllCart(cartRequest);

      if (result.isSuccess) {
        // Reload cart data to reflect changes
        await _loadCartData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể xóa sản phẩm'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateItemQuantity(int index, int newQuantity) async {
    if (_cartData?.items == null || index >= _cartData!.items.length) return;
    if (newQuantity <= 0) {
      await _removeItemFromCart(index);
      return;
    }

    try {
      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Create updated cart items with new quantity
      final updatedItems = <CartItem>[];
      for (int i = 0; i < _cartData!.items.length; i++) {
        final item = _cartData!.items[i];
        updatedItems.add(
          CartItem(
            productVariantId: item.productVariantId,
            quantity: i == index ? newQuantity : item.quantity,
          ),
        );
      }

      // Create cart request
      final cartRequest = CartReplaceRequest(
        customerId: userId,
        items: updatedItems,
      );

      // Call API to update cart
      final result = await _cartService.replaceAllCart(cartRequest);

      if (result.isSuccess) {
        // Reload cart data to reflect changes
        await _loadCartData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể cập nhật số lượng'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Giỏ hàng (${_cartItems.length})',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
    
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _cartItems.isEmpty
              ? _buildEmptyCart()
              : _buildStepContent(),
      bottomNavigationBar: _cartItems.isNotEmpty ? _buildStepBottomBar() : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 80),
            height: ResponsiveHelper.getIconSize(context, 80),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Đang tải giỏ hàng...',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 100),
            height: ResponsiveHelper.getIconSize(context, 100),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              size: ResponsiveHelper.getIconSize(context, 50),
              color: AppColors.error,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Giỏ hàng trống',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Mua sắm ngay để có những sản phẩm tốt nhất cho người thân',
            // _errorMessage ?? 'Đã xảy ra lỗi không xác định',
            textAlign: TextAlign.center,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getExtraLargeSpacing(context),
                  vertical: ResponsiveHelper.getLargeSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 20),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Mua sắm ngay',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 100),
            height: ResponsiveHelper.getIconSize(context, 100),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: ResponsiveHelper.getIconSize(context, 50),
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Giỏ hàng trống',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng\nđể mua sắm cho người thân',
            textAlign: TextAlign.center,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getExtraLargeSpacing(context),
                  vertical: ResponsiveHelper.getLargeSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_rounded, size: 20),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Tiếp tục mua sắm',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildStepContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStepIndicator(),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          _buildCurrentStepContent(),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Sản phẩm', 'Địa chỉ giao hàng', 'Thanh toán'];

    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children:
            steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: ResponsiveHelper.getIconSize(context, 32),
                      height: ResponsiveHelper.getIconSize(context, 32),
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? AppColors.success
                                : isActive
                                ? AppColors.primary
                                : AppColors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_rounded
                            : Icons.circle_rounded,
                        size: ResponsiveHelper.getIconSize(context, 16),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Expanded(
                      child: Text(
                        step,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppColors.primary : AppColors.grey,
                        ),
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 20,
                        height: 1,
                        color:
                            isCompleted
                                ? AppColors.success
                                : AppColors.grey.withOpacity(0.3),
                      ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1CartItems();
      case 1:
        return _buildStep2Address();
      case 2:
        return _buildStep3Checkout();
      default:
        return _buildStep1CartItems();
    }
  }

  Widget _buildStep1CartItems() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildModernCartItem(_cartItems[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Address() {
    return Column(
      children: [
        _buildCompactElderlySelection(),
        _buildCompactAddressSelection(),
      ],
    );
  }

  Widget _buildStep3Checkout() {
    return Column(
      children: [
        _buildCompactPaymentMethod(),
        _buildPromotionSection(),
        _buildCompactOrderNote(),
        _buildModernOrderSummary(),
      ],
    );
  }

  Widget _buildModernCartItem(Map<String, dynamic> item, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:
                    item['imageUrl'] != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  item['emoji'],
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getIconSize(
                                      context,
                                      20,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : Center(
                          child: Text(
                            item['emoji'],
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getIconSize(context, 20),
                            ),
                          ),
                        ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
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
                    // Container(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: ResponsiveHelper.getSpacing(context),
                    //     vertical: 2,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.secondary.withOpacity(0.1),
                    //     borderRadius: BorderRadius.circular(8),
                    //     border: Border.all(
                    //       color: AppColors.secondary.withOpacity(0.3),
                    //       width: 1,
                    //     ),
                    //   ),
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Icon(
                    //         Icons.person_rounded,
                    //         size: 12,
                    //         color: AppColors.secondary,
                    //       ),
                    //       SizedBox(width: 4),
                    //       Text(
                    //         item['elderly'],
                    //         style: ResponsiveHelper.responsiveTextStyle(
                    //           context: context,
                    //           baseSize: 10,
                    //           color: AppColors.secondary,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                     Row(
                      children: [
                           if (item['originalPrice'] != null) ...[
                          Text(
                            CurrencyUtils.formatVND(item['originalPrice']),
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 12,
                              color: AppColors.grey,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                        ],
                        Text(
                          CurrencyUtils.formatVND(item['price']),
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                     ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: 12,
                                    color:
                                        item['quantity'] > 1
                                            ? AppColors.primary
                                            : AppColors.grey,
                                  ),
                                ),
                                onTap:
                                    item['quantity'] > 1
                                        ? () async {
                                          await _updateItemQuantity(
                                            index,
                                            item['quantity'] - 1,
                                          );
                                        }
                                        : null,
                              ),
                              Container(
                                width: 25,
                                child: Text(
                                  '${item['quantity']}',
                                  textAlign: TextAlign.center,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                                onTap: () async {
                                  await _updateItemQuantity(
                                    index,
                                    item['quantity'] + 1,
                                  );
                                },
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
        // X button floating outside the card
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => _removeFromCart(index),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactElderlySelection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 28),
                height: ResponsiveHelper.getIconSize(context, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: ResponsiveHelper.getIconSize(context, 14),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Giao hàng cho',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          SizedBox(
            height: 36,
            child:
                _isLoadingAddresses
                    ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                    : _elderlyList.isEmpty
                    ? Center(
                      child: Text(
                        'Không có người thân nào',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    )
                    : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _elderlyList.length,
                      separatorBuilder:
                          (context, index) => SizedBox(
                            width: ResponsiveHelper.getSpacing(context),
                          ),
                      itemBuilder: (context, index) {
                        final elderly = _elderlyList[index];
                        bool isSelected = _selectedElderlyId == elderly.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedElderlyId = elderly.id;
                              // Auto-select address for the selected elderly
                              _updateAddressForSelectedElderly();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getSpacing(context),
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.secondary
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.secondary
                                        : AppColors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                elderly.fullName,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.text,
                                ),
                              ),
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

  Widget _buildCompactAddressSelection() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 40),
            height: ResponsiveHelper.getIconSize(context, 40),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: ResponsiveHelper.getIconSize(context, 20),
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Địa chỉ giao hàng',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _getSelectedAddressText(),
                    key: ValueKey(_selectedAddressId ?? 'no-address'),
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              onPressed: () => _showAddressSelection(),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.all(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPaymentMethod() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 28),
                height: ResponsiveHelper.getIconSize(context, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  size: ResponsiveHelper.getIconSize(context, 14),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Thanh toán',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context)),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: ResponsiveHelper.getSpacing(context)),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0: // Wallet
                    return _buildPaymentMethodCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Ví SilverCart',
                      subtitle: _isLoadingWallet 
                          ? 'Đang tải...'
                          : _walletErrorMessage != null
                              ? 'Lỗi tải ví'
                              : 'Số dư: ${CurrencyUtils.formatVND(_walletBalance)}',
                      isSelected: _paymentMethod == 'Wallet',
                      isDisabled: !_hasEnoughWalletBalance,
                      color: AppColors.success,
                      onTap: _hasEnoughWalletBalance ? () {
                        setState(() {
                          _paymentMethod = 'Wallet';
                        });
                      } : null,
                      showWarning: !_hasEnoughWalletBalance && !_isLoadingWallet && _walletErrorMessage == null,
                    );
                  case 1: // VNPay
                    return _buildPaymentMethodCard(
                      icon: Icons.money_rounded,
                      title: 'VNPAY',
                      subtitle: 'Thanh toán online',
                      isSelected: _paymentMethod == 'VNPay',
                      isDisabled: false,
                      color: AppColors.primary,
                      onTap: () {
                        setState(() {
                          _paymentMethod = 'VNPay';
                        });
                      },
                      showWarning: false,
                    );
                  case 2: // PayOS
                    return _buildPaymentMethodCard(
                      icon: Icons.credit_card_rounded,
                      title: 'PAYOS',
                      subtitle: 'Thẻ tín dụng',
                      isSelected: _paymentMethod == 'PayOS',
                      isDisabled: false,
                      color: AppColors.secondary,
                      onTap: () {
                        setState(() {
                          _paymentMethod = 'PayOS';
                        });
                      },
                      showWarning: false,
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionSection() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 28),
                height: ResponsiveHelper.getIconSize(context, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  size: ResponsiveHelper.getIconSize(context, 14),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Mã giảm giá',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              if (_isLoadingPromotions)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          if (_isLoadingPromotions)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                child: Text(
                  'Đang tải mã giảm giá...',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ),
            )
          else if (_promotionErrorMessage != null)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 32,
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    Text(
                      _promotionErrorMessage!,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    TextButton(
                      onPressed: _loadPromotions,
                      child: Text(
                        'Thử lại',
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
              ),
            )
          else if (_promotions.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                child: Column(
                  children: [
                    Icon(
                      Icons.discount_outlined,
                      color: AppColors.grey,
                      size: 32,
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    Text(
                      'Không có mã giảm giá khả dụng',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context)),
                itemCount: _promotions.length,
                separatorBuilder: (_, __) => SizedBox(width: ResponsiveHelper.getSpacing(context)),
                itemBuilder: (context, index) {
                  final promotion = _promotions[index];
                  final isSelected = _selectedPromotionId == promotion.id;
                  
                  return GestureDetector(
                    onTap: () {
                      // setState(() {
                      //   _selectedPromotionId = isSelected ? null : promotion.id;
                      // });
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 200,
                          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: 
                                [
                                      AppColors.primary,
                                      AppColors.primary.withOpacity(0.8),
                                    ]
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.elderlyWarning
                                  : AppColors.warning.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withOpacity(isSelected ? 0.3 : 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveHelper.getSpacing(context) / 2,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:  AppColors.warning,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${promotion.discountPercent}%',
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                              Text(
                                promotion.title.isNotEmpty
                                    ? promotion.title
                                    : 'Giảm ${promotion.discountPercent}%',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white ,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                              Text(
                                promotion.description.isNotEmpty
                                    ? promotion.description
                                    : 'Áp dụng cho đơn hàng',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 12,
                                  color:  Colors.white.withOpacity(0.9)
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Text(
                                'HSD: ${promotion.formattedPeriod}',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 10,
                                  color: Colors.white.withOpacity(0.8)
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Radio button at top right corner
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.9),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.warning 
                                    : AppColors.grey.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactOrderNote() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 28),
                height: ResponsiveHelper.getIconSize(context, 28),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.note_rounded,
                  size: ResponsiveHelper.getIconSize(context, 14),
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Ghi chú',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              maxLines: 2,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Ghi chú cho đơn hàng...',
                hintStyle: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(
                  ResponsiveHelper.getSpacing(context),
                ),
              ),
              onChanged: (value) {
                _note = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOrderSummary() {
    double subtotal = _cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
    double shipping = _shippingFee;
    
    // Calculate discount from selected promotion
    double discount = 0;
    if (_selectedPromotionId != null) {
      final selectedPromo = _promotions.firstWhere(
        (promo) => promo.id == _selectedPromotionId,
        orElse: () => _promotions.first, // fallback, shouldn't happen
      );
      discount = subtotal * (selectedPromo.discountPercent / 100);
    }
    
    double total = subtotal + shipping - discount;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
      ),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
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
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.receipt_rounded,
                  size: ResponsiveHelper.getIconSize(context, 16),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Tóm tắt đơn hàng',
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
          _buildModernSummaryRow('Tạm tính', CurrencyUtils.formatVND(subtotal)),
          _buildModernSummaryRow(
            'Phí vận chuyển',
            _isLoadingShipping 
                ? 'Đang tính...'
                : _shippingErrorMessage != null
                    ? 'Lỗi tải phí'
                    : CurrencyUtils.formatVND(shipping),
            color: _shippingErrorMessage != null ? AppColors.error : null,
          ),
          if (discount > 0)
            _buildModernSummaryRow(
              'Giảm giá',
              '-${CurrencyUtils.formatVND(discount)}',
              color: AppColors.success,
            ),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.getSpacing(context),
            ),
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          _buildModernSummaryRow(
            'Tổng cộng',
            CurrencyUtils.formatVND(total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildModernSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
      child: Row(
        children: [
          Text(
            label,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: color ?? (isTotal ? AppColors.text : AppColors.grey),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: color ?? (isTotal ? AppColors.primary : AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBottomBar() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey,
                  side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 20),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Text(
                      'Quay lại',
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
          if (_currentStep > 0)
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentStep < 2) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    _checkout();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentStep == 2
                          ? Icons.shopping_bag_rounded
                          : Icons.arrow_forward_rounded,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Text(
                      _currentStep == 2 ? 'Đặt hàng' : 'Tiếp tục',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromCart(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 40),
                  height: ResponsiveHelper.getIconSize(context, 40),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Xóa sản phẩm',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            content: Text(
              'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.text,
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey,
                  side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Hủy'),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await _removeItemFromCart(index);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Xóa',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showAddressSelection() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 40),
                  height: ResponsiveHelper.getIconSize(context, 40),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Chọn địa chỉ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            content:
                _isLoadingAddresses
                    ? Container(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                    : _addressErrorMessage != null
                    ? Container(
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            _addressErrorMessage!,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_userAddresses.isNotEmpty) ...[
                          Text(
                            'Địa chỉ của bạn:',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 8),
                          ..._userAddresses.map((address) {
                            final addressText =
                                '🏠 ${address.streetAddress}, ${address.wardName}, ${address.districtName}, ${address.provinceName}';
                            return RadioListTile<String>(
                              title: Text(
                                addressText,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.text,
                                ),
                              ),
                              value: address.id,
                              groupValue: _selectedAddressId,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAddressId = value!;
                                });
                                // Load shipping fee for the new address
                                _loadShippingFee();
                                Navigator.of(context).pop();
                              },
                              activeColor: AppColors.primary,
                            );
                          }).toList(),
                        ],
                        if (_elderlyAddresses.isNotEmpty) ...[
                          if (_userAddresses.isNotEmpty) SizedBox(height: 16),
                          Text(
                            'Địa chỉ người thân:',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 8),
                          ..._elderlyAddresses.entries.expand((entry) {
                            final elderId = entry.key;
                            final addresses = entry.value;
                            final elder = _elderlyList.firstWhere(
                              (e) => e.id == elderId,
                            );

                            return addresses.map((address) {
                              final addressText =
                                  '👤 ${elder.fullName} - ${address.streetAddress}, ${address.wardName}, ${address.districtName}, ${address.provinceName}';
                              return RadioListTile<String>(
                                title: Text(
                                  addressText,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 14,
                                    color: AppColors.text,
                                  ),
                                ),
                                value: address.id,
                                groupValue: _selectedAddressId,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAddressId = value!;
                                  });
                                  // Load shipping fee for the new address
                                  _loadShippingFee();
                                  Navigator.of(context).pop();
                                },
                                activeColor: AppColors.primary,
                              );
                            });
                          }).toList(),
                        ],
                        if (_userAddresses.isEmpty && _elderlyAddresses.isEmpty)
                          Container(
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  color: AppColors.grey,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Chưa có địa chỉ nào',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 14,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            actions: [
              if (_addressErrorMessage != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _loadAddressData();
                  },
                  child: Text(
                    'Thử lại',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey,
                  side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Đóng'),
              ),
            ],
          ),
    );
  }

  Future<void> _checkout() async {
    // Validate required fields
    if (_cartData?.cartId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy thông tin giỏ hàng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn địa chỉ giao hàng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    log('Test Cart: ${_cartData?.cartId}');

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                Text(
                  'Đang tạo đơn hàng...',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
    );

    try {
      // Create order request
      final createOrderRequest = CreateOrderRequest(
        cartId: _cartData!.cartId,
        note: _note.isEmpty ? '' : _note,
        addressId: _selectedAddressId!,
        userPromotionId: _selectedPromotionId, // Add selected promotion ID
      );

      await _cartService.changeCartStatus(_cartData!.cartId, 1);
      
      // Call appropriate API based on effective payment method
      late final BaseResponse<CreateOrderResponse> result;
      final effectiveMethod = _effectivePaymentMethod;
      
      if (effectiveMethod == 'Wallet') {
        // Wallet payment - direct checkout
        result = await _orderService.checkoutByWallet(createOrderRequest);
      } else {
        // VNPay/PayOS - external payment
        result = await _orderService.createOrder(createOrderRequest);
      }
      
      // // Close loading dialog
      Navigator.of(context).pop();

      if (result.isSuccess) {
        if (effectiveMethod == 'Wallet') {
         //navigate to home page
        //  Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (context) => const HomePage()),
        //   (route) => false,
        //  );
             final String? paymentUrl = result.data?.data;
          if (paymentUrl != null) {
            final uri = Uri.parse(paymentUrl);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } else {
          // External payment - launch payment URL
          final String? paymentUrl = result.data?.data;
          if (paymentUrl != null) {
            final uri = Uri.parse(paymentUrl);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    effectiveMethod == 'VNPay' 
                        ? 'Đang mở VNPay... Vui lòng hoàn tất thanh toán trong trình duyệt'
                        : 'Đang mở PayOS... Vui lòng hoàn tất thanh toán trong trình duyệt',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          } else {
            // Fallback: no payment url, show success immediately
            _showSuccessDialog(result.data?.message ?? 'Đặt hàng thành công!');
          }
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể tạo đơn hàng'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 40),
                  height: ResponsiveHelper.getIconSize(context, 40),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Đặt hàng thành công!',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            content: Text(
              message + (_note.isNotEmpty ? '\nGhi chú: $_note' : ''),
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.text,
              ),
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to previous page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDisabled,
    required Color color,
    required VoidCallback? onTap,
    required bool showWarning,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200, // Fixed width for consistent sizing
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.grey.withOpacity(0.1)
              : isSelected
                  ? color.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? AppColors.grey.withOpacity(0.3)
                : isSelected
                    ? color
                    : AppColors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isDisabled
                      ? AppColors.grey
                      : isSelected
                          ? color
                          : AppColors.grey,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                Expanded(
                  child: Text(
                    title,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? AppColors.grey
                          : isSelected
                              ? color
                              : AppColors.grey,
                    ),
                  ),
                ),
                if (isSelected && !isDisabled)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: color,
                  ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 10,
                      color: isDisabled
                          ? AppColors.grey
                          : showWarning
                              ? AppColors.error
                              : isSelected
                                  ? color
                                  : AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showWarning) ...[
                  SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                  Icon(
                    Icons.warning_rounded,
                    size: 12,
                    color: AppColors.error,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
