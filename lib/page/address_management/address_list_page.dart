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
  String _selectedFilter = 'Tất cả';
  String _selectedElderly = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Nhà riêng', 'Chung cư', 'Văn phòng'];
  final List<String> _elderlyList = ['Tất cả', 'Bà Nguyễn Thị A', 'Ông Trần Văn B', 'Bà Lê Thị C'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '📍 Quản lý địa chỉ',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              size: ResponsiveHelper.getIconSize(context, 24),
              color: AppColors.primary,
            ),
            onPressed: () {
              _showAddAddressDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildAddressList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loại địa chỉ filter
          Text(
            '🏠 Loại địa chỉ',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                bool isSelected = _selectedFilter == filter;
                return Container(
                  margin: EdgeInsets.only(right: ResponsiveHelper.getLargeSpacing(context)),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getLargeSpacing(context),
                        vertical: ResponsiveHelper.getSpacing(context),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 2),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        filter,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Người thân filter
          Text(
            '👥 Người thân',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _elderlyList.map((elderly) {
                bool isSelected = _selectedElderly == elderly;
                return Container(
                  margin: EdgeInsets.only(right: ResponsiveHelper.getLargeSpacing(context)),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedElderly = elderly;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getLargeSpacing(context),
                        vertical: ResponsiveHelper.getSpacing(context),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary : Colors.white,
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 2),
                        border: Border.all(
                          color: isSelected ? AppColors.secondary : AppColors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        elderly,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      children: [
        _buildAddressCard(
          title: '🏠 Nhà riêng',
          address: '123 Đường ABC, Phường XYZ, Quận 1, TP.HCM',
          type: 'Nhà riêng',
          elderly: 'Bà Nguyễn Thị A',
          isDefault: true,
          onTap: () => _showEditAddressDialog(),
          onDelete: () => _showDeleteConfirmation(),
        ),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildAddressCard(
          title: '🏢 Chung cư',
          address: '456 Tòa nhà DEF, Lầu 5, Phường UVW, Quận 3, TP.HCM',
          type: 'Chung cư',
          elderly: 'Ông Trần Văn B',
          isDefault: false,
          onTap: () => _showEditAddressDialog(),
          onDelete: () => _showDeleteConfirmation(),
        ),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildAddressCard(
          title: '🏢 Văn phòng',
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

  Widget _buildAddressCard({
    required String title,
    required String address,
    required String type,
    required String elderly,
    required bool isDefault,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDefault ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    if (isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getSpacing(context),
                          vertical: ResponsiveHelper.getSpacing(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                        ),
                        child: Text(
                          'Mặc định',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: ResponsiveHelper.getIconSize(context, 16),
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
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: ResponsiveHelper.getIconSize(context, 16),
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Text(
                      elderly,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getSpacing(context),
                        vertical: ResponsiveHelper.getSpacing(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                      ),
                      child: Text(
                        type,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          color: _getTypeColor(type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: ResponsiveHelper.getIconSize(context, 20),
                        color: AppColors.primary,
                      ),
                      onPressed: onTap,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: ResponsiveHelper.getIconSize(context, 20),
                        color: AppColors.error,
                      ),
                      onPressed: onDelete,
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
      builder: (context) => _buildAddressDialog(),
    );
  }

  void _showEditAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildAddressDialog(isEditing: true),
    );
  }

  Widget _buildAddressDialog({bool isEditing = false}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
      ),
      title: Text(
        isEditing ? '✏️ Chỉnh sửa địa chỉ' : '➕ Thêm địa chỉ mới',
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
          TextField(
            decoration: InputDecoration(
              labelText: 'Tên địa chỉ',
              hintText: 'VD: Nhà riêng, Văn phòng...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Địa chỉ chi tiết',
              hintText: 'Nhập địa chỉ đầy đủ...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Loại địa chỉ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Hủy',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showSuccessMessage(isEditing ? 'Cập nhật thành công!' : 'Thêm địa chỉ thành công!');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            ),
          ),
          child: Text(
            isEditing ? 'Cập nhật' : 'Thêm',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
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
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        ),
        title: Text(
          '🗑️ Xóa địa chỉ',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessMessage('Xóa địa chỉ thành công!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
            child: Text(
              'Xóa',
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
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
        ),
      ),
    );
  }
} 