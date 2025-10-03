import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/elder_budget_statistic_response.dart';
import '../../network/service/order_service.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';

class ElderBudgetPage extends StatefulWidget {
  const ElderBudgetPage({super.key});

  @override
  State<ElderBudgetPage> createState() => _ElderBudgetPageState();
}

class _ElderBudgetPageState extends State<ElderBudgetPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late final OrderService _orderService;
  late final AuthService _authService;
  
  List<ElderBudgetData> _budgetData = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPeriod = 'Tháng này';
  
  final List<String> _periods = ['Tuần này', 'Tháng này', 'Quý này', 'Năm này'];

  @override
  void initState() {
    super.initState();
    _orderService = getIt<OrderService>();
    _authService = getIt<AuthService>();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _loadBudgetData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgetData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy thông tin người dùng';
          _isLoading = false;
        });
        return;
      }

      // Get date range based on selected period
      final dateRange = _getDateRange(_selectedPeriod);
      
      final result = await _orderService.getElderBudgetStatistic(
        userId,
        dateRange['fromDate']!,
        dateRange['toDate']!,
      );

      if (result.isSuccess && result.data != null) {
        setState(() {
          _budgetData = result.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải dữ liệu ngân sách';
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

  Map<String, String> _getDateRange(String period) {
    final now = DateTime.now();
    DateTime fromDate;
    DateTime toDate = now;

    switch (period) {
      case 'Tuần này':
        fromDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'Tháng này':
        fromDate = DateTime(now.year, now.month, 1);
        break;
      case 'Quý này':
        final quarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
        fromDate = DateTime(now.year, quarterStart, 1);
        break;
      case 'Năm này':
        fromDate = DateTime(now.year, 1, 1);
        break;
      default:
        fromDate = DateTime(now.year, now.month, 1);
    }

    return {
      'fromDate': fromDate.toIso8601String().split('T')[0],
      'toDate': toDate.add(Duration(days: 1)).toIso8601String().split('T')[0],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ngân sách & Chi tiêu 💰',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadBudgetData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Period selector
                        _buildPeriodSelector(),
                        
                        // Budget overview
                        _buildBudgetOverview(),
                        
                        // Elder budget cards
                        _buildElderBudgetList(),
                        
                        const SizedBox(height: 100), // Bottom spacing
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu ngân sách...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải dữ liệu ngân sách',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi không xác định',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBudgetData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedPeriod = period);
                _loadBudgetData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetOverview() {
    if (_budgetData.isEmpty) return const SizedBox.shrink();

    final totalSpent = _budgetData.fold<double>(
      0, 
      (sum, item) => sum + item.totalSpent,
    );
    final totalOrders = _budgetData.fold<int>(
      0, 
      (sum, item) => sum + item.orderCount,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng chi tiêu $_selectedPeriod',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalOrders đơn hàng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyUtils.formatVND(totalSpent),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderBudgetList() {
    if (_budgetData.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu chi tiêu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dữ liệu sẽ được hiển thị sau khi có đơn hàng',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Chi tiết theo người',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ..._budgetData.map((budgetData) => _buildElderBudgetCard(budgetData)),
      ],
    );
  }

  Widget _buildElderBudgetCard(ElderBudgetData budgetData) {
    final hasLimit = budgetData.limitSpent != null && budgetData.limitSpent! > 0;
    final isOverBudget = budgetData.isOverBudget;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isOverBudget
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: budgetData.isSelf 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  budgetData.isSelf ? Icons.person : Icons.elderly,
                  color: budgetData.isSelf ? AppColors.primary : AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budgetData.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${budgetData.orderCount} đơn hàng',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Vượt ngân sách',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Spending amount
          Text(
            'Đã chi tiêu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyUtils.formatVND(budgetData.totalSpent),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isOverBudget ? Colors.red : AppColors.primary,
            ),
          ),
          
          if (hasLimit) ...[
            const SizedBox(height: 16),
            
            // Budget progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ngân sách',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${budgetData.budgetUsedPercent.toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (budgetData.budgetUsedPercent / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? Colors.red : AppColors.primary,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hạn mức: ${CurrencyUtils.formatVND(budgetData.limitSpent!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  isOverBudget 
                      ? 'Vượt: ${CurrencyUtils.formatVND(budgetData.totalSpent - budgetData.limitSpent!)}'
                      : 'Còn lại: ${CurrencyUtils.formatVND(budgetData.remainingBudget)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget ? Colors.red : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
