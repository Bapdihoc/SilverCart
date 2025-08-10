import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  String _selectedElderly = 'Tất cả';
  String _searchQuery = '';
  final List<String> _elderlyList = ['Tất cả', 'Bà Nguyễn Thị A', 'Ông Trần Văn B', 'Bà Lê Thị C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Quản lý địa chỉ',
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
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => _showAddAddressDialog(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCompactFilterSection(),
          Expanded(
            child: _buildModernAddressList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilterSection() {
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
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với icon
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 40),
                height: ResponsiveHelper.getIconSize(context, 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Text(
                'Bộ lọc',
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

          // Search field
          Text(
            'Tìm kiếm',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm địa chỉ...',
                hintStyle: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                prefixIcon: Container(
                  margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context)),
                  child: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Người thân dropdown
          Text(
            'Người thân',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedElderly,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                prefixIcon: Container(
                  margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context)),
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              items: _elderlyList.map((elderly) {
                return DropdownMenuItem(
                  value: elderly,
                  child: Text(
                    elderly,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedElderly = value!;
                });
              },
              dropdownColor: Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.secondary,
                size: 24,
              ),
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAddressList() {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
      ),
      children: [
        _buildModernAddressCard(
          title: 'Nhà riêng',
          address: '123 Đường ABC, Phường XYZ, Quận 1, TP.HCM',
          type: 'Nhà riêng',
          elderly: 'Bà Nguyễn Thị A',
          isDefault: true,
          onTap: () => _showEditAddressDialog(),
          onDelete: () => _showDeleteConfirmation(),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        _buildModernAddressCard(
          title: 'Chung cư',
          address: '456 Tòa nhà DEF, Lầu 5, Phường UVW, Quận 3, TP.HCM',
          type: 'Chung cư',
          elderly: 'Ông Trần Văn B',
          isDefault: false,
          onTap: () => _showEditAddressDialog(),
          onDelete: () => _showDeleteConfirmation(),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        _buildModernAddressCard(
          title: 'Văn phòng',
          address: '789 Tòa nhà GHI, Tầng 10, Phường RST, Quận 7, TP.HCM',
          type: 'Văn phòng',
          elderly: 'Bà Lê Thị C',
          isDefault: false,
          onTap: () => _showEditAddressDialog(),
          onDelete: () => _showDeleteConfirmation(),
        ),
      ],
    );
  }

  Widget _buildModernAddressCard({
    required String title,
    required String address,
    required String type,
    required String elderly,
    required bool isDefault,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Container(
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
        border: Border.all(
          color: isDefault ? AppColors.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với icon và title
                Row(
                  children: [
                    Container(
                      width: ResponsiveHelper.getIconSize(context, 50),
                      height: ResponsiveHelper.getIconSize(context, 50),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getTypeColor(type),
                            _getTypeColor(type).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: _getTypeColor(type).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getTypeIcon(type),
                        size: ResponsiveHelper.getIconSize(context, 24),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          if (isDefault)
                            Container(
                              margin: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context) / 2),
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getSpacing(context),
                                vertical: ResponsiveHelper.getSpacing(context) / 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
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
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Mặc định',
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 10,
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
                    // Action buttons
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: onTap,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            onPressed: onDelete,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                
                // Address info
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Expanded(
                        child: Text(
                          address,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                
                // Footer info
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getSpacing(context),
                        vertical: ResponsiveHelper.getSpacing(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 12,
                            color: AppColors.secondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            elderly,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getSpacing(context),
                        vertical: ResponsiveHelper.getSpacing(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getTypeColor(type).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        type,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(type),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Nhà riêng':
        return Icons.home_rounded;
      case 'Chung cư':
        return Icons.apartment_rounded;
      case 'Văn phòng':
        return Icons.business_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Nhà riêng':
        return AppColors.primary;
      case 'Chung cư':
        return AppColors.secondary;
      case 'Văn phòng':
        return AppColors.warning;
      default:
        return AppColors.grey;
    }
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildModernAddressDialog(),
    );
  }

  void _showEditAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildModernAddressDialog(isEditing: true),
    );
  }

  Widget _buildModernAddressDialog({bool isEditing = false}) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 40),
                  height: ResponsiveHelper.getIconSize(context, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEditing ? Icons.edit_rounded : Icons.add_rounded,
                    size: ResponsiveHelper.getIconSize(context, 20),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
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
            
            // Form fields
            _buildModernDialogField(
              label: 'Tên địa chỉ',
              hint: 'VD: Nhà riêng, Văn phòng...',
              icon: Icons.label_rounded,
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            _buildModernDialogField(
              label: 'Địa chỉ chi tiết',
              hint: 'Nhập địa chỉ đầy đủ...',
              icon: Icons.location_on_rounded,
              maxLines: 3,
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            _buildModernDialogDropdown(),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSpacing(context)),
                    ),
                    child: Text('Hủy'),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showSuccessMessage(isEditing ? 'Cập nhật thành công!' : 'Thêm địa chỉ thành công!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSpacing(context)),
                      ),
                      child: Text(
                        isEditing ? 'Cập nhật' : 'Thêm',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }

  Widget _buildModernDialogField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            maxLines: maxLines,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context)),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDialogDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại địa chỉ',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context)),
                child: Icon(
                  Icons.category_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            items: ['Nhà riêng', 'Chung cư', 'Văn phòng'].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 40),
              height: ResponsiveHelper.getIconSize(context, 40),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text(
              'Xóa địa chỉ',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa địa chỉ này?',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            color: AppColors.text,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.grey,
              side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Hủy'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessMessage('Xóa địa chỉ thành công!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Xóa',
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
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Expanded(
              child: Text(
                message,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
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
        margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      ),
    );
  }
}