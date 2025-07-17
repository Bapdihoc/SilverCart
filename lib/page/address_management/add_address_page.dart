import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedType = 'Nhà riêng';
  String _selectedElderly = 'Bà Nguyễn Thị A';
  bool _isDefault = false;
  bool _isLoading = false;

  final List<String> _addressTypes = [
    'Nhà riêng',
    'Chung cư',
    'Văn phòng',
    'Trường học',
    'Bệnh viện',
    'Khác'
  ];

  final List<String> _elderlyList = [
    'Bà Nguyễn Thị A',
    'Ông Trần Văn B',
    'Bà Lê Thị C'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.text,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '📍 Thêm địa chỉ mới',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildForm(),
            _buildMapSection(),
            _buildActionButtons(),
            SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            ),
            child: Icon(
              Icons.location_on,
              size: ResponsiveHelper.getIconSize(context, 24),
              color: Colors.white,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thêm địa chỉ mới',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  'Quản lý địa chỉ giao hàng cho người thân',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 Thông tin địa chỉ',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Tên địa chỉ
            _buildFormField(
              controller: _titleController,
              label: 'Tên địa chỉ',
              hint: 'VD: Nhà riêng, Văn phòng...',
              icon: Icons.home_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên địa chỉ';
                }
                return null;
              },
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Loại địa chỉ
            _buildDropdownField(),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Người thân
            _buildElderlyDropdownField(),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Địa chỉ chi tiết
            _buildFormField(
              controller: _addressController,
              label: 'Địa chỉ chi tiết',
              hint: 'Nhập địa chỉ đầy đủ...',
              icon: Icons.location_on_outlined,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập địa chỉ chi tiết';
                }
                return null;
              },
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Số điện thoại
            _buildFormField(
              controller: _phoneController,
              label: 'Số điện thoại',
              hint: '0123456789',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Ghi chú
            _buildFormField(
              controller: _noteController,
              label: 'Ghi chú (tùy chọn)',
              hint: 'Hướng dẫn giao hàng, thời gian...',
              icon: Icons.note_outlined,
              maxLines: 2,
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            
            // Đặt làm địa chỉ mặc định
            _buildDefaultAddressSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: ResponsiveHelper.getIconSize(context, 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.error),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
      child: DropdownButtonFormField<String>(
        value: _selectedType,
        decoration: InputDecoration(
          labelText: 'Loại địa chỉ',
          prefixIcon: Icon(
            Icons.category_outlined,
            color: AppColors.primary,
            size: ResponsiveHelper.getIconSize(context, 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _addressTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedType = value!;
          });
        },
      ),
    );
  }

  Widget _buildElderlyDropdownField() {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
      child: DropdownButtonFormField<String>(
        value: _selectedElderly,
        decoration: InputDecoration(
          labelText: 'Người thân',
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColors.secondary,
            size: ResponsiveHelper.getIconSize(context, 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            borderSide: BorderSide(color: AppColors.secondary, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _elderlyList.map((elderly) {
          return DropdownMenuItem(
            value: elderly,
            child: Text(elderly),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedElderly = value!;
          });
        },
      ),
    );
  }

  Widget _buildDefaultAddressSwitch() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_outline,
            color: AppColors.primary,
            size: ResponsiveHelper.getIconSize(context, 20),
          ),
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt làm địa chỉ mặc định',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  'Địa chỉ này sẽ được chọn mặc định khi đặt hàng',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isDefault,
            onChanged: (value) {
              setState(() {
                _isDefault = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗺️ Vị trí trên bản đồ',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              border: Border.all(
                color: AppColors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: ResponsiveHelper.getIconSize(context, 48),
                    color: AppColors.grey,
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Bản đồ sẽ được hiển thị ở đây',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Open map picker
                    },
                    icon: Icon(
                      Icons.my_location,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                    label: Text(
                      'Chọn vị trí',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                      ),
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

  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.getLargeSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_outlined,
                          size: ResponsiveHelper.getIconSize(context, 20),
                        ),
                        SizedBox(width: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Lưu địa chỉ',
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
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grey,
                side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.getLargeSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                ),
              ),
              child: Text(
                'Hủy',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thêm địa chỉ thành công!',
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

    Navigator.of(context).pop();
  }
} 