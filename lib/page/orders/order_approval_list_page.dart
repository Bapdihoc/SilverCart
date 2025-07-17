import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import 'order_detail_page.dart';

class OrderApprovalListPage extends StatefulWidget {
  const OrderApprovalListPage({super.key});

  @override
  State<OrderApprovalListPage> createState() => _OrderApprovalListPageState();
}

class _OrderApprovalListPageState extends State<OrderApprovalListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedElderlyFilter = 'Tất cả';
  String _selectedSortOption = 'Mới nhất';
  String _searchQuery = '';

  final List<String> _elderlyOptions = [
    'Tất cả',
    'Bà Lan (79 tuổi)',
    'Ông Minh (82 tuổi)',
    'Bà Thu (75 tuổi)'
  ];

  final List<String> _sortOptions = ['Mới nhất', 'Cũ nhất', 'Giá thấp', 'Giá cao'];

  // Mock data for orders
  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': 'ORD001',
      'elderlyName': 'Bà Lan',
      'elderlyAge': 79,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      'totalAmount': 450000,
      'itemCount': 5,
      'status': 'pending',
      'urgency': 'high',
      'items': [
        {'name': 'Thuốc huyết áp', 'quantity': 2, 'price': 150000},
        {'name': 'Vitamin D3', 'quantity': 1, 'price': 200000},
        {'name': 'Cháo ăn liền', 'quantity': 10, 'price': 100000},
      ],
      'address': '123 Đường ABC, Quận 1, TP.HCM',
      'note': 'Cần gấp thuốc huyết áp'
    },
    {
      'id': 'ORD002',
      'elderlyName': 'Ông Minh',
      'elderlyAge': 82,
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
      'totalAmount': 280000,
      'itemCount': 3,
      'status': 'pending',
      'urgency': 'medium',
      'items': [
        {'name': 'Sữa ensure', 'quantity': 2, 'price': 180000},
        {'name': 'Bánh quy dinh dưỡng', 'quantity': 5, 'price': 100000},
      ],
      'address': '456 Đường XYZ, Quận 3, TP.HCM',
      'note': ''
    },
    {
      'id': 'ORD003',
      'elderlyName': 'Bà Thu',
      'elderlyAge': 75,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'totalAmount': 320000,
      'itemCount': 4,
      'status': 'pending',
      'urgency': 'low',
      'items': [
        {'name': 'Mật ong rừng', 'quantity': 1, 'price': 220000},
        {'name': 'Trà gừng', 'quantity': 3, 'price': 100000},
      ],
      'address': '789 Đường DEF, Quận 7, TP.HCM',
      'note': 'Giao vào cuối tuần'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredOrders {
    var filtered = _allOrders.where((order) {
      bool matchesElderly = _selectedElderlyFilter == 'Tất cả' ||
          order['elderlyName'].contains(_selectedElderlyFilter.split(' ')[0]);
      bool matchesSearch = _searchQuery.isEmpty ||
          order['elderlyName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order['id'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesElderly && matchesSearch;
    }).toList();

    // Sort
    switch (_selectedSortOption) {
      case 'Mới nhất':
        filtered.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
        break;
      case 'Cũ nhất':
        filtered.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
        break;
      case 'Giá thấp':
        filtered.sort((a, b) => a['totalAmount'].compareTo(b['totalAmount']));
        break;
      case 'Giá cao':
        filtered.sort((a, b) => b['totalAmount'].compareTo(a['totalAmount']));
        break;
    }

    return filtered;
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
                          (value) => setState(() => _selectedElderlyFilter = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFilterDropdown(
                          '📊 ${_selectedSortOption}',
                          _sortOptions,
                          (value) => setState(() => _selectedSortOption = value),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('pending'),
          _buildOrdersList('approved'),
          _buildOrdersList('rejected'),
        ],
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
        items: options.map((option) {
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
    final orders = _filteredOrders.where((order) => order['status'] == status).toList();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending' ? Icons.inbox :
              status == 'approved' ? Icons.check_circle :
              Icons.cancel,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              status == 'pending' ? 'Không có đơn hàng chờ duyệt' :
              status == 'approved' ? 'Chưa có đơn hàng được duyệt' :
              'Chưa có đơn hàng bị từ chối',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final urgencyColor = order['urgency'] == 'high' ? Colors.red[100] :
                        order['urgency'] == 'medium' ? Colors.orange[100] :
                        Colors.green[100];
    final urgencyTextColor = order['urgency'] == 'high' ? Colors.red[700] :
                            order['urgency'] == 'medium' ? Colors.orange[700] :
                            Colors.green[700];
    final urgencyText = order['urgency'] == 'high' ? 'Khẩn cấp' :
                       order['urgency'] == 'medium' ? 'Bình thường' :
                       'Không gấp';

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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: order),
            ),
          );
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      urgencyText,
                      style: TextStyle(
                        color: urgencyTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    order['id'],
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
                  Text(
                    '${order['elderlyName']} (${order['elderlyAge']} tuổi)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Time
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(order['createdAt']),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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
                      '${order['itemCount']} sản phẩm',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(order['totalAmount'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (order['note'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order['note'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (order['status'] == 'pending') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(order),
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
                        onPressed: () => _approveOrder(order),
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  void _approveOrder(Map<String, dynamic> order) {
    setState(() {
      order['status'] = 'approved';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã duyệt đơn hàng ${order['id']} ✅'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> order) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Từ chối đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bạn có chắc muốn từ chối đơn hàng ${order['id']}?'),
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
            onPressed: () {
              setState(() {
                order['status'] = 'rejected';
                order['rejectReason'] = reasonController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã từ chối đơn hàng ${order['id']} ❌'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

 