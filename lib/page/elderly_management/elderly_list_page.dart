import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/models/elderly_model.dart';
import 'elderly_profile_form_page.dart';
import 'elderly_qr_management_page.dart';

class ElderlyListPage extends StatefulWidget {
  const ElderlyListPage({super.key});

  @override
  State<ElderlyListPage> createState() => _ElderlyListPageState();
}

class _ElderlyListPageState extends State<ElderlyListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Elderly> _allElderly = [];
  List<Elderly> _filteredElderly = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _filterOptions = [
    {'value': 'all', 'label': 'Tất cả', 'icon': Icons.group},
    {'value': 'active', 'label': 'Hoạt động', 'icon': Icons.check_circle},
    {'value': 'inactive', 'label': 'Không hoạt động', 'icon': Icons.cancel},
    {'value': 'expired_qr', 'label': 'QR hết hạn', 'icon': Icons.qr_code_scanner_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _loadElderly();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadElderly() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load elderly from API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Mock data for demo
      _allElderly = [
        Elderly(
          id: '1',
          fullName: 'Nguyễn Thị Bích',
          nickname: 'Bà Ngoại',
          dateOfBirth: DateTime(1948, 3, 15),
          relationship: 'grandmother',
          phone: '0123456789',
          avatar: null,
          medicalNotes: 'Cao huyết áp, tiểu đường type 2',
          dietaryRestrictions: ['Tiểu đường', 'Cao huyết áp'],
          emergencyContact: '0987654321',
          monthlyBudgetLimit: 2000000,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          managedBy: 'guardian_1',
          currentQRCode: 'QR_1_active',
          qrCodeExpiresAt: DateTime.now().add(const Duration(hours: 12)),
          lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
          totalOrders: 25,
          totalSpent: 1850000,
        ),
        Elderly(
          id: '2',
          fullName: 'Trần Văn Minh',
          nickname: 'Ông Nội',
          dateOfBirth: DateTime(1945, 8, 20),
          relationship: 'grandfather',
          phone: '0987654321',
          avatar: null,
          medicalNotes: 'Tim mạch, khớp',
          dietaryRestrictions: ['Tim mạch'],
          emergencyContact: '0123456789',
          monthlyBudgetLimit: 1500000,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          managedBy: 'guardian_1',
          currentQRCode: 'QR_2_active',
          qrCodeExpiresAt: DateTime.now().add(const Duration(days: 2)),
          lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
          totalOrders: 18,
          totalSpent: 980000,
        ),
        Elderly(
          id: '3',
          fullName: 'Lê Thị Hoa',
          nickname: 'Cô Ba',
          dateOfBirth: DateTime(1952, 12, 10),
          relationship: 'aunt',
          phone: '0555666777',
          avatar: null,
          medicalNotes: null,
          dietaryRestrictions: [],
          emergencyContact: '0444555666',
          monthlyBudgetLimit: 1000000,
          isActive: false,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now().subtract(const Duration(days: 15)),
          managedBy: 'guardian_1',
          currentQRCode: 'QR_3_expired',
          qrCodeExpiresAt: DateTime.now().subtract(const Duration(days: 2)),
          lastLoginAt: DateTime.now().subtract(const Duration(days: 15)),
          totalOrders: 5,
          totalSpent: 380000,
        ),
      ];

      _applyFilter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredElderly = _allElderly.where((elderly) {
        // Search filter
        bool matchesSearch = searchQuery.isEmpty ||
            elderly.fullName.toLowerCase().contains(searchQuery) ||
            elderly.nickname.toLowerCase().contains(searchQuery) ||
            elderly.phone.contains(searchQuery);

        if (!matchesSearch) return false;

        // Status filter
        switch (_selectedFilter) {
          case 'active':
            return elderly.isActive;
          case 'inactive':
            return !elderly.isActive;
          case 'expired_qr':
            return !elderly.hasValidQRCode;
          default:
            return true;
        }
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _applyFilter();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilter();
  }

  Future<void> _navigateToAddElderly() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ElderlyProfileFormPage(),
      ),
    );

    if (result == true) {
      _loadElderly(); // Refresh list
    }
  }

  Future<void> _navigateToEditElderly(Elderly elderly) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ElderlyProfileFormPage(elderly: elderly),
      ),
    );

    if (result == true) {
      _loadElderly(); // Refresh list
    }
  }

  void _navigateToQRManagement(Elderly elderly) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ElderlyQRManagementPage(elderly: elderly),
      ),
    );
  }

  void _showElderlyOptions(Elderly elderly) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ResponsiveHelper.getBorderRadius(context) * 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
              child: Column(
                children: [
                  Text(
                    elderly.nickname,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Text(
                    elderly.fullName,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

            _buildBottomSheetOption(
              icon: Icons.edit,
              title: 'Chỉnh sửa thông tin',
              onTap: () {
                Navigator.pop(context);
                _navigateToEditElderly(elderly);
              },
            ),

            _buildBottomSheetOption(
              icon: Icons.qr_code,
              title: 'Quản lý mã QR',
              onTap: () {
                Navigator.pop(context);
                _navigateToQRManagement(elderly);
              },
            ),

            _buildBottomSheetOption(
              icon: Icons.shopping_cart,
              title: 'Xem đơn hàng',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to orders
              },
            ),

            _buildBottomSheetOption(
              icon: Icons.analytics,
              title: 'Thống kê chi tiêu',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to analytics
              },
            ),

            if (!elderly.isActive)
              _buildBottomSheetOption(
                icon: Icons.check_circle,
                title: 'Kích hoạt',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Activate elderly
                },
              )
            else
              _buildBottomSheetOption(
                icon: Icons.pause_circle,
                title: 'Tạm dừng',
                color: AppColors.warning,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Deactivate elderly
                },
              ),

            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppColors.primary,
        size: ResponsiveHelper.getIconSize(context, 24),
      ),
      title: Text(
        title,
        style: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 16,
          color: color ?? AppColors.text,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
       
        title: Text(
          '👥 Quản lý người thân',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context)),
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
              onPressed: _isLoading ? null : _loadElderly,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  Text(
                    'Đang tải...',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Modern Search Header
                Container(
                  margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      // Modern Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: '🔍 Tìm kiếm người thân...',
                            hintStyle: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              color: AppColors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getLargeSpacing(context),
                              vertical: ResponsiveHelper.getLargeSpacing(context),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: AppColors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),

                      SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                      // Modern Filter Chips
                      SizedBox(
                        height: 45,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filterOptions.length,
                          separatorBuilder: (context, index) => 
                              SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          itemBuilder: (context, index) {
                            final filter = _filterOptions[index];
                            final isSelected = _selectedFilter == filter['value'];
                            
                            return GestureDetector(
                              onTap: () => _onFilterChanged(filter['value']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveHelper.getLargeSpacing(context),
                                  vertical: ResponsiveHelper.getSpacing(context),
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      filter['icon'],
                                      size: 16,
                                      color: isSelected ? Colors.white : AppColors.primary,
                                    ),
                                    SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                                    Text(
                                      filter['label'],
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Modern Results Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getSpacing(context),
                          vertical: ResponsiveHelper.getSpacing(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '📊 ${_filteredElderly.length} người thân',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        'Tổng: ${_allElderly.length}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getSpacing(context)),

                // Modern Elderly List
                Expanded(
                  child: _filteredElderly.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Icon(
                                  _allElderly.isEmpty ? Icons.group_add_rounded : Icons.search_off_rounded,
                                  size: 60,
                                  color: AppColors.grey.withOpacity(0.5),
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                              Text(
                                _allElderly.isEmpty 
                                    ? 'Chưa có người thân nào 😔'
                                    : 'Không tìm thấy kết quả 🔍',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getSpacing(context)),
                              Text(
                                _allElderly.isEmpty 
                                    ? 'Thêm người thân đầu tiên để bắt đầu!'
                                    : 'Thử thay đổi từ khóa tìm kiếm',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 16,
                                  color: AppColors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_allElderly.isEmpty) ...[
                                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: _navigateToAddElderly,
                                    icon: Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                    ),
                                    label: Text(
                                      '➕ Thêm người thân',
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveHelper.getLargeSpacing(context) * 2,
                                        vertical: ResponsiveHelper.getLargeSpacing(context),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                          itemCount: _filteredElderly.length,
                          separatorBuilder: (context, index) => 
                              SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          itemBuilder: (context, index) {
                            final elderly = _filteredElderly[index];
                            return _buildModernElderlyCard(elderly);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToAddElderly,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: Icon(
            Icons.person_add_rounded,
            size: 24,
          ),
          label: Text(
            'Thêm mới',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernElderlyCard(Elderly elderly) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showElderlyOptions(elderly),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          child: Column(
            children: [
              // Compact Header Row
              Row(
                children: [
                  // Compact Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: elderly.avatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              elderly.avatar!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  
                  // Compact Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                elderly.nickname,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: elderly.isActive 
                                    ? AppColors.success.withOpacity(0.15)
                                    : AppColors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: elderly.isActive 
                                      ? AppColors.success.withOpacity(0.4)
                                      : AppColors.grey.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: elderly.isActive ? AppColors.success : AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    elderly.isActive ? 'Active' : 'Paused',
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: elderly.isActive ? AppColors.success : AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          elderly.fullName,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 13,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${elderly.age} tuổi',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.phone_rounded,
                              size: 12,
                              color: AppColors.grey,
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                elderly.phone,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 11,
                                  color: AppColors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // QR Status Badge
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: elderly.hasValidQRCode 
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: elderly.hasValidQRCode 
                            ? AppColors.success.withOpacity(0.4)
                            : AppColors.error.withOpacity(0.4),
                      ),
                    ),
                    child: Icon(
                      elderly.hasValidQRCode ? Icons.qr_code_rounded : Icons.qr_code_scanner_outlined,
                      color: elderly.hasValidQRCode ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.getSpacing(context)),

              // Horizontal Stats Row
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF8F9FA),
                      const Color(0xFFF8F9FA).withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompactStatItem(
                      icon: Icons.shopping_cart_rounded,
                      value: elderly.totalOrders.toString(),
                      label: 'Đơn hàng',
                      color: AppColors.primary,
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.grey.withOpacity(0.1),
                            AppColors.grey.withOpacity(0.3),
                            AppColors.grey.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    _buildCompactStatItem(
                      icon: Icons.monetization_on_rounded,
                      value: '${(elderly.totalSpent / 1000000).toStringAsFixed(1)}M',
                      label: 'Chi tiêu',
                      color: AppColors.secondary,
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.grey.withOpacity(0.1),
                            AppColors.grey.withOpacity(0.3),
                            AppColors.grey.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    _buildCompactStatItem(
                      icon: Icons.account_balance_wallet_rounded,
                      value: '${(elderly.monthlyBudgetLimit / 1000000).toStringAsFixed(1)}M',
                      label: 'Budget',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveHelper.getSpacing(context)),

              // Compact Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToQRManagement(elderly),
                        icon: Icon(
                          Icons.qr_code_rounded,
                          size: 16,
                        ),
                        label: Text(
                          'QR Code',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                  Expanded(
                    child: Container(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToEditElderly(elderly),
                        icon: Icon(
                          Icons.edit_rounded,
                          size: 16,
                        ),
                        label: Text(
                          'Sửa',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withOpacity(0.7), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  Widget _buildCompactStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 9,
            color: AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 