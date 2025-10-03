import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/payment_history_response.dart';
import '../../network/service/payment_history_service.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with TickerProviderStateMixin {
  late final PaymentHistoryService _paymentHistoryService;
  late final AuthService _authService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<PaymentHistoryItem> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter options
  String _selectedFilter = 'all'; // all, success, failed, pending
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _paymentHistoryService = getIt<PaymentHistoryService>();
    _authService = getIt<AuthService>();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadTransactions();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      // Default to last 30 days if no date range selected
      final endDate = _endDate ?? DateTime.now();
      final startDate = _startDate ?? endDate.subtract(const Duration(days: 30));

      final request = PaymentHistorySearchRequest(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
      );

      final result = await _paymentHistoryService.searchPaymentHistory(request);

      if (result.isSuccess && result.data != null) {
        setState(() {
          _transactions = result.data!.data.items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải lịch sử giao dịch';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<PaymentHistoryItem> get _filteredTransactions {
    // TopUp,     // Nạp tiền
    // Paid,      // Thanh toán
    // Refund,    // Hoàn tiền
    // Withdraw   // Rút tiền

    switch (_selectedFilter) {
      case 'TopUp':
        return _transactions.where((t) => t.paymentStatus == 0).toList();
      case 'Paid':
        return _transactions.where((t) => t.paymentStatus == 1).toList();
      case 'Refund':
        return _transactions.where((t) => t.paymentStatus == 2).toList();
      case 'Withdraw':
        return _transactions.where((t) => t.paymentStatus == 3).toList();
      default:
        return _transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.text, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Lịch sử giao dịch',
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
              icon: Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 20),
              onPressed: _showFilterDialog,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _filteredTransactions.isEmpty
                          ? _buildEmptyState()
                          : _buildTransactionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tất cả', 'all'),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            _buildFilterChip('Nạp tiền', 'TopUp'),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            _buildFilterChip('Thanh toán', 'Paid'),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            _buildFilterChip('Hoàn tiền', 'Refund'),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            _buildFilterChip('Rút tiền', 'Withdraw'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getLargeSpacing(context),
          vertical: ResponsiveHelper.getSpacing(context),
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 10 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.text,
          ),
        ),
      ),
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
            'Đang tải lịch sử giao dịch...',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
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
              Icons.error_outline_rounded,
              size: ResponsiveHelper.getIconSize(context, 50),
              color: AppColors.error,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Không thể tải lịch sử giao dịch',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
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
              baseSize: 14,
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
              onPressed: _loadTransactions,
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
            'Chưa có giao dịch nào',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Lịch sử giao dịch sẽ hiển thị ở đây\nkhi bạn thực hiện thanh toán',
            textAlign: TextAlign.center,
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

  Widget _buildTransactionsList() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(PaymentHistoryItem transaction) {
    final statusColor = _getStatusColor(transaction.statusColor);
    final statusTextColor = _getStatusTextColor(transaction.statusColor);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and amount
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.statusText,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Amount with prefix
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getAmountPrefix(transaction.paymentStatus),
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getAmountColor(transaction.paymentStatus),
                          ),
                        ),
                        Text(
                          CurrencyUtils.formatVND(transaction.amount),
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getAmountColor(transaction.paymentStatus),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context) / 4),
                    // Date
                    Text(
                      transaction.formattedDate,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 12,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Transaction info
            Row(
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 50),
                  height: ResponsiveHelper.getIconSize(context, 50),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor(transaction.paymentMenthod).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: _getPaymentMethodColor(transaction.paymentMenthod).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getPaymentMethodIcon(transaction.paymentMenthod),
                    color: _getPaymentMethodColor(transaction.paymentMenthod),
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giao dịch ${transaction.paymentMenthod}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                      Text(
                        'ID: ${transaction.orderId != null ? '${transaction.orderId?.substring(0, 8)}...' : 'N/A'}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Amount
            // Container(
            //   width: double.infinity,
            //   padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            //   decoration: BoxDecoration(
            //     color: AppColors.primary.withOpacity(0.05),
            //     borderRadius: BorderRadius.circular(16),
            //     border: Border.all(
            //       color: AppColors.primary.withOpacity(0.1),
            //       width: 1,
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Icon(
            //         Icons.attach_money_rounded,
            //         color: AppColors.primary,
            //         size: ResponsiveHelper.getIconSize(context, 24),
            //       ),
            //       SizedBox(width: ResponsiveHelper.getSpacing(context)),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               _getAmountDescription(transaction.paymentStatus),
            //               style: ResponsiveHelper.responsiveTextStyle(
            //                 context: context,
            //                 baseSize: 12,
            //                 color: AppColors.grey,
            //                 fontWeight: FontWeight.w500,
            //               ),
            //             ),
            //             SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            //             Row(
            //               children: [
            //                 Text(
            //                   _getAmountPrefix(transaction.paymentStatus),
            //                   style: ResponsiveHelper.responsiveTextStyle(
            //                     context: context,
            //                     baseSize: 20,
            //                     fontWeight: FontWeight.bold,
            //                     color: _getAmountColor(transaction.paymentStatus),
            //                   ),
            //                 ),
            //                 Text(
            //                   CurrencyUtils.formatVND(transaction.amount),
            //                   style: ResponsiveHelper.responsiveTextStyle(
            //                     context: context,
            //                     baseSize: 20,
            //                     fontWeight: FontWeight.bold,
            //                     color: _getAmountColor(transaction.paymentStatus),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String statusColor) {
    switch (statusColor) {
      case 'green':
        return Colors.green.shade100;
      case 'red':
        return Colors.red.shade100;
      case 'orange':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String statusColor) {
    switch (statusColor) {
      case 'green':
        return Colors.green.shade700;
      case 'red':
        return Colors.red.shade700;
      case 'orange':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'vnpay':
        return Colors.orange;
      case 'payos':
        return Colors.blue;
      case 'wallet':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'vnpay':
        return Icons.credit_card_rounded;
      case 'payos':
        return Icons.payment_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  // Helper method to get amount prefix (+ or -)
  String _getAmountPrefix(int paymentStatus) {
    switch (paymentStatus) {
      case 1: // Thanh toán
      case 3: // Rút tiền
        return '-';
      case 0: // Nạp tiền
      case 2: // Hoàn tiền
      default:
        return '+';
    }
  }

  // Helper method to get amount color based on payment status
  Color _getAmountColor(int paymentStatus) {
    switch (paymentStatus) {
      case 1: // Thanh toán
      case 3: // Rút tiền
        return AppColors.error; // Red for outgoing money
      case 0: // Nạp tiền
      case 2: // Hoàn tiền
      default:
        return AppColors.success; // Green for incoming money
    }
  }

  // Helper method to get amount description
  String _getAmountDescription(int paymentStatus) {
    switch (paymentStatus) {
      case 0:
        return 'Số tiền nạp vào';
      case 1:
        return 'Số tiền thanh toán';
      case 2:
        return 'Số tiền hoàn lại';
      case 3:
        return 'Số tiền rút ra';
      default:
        return 'Số tiền giao dịch';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Lọc giao dịch',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chọn khoảng thời gian:',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                    child: Text(_startDate != null 
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Từ ngày'),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                    child: Text(_endDate != null 
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Đến ngày'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadTransactions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Áp dụng'),
          ),
        ],
      ),
    );
  }
}
