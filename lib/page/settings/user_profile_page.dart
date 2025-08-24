import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:silvercart/network/service/auth_service.dart';
import 'package:silvercart/injection.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/user_me_response.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final AuthService _authService;
  UserMeResponse? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() => _isLoading = true);
      final result = await _authService.getMe();
      if (result.isSuccess && result.data != null) {
        setState(() {
          _user = result.data;
          _nameController.text = _user?.userName ?? '';
          _emailController.text = _user?.userName ?? '';
          _phoneController.text = '';
        });
      } else {
        _showErrorSnackBar('Không thể tải thông tin người dùng');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải thông tin: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
          ),
        ),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset values if canceling edit
        _nameController.text = _user?.userName ?? '';
        _emailController.text = '';
        _phoneController.text = '';
      }
    });
  }

  Future<void> _saveChanges() async {
    try {
      // TODO: Implement update user info API call
      _showSuccessSnackBar('Cập nhật thông tin thành công!');
      setState(() => _isEditing = false);
    } catch (e) {
      _showErrorSnackBar('Lỗi khi cập nhật: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildProfileAvatar(),
                    _buildUserInfoCard(),
                    // _buildAccountStatsCard(),
                    SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              size: ResponsiveHelper.getIconSize(context, 20),
              color: AppColors.text,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context)),
          Text(
            '👤 Thông tin cá nhân',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEditMode,
              icon: Icon(
                Icons.edit_outlined,
                size: ResponsiveHelper.getIconSize(context, 20),
                color: AppColors.primary,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
      ),
      child: Column(
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 120),
            height: ResponsiveHelper.getIconSize(context, 120),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 60)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: ResponsiveHelper.getIconSize(context, 60),
              color: Colors.white,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getLargeSpacing(context),
              vertical: ResponsiveHelper.getSpacing(context) / 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.5),
            ),
            child: Text(
              '👑 ${_user?.role ?? 'Đang tải...'}',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
      
              if (_isEditing) ...[
                TextButton(
                  onPressed: _toggleEditMode,
                  child: Text(
                    'Hủy',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getLargeSpacing(context),
                      vertical: ResponsiveHelper.getSpacing(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                    ),
                  ),
                  child: Text(
                    'Lưu',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          // _buildInfoField(
          //   icon: '👤',
          //   label: 'Tên đăng nhập',
          //   controller: _nameController,
          //   enabled: _isEditing,
          // ),
          // SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          _buildInfoField(
            icon: '📧',
            label: 'Email',
            controller: _emailController,
            enabled: _isEditing,
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          _buildInfoField(
            icon: '📱',
            label: 'Số điện thoại',
            controller: _phoneController,
            enabled: _isEditing,
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          _buildInfoItem(
            icon: '🆔',
            label: 'ID người dùng',
            value: _user?.userId ?? 'Chưa có thông tin',
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          _buildInfoItem(
            icon: '📅',
            label: 'Ngày tạo tài khoản',
            value: 'Chưa có thông tin',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: ResponsiveHelper.getIconSize(context, 16)),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text(
              label,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
        TextFormField(
          controller: controller,
          enabled: enabled,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            color: enabled ? AppColors.text : AppColors.grey,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              borderSide: BorderSide(
                color: enabled ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: ResponsiveHelper.getIconSize(context, 16)),
        ),
        SizedBox(width: ResponsiveHelper.getSpacing(context)),
        Expanded(
          child: Column(
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
              SizedBox(height: ResponsiveHelper.getSpacing(context) / 4),
              Text(
                value,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountStatsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Thống kê tài khoản',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '👥',
                  label: 'Người thân',
                  value: '3',
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: _buildStatItem(
                  icon: '🛒',
                  label: 'Đơn hàng',
                  value: '12',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '🏠',
                  label: 'Địa chỉ',
                  value: '5',
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: _buildStatItem(
                  icon: '💳',
                  label: 'Thanh toán',
                  value: '2',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: ResponsiveHelper.getIconSize(context, 24)),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
          Text(
            value,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context) / 4),
          Text(
            label,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
