import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';

import '../../network/service/wallet_service.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';
import '../../models/withdrawal_request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'transaction_history_page.dart';

class WalletManagementPage extends StatefulWidget {
  const WalletManagementPage({super.key});

  @override
  State<WalletManagementPage> createState() => _WalletManagementPageState();
}

class _WalletManagementPageState extends State<WalletManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Top-up form
  final TextEditingController _topUpAmountController = TextEditingController();
  int? _selectedTopUpAmount;
  String _selectedPaymentMethod = 'vnpay';

  // Withdrawal form
  final TextEditingController _withdrawAmountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  bool _isProcessing = false;

  final List<int> _quickTopUpAmounts = [100000, 200000, 500000, 1000000, 2000000];
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'vnpay', 
      'name': 'VNPay', 
      'description': 'Cổng thanh toán quốc gia',
      'icon': Icons.credit_card_rounded, 
      'color': Colors.orange
    }
    // ,
    // {
    //   'id': 'payos', 
    //   'name': 'PayOS', 
    //   'description': 'Thanh toán nhanh chóng',
    //   'icon': Icons.payment_rounded, 
    //   'color': Colors.blue
    // },
  ];

  // API services
  late final WalletService _walletService;
  late final AuthService _authService;
  
  // Wallet data
  double _currentBalance = 0;
  bool _isLoadingBalance = true;
  String? _balanceError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _walletService = getIt<WalletService>();
    _authService = getIt<AuthService>();
    
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
    
    _loadWalletBalance();
    _animationController.forward();
  }

  Future<void> _loadWalletBalance() async {
    setState(() {
      _isLoadingBalance = true;
      _balanceError = null;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      final result = await _walletService.getWalletAmount(userId);
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _currentBalance = result.data!.data.amount;
          _isLoadingBalance = false;
        });
      } else {
        setState(() {
          _balanceError = result.message ?? 'Không thể tải số dư ví';
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      setState(() {
        _balanceError = 'Lỗi tải số dư: ${e.toString()}';
        _isLoadingBalance = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _topUpAmountController.dispose();
    _withdrawAmountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Quản lý ví'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white, size: 20),
            onPressed: _showTransactionHistory,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          primary: true,
          slivers: [
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      _buildWalletBalanceCard(),
                      _buildTabSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildWalletBalanceCard() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 50),
                height: ResponsiveHelper.getIconSize(context, 50),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Image.asset(
                  'assets/wallet.png',
                  width: ResponsiveHelper.getIconSize(context, 50),
                  height: ResponsiveHelper.getIconSize(context, 50),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số dư hiện tại',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                    if (_isLoadingBalance)
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Đang tải...',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      )
                    else if (_balanceError != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lỗi tải số dư',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                          GestureDetector(
                            onTap: _loadWalletBalance,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Tap để thử lại',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        CurrencyUtils.formatVND(_currentBalance),
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: ResponsiveHelper.getIconSize(context, 16),
                  color: Colors.white.withOpacity(0.8),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                Expanded(
                  child: Text(
                    'Sử dụng ví để thanh toán đơn hàng nhanh chóng và an toàn',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 12,
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildTabSection() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
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
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.grey,
              labelStyle: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 18),
                      SizedBox(width: 6),
                      Text('Nạp tiền'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_circle_outline, size: 18),
                      SizedBox(width: 6),
                      Text('Rút tiền'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content with flexible height
          Container(
            constraints: BoxConstraints(
              minHeight: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTopUpTab(),
                _buildWithdrawTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpTab() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            '💰 Chọn số tiền nạp',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Quick amount selection
          Wrap(
            spacing: ResponsiveHelper.getSpacing(context),
            runSpacing: ResponsiveHelper.getSpacing(context),
            children: _quickTopUpAmounts.map((amount) {
              final isSelected = _selectedTopUpAmount == amount;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTopUpAmount = amount;
                    _topUpAmountController.text = amount.toString();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context),
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(colors: [AppColors.success, AppColors.success.withOpacity(0.8)])
                        : null,
                    color: isSelected ? null : AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.success : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    CurrencyUtils.formatVND(amount.toDouble()),
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Custom amount input
          TextField(
            controller: _topUpAmountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Hoặc nhập số tiền khác',
              hintText: 'Nhập số tiền (VND)',
              prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.success),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.success),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedTopUpAmount = null; // Clear quick selection
              });
            },
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Payment method selection
          Text(
            '💳 Phương thức thanh toán',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // VNPay and PayOS in a row
          Row(
            children: _paymentMethods.map((method) {
              final isSelected = _selectedPaymentMethod == method['id'];
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: method['id'] == 'vnpay' ? ResponsiveHelper.getSpacing(context) : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethod = method['id'];
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? LinearGradient(
                                  colors: [method['color'], method['color'].withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : AppColors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? method['color'] : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: method['color'].withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ] : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: ResponsiveHelper.getIconSize(context, 50),
                              height: ResponsiveHelper.getIconSize(context, 50),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.white.withOpacity(0.2) 
                                    : method['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                method['icon'],
                                size: ResponsiveHelper.getIconSize(context, 24),
                                color: isSelected ? Colors.white : method['color'],
                              ),
                            ),
                            SizedBox(width: ResponsiveHelper.getSpacing(context)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                              method['name'],
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.text,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                            Text(
                              method['description'],
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 12,
                                color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                              ],
                            ),
                            if (isSelected) ...[
                              SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: ResponsiveHelper.getIconSize(context, 20),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Top-up button
          SizedBox(
            width: double.infinity,
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
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processTopUp,
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
                child: _isProcessing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_rounded, size: 20),
                          SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Nạp tiền ngay',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawTab() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💸 Thông tin rút tiền',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Withdraw amount
            TextField(
              controller: _withdrawAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Số tiền rút *',
                hintText: 'Nhập số tiền muốn rút',
                prefixIcon: Icon(Icons.money_off_rounded, color: AppColors.error),
                suffixText: 'VND',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Row(
              children: [
                Text(
                  'Số dư khả dụng: ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                if (_isLoadingBalance)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.primary,
                    ),
                  )
                else if (_balanceError != null)
                  GestureDetector(
                    onTap: _loadWalletBalance,
                    child: Text(
                      'Lỗi - Tap để tải lại',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(
                    CurrencyUtils.formatVND(_currentBalance),
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Bank information
            Text(
              '🏦 Thông tin ngân hàng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            
            TextField(
              controller: _bankNameController,
              decoration: InputDecoration(
                labelText: 'Tên ngân hàng *',
                hintText: 'VD: Vietcombank, BIDV, Techcombank...',
                prefixIcon: Icon(Icons.account_balance, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Số tài khoản *',
                hintText: 'Nhập số tài khoản ngân hàng',
                prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            
            TextField(
              controller: _accountHolderController,
              decoration: InputDecoration(
                labelText: 'Tên chủ tài khoản *',
                hintText: 'Nhập tên chủ tài khoản',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                hintText: 'Nhập lý do rút tiền...',
                prefixIcon: Icon(Icons.note_outlined, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Withdraw button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processWithdraw,
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
                  child: _isProcessing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.remove_circle_rounded, size: 20),
                            SizedBox(width: ResponsiveHelper.getSpacing(context)),
                            Text(
                              'Gửi yêu cầu rút tiền',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            
            // Extra bottom padding to prevent cut-off
            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _processTopUp() async {
    final amount = _topUpAmountController.text.trim();
    if (amount.isEmpty || int.tryParse(amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }

      if (_selectedPaymentMethod == 'vnpay') {
        final result = await _walletService.topUpByVnPay(
          userId: userId,
          amount: int.parse(amount),
        );

        if (result.isSuccess && result.data?.data != null) {
          final String paymentUrl = result.data!.data['result'] as String;
          final uri = Uri.parse(paymentUrl);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đang mở VNPay... Vui lòng hoàn tất thanh toán trong trình duyệt'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        } else {
          throw Exception(result.message ?? 'Không nhận được liên kết thanh toán');
        }
      } else {
        throw Exception('Phương thức thanh toán chưa được hỗ trợ');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nạp tiền: ${e.toString()}'),
            backgroundColor: AppColors.error,
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

  Future<void> _processWithdraw() async {
    // Validate form
    if (_withdrawAmountController.text.trim().isEmpty ||
        _bankNameController.text.trim().isEmpty ||
        _accountNumberController.text.trim().isEmpty ||
        _accountHolderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final amount = double.tryParse(_withdrawAmountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (amount > _currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Số dư không đủ để thực hiện giao dịch'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create withdrawal request
      final withdrawalRequest = WithdrawalRequest(
        bankName: _bankNameController.text.trim(),
        bankAccountNumber: _accountNumberController.text.trim(),
        accountHolder: _accountHolderController.text.trim(),
        note: _noteController.text.trim(),
        amount: amount,
      );

      // Send withdrawal request to server
      final result = await _walletService.requestWithdrawal(withdrawalRequest);
      
      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Expanded(
                    child: Text(
                      'Đã gửi yêu cầu rút ${CurrencyUtils.formatVND(amount)}! Sẽ xử lý trong 1-3 ngày. 📤',
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
              duration: const Duration(seconds: 4),
            ),
          );
          
          // Clear form
          _withdrawAmountController.clear();
          _bankNameController.clear();
          _accountNumberController.clear();
          _accountHolderController.clear();
          _noteController.clear();
        }
      } else {
        throw Exception(result.message ?? 'Không thể gửi yêu cầu rút tiền');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi rút tiền: ${e.toString()}'),
            backgroundColor: AppColors.error,
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

  void _showTransactionHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionHistoryPage(),
      ),
    );
  }


}
