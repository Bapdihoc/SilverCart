import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/elder_carts_response.dart';
import '../../models/create_order_request.dart';
import '../../models/create_order_response.dart';
import '../../models/user_detail_response.dart';
import '../../models/elder_list_response.dart';
import '../../network/service/order_service.dart';
import '../../network/service/auth_service.dart';
import '../../network/service/wallet_service.dart';
import '../../network/service/shipping_service.dart';
import '../../network/service/cart_service.dart';
import '../../core/models/base_response.dart';
import '../../injection.dart';

class CartPaymentPage extends StatefulWidget {
  final ElderCartData cart;

  const CartPaymentPage({
    super.key,
    required this.cart,
  });

  @override
  State<CartPaymentPage> createState() => _CartPaymentPageState();
}

class _CartPaymentPageState extends State<CartPaymentPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late final OrderService _orderService;
  late final AuthService _authService;
  late final WalletService _walletService;
  late final ShippingService _shippingService;
  late final CartService _cartService;
  
  bool _isProcessing = false;
  String _paymentMethod = 'Wallet';
  String _note = '';

  // Address and elderly data
  List<ElderAddressData> _elderlyAddresses = [];
  String? _selectedAddressId;
  bool _isLoadingAddresses = false;
  String? _addressErrorMessage;

  // Wallet data
  double _walletBalance = 0;
  bool _isLoadingWallet = false;
  String? _walletErrorMessage;

  // Shipping data
  double _shippingFee = 20000; // Default shipping fee
  bool _isLoadingShipping = false;
  String? _shippingErrorMessage;

  // Helper method to get effective payment method (auto-switch if wallet insufficient)
  String get _effectivePaymentMethod {
    if (_paymentMethod == 'Wallet' && !_hasEnoughWalletBalance) {
      return 'VNPay'; // Auto fallback to VNPay
    }
    return _paymentMethod;
  }

  // Helper method to check if wallet has enough balance
  bool get _hasEnoughWalletBalance {
    if (_isLoadingWallet) return false;
    
    double subtotal = widget.cart.totalAmount;
    double total = subtotal + _shippingFee;
    return _walletBalance >= total;
  }

  @override
  void initState() {
    super.initState();
    _orderService = getIt<OrderService>();
    _authService = getIt<AuthService>();
    _walletService = getIt<WalletService>();
    _shippingService = getIt<ShippingService>();
    _cartService = getIt<CartService>();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    _loadAddressData();
    _loadWalletBalance();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAddressData() async {
    setState(() {
      _isLoadingAddresses = true;
      _addressErrorMessage = null;
    });

    try {
      // Get elder addresses
      final dataElder = await _authService.getUserDetail(widget.cart.elderId);
      
      if (dataElder.isSuccess && dataElder.data != null) {
        final elderData = dataElder.data as UserDetailResponse;
        _elderlyAddresses = elderData.data.addresses.map((address) => ElderAddressData(
          id: address.id,
          streetAddress: address.streetAddress,
          wardCode: address.wardCode,
          wardName: address.wardName,
          districtID: address.districtID,
          districtName: address.districtName,
          provinceID: address.provinceID,
          provinceName: address.provinceName,
          phoneNumber: address.phoneNumber,
        )).toList();
        
        // Set default address selection
        if (_elderlyAddresses.isNotEmpty && _selectedAddressId == null) {
          _selectedAddressId = _elderlyAddresses.first.id;
          // Load shipping fee for the default address
          _loadShippingFee();
        }
      }

      setState(() {
        _isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() {
        _addressErrorMessage = 'Lỗi tải địa chỉ: ${e.toString()}';
        _isLoadingAddresses = false;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildOrderSummarySection(),
                    _buildAddressSection(),
                    _buildPaymentMethodSection(),
                    _buildOrderNoteSection(),
                    _buildActionButtonsSection(),
                    SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      expandedHeight: 120,
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
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.text, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Thanh toán đơn hàng',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                      Text(
                        '#${widget.cart.cartId.substring(0, 8).toUpperCase()}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.primary,
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
          
          // Customer info
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Người đặt: ${widget.cart.customerName}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Người nhận: ${widget.cart.elderName}',
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
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Items count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số sản phẩm',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.text,
                ),
              ),
              Text(
                '${widget.cart.itemCount} sản phẩm',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Shipping
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí vận chuyển',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.text,
                ),
              ),
              Text(
                _isLoadingShipping 
                    ? 'Đang tính...'
                    : _shippingErrorMessage != null
                        ? 'Lỗi tải phí'
                        : _shippingFee == 0 
                            ? 'Miễn phí'
                            : CurrencyUtils.formatVND(_shippingFee),
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: _shippingErrorMessage != null 
                      ? AppColors.error 
                      : _shippingFee == 0 
                          ? AppColors.success 
                          : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          Divider(
            color: AppColors.primary.withOpacity(0.3),
            height: ResponsiveHelper.getLargeSpacing(context) * 2,
          ),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Text(
                CurrencyUtils.formatVND(widget.cart.totalAmount + _shippingFee),
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 22,
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

  Widget _buildAddressSection() {
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: ResponsiveHelper.getIconSize(context, 14),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Địa chỉ giao hàng',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              if (_isLoadingShipping) ...[
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          if (_isLoadingAddresses)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_addressErrorMessage != null)
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
              ),
            )
          else if (_elderlyAddresses.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      color: AppColors.grey,
                      size: 32,
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
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
            )
          else
            Column(
              children: _elderlyAddresses.map((address) {
                final isSelected = _selectedAddressId == address.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAddressId = address.id;
                    });
                    // Load shipping fee for the new address
                    _loadShippingFee();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                    padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primary.withOpacity(0.1)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primary
                            : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppColors.primary : AppColors.grey,
                          size: 20,
                        ),
                        SizedBox(width: ResponsiveHelper.getSpacing(context)),
                        Expanded(
                          child: Text(
                            '🏠 ${address.streetAddress}, ${address.wardName}, ${address.districtName}, ${address.provinceName}',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
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
                'Phương thức thanh toán',
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
              itemCount: 2,
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

  Widget _buildOrderNoteSection() {
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
                'Ghi chú đơn hàng',
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
              maxLines: 3,
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

  Widget _buildActionButtonsSection() {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚡ Xác nhận thanh toán',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Row(
            children: [
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _showRejectDialog,
                    icon: Icon(
                      Icons.close_rounded,
                      size: ResponsiveHelper.getIconSize(context, 18),
                    ),
                    label: Text(
                      'Từ chối',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide.none,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.getLargeSpacing(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _processPayment,
                    icon: _isProcessing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.payment_rounded,
                            size: ResponsiveHelper.getIconSize(context, 18),
                          ),
                    label: Text(
                      _isProcessing ? 'Đang xử lý...' : 'Thanh toán',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                  ),
                ),
              ),
            ],
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
        width: 200,
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

  Future<void> _processPayment() async {
    // Validate required fields
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn địa chỉ giao hàng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_isLoadingShipping) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang tính phí vận chuyển, vui lòng đợi...'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            Text(
              'Đang xử lý thanh toán...',
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
      // await _cartService.changeCartStatus(widget.cart.cartId, 1);
      // Create order request
      final createOrderRequest = CreateOrderRequest(
        cartId: widget.cart.cartId,
        note: _note.isEmpty ? '' : _note,
        addressId: _selectedAddressId!,
      );

      // Call appropriate API based on effective payment method
      late final BaseResponse<CreateOrderResponse> result;
      final effectiveMethod = _effectivePaymentMethod;
      
      if (effectiveMethod == 'Wallet') {
        // Wallet payment - direct checkout
        result = await _orderService.checkoutByWallet(createOrderRequest);
      } else {
        // VNPay - external payment
        result = await _orderService.createOrder(createOrderRequest);
      }
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (result.isSuccess) {
        if (effectiveMethod == 'Wallet') {
          // Wallet payment success
          final String? paymentUrl = result.data?.data;
          if (paymentUrl != null) {
            final uri = Uri.parse(paymentUrl);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } else {
          // External payment - launch payment URL
          log('Payment URL: ${result.data?.data}');
          final String? paymentUrl = result.data?.data['result'];
          if (paymentUrl != null) {
            final uri = Uri.parse(paymentUrl);
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đang mở VNPay... Vui lòng hoàn tất thanh toán trong trình duyệt',
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
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    
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
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getIconSize(context, 40),
                    height: ResponsiveHelper.getIconSize(context, 40),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.cancel_rounded,
                      color: AppColors.error,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Expanded(
                    child: Text(
                      'Từ chối đơn hàng',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              
              Text(
                'Bạn có chắc muốn từ chối đơn hàng #${widget.cart.cartId.substring(0, 8).toUpperCase()}?',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Lý do từ chối (tùy chọn)',
                  hintText: 'Nhập lý do từ chối đơn hàng...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                maxLines: 3,
              ),
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
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.getLargeSpacing(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Hủy'),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () => _rejectCart(reasonController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getLargeSpacing(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Từ chối',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Future<void> _rejectCart(String reason) async {
    Navigator.of(context).pop(); // Close dialog
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Call API to reject cart (status = 3)
      final result = await _cartService.changeCartStatus(widget.cart.cartId, 3);
      
      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.white, size: 20),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Expanded(
                    child: Text(
                      'Đã từ chối đơn hàng #${widget.cart.cartId.substring(0, 8).toUpperCase()} ❌',
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
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Go back after rejection
          Navigator.of(context).pop(true); // Return true to indicate change
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể từ chối đơn hàng'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi từ chối đơn hàng: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              'Thanh toán thành công!',
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
                Navigator.of(context).pop(true); // Return to cart list with success
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
}
