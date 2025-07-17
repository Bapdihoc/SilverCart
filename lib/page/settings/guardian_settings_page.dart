import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class GuardianSettingsPage extends StatefulWidget {
  const GuardianSettingsPage({super.key});

  @override
  State<GuardianSettingsPage> createState() => _GuardianSettingsPageState();
}

class _GuardianSettingsPageState extends State<GuardianSettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';

  final List<String> _languages = [
    'Tiếng Việt',
    'English',
    '中文',
    '한국어',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildProfileSection(),
              _buildSettingsSections(),
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
          Text(
            '⚙️ Cài đặt',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.edit_outlined,
              size: ResponsiveHelper.getIconSize(context, 20),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 70),
            height: ResponsiveHelper.getIconSize(context, 70),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getIconSize(context, 35)),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: ResponsiveHelper.getIconSize(context, 35),
              color: Colors.white,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyễn Văn Guardian',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                Text(
                  'guardian@silvercart.app',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                  ),
                  child: Text(
                    '👑 Guardian Premium',
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
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: ResponsiveHelper.getIconSize(context, 16),
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections() {
    return Column(
      children: [
        _buildSettingsSection(
          title: '👥 Quản lý tài khoản',
          items: [
            _buildSettingsItem(
              icon: '📱',
              title: 'Thông tin cá nhân',
              subtitle: 'Cập nhật thông tin cá nhân',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '🔔',
              title: 'Thông báo',
              subtitle: 'Quản lý thông báo ứng dụng',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '🔐',
              title: 'Bảo mật',
              subtitle: 'Mật khẩu và xác thực 2 bước',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '🆔',
              title: 'Xác thực sinh trắc học',
              subtitle: 'Vân tay và Face ID',
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              onTap: () {},
            ),
          ],
        ),
        
        _buildSettingsSection(
          title: '🎨 Giao diện & Ngôn ngữ',
          items: [
            _buildSettingsItem(
              icon: '🌙',
              title: 'Chế độ tối',
              subtitle: 'Giao diện tối bảo vệ mắt',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '🌍',
              title: 'Ngôn ngữ',
              subtitle: _selectedLanguage,
              onTap: () => _showLanguageDialog(),
            ),
            _buildSettingsItem(
              icon: '📏',
              title: 'Kích thước chữ',
              subtitle: 'Điều chỉnh cho người cao tuổi',
              onTap: () {},
            ),
          ],
        ),

        _buildSettingsSection(
          title: '👨‍👩‍👧‍👦 Quản lý gia đình',
          items: [
            _buildSettingsItem(
              icon: '👴',
              title: 'Danh sách người thân',
              subtitle: '3 người thân đang quản lý',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '🏠',
              title: 'Địa chỉ giao hàng',
              subtitle: '5 địa chỉ đã lưu',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '💳',
              title: 'Phương thức thanh toán',
              subtitle: 'Quản lý thẻ và ví điện tử',
              onTap: () {},
            ),
          ],
        ),

        _buildSettingsSection(
          title: '🛡️ Hỗ trợ & Bảo mật',
          items: [
            _buildSettingsItem(
              icon: '❓',
              title: 'Trung tâm trợ giúp',
              subtitle: 'FAQ và hướng dẫn sử dụng',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '💬',
              title: 'Liên hệ hỗ trợ',
              subtitle: 'Chat với đội ngũ hỗ trợ',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '⭐',
              title: 'Đánh giá ứng dụng',
              subtitle: 'Chia sẻ trải nghiệm của bạn',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '📋',
              title: 'Điều khoản sử dụng',
              subtitle: 'Chính sách và điều khoản',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: '🔒',
              title: 'Chính sách bảo mật',
              subtitle: 'Cách chúng tôi bảo vệ dữ liệu',
              onTap: () {},
            ),
          ],
        ),

        _buildLogoutSection(),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
        vertical: ResponsiveHelper.getSpacing(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveHelper.getSpacing(context),
              bottom: ResponsiveHelper.getLargeSpacing(context),
            ),
            child: Text(
              title,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required String icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          child: Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 45),
                height: ResponsiveHelper.getIconSize(context, 45),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getIconSize(context, 22),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                    Text(
                      subtitle,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? Icon(
                Icons.arrow_forward_ios,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error,
                  AppColors.error.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showLogoutConfirmation(),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        size: ResponsiveHelper.getIconSize(context, 24),
                        color: Colors.white,
                      ),
                      SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                      Text(
                        'Đăng xuất',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'SilverCart v1.0.0',
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        ),
        title: Text(
          '🌍 Chọn ngôn ngữ',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return RadioListTile<String>(
              title: Text(
                language,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  color: AppColors.text,
                ),
              ),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.of(context).pop();
              },
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Đóng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        ),
        title: Text(
          '👋 Đăng xuất',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
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
              // TODO: Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã đăng xuất thành công!',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
            child: Text(
              'Đăng xuất',
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
} 