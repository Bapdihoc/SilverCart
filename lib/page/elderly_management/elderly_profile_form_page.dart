import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/models/elderly_model.dart';

class ElderlyProfileFormPage extends StatefulWidget {
  final Elderly? elderly; // null means add new, non-null means edit
  
  const ElderlyProfileFormPage({
    super.key,
    this.elderly,
  });

  @override
  State<ElderlyProfileFormPage> createState() => _ElderlyProfileFormPageState();
}

class _ElderlyProfileFormPageState extends State<ElderlyProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _medicalNotesController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _budgetController = TextEditingController();
  final _addressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedRelationship = 'mother';
  List<String> _dietaryRestrictions = [];
  String _selectedAddressType = 'home';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _relationships = [
    'mother', 'father', 'grandmother', 'grandfather',
    'aunt', 'uncle', 'other'
  ];

  final List<String> _addressTypes = ['home', 'work', 'other'];

  final List<String> _commonDietaryRestrictions = [
    'Tiểu đường', 'Cao huyết áp', 'Tim mạch', 'Dạ dày',
    'Thận', 'Gan', 'Cholesterol cao', 'Gout'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.elderly != null) {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    final elderly = widget.elderly!;
    _fullNameController.text = elderly.fullName;
    _nicknameController.text = elderly.nickname;
    _phoneController.text = elderly.phone;
    _selectedDate = elderly.dateOfBirth;
    _selectedRelationship = elderly.relationship;
    _medicalNotesController.text = elderly.medicalNotes ?? '';
    _emergencyContactController.text = elderly.emergencyContact ?? '';
    _budgetController.text = elderly.monthlyBudgetLimit.toString();
    _dietaryRestrictions = elderly.dietaryRestrictions ?? [];

    // Initialize address if available
    if (elderly.addresses?.isNotEmpty == true) {
      final primaryAddress = elderly.addresses!.first;
      _addressController.text = primaryAddress.fullAddress;
      _recipientNameController.text = primaryAddress.recipientName;
      _recipientPhoneController.text = primaryAddress.recipientPhone;
      _selectedAddressType = primaryAddress.addressType;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _medicalNotesController.dispose();
    _emergencyContactController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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

  String _getRelationshipText(String relationship) {
    switch (relationship) {
      case 'mother': return 'Mẹ';
      case 'father': return 'Bố';
      case 'grandmother': return 'Bà';
      case 'grandfather': return 'Ông';
      case 'aunt': return 'Cô/Dì';
      case 'uncle': return 'Chú/Bác';
      default: return 'Khác';
    }
  }

  String _getAddressTypeText(String type) {
    switch (type) {
      case 'home': return 'Nhà riêng';
      case 'work': return 'Nơi làm việc';
      default: return 'Khác';
    }
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
      // TODO: Implement save logic with API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.elderly == null 
                ? 'Thêm người thân thành công!' 
                : 'Cập nhật thông tin thành công!'
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.elderly == null ? 'Thêm người thân' : 'Sửa thông tin',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _handleSave,
              child: Text(
                'Lưu',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: ResponsiveHelper.responsiveContainer(
        context: context,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Profile Photo Section
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: ResponsiveHelper.getIconSize(context, 120),
                      height: ResponsiveHelper.getIconSize(context, 120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.elderly?.avatar != null
                              ? ClipOval(
                                  child: Image.network(
                                    widget.elderly!.avatar!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person_add,
                                        size: ResponsiveHelper.getIconSize(context, 40),
                                        color: AppColors.primary,
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.person_add,
                                  size: ResponsiveHelper.getIconSize(context, 40),
                                  color: AppColors.primary,
                                ),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getSpacing(context)),

                Center(
                  child: Text(
                    'Chạm để chọn ảnh',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                // Personal Information Section
                Text(
                  'Thông tin cá nhân',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Họ và tên *',
                    hintText: 'Nhập họ và tên đầy đủ',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Nickname
                TextFormField(
                  controller: _nicknameController,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Tên thường gọi *',
                    hintText: 'Bà, ông, mẹ, bố...',
                    prefixIcon: Icon(
                      Icons.tag_faces,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên thường gọi';
                    }
                    return null;
                  },
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Date of Birth
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: ResponsiveHelper.getIconSize(context, 20),
                          color: AppColors.grey,
                        ),
                        SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Chọn ngày sinh *'
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

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Relationship
                DropdownButtonFormField<String>(
                  value: _selectedRelationship,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Mối quan hệ *',
                    prefixIcon: Icon(
                      Icons.family_restroom,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  items: _relationships.map((relationship) {
                    return DropdownMenuItem(
                      value: relationship,
                      child: Text(_getRelationshipText(relationship)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRelationship = value!;
                    });
                  },
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Số điện thoại *',
                    hintText: 'Nhập số điện thoại',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
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

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                // Health Information Section
                Text(
                  'Thông tin sức khỏe',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Medical Notes
                TextFormField(
                  controller: _medicalNotesController,
                  maxLines: 3,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Ghi chú y tế',
                    hintText: 'Các bệnh lý, thuốc đang sử dụng...',
                    prefixIcon: Icon(
                      Icons.medical_services_outlined,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Dietary Restrictions
                Text(
                  'Hạn chế chế độ ăn',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
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
                    return FilterChip(
                      label: Text(
                        restriction,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => _toggleDietaryRestriction(restriction),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.grey.withOpacity(0.1),
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Emergency Contact
                TextFormField(
                  controller: _emergencyContactController,
                  keyboardType: TextInputType.phone,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Số điện thoại khẩn cấp',
                    hintText: 'Số điện thoại liên hệ khẩn cấp',
                    prefixIcon: Icon(
                      Icons.emergency,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                // Budget Section
                Text(
                  'Quản lý chi tiêu',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Monthly Budget Limit
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Hạn mức chi tiêu tháng *',
                    hintText: '1000000',
                    prefixIcon: Icon(
                      Icons.monetization_on_outlined,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                    // suffixText: 'VNĐ',
                  ),
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

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                // Address Section
                Text(
                  'Địa chỉ giao hàng',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Address Type
                DropdownButtonFormField<String>(
                  value: _selectedAddressType,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Loại địa chỉ',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  items: _addressTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getAddressTypeText(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAddressType = value!;
                    });
                  },
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Full Address
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Địa chỉ đầy đủ *',
                    hintText: 'Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố',
                    prefixIcon: Icon(
                      Icons.home_outlined,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    return null;
                  },
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Recipient Name
                TextFormField(
                  controller: _recipientNameController,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Tên người nhận *',
                    hintText: 'Tên người nhận hàng',
                    prefixIcon: Icon(
                      Icons.person_pin_outlined,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên người nhận';
                    }
                    return null;
                  },
                ),

                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

                // Recipient Phone
                TextFormField(
                  controller: _recipientPhoneController,
                  keyboardType: TextInputType.phone,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                  ),
                  decoration: ResponsiveHelper.responsiveInputDecoration(
                    context: context,
                    labelText: 'Số điện thoại người nhận *',
                    hintText: 'Số điện thoại để liên hệ giao hàng',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại người nhận';
                    }
                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.getLargeSpacing(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            widget.elderly == null ? 'Thêm người thân' : 'Cập nhật thông tin',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 