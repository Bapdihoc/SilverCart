import 'package:flutter/material.dart';
// import 'package:silvercart/network/service/auth_service.dart';
import 'package:silvercart/page/orders/cart_approval_detail_page.dart';
import '../../core/constants/app_colors.dart';
import '../../models/elder_carts_response.dart';
import '../../network/service/cart_service.dart';
import '../../injection.dart';
import 'cart_payment_page.dart';

class OrderApprovalListPage extends StatefulWidget {
  const OrderApprovalListPage({super.key});

  @override
  State<OrderApprovalListPage> createState() => _OrderApprovalListPageState();
}

class _OrderApprovalListPageState extends State<OrderApprovalListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late final CartService _cartService;
  String _selectedElderlyFilter = 'Tất cả';
  String _selectedSortOption = 'Mới nhất';
  String _searchQuery = '';

  List<ElderCartData> _allCarts = [];
  bool _isLoading = true;
  bool _isRefreshing = false; // For tab change refresh
  String? _errorMessage;

  final List<String> _sortOptions = [
    'Mới nhất',
    'Cũ nhất',
    'Giá thấp',
    'Giá cao',
  ];

  // Dynamic elderly options based on loaded data
  List<String> get _elderlyOptions {
    final elderNames = _allCarts.map((cart) => cart.elderName).toSet().toList();
    return ['Tất cả', ...elderNames];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cartService = getIt<CartService>();

    // Add listener to refresh data when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _refreshDataOnTabChange();
      }
    });

    _loadElderCarts();
  }

  Future<void> _loadElderCarts() async {
    setState(() {
      if (!_isLoading) {
        _isRefreshing = true; // Only set refreshing if not initial load
      }
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _cartService.getAllElderCarts();

      if (result.isSuccess && result.data != null) {
        setState(() {
          _allCarts = result.data!.data;
          _isLoading = false;
          _isRefreshing = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải danh sách đơn hàng';
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ElderCartData> get _filteredCarts {
    var filtered =
        _allCarts.where((cart) {
          bool matchesElderly =
              _selectedElderlyFilter == 'Tất cả' ||
              cart.elderName.contains(_selectedElderlyFilter);
          bool matchesSearch =
              _searchQuery.isEmpty ||
              cart.elderName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              cart.cartId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              cart.customerName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
          return matchesElderly && matchesSearch;
        }).toList();

    // Sort
    switch (_selectedSortOption) {
      case 'Mới nhất':
        // Since we don't have createdAt from API, sort by cartId (newer IDs typically come first)
        filtered.sort((a, b) => b.cartId.compareTo(a.cartId));
        break;
      case 'Cũ nhất':
        filtered.sort((a, b) => a.cartId.compareTo(b.cartId));
        break;
      case 'Giá thấp':
        filtered.sort((a, b) => _calculateDiscountedTotal(a).compareTo(_calculateDiscountedTotal(b)));
        break;
      case 'Giá cao':
        filtered.sort((a, b) => _calculateDiscountedTotal(b).compareTo(_calculateDiscountedTotal(a)));
        break;
    }

    return filtered;
  }

  double _calculateDiscountedTotal(ElderCartData cart) {
    return cart.items.fold(0.0, (sum, item) {
      final bool hasDiscount = item.discount > 0;
      final double unitPrice = hasDiscount
          ? item.productPrice * (1 - item.discount / 100)
          : item.productPrice;
      return sum + unitPrice * item.quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Duyệt đơn hàng 📋',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_isRefreshing)
            Container(
              margin: const EdgeInsets.all(16),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm đơn hàng...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterDropdown(
                          '👨‍👩‍👧‍👦 ${_selectedElderlyFilter}',
                          _elderlyOptions,
                          (value) =>
                              setState(() => _selectedElderlyFilter = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFilterDropdown(
                          '📊 ${_selectedSortOption}',
                          _sortOptions,
                          (value) =>
                              setState(() => _selectedSortOption = value),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab bar
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey[600],
                  tabs: const [
                    Tab(text: 'Chờ duyệt'),
                    Tab(text: 'Đã duyệt'),
                    Tab(text: 'Từ chối'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : _errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList('Pending'),
                  _buildOrdersList('Approve'),
                  _buildOrdersList('Reject'),
                ],
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
            'Đang tải danh sách đơn hàng...',
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
              'Không thể tải danh sách đơn hàng',
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
              onPressed: _loadElderCarts,
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

  Widget _buildFilterDropdown(
    String title,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: title.split(' ').skip(1).join(' '),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        items:
            options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
        onChanged: (value) => onChanged(value!),
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    final carts =
        _filteredCarts
            .where((cart) => cart.status.toLowerCase() == status.toLowerCase())
            .toList();

    if (carts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending'
                  ? Icons.inbox
                  : status == 'approve'
                  ? Icons.check_circle
                  : Icons.cancel,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              status == 'pending'
                  ? 'Không có đơn hàng chờ duyệt'
                  : status == 'approve'
                  ? 'Chưa có đơn hàng được duyệt'
                  : 'Chưa có đơn hàng bị từ chối',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadElderCarts,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: carts.length,
        itemBuilder: (context, index) {
          final cart = carts[index];
          return _buildOrderCard(cart);
        },
      ),
    );
  }

  Widget _buildOrderCard(ElderCartData cart) {
    // Status-based colors
    final statusColor =
        cart.statusColor == 'red'
            ? Colors.red[100]
            : cart.statusColor == 'orange'
            ? Colors.orange[100]
            : cart.statusColor == 'green'
            ? Colors.green[100]
            : Colors.blue[100];
    final statusTextColor =
        cart.statusColor == 'red'
            ? Colors.red[700]
            : cart.statusColor == 'orange'
            ? Colors.orange[700]
            : cart.statusColor == 'green'
            ? Colors.green[700]
            : Colors.blue[700];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () async {
          if (cart.status.toLowerCase() == 'pending') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPaymentPage(cart: cart),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartApprovalDetailPage(cart: cart),
              ),
            );
          }
          // Always refresh the list when returning from detail page
          _loadElderCarts();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      cart.statusText,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    cart.cartId.substring(0, 8),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Elderly info
              Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cart.elderName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Customer info
              Row(
                children: [
                  const Icon(
                    Icons.family_restroom,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Người thân: ${cart.customerName}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Order summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${cart.itemCount} sản phẩm',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '${_calculateDiscountedTotal(cart).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons for pending status
              if (cart.status.toLowerCase() == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(cart),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Từ chối'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveCart(cart),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Duyệt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _approveCart(ElderCartData cart) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartPaymentPage(cart: cart)),
    );
    _loadElderCarts();
  }

  void _showRejectDialog(ElderCartData cart) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Từ chối đơn hàng'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn có chắc muốn từ chối đơn hàng ${cart.cartId.substring(0, 8)}?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Lý do từ chối (tùy chọn)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => _rejectCart(cart, reasonController.text),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Từ chối',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _rejectCart(ElderCartData cart, String reason) async {
    Navigator.pop(context); // Close dialog first

    try {
      // Call API to change cart status to 'Reject' (status = 3)
      final result = await _cartService.changeCartStatus(cart.cartId, 3);

      if (result.isSuccess) {
        // Refresh data from API instead of local update
        await _loadElderCarts();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã từ chối đơn hàng ${cart.cartId.substring(0, 8)} ❌',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể từ chối đơn hàng'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _refreshDataOnTabChange() async {
    // Only refresh if not already loading
    if (!_isLoading) {
      setState(() {
        _isRefreshing = true;
      });

      try {
        final result = await _cartService.getAllElderCarts();

        if (result.isSuccess && result.data != null) {
          setState(() {
            _allCarts = result.data!.data;
            _isRefreshing = false;
          });
        } else {
          setState(() {
            _isRefreshing = false;
          });
        }
      } catch (e) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }
}
