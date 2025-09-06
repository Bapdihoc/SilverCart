import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/models/elderly_model.dart';
import '../../models/user_detail_response.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';
import 'category_preferences_page.dart';
import 'edit_elderly_info_page.dart';
import 'edit_elderly_address_page.dart';

class ElderlyProfileDetailPage extends StatefulWidget {
  final Elderly elderly;

  const ElderlyProfileDetailPage({
    super.key,
    required this.elderly,
  });

  @override
  State<ElderlyProfileDetailPage> createState() => _ElderlyProfileDetailPageState();
}

class _ElderlyProfileDetailPageState extends State<ElderlyProfileDetailPage> {
  bool _isLoading = true;
  UserDetailData? _userDetail;
  String? _errorMessage;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _loadUserDetail();
  }

  Future<void> _loadUserDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.getUserDetail(widget.elderly.id);
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _userDetail = result.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải thông tin chi tiết';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải thông tin: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getGenderText(int gender) {
    switch (gender) {
      case 0:
        return 'Nam';
      case 1:
        return 'Nữ';
      default:
        return 'Khác';
    }
  }

  String _formatAddress(UserDetailAddress address) {
    return '${address.streetAddress}, ${address.wardName}, ${address.districtName}, ${address.provinceName}';
  }

  String _buildDisplayDescription(String description) {
    // Format the combined description for better display
    if (description.isEmpty) return '';
    
    // Replace the prefixes with more user-friendly format
    String formatted = description
        .replaceAll('Ghi chú y tế:', '• Y tế:')
        .replaceAll('Hạn chế chế độ ăn:', '• Chế độ ăn:')
        .replaceAll('\n\n', '\n');
    
    return formatted;
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Chi tiết hồ sơ',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
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
              'Đang tải thông tin chi tiết...',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Chi tiết hồ sơ',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: ResponsiveHelper.getIconSize(context, 80),
                color: AppColors.error,
              ),
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              Text(
                'Không thể tải thông tin',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
              Text(
                _errorMessage ?? 'Đã xảy ra lỗi không xác định',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
              ElevatedButton(
                onPressed: _loadUserDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context) * 2,
                    vertical: ResponsiveHelper.getSpacing(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                  ),
                ),
                child: Text(
                  'Thử lại',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null || _userDetail == null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileCard(),
                _buildPersonalInfo(),
                _buildAddressInfo(),
                _buildCategoryPreferences(),
                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      expandedHeight: 120,
      leading: Container(
        margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        'Chi tiết hồ sơ',
        style: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar và tên
          Row(
            children: [
              Container(
                width: ResponsiveHelper.getIconSize(context, 80),
                height: ResponsiveHelper.getIconSize(context, 80),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context) * 2,
                  ),
                ),
                child: _userDetail!.avatar != null && _userDetail!.avatar!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context) * 2,
                        ),
                        child: Image.network(
                          _userDetail!.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                _userDetail!.fullName.isNotEmpty 
                                    ? _userDetail!.fullName[0].toUpperCase()
                                    : 'U',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          _userDetail!.fullName.isNotEmpty 
                              ? _userDetail!.fullName[0].toUpperCase()
                              : 'U',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                      _userDetail!.fullName,
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getSpacing(context),
                        vertical: ResponsiveHelper.getSpacing(context) / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getBorderRadius(context),
                        ),
                      ),
                      child: Text(
                        _userDetail!.roleName,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                    Text(
                      'Mối quan hệ: ${_userDetail!.relationShip}',
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
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // // Thống kê
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildStatCard(
          //         'Tuổi',
          //         '${_userDetail!.age}',
          //         Icons.cake,
          //         AppColors.primary,
          //       ),
          //     ),
          //     SizedBox(width: ResponsiveHelper.getSpacing(context)),
          //     Expanded(
          //       child: _buildStatCard(
          //         'Điểm thưởng',
          //         '${_userDetail!.rewardPoint}',
          //         Icons.stars,
          //         AppColors.secondary,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getIconSize(context, 24),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
          Text(
            value,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
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

  Widget _buildPersonalInfo() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppColors.primary,
                size: ResponsiveHelper.getIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: Text(
                  'Thông tin cá nhân',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 16),
                  ),
                  onPressed: () async {
                    if (_userDetail != null) {
                      // Navigate to edit personal info page
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditElderlyInfoPage(
                            userDetail: _userDetail!,
                          ),
                        ),
                      );
                      
                      // Reload data if info was updated
                      if (result == true) {
                        _loadUserDetail();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          // _buildInfoRow('Tên đăng nhập', _userDetail!.userName),
          // _buildInfoRow('Email', _userDetail!.email ?? 'Chưa cập nhật'),
          _buildInfoRow('Giới tính', _getGenderText(_userDetail!.gender)),
          // _buildInfoRow('Số điện thoại', _userDetail!.phoneNumber ?? 'Chưa cập nhật'),
          _buildInfoRow('Ngày sinh', '${_userDetail!.birthDate.day}/${_userDetail!.birthDate.month}/${_userDetail!.birthDate.year}'),
          _buildInfoRow('Số khẩn cấp', _userDetail!.emergencyPhoneNumber ?? 'Chưa cập nhật',),
          if (_userDetail!.description.isNotEmpty)
            _buildInfoRow('Ghi chú', _buildDisplayDescription(_userDetail!.description), isLast: true),
        ],
      ),
    );
  }

  Widget _buildAddressInfo() {
    if (_userDetail!.addresses.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: ResponsiveHelper.getIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: Text(
                  'Địa chỉ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 16),
                  ),
                  onPressed: () async {
                    if (_userDetail != null) {
                      // Navigate to edit address page
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditElderlyAddressPage(
                            userDetail: _userDetail!,
                          ),
                        ),
                      );
                      
                      // Reload data if address was updated
                      if (result == true) {
                        _loadUserDetail();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          ..._userDetail!.addresses.asMap().entries.map((entry) {
            final index = entry.key;
            final address = entry.value;
            final isLast = index == _userDetail!.addresses.length - 1;
            
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                    border: Border.all(
                      color: AppColors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatAddress(address),
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.text,
                        ),
                      ),
                      if (address.phoneNumber.isNotEmpty) ...[
                        SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: ResponsiveHelper.getIconSize(context, 14),
                              color: AppColors.grey,
                            ),
                            SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                            Text(
                              address.phoneNumber,
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isLast) SizedBox(height: ResponsiveHelper.getSpacing(context)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryPreferences() {
   

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getLargeSpacing(context),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context) * 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.interests,
                color: AppColors.primary,
                size: ResponsiveHelper.getIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: Text(
                  'Sở thích danh mục',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 16),
                  ),
                  onPressed: () async {
                    // Navigate to category preferences page
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CategoryPreferencesPage(
                          elderly: widget.elderly,
                          currentCategories: _userDetail?.categoryValues ?? [],
                        ),
                      ),
                    );
                    
                    // Reload data if preferences were updated
                    if (result == true) {
                      _loadUserDetail();
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
            (_userDetail!.categoryValues.isEmpty) ?
       SizedBox.shrink():
    
          Wrap(
            spacing: ResponsiveHelper.getSpacing(context),
            runSpacing: ResponsiveHelper.getSpacing(context),
            children: _userDetail!.categoryValues.map((category) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context),
                  ),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  category.label,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: ResponsiveHelper.getIconSize(context, 100),
              child: Text(
                label,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.grey,
                ),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Expanded(
              child: Text(
                value,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Divider(
            color: AppColors.grey.withOpacity(0.2),
            height: 1,
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
        ],
      ],
    );
  }
}
