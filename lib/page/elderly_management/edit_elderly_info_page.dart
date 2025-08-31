import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/user_detail_response.dart';
import '../../models/update_elder_request.dart';
import '../../network/service/elder_service.dart';
import '../../injection.dart';

class EditElderlyInfoPage extends StatefulWidget {
  final UserDetailData userDetail;

  const EditElderlyInfoPage({
    super.key,
    required this.userDetail,
  });

  @override
  State<EditElderlyInfoPage> createState() => _EditElderlyInfoPageState();
}

class _EditElderlyInfoPageState extends State<EditElderlyInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _budgetController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _genderController = TextEditingController();

  DateTime? _selectedDate;
  List<String> _dietaryRestrictions = [];
  bool _isLoading = false;
  
  late final ElderService _elderService;



  final List<String> _commonDietaryRestrictions = [
    'Tiểu đường', 'Cao huyết áp', 'Tim mạch', 'Dạ dày',
    'Thận', 'Gan', 'Cholesterol cao', 'Gout'
  ];

  @override
  void initState() {
    super.initState();
    _elderService = getIt<ElderService>();
    _initializeWithUserData();
  }

  void _initializeWithUserData() {
    final userDetail = widget.userDetail;
    
    // Extract full name and nickname from combined name if available
    final combinedName = userDetail.fullName;
    if (combinedName.contains('(') && combinedName.contains(')')) {
      final nameParts = combinedName.split('(');
      if (nameParts.length == 2) {
        _fullNameController.text = nameParts[0].trim();
        _nicknameController.text = nameParts[1].replaceAll(')', '').trim();
      } else {
        _fullNameController.text = combinedName;
        _nicknameController.text = '';
      }
    } else {
      _fullNameController.text = combinedName;
      _nicknameController.text = '';
    }
    
    _phoneController.text = userDetail.phoneNumber ?? '';
    _selectedDate = userDetail.birthDate;
    _relationshipController.text = userDetail.relationShip;
    _genderController.text = userDetail.gender == 0 ? 'Nam' : userDetail.gender == 1 ? 'Nữ' : 'Khác';
    _emergencyPhoneController.text = userDetail.emergencyPhoneNumber ?? '';
    
    // Extract medical notes and dietary restrictions from description
    final description = userDetail.description;
    if (description.isNotEmpty) {
      final parts = description.split('\n\n');
      for (final part in parts) {
        if (part.startsWith('Ghi chú y tế:')) {
          _medicalNotesController.text = part.replaceFirst('Ghi chú y tế:', '').trim();
        } else if (part.startsWith('Hạn chế chế độ ăn:')) {
          final restrictions = part.replaceFirst('Hạn chế chế độ ăn:', '').trim();
          _dietaryRestrictions = restrictions.split(', ').where((r) => r.isNotEmpty).toList();
        }
      }
    } else {
      _medicalNotesController.text = '';
      _dietaryRestrictions = [];
    }
    
    // Set budget (this might not be available from API, so set default)
    _budgetController.text = '0';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emergencyPhoneController.dispose();
    _medicalNotesController.dispose();
    _budgetController.dispose();
    _relationshipController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  /// Builds combined full name with nickname in format: "Họ và tên (Tên thường gọi)"
  String _buildCombinedFullName() {
    final fullName = _fullNameController.text.trim();
    final nickname = _nicknameController.text.trim();
    
    if (nickname.isNotEmpty && nickname != fullName) {
      return '$fullName ($nickname)';
    }
    return fullName;
  }

  /// Builds combined description with medical notes and dietary restrictions
  String _buildCombinedDescription() {
    final medicalNotes = _medicalNotesController.text.trim();
    final dietaryRestrictions = _dietaryRestrictions;
    
    List<String> parts = [];
    
    if (medicalNotes.isNotEmpty) {
      parts.add('Ghi chú y tế: $medicalNotes');
    }
    
    if (dietaryRestrictions.isNotEmpty) {
      parts.add('Hạn chế chế độ ăn: ${dietaryRestrictions.join(', ')}');
    }
    
    if (parts.isEmpty) return '';
    
    return parts.join('\n\n');
  }

  /// Converts gender text to int for API
  int _convertGenderToInt(String genderText) {
    switch (genderText.toLowerCase()) {
      case 'nam':
      case 'male':
        return 0;
      case 'nữ':
      case 'female':
        return 1;
      default:
        return 0; // Default to male if unknown
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1950),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _toggleDietaryRestriction(String restriction) {
    setState(() {
      if (_dietaryRestrictions.contains(restriction)) {
        _dietaryRestrictions.remove(restriction);
      } else {
        _dietaryRestrictions.add(restriction);
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày sinh')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateRequest = UpdateElderRequest(
        id: widget.userDetail.id,
        fullName: _buildCombinedFullName(),
        userName: _fullNameController.text.trim(),
        description: _buildCombinedDescription(),
        birthDate: _selectedDate!,
        spendlimit: double.tryParse(_budgetController.text) ?? 0.0,
        avatar: null, // TODO: Handle avatar upload
        emergencyPhoneNumber: _emergencyPhoneController.text.trim(),
        relationShip: _relationshipController.text.trim(),
        gender: _convertGenderToInt(_genderController.text.trim()),
      );

      final result = await _elderService.updateElder(updateRequest);

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật thông tin thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Có lỗi xảy ra khi cập nhật thông tin'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
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
          'Chỉnh sửa thông tin',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          child: Column(
            children: [
              _buildSectionCard(
                title: 'Thông tin cá nhân',
                icon: Icons.person_rounded,
                children: [
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Họ và tên',
                    hint: 'Nhập họ và tên đầy đủ',
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildTextField(
                    controller: _nicknameController,
                    label: 'Tên thường gọi',
                    hint: 'Bà, ông, mẹ, bố...',
                    icon: Icons.tag_faces_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên thường gọi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildDatePicker(),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildTextField(
                    controller: _relationshipController,
                    label: 'Mối quan hệ',
                    hint: 'Ví dụ: Mẹ, Bố, Bà, Ông, Cô/Dì, Chú/Bác...',
                    icon: Icons.family_restroom_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập mối quan hệ';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildTextField(
                    controller: _genderController,
                    label: 'Giới tính',
                    hint: 'Ví dụ: Nam, Nữ, Khác...',
                    icon: Icons.person_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập giới tính';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    hint: 'Nhập số điện thoại',
                    icon: Icons.phone_rounded,
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
                ],
              ),

              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

              _buildSectionCard(
                title: 'Thông tin sức khỏe',
                icon: Icons.health_and_safety_rounded,
                children: [
                  _buildTextField(
                    controller: _medicalNotesController,
                    label: 'Ghi chú y tế',
                    hint: 'Các bệnh lý, thuốc đang sử dụng...',
                    icon: Icons.medical_services_rounded,
                    maxLines: 3,
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildDietaryRestrictionsSection(),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: 'Số điện thoại khẩn cấp',
                    hint: 'Số điện thoại liên hệ khẩn cấp',
                    icon: Icons.emergency_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

              _buildSectionCard(
                title: 'Quản lý chi tiêu',
                icon: Icons.account_balance_wallet_rounded,
                children: [
                  _buildTextField(
                    controller: _budgetController,
                    label: 'Hạn mức chi tiêu tháng',
                    hint: '1000000',
                    icon: Icons.monetization_on_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập hạn mức chi tiêu';
                      }
                      final budget = double.tryParse(value);
                      if (budget == null || budget <= 0) {
                        return 'Hạn mức phải lớn hơn 0';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

              // Save Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getLargeSpacing(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded, size: 20),
                            SizedBox(width: ResponsiveHelper.getSpacing(context)),
                            Text(
                              'Lưu thay đổi',
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

              SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: ResponsiveHelper.getIconSize(context, 20),
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Text(
                  title,
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
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            validator: validator,
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
              contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context)),
                child: Icon(
                  icon,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày sinh',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Chọn ngày sinh'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: _selectedDate == null ? AppColors.grey : AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }





  Widget _buildDietaryRestrictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hạn chế chế độ ăn',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        Wrap(
          spacing: ResponsiveHelper.getSpacing(context),
          runSpacing: ResponsiveHelper.getSpacing(context),
          children: _commonDietaryRestrictions.map((restriction) {
            final isSelected = _dietaryRestrictions.contains(restriction);
            return GestureDetector(
              onTap: () => _toggleDietaryRestriction(restriction),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  restriction,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
