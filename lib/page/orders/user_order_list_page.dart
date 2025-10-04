import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/user_order_response.dart';
import '../../core/utils/currency_utils.dart';
import '../../network/service/order_service.dart';
import '../../injection.dart';
import 'order_detail_page.dart';

class UserOrderListPage extends StatefulWidget {
  const UserOrderListPage({super.key});

  @override
  State<UserOrderListPage> createState() => _UserOrderListPageState();
}

class _UserOrderListPageState extends State<UserOrderListPage> {
  late final OrderService _orderService;
  List<UserOrderData> _orders = [];
  List<UserOrderData> _filteredOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;

  final List<Map<String, dynamic>> _orderStatusFilters = [
    {'status': null, 'label': 'Tất cả', 'icon': Icons.list_alt_rounded},
    {'status': 'Created', 'label': 'Đã tạo', 'icon': Icons.receipt_rounded},
    {'status': 'Paid', 'label': 'Đã thanh toán', 'icon': Icons.payment_rounded},
    {
      'status': 'PendingChecked',
      'label': 'Đang giao',
      'icon': Icons.local_shipping_rounded,
    },
    {
      'status': 'PendingConfirm',
      'label': 'Hoàn thành',
      'icon': Icons.check_circle_rounded,
    },
    {'status': 'Canceled', 'label': 'Đã hủy', 'icon': Icons.cancel_rounded},
    {'status': 'Fail', 'label': 'Thất bại', 'icon': Icons.error_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _orderService = getIt<OrderService>();
    _loadOrders();
  }

  void _filterOrders() {
    if (_selectedStatus == null) {
      _filteredOrders = List.from(_orders);
    } else {
      _filteredOrders =
          _orders
              .where((order) => order.orderStatus == _selectedStatus)
              .toList();
    }
    _filteredOrders = _filteredOrders.reversed.toList();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _orderService.getUserOrders();

      if (result.isSuccess && result.data != null) {
        setState(() {
          _orders = result.data!.data;
          _filterOrders();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải danh sách đơn hàng';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải đơn hàng: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: Container(
        //   margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.1),
        //         blurRadius: 10,
        //         offset: const Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: IconButton(
        //     icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),
        // ),
        title: Row(
          children: [
            Image.asset(
              'assets/order_list.png',
              width: ResponsiveHelper.getIconSize(context, 50),
              height: ResponsiveHelper.getIconSize(context, 50),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text(
              'Đơn hàng của tôi',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: _loadOrders,
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : _orders.isEmpty
              ? _buildEmptyState()
              : _buildOrderList(),
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
            'Đang tải đơn hàng...',
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
              Icons.error_outline,
              size: ResponsiveHelper.getIconSize(context, 50),
              color: AppColors.error,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Không thể tải đơn hàng',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            _errorMessage ?? 'Đã xảy ra lỗi không xác định',
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
              onPressed: _loadOrders,
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
                    'Thử lại',
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

  Widget _buildEmptyFilterState() {
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
              Icons.filter_list_off_rounded,
              size: ResponsiveHelper.getIconSize(context, 50),
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Không tìm thấy đơn hàng',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Không có đơn hàng nào phù hợp\nvới bộ lọc đã chọn',
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
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _filterOrders();
                });
              },
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
                  Icon(Icons.filter_list_rounded, size: 20),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Xóa bộ lọc',
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

  Widget _buildEmptyState() {
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
              Icons.receipt_long_outlined,
              size: ResponsiveHelper.getIconSize(context, 50),
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Chưa có đơn hàng nào',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Hãy mua sắm để tạo đơn hàng\ncho người thân yêu của bạn',
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
              onPressed: () {
                Navigator.of(context).pop(); // Go back to shopping
              },
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

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getSpacing(context),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getLargeSpacing(context),
        ),
        itemCount: _orderStatusFilters.length,
        itemBuilder: (context, index) {
          final filter = _orderStatusFilters[index];
          final isSelected = _selectedStatus == filter['status'];

          return Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.getSpacing(context),
            ),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: Icon(
                filter['icon'] as IconData,
                size: 18,
                color: isSelected ? Colors.white : AppColors.grey,
              ),
              label: Text(
                filter['label'] as String,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.grey,
                ),
              ),
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(context),
              ),
              onSelected: (bool selected) {
                setState(() {
                  _selectedStatus = selected ? filter['status'] : null;
                  _filterOrders();
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child:
                _filteredOrders.isEmpty
                    ? _buildEmptyFilterState()
                    : ListView.builder(
                      padding: EdgeInsets.all(
                        ResponsiveHelper.getLargeSpacing(context),
                      ),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(_filteredOrders[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(UserOrderData order) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getLargeSpacing(context),
      ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context)
                .push<bool>(
                  MaterialPageRoute(
                    builder: (context) => OrderDetailPage(order: order),
                  ),
                )
                .then((needRefresh) {
                  // Chỉ refresh khi có thay đổi (hủy đơn thành công)
                  if (needRefresh == true) {
                    _loadOrders();
                  }
                });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact header with order ID and status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.id.substring(0, 8).toUpperCase()}',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          if (order.elderName != null &&
                              order.elderName!.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.elderly_rounded,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.elderName!,
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 13,
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (order.elderName == null ||
                              order.elderName!.isEmpty) ...[
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_rounded,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Của tôi',
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 13,
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color:order.paymentMethod == 'VNPay'? Colors.blue: Colors.amber, borderRadius: BorderRadius.circular(16)),
                      child: Text('${order.paymentMethod?.toUpperCase()}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                    SizedBox(width: 15),

                    _buildCompactStatusChip(order),
                    // \
                    // Column(
                    //   children: [
                    //     // Text('${order.paymentMethod}')
                    //   ],
                    // ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Compact product summary
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getLargeSpacing(context),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFF8F9FA), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Product count and total
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getSpacing(context),
                              vertical:
                                  ResponsiveHelper.getSpacing(context) / 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${order.orderDetails.length}',
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
                          const Spacer(),
                          Text(
                            CurrencyUtils.formatVND(order.totalPrice),
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      if (order.orderDetails.isNotEmpty) ...[
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Divider(color: Colors.grey.withOpacity(0.2)),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),

                        // Show first 2 products
                        ...order.orderDetails
                            .take(2)
                            .map(
                              (detail) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      ResponsiveHelper.getSpacing(context) / 2,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        detail.productName,
                                        style:
                                            ResponsiveHelper.responsiveTextStyle(
                                              context: context,
                                              baseSize: 13,
                                              color: AppColors.text,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'x${detail.quantity}',
                                      style:
                                          ResponsiveHelper.responsiveTextStyle(
                                            context: context,
                                            baseSize: 12,
                                            color: AppColors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),

                        // Show more indicator if needed
                        if (order.orderDetails.length > 2)
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  ResponsiveHelper.getSpacing(context) / 2,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.more_horiz_rounded,
                                  size: 16,
                                  color: AppColors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'và ${order.orderDetails.length - 2} sản phẩm khác',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                // Note section if exists
                if (order.note.isNotEmpty) ...[
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveHelper.getSpacing(context),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getSpacing(context) / 2,
                        ),
                        Expanded(
                          child: Text(
                            order.note,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 12,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatusChip(UserOrderData order) {
    Color chipColor;
    Color textColor;

    switch (order.orderStatus) {
      case 'Created': // Created
        chipColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'Paid': // Paid
        chipColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'Shipping': // Shipping
        chipColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
      case 'Completed': // Completed
        chipColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case 'Fail': // Failed
        chipColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      default:
        chipColor = AppColors.grey.withOpacity(0.1);
        textColor = AppColors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context) / 2,
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        '${order.orderStatusText}',
        style: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
