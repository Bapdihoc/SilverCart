import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/user_order_response.dart';
import '../../network/service/order_service.dart';
import '../../injection.dart';

class OrderDetailPage extends StatefulWidget {
  final UserOrderData order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with TickerProviderStateMixin {
  late final OrderService _orderService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _orderService = getIt<OrderService>();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate subtotal (total price minus shipping fee)
  double _calculateSubtotal() {
    final shippingFee = widget.order.shippingFee ?? 0;
    return widget.order.totalPrice - shippingFee;
  }

  // Calculate total discount amount for all products
  double _calculateTotalDiscount() {
    double totalDiscount = 0;
    for (final detail in widget.order.orderDetails) {
      if (detail.discount != null && detail.discount! > 0) {
        final originalPrice = detail.price * detail.quantity;
        final discountedPrice = originalPrice * (1 - detail.discount! / 100);
        totalDiscount += originalPrice - discountedPrice;
      }
    }
    return totalDiscount;
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
                    _buildOrderStatusSection(),
                    _buildOrderInfoSection(widget.order),
                    _buildCustomerInfoSection(),
                    _buildShippingAddressSection(),
                    _buildOrderItemsSection(),
                    _buildOrderSummarySection(),
                    if (widget.order.note.isNotEmpty) _buildOrderNoteSection(),
                    _buildOrderTimelineSection(),
                    if (_canCancelOrder()) _buildCancelOrderButton(),
                    SizedBox(
                      height: ResponsiveHelper.getExtraLargeSpacing(context),
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
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.text,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white.withOpacity(0.9)],
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
                        'Chi tiết đơn hàng',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getSpacing(context) / 2,
                      ),
                      Text(
                        '#${widget.order.id.substring(0, 8).toUpperCase()}',
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

  Widget _buildOrderStatusSection() {
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
                  widget.order.orderStatusText,
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

  Widget _buildOrderInfoSection(UserOrderData order) {
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
                Icons.info_outline_rounded,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.primary,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Thông tin đơn hàng',
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
          _buildInfoRow(
            'Mã đơn hàng',
            '#${widget.order.id.substring(0, 8).toUpperCase()}',
          ),
          _buildInfoRow('Trạng thái', widget.order.orderStatusText),
          _buildInfoRow(
            'Tổng tiền',
            CurrencyUtils.formatVND(widget.order.totalPrice),
          ),
          _buildInfoRow(
            'Số sản phẩm',
            '${widget.order.orderDetails.length} sản phẩm',
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getSpacing(context),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Phương thức thanh toán',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(right: 50),
                    decoration: BoxDecoration(
                      color:
                          order.paymentMethod == 'VNPay'
                              ? Colors.blue
                              : Colors.amber,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${order.paymentMethod?.toUpperCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    if (widget.order.elderName == null || widget.order.elderName!.isEmpty)
      return const SizedBox.shrink();

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
                Icons.person_outline_rounded,
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
                    Icons.elderly_rounded,
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
                        widget.order.elderName!,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getSpacing(context) / 2,
                      ),
                      Text(
                        'Người thân được chăm sóc',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.secondary,
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

  Widget _buildShippingAddressSection() {
    // Only show if we have address information
    if (widget.order.streetAddress == null ||
        widget.order.streetAddress!.isEmpty) {
      return const SizedBox.shrink();
    }

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
                Icons.location_on_outlined,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.primary,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Địa chỉ giao hàng',
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
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Expanded(
                      child: Text(
                        widget.order.streetAddress!,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),

                // Ward, District, Province
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Expanded(
                      child: Text(
                        '${widget.order.wardName ?? ''}, ${widget.order.districtName ?? ''}, ${widget.order.provinceName ?? ''}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                // Shipping code if available
                if (widget.order.shippingCode != null &&
                    widget.order.shippingCode!.isNotEmpty) ...[
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Text(
                        'Mã vận đơn: ${widget.order.shippingCode}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
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
                Icons.shopping_bag_outlined,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.primary,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Sản phẩm đã đặt',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
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
                  '${widget.order.orderDetails.length} sản phẩm',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          ...widget.order.orderDetails.asMap().entries.map((entry) {
            final index = entry.key;
            final detail = entry.value;
            return Column(
              children: [
                if (index > 0)
                  Divider(
                    color: Colors.grey.withOpacity(0.2),
                    height: ResponsiveHelper.getLargeSpacing(context) * 2,
                  ),
                _buildProductItem(detail),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProductItem(UserOrderDetail detail) {
    // Calculate discounted price
    final discountedPrice =
        detail.discount != null && detail.discount! > 0
            ? detail.price * (1 - detail.discount! / 100)
            : detail.price;

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
                  detail.productName,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show original price with strikethrough if there's discount
                    if (detail.discount != null && detail.discount! > 0) ...[
                      Text(
                        CurrencyUtils.formatVND(detail.price),
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          color: AppColors.grey,
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                      // Discount badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${detail.discount!.toStringAsFixed(0)}%',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                    ],
                    // Show final price (discounted or original)
                    // Text(
                    //   CurrencyUtils.formatVND(discountedPrice),
                    //   style: ResponsiveHelper.responsiveTextStyle(
                    //     context: context,
                    //     baseSize: 14,
                    //     fontWeight: FontWeight.w600,
                    //     color: detail.discount != null && detail.discount! > 0
                    //         ? AppColors.error
                    //         : AppColors.primary,
                    //   ),
                    // ),
                    Text(
                      ' x ${detail.quantity}',
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
                CurrencyUtils.formatVND(discountedPrice * detail.quantity),
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
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
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
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
                CurrencyUtils.formatVND(_calculateSubtotal()),
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.text,
                ),
              ),
            ],
          ),

          // Show discount if any
          if (_calculateTotalDiscount() > 0) ...[
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Giảm giá',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '-${CurrencyUtils.formatVND(_calculateTotalDiscount())}',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

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
                widget.order.shippingFee != null &&
                        widget.order.shippingFee! > 0
                    ? CurrencyUtils.formatVND(widget.order.shippingFee!)
                    : 'Miễn phí',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color:
                      widget.order.shippingFee != null &&
                              widget.order.shippingFee! > 0
                          ? AppColors.text
                          : AppColors.success,
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
                CurrencyUtils.formatVND(widget.order.totalPrice),
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

  Widget _buildOrderNoteSection() {
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
                Icons.note_rounded,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.warning,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Ghi chú đơn hàng',
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
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              widget.order.note,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimelineSection() {
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
                Icons.timeline_rounded,
                size: ResponsiveHelper.getIconSize(context, 24),
                color: AppColors.primary,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Tiến trình đơn hàng',
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
          _buildTimelineItem(
            'Đã tạo đơn hàng',
            'Đơn hàng đã được tạo thành công',
            Icons.receipt_rounded,
            true,
            widget.order.orderStatus == 'Created',
          ),
          _buildTimelineItem(
            'Đã thanh toán',
            'Đơn hàng đã được thanh toán',
            Icons.payment_rounded,
            false,
            widget.order.orderStatus == 'Paid',
          ),
          _buildTimelineItem(
            'Đang giao hàng',
            'Đơn hàng đang được vận chuyển',
            Icons.local_shipping_rounded,
            false,
            widget.order.orderStatus == 'PendingChecked',
          ),
          _buildTimelineItem(
            'Hoàn thành',
            'Đơn hàng đã được giao thành công',
            Icons.check_circle_rounded,
            false,
            widget.order.orderStatus == 'PendingConfirm',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    IconData icon,
    bool isFirst,
    bool isCompleted, {
    bool isLast = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isCompleted
                        ? AppColors.primary
                        : AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isCompleted ? Colors.white : AppColors.grey,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color:
                    isCompleted
                        ? AppColors.primary
                        : AppColors.grey.withOpacity(0.3),
              ),
          ],
        ),
        SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.getSpacing(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppColors.text : AppColors.grey,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                Text(
                  subtitle,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color:
                        isCompleted
                            ? AppColors.grey
                            : AppColors.grey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Color _getStatusColor() {
    switch (widget.order.orderStatus) {
      case 'Created':
        return Colors.blue;
      case 'Paid':
        return Colors.orange;
      case 'PendingChecked':
        return Colors.purple;
      case 'PendingConfirm':
        return AppColors.success;
      case 'PendingPickup':
        return AppColors.error;
      case 'PendingDelivery':
        return AppColors.error;
      case 'Shipping':
        return AppColors.error;
      case 'Delivered':
        return AppColors.error;
      case 'Completed':
        return AppColors.error;
      case 'Canceled':
        return AppColors.error;
      case 'Fail':
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
    switch (widget.order.orderStatus) {
      case 'Created':
        return Icons.receipt_rounded;
      case 'Paid':
        return Icons.payment_rounded;
      case 'PendingChecked':
        return Icons.local_shipping_rounded;
      case 'PendingConfirm':
        return Icons.check_circle_rounded;
      case 'PendingPickup':
        return Icons.error_rounded;
      case 'PendingDelivery':
        return Icons.error_rounded;
      case 'Shipping':
        return Icons.error_rounded;
      case 'Delivered':
        return Icons.error_rounded;
      case 'Completed':
        return Icons.error_rounded;
      case 'Canceled':
        return Icons.error_rounded;
      case 'Fail':
        return Icons.error_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getStatusDescription() {
    switch (widget.order.orderStatus) {
      case 'Created':
        return 'Đơn hàng đã được tạo và đang chờ xử lý';
      case 'Paid':
        return 'Đơn hàng đã được thanh toán thành công';
      case 'PendingChecked':
        return 'Đơn hàng đang được vận chuyển đến bạn';
      case 'PendingConfirm':
        return 'Đơn hàng đã được giao thành công';
      case 'PendingPickup':
        return 'Đơn hàng gặp sự cố trong quá trình xử lý';
      case 'PendingDelivery':
        return 'Đơn hàng gặp sự cố trong quá trình xử lý';
      case 'Shipping':
        return 'Đơn hàng gặp sự cố trong quá trình xử lý';
      case 'Delivered':
        return 'Đơn hàng gặp sự cố trong quá trình xử lý';
      case 'Completed':
        return 'Đơn hàng gặp sự cố trong quá trình xử lý';
      case 'Canceled':
        return 'Đơn hàng gặp sự cố trong quá trình xử lý';
      case 'Fail':
        return 'Đơn hàng gặp sự cố trong quá trình xử lý';
      default:
        return 'Trạng thái đơn hàng không xác định';
    }
  }

  bool _canCancelOrder() {
    // Chỉ cho phép hủy đơn hàng khi trạng thái là "Đã thanh toán" hoặc các trạng thái trước đó
    final cancelableStatuses = ['Created', 'Paid'];
    final currentStatusIndex = _getOrderStatusIndex(widget.order.orderStatus);
    final paidStatusIndex = _getOrderStatusIndex('Paid');

    return currentStatusIndex <= paidStatusIndex &&
        cancelableStatuses.contains(widget.order.orderStatus);
  }

  int _getOrderStatusIndex(String status) {
    final orderStatuses = [
      'Created', // 0: Đã tạo
      'Paid', // 1: Đã thanh toán
      'PendingChecked', // 2: Đang giao
      'PendingConfirm', // 3: Hoàn thành
      'Canceled', // 4: Đã hủy
      'Fail', // 5: Thất bại
    ];

    return orderStatuses.indexOf(status);
  }

  Widget _buildCancelOrderButton() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
      ),
      child: ElevatedButton(
        onPressed: _showCancelConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withOpacity(0.1),
          foregroundColor: AppColors.error,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getExtraLargeSpacing(context),
            vertical: ResponsiveHelper.getLargeSpacing(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_rounded, size: 20),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text(
              'Hủy đơn hàng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CancelOrderDialog(
          onCancel: (String reason) {
            Navigator.of(context).pop();
            _cancelOrder(reason);
          },
        );
      },
    );
  }

  Future<void> _cancelOrder(String reason) async {
    try {
      final result = await _orderService.cancelOrder(widget.order.id, reason);
      if (!mounted) return;

      if (result.isSuccess) {
        // Cập nhật trạng thái đơn hàng trong widget
        // setState(() {
        //   widget.order.orderStatus = 'Canceled';
        // });

        // Hiển thị thông báo thành công
        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message ?? 'Đã hủy đơn hàng thành công',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Trả về kết quả để parent widget biết cần refresh
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể hủy đơn hàng: ${e.toString()}',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

class _CancelOrderDialog extends StatefulWidget {
  final Function(String) onCancel;

  const _CancelOrderDialog({required this.onCancel});

  @override
  State<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  late final TextEditingController _reasonController;
  bool _isReasonEmpty = true;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_rounded,
              color: AppColors.error,
              size: ResponsiveHelper.getIconSize(context, 30),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Xác nhận hủy đơn hàng',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vui lòng cho biết lý do hủy đơn hàng:',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _isReasonEmpty
                        ? AppColors.error
                        : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập lý do hủy đơn hàng...',
                hintStyle: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: Colors.grey,
                ),
                contentPadding: EdgeInsets.all(
                  ResponsiveHelper.getLargeSpacing(context),
                ),
                border: InputBorder.none,
              ),
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.text,
              ),
              onChanged: (value) {
                setState(() {
                  _isReasonEmpty = value.trim().isEmpty;
                });
              },
            ),
          ),
          if (_isReasonEmpty) ...[
            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            Text(
              'Vui lòng nhập lý do hủy đơn hàng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.error,
              ),
            ),
          ],
          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getLargeSpacing(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Không',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _isReasonEmpty
                          ? null
                          : () {
                            widget.onCancel(_reasonController.text.trim());
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    disabledBackgroundColor: AppColors.error.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getLargeSpacing(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Hủy đơn',
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
        ],
      ),
      contentPadding: EdgeInsets.all(
        ResponsiveHelper.getExtraLargeSpacing(context),
      ),
    );
  }
}
