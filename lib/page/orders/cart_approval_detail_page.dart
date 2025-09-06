import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/elder_carts_response.dart';
import 'cart_payment_page.dart';

class CartApprovalDetailPage extends StatefulWidget {
  final ElderCartData cart;

  const CartApprovalDetailPage({
    super.key,
    required this.cart,
  });

  @override
  State<CartApprovalDetailPage> createState() => _CartApprovalDetailPageState();
}

class _CartApprovalDetailPageState extends State<CartApprovalDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                    _buildStatusSection(),
                    _buildCustomerInfoSection(),
                    _buildElderInfoSection(),
                    _buildCartItemsSection(),
                    _buildOrderSummarySection(),
                    if (widget.cart.status.toLowerCase() == 'pending') 
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
      actions: [
        Container(
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
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
            onPressed: () {
              setState(() {
                // Refresh page
              });
            },
          ),
        ),
      ],
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
                        'Chi tiết giỏ hàng',
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

  Widget _buildStatusSection() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        gradient: _getStatusGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 60),
            height: ResponsiveHelper.getIconSize(context, 60),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              _getStatusIcon(),
              size: ResponsiveHelper.getIconSize(context, 30),
              color: Colors.white,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cart.statusText,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                Text(
                  _getStatusDescription(),
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.family_restroom_rounded,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.primary,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Thông tin người đặt',
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
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 50),
                  height: ResponsiveHelper.getIconSize(context, 50),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: ResponsiveHelper.getIconSize(context, 24),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cart.customerName,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                      Text(
                        'Người thân đặt hàng',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.elderly_rounded,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.secondary,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Thông tin người nhận',
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
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 50),
                  height: ResponsiveHelper.getIconSize(context, 50),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.elderly_woman_rounded,
                    size: ResponsiveHelper.getIconSize(context, 24),
                    color: AppColors.secondary,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cart.elderName,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.primary,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
             Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                'Sản phẩm trong giỏ hàng',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.cart.itemCount} sản phẩm',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              ],
             )
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          ...widget.cart.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0) 
                  Divider(
                    color: Colors.grey.withOpacity(0.2),
                    height: ResponsiveHelper.getLargeSpacing(context) * 2,
                  ),
                _buildCartItem(item),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCartItem(ElderCartItem item) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 60),
            height: ResponsiveHelper.getIconSize(context, 60),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: ResponsiveHelper.getIconSize(context, 30),
              color: AppColors.grey,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                Row(
                  children: [
                    Text(
                      CurrencyUtils.formatVND(item.productPrice),
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      ' x ${item.quantity}',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyUtils.formatVND(item.productPrice * item.quantity),
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
      ),
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
                'Tổng kết đơn hàng',
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
          
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.text,
                ),
              ),
              Text(
                CurrencyUtils.formatVND(widget.cart.totalAmount),
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
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
                'Miễn phí',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.success,
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
                CurrencyUtils.formatVND(widget.cart.totalAmount),
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
            '⚡ Hành động',
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
                    onPressed: _isProcessing ? null : () => _showRejectDialog(),
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
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
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
                    onPressed: _isProcessing ? null : _approveCart,
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
                            Icons.check_rounded,
                            size: ResponsiveHelper.getIconSize(context, 18),
                          ),
                    label: Text(
                      _isProcessing ? 'Đang xử lý...' : 'Duyệt đơn',
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

  Color _getStatusColor() {
    switch (widget.cart.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approve':
        return AppColors.success;
      case 'reject':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  LinearGradient _getStatusGradient() {
    final color = _getStatusColor();
    return LinearGradient(
      colors: [color, color.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getStatusIcon() {
    switch (widget.cart.status.toLowerCase()) {
      case 'pending':
        return Icons.pending_rounded;
      case 'approve':
        return Icons.check_circle_rounded;
      case 'reject':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getStatusDescription() {
    switch (widget.cart.status.toLowerCase()) {
      case 'pending':
        return 'Đơn hàng đang chờ người thân duyệt';
      case 'approve':
        return 'Đơn hàng đã được duyệt và xử lý';
      case 'reject':
        return 'Đơn hàng đã bị từ chối';
      default:
        return 'Trạng thái không xác định';
    }
  }

  Future<void> _approveCart() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Navigate to payment page
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => CartPaymentPage(cart: widget.cart),
        ),
      );

      if (result == true && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    'Đã duyệt đơn hàng thành công! 🎉',
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
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Go back after success
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi duyệt đơn hàng: ${e.toString()}'),
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
      // TODO: Call API to reject cart with reason
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.cancel, color: Colors.white, size: 20),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    'Đã từ chối đơn hàng',
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
          ),
        );
        
        // Go back after rejection
        Navigator.of(context).pop(true); // Return true to indicate change
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
}
