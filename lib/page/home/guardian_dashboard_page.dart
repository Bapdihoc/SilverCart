import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../shopping/product_catalog_page.dart';
import '../budget/elder_budget_page.dart';
import '../wallet/wallet_management_page.dart';
import '../reports/elderly_reports_overview_page.dart';
import '../../network/service/wallet_service.dart';
import '../../network/service/auth_service.dart';
import '../../network/service/order_service.dart';
import '../../injection.dart';
import '../../core/utils/currency_utils.dart';

class GuardianDashboardPage extends StatefulWidget {
  const GuardianDashboardPage({super.key});

  @override
  State<GuardianDashboardPage> createState() => _GuardianDashboardPageState();
}

class _GuardianDashboardPageState extends State<GuardianDashboardPage> {
  late final PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _autoScrollTimer;
  
  // Wallet data
  late final WalletService _walletService;
  late final AuthService _authService;
  late final OrderService _orderService;
  double _currentBalance = 0;
  bool _isLoadingBalance = true;
  
  // Order statistics
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _completedOrders = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _walletService = getIt<WalletService>();
    _authService = getIt<AuthService>();
    _orderService = getIt<OrderService>();
    
    const int initialPage = 1000; // allow virtually infinite backward/forward scrolling
    _bannerController = PageController(viewportFraction: 0.85, initialPage: initialPage);
    _startAutoScroll();
    _loadWalletBalance();
    _loadOrderStatistics();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final userId = await _authService.getUserId();
      if (userId != null) {
        final result = await _walletService.getWalletAmount(userId);
        if (result.isSuccess && result.data != null) {
          setState(() {
            _currentBalance = result.data!.data.amount;
            _isLoadingBalance = false;
          });
        } else {
          setState(() {
            _isLoadingBalance = false;
          });
        }
      } else {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingBalance = false;
      });
    }
  }

  // Public method to reload wallet balance
  Future<void> reloadWalletBalance() async {
    setState(() {
      _isLoadingBalance = true;
    });
    await _loadWalletBalance();
  }

  Future<void> _loadOrderStatistics() async {
    try {
      final userId = await _authService.getUserId();
      if (userId != null) {
        final result = await _orderService.getUserStatistic(userId);
        if (result.isSuccess && result.data != null) {
          setState(() {
            _totalOrders = result.data!.data.totalCount;
            _pendingOrders = result.data!.data.totalOrderToPending;
            _completedOrders = result.data!.data.totalOrderComplete;
            _isLoadingStats = false;
          });
        } else {
          setState(() {
            _isLoadingStats = false;
          });
        }
      } else {
        setState(() {
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  // Public method to reload order statistics
  Future<void> reloadOrderStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    await _loadOrderStatistics();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_bannerController.hasClients) {
        _bannerController.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              _buildBannerSlider(),
              _buildQuickStats(),
              _buildQuickActions(),
              SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    final List<_BannerData> banners = [
      _BannerData(
        title: 'Ưu đãi đặc biệt',
        subtitle: 'Giảm đến 50% cho sản phẩm chăm sóc sức khỏe',
        startColor: AppColors.primary,
        endColor: AppColors.secondary,
        icon: Icons.local_offer_rounded,
      ),
      _BannerData(
        title: 'Giao nhanh trong ngày',
        subtitle: 'Miễn phí giao hàng cho đơn từ 199k',
        startColor: AppColors.success,
        endColor: AppColors.primary,
        icon: Icons.local_shipping_rounded,
      ),
      _BannerData(
        title: 'Sản phẩm mới',
        subtitle: 'Đã có mặt tại SilverCart',
        startColor: AppColors.warning,
        endColor: AppColors.secondary,
        icon: Icons.new_releases_rounded,
      ),
    ];

    return Container(
      margin: EdgeInsets.only(
        top: ResponsiveHelper.getLargeSpacing(context),
        bottom: ResponsiveHelper.getSpacing(context),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 6,
            child: Listener(
              onPointerDown: (_) => _stopAutoScroll(),
              onPointerUp: (_) => _startAutoScroll(),
              child: PageView.builder(
                controller: _bannerController,
                onPageChanged: (index) => setState(() => _currentBannerIndex = index % banners.length),
                itemBuilder: (context, index) {
                  final banner = banners[index % banners.length];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getSpacing(context) / 2,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [banner.startColor, banner.endColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Icon(
                              banner.icon,
                              size: ResponsiveHelper.getIconSize(context, 56),
                              color: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner.title,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                                Text(
                                  banner.subtitle,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 14,
                                    color: Colors.white.withOpacity(0.95),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              final bool isActive = index == _currentBannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: isActive ? 18 : 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào! 👋',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                    Text(
                      'Chào mừng bạn trở lại',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // Wallet section - clickable
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletManagementPage(),
                      ),
                    );
                    
                    // Refresh balance when returning from wallet page
                    if (result == true || result == null) {
                      _loadWalletBalance();
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getLargeSpacing(context),
                      vertical: ResponsiveHelper.getSpacing(context),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/wallet.png',
                          width: ResponsiveHelper.getIconSize(context, 40),
                          height: ResponsiveHelper.getIconSize(context, 40),
                        ),
                        SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                                    Text(
                          'Số dư ví',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_isLoadingBalance)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white,
                            ),
                          )
                        else
                          Text(
                            CurrencyUtils.formatVND(_currentBalance),
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          
        ],
      ),
    );
  }

  

  Widget _buildQuickStats() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Thống kê nhanh',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Row(
            children: [
              Expanded(
                child: _buildModernStatCard(
                  icon: Image.asset(
                    'assets/order_list.png',
                    width: ResponsiveHelper.getIconSize(context, 50),
                    height: ResponsiveHelper.getIconSize(context, 50),
                  ),
                  title: 'Đơn hàng',
                  value: _isLoadingStats ? '...' : '$_totalOrders',
                  color: AppColors.secondary,
                  gradient: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
                ),
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              Expanded(
                child: _buildModernStatCard(
                  icon: Image.asset(
                    'assets/order_process.png',
                    width: ResponsiveHelper.getIconSize(context, 50),
                    height: ResponsiveHelper.getIconSize(context, 50),
                  ),
                  title: 'Đang\nxử lý',
                  value: _isLoadingStats ? '...' : '$_pendingOrders',
                  color: AppColors.blue,
                  gradient: [AppColors.blue, AppColors.blue.withOpacity(0.7)],
                ),
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              Expanded(
                child: _buildModernStatCard(
                  icon: Image.asset(
                    'assets/order_success.png',
                    width: ResponsiveHelper.getIconSize(context, 50),
                    height: ResponsiveHelper.getIconSize(context, 50),
                  ),
                  title: 'Hoàn thành',
                  value: _isLoadingStats ? '...' : '$_completedOrders',
                  color: AppColors.success,
                  gradient: [AppColors.success, AppColors.success.withOpacity(0.7)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard({
    required Widget icon,
    required String title,
    required String value,
    required Color color,
    required List<Color> gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        height: 180, // Cố định chiều cao cho tất cả card
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Phân bố đều các phần tử
          children: [
            // Icon tròn với background
            Container(
              width: ResponsiveHelper.getIconSize(context, 50),
              height: ResponsiveHelper.getIconSize(context, 50),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 25)),
              ),
              child: icon,
            ),
            Text(
              value,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Chức năng',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
            mainAxisSpacing: ResponsiveHelper.getLargeSpacing(context),
            childAspectRatio: 1.1,
            children: [
              _buildModernActionCard(
                icon: Image.asset(
                  'assets/logo.png',
                  width: ResponsiveHelper.getIconSize(context, 30),
                  height: ResponsiveHelper.getIconSize(context, 30),
                ),
                title: 'Mua sắm',
                subtitle: 'Mua sắm ngay',
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductGuardianPage(),
                    ),
                  );
                },
              ),
              _buildModernActionCard(
                icon: Image.asset(
                  'assets/wallet.png',
                  width: ResponsiveHelper.getIconSize(context, 30),
                  height: ResponsiveHelper.getIconSize(context, 30),
                ),
                title: 'Ngân sách',
                subtitle: 'Quản lý chi tiêu',
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ElderBudgetPage(),
                    ),
                  );
                },
              ),
            
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          GestureDetector(
            onTap: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ElderlyReportsOverviewPage(),
                    ),
                  );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                width: ResponsiveHelper.getIconSize(context, 60),
                height: ResponsiveHelper.getIconSize(context, 60),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error,
                      AppColors.error.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                    child: Image.asset(
                      'assets/report.png',
                      width: ResponsiveHelper.getIconSize(context, 30),
                      height: ResponsiveHelper.getIconSize(context, 30),
                    ),
                  ),
                   SizedBox(height: ResponsiveHelper.getSpacing(context)),
              Text(
                'Lịch sử tư vấn',
                textAlign: TextAlign.center,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
              Text(
                'Xem lịch sử tư vấn',
                textAlign: TextAlign.center,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 12,
                  color: AppColors.grey,
                ),
              ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModernActionCard({
    required Widget icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon tròn với gradient
            Container(
              width: ResponsiveHelper.getIconSize(context, 60),
              height: ResponsiveHelper.getIconSize(context, 60),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 30)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: icon,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  
} 

class _BannerData {
  final String title;
  final String subtitle;
  final Color startColor;
  final Color endColor;
  final IconData icon;

  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.startColor,
    required this.endColor,
    required this.icon,
  });
}