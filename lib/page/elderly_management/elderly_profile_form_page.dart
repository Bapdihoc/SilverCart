import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/models/elderly_model.dart';
import '../../models/user_detail_response.dart';
import '../../network/service/location_service.dart';
import '../../network/service/elder_service.dart';
import '../../models/province_model.dart';
import '../../models/district_model.dart';
import '../../models/ward_model.dart';
import '../../models/elder_request.dart';
import '../../injection.dart';

class ElderlyProfileFormPage extends StatefulWidget {
  final Elderly? elderly; // null means add new, non-null means edit
  final UserDetailData? userDetail; // Detail data from API
  
  const ElderlyProfileFormPage({
    super.key,
    this.elderly,
    this.userDetail,
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
  final _recipientPhoneController = TextEditingController();
  
  // Address detail controllers
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _specificAddressController = TextEditingController();
  
  // Multiple addresses support
  List<Map<String, dynamic>> _addresses = [];
  int _selectedAddressIndex = 0;

  DateTime? _selectedDate;
  String _selectedRelationship = 'Mẹ';
  int _selectedGender = 0; // 0: Nam, 1: Nữ
  List<String> _dietaryRestrictions = [];
  File? _selectedImage;
  bool _isLoading = false;
  
  // Location related variables
  late final LocationService _locationService;
  late final ElderService _elderService;
  List<Province> _provinces = [];
  Province? _selectedProvince;
  bool _isLoadingProvinces = false;
  
  List<District> _districts = [];
  District? _selectedDistrict;
  bool _isLoadingDistricts = false;
  
  List<Ward> _wards = [];
  Ward? _selectedWard;
  bool _isLoadingWards = false;

  final List<String> _relationships = [
    'Mẹ', 'Bố', 'Bà', 'Ông',
    'Cô/Dì', 'Chú/Bác', 'Khác'
  ];



  final List<String> _commonDietaryRestrictions = [
    'Tiểu đường', 'Cao huyết áp', 'Tim mạch', 'Dạ dày',
    'Thận', 'Gan', 'Cholesterol cao', 'Gout'
  ];

  @override
  void initState() {
    super.initState();
    _locationService = getIt<LocationService>();
    _elderService = getIt<ElderService>();
    _loadProvinces();
    
    // Initialize with default address if creating new
    if (widget.elderly == null) {
      _addresses.add({
        'streetAddress': '',
        'wardCode': '0',
        'wardName': '',
        'districtID': 0,
        'districtName': '',
        'provinceID': 0,
        'provinceName': '',
        'phoneNumber': '',
      });
    } else {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    // Use userDetail data if available, otherwise fall back to elderly data
    if (widget.userDetail != null) {
      final userDetail = widget.userDetail!;
      
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
      _selectedRelationship = userDetail.relationShip;
      _selectedGender = userDetail.gender;
      
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
      
      _emergencyContactController.text = ''; // Not available in API response
      _budgetController.text = '0'; // Not available in API response

      // Initialize addresses from API data
      if (userDetail.addresses.isNotEmpty) {
        _addresses = userDetail.addresses.map((address) => {
          'streetAddress': address.streetAddress,
          'wardCode': address.wardCode,
          'wardName': address.wardName,
          'districtID': address.districtID,
          'districtName': address.districtName,
          'provinceID': address.provinceID,
          'provinceName': address.provinceName,
          'phoneNumber': address.phoneNumber,
        }).toList();
        
        if (_addresses.isNotEmpty) {
          _loadAddressData(0);
        }
      } else {
        // Add default empty address
        _addresses.add({
          'streetAddress': '',
          'wardCode': '0',
          'wardName': '',
          'districtID': 0,
          'districtName': '',
          'provinceID': 0,
          'provinceName': '',
          'phoneNumber': '',
        });
      }
    } else if (widget.elderly != null) {
      // Fallback to elderly data if userDetail is not available
      final elderly = widget.elderly!;
      
      // Extract full name and nickname from combined name if available
      final combinedName = elderly.fullName;
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
      
      _phoneController.text = elderly.phone;
      _selectedDate = elderly.dateOfBirth;
      _selectedRelationship = elderly.relationship;
      // Note: gender field not available in current Elderly model
      
      // Extract medical notes and dietary restrictions from description
      final description = elderly.medicalNotes ?? '';
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
      
      _emergencyContactController.text = elderly.emergencyContact ?? '';
      _budgetController.text = elderly.monthlyBudgetLimit.toString();

      // Initialize addresses if available
    if (elderly.addresses?.isNotEmpty == true) {
        _addresses = elderly.addresses!.map((address) => {
          'streetAddress': address.fullAddress,
          'wardCode': '0', // Default value
          'wardName': '',
          'districtID': 0,
          'districtName': '',
          'provinceID': 0,
          'provinceName': '',
          'phoneNumber': address.recipientPhone,
        }).toList();
        
        if (_addresses.isNotEmpty) {
          _loadAddressData(0);
        }
      } else {
        // Add default empty address
        _addresses.add({
          'streetAddress': '',
          'wardCode': '0',
          'wardName': '',
          'districtID': 0,
          'districtName': '',
          'provinceID': 0,
          'provinceName': '',
          'phoneNumber': '',
        });
      }
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
    _recipientPhoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _specificAddressController.dispose();
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

  void _loadAddressData(int index) {
    if (index >= 0 && index < _addresses.length) {
      final address = _addresses[index];
      _specificAddressController.text = address['streetAddress'] ?? '';
      _recipientPhoneController.text = address['phoneNumber'] ?? '';
      
      // Load location data if available
      if (address['provinceID'] != null && address['provinceID'] > 0) {
        _loadProvinces().then((_) {
          final province = _provinces.firstWhere(
            (p) => p.provinceID == address['provinceID'],
            orElse: () => _provinces.first,
          );
          setState(() {
            _selectedProvince = province;
            _cityController.text = province.provinceName;
          });
          
          if (address['districtID'] != null && address['districtID'] > 0) {
            _loadDistricts(province.provinceID).then((_) {
              final district = _districts.firstWhere(
                (d) => d.districtID == address['districtID'],
                orElse: () => _districts.first,
              );
              setState(() {
                _selectedDistrict = district;
                _districtController.text = district.districtName;
              });
              
              if (address['wardCode'] != null && address['wardCode'] != '0') {
                _loadWards(district.districtID).then((_) {
                  final ward = _wards.firstWhere(
                    (w) => w.wardCode == address['wardCode'],
                    orElse: () => _wards.first,
                  );
                  setState(() {
                    _selectedWard = ward;
                    _wardController.text = ward.wardName;
                  });
                });
              }
            });
          }
        });
      } else {
        // Clear location data if no province
        setState(() {
          _selectedProvince = null;
          _selectedDistrict = null;
          _selectedWard = null;
          _cityController.clear();
          _districtController.clear();
          _wardController.clear();
        });
      }
    }
  }

  void _saveCurrentAddress() {
    if (_selectedAddressIndex >= 0 && _selectedAddressIndex < _addresses.length) {
      _addresses[_selectedAddressIndex] = {
        'streetAddress': _specificAddressController.text.trim(),
        'wardCode': _selectedWard?.wardCode ?? '0',
        'wardName': _selectedWard?.wardName ?? '',
        'districtID': _selectedDistrict?.districtID ?? 0,
        'districtName': _selectedDistrict?.districtName ?? '',
        'provinceID': _selectedProvince?.provinceID ?? 0,
        'provinceName': _selectedProvince?.provinceName ?? '',
        'phoneNumber': _recipientPhoneController.text.trim(),
      };
    }
  }

  void _updateCurrentAddressLocation() {
    if (_selectedAddressIndex >= 0 && _selectedAddressIndex < _addresses.length) {
      _addresses[_selectedAddressIndex] = {
        'streetAddress': _addresses[_selectedAddressIndex]['streetAddress'] ?? '',
        'wardCode': _selectedWard?.wardCode ?? '0',
        'wardName': _selectedWard?.wardName ?? '',
        'districtID': _selectedDistrict?.districtID ?? 0,
        'districtName': _selectedDistrict?.districtName ?? '',
        'provinceID': _selectedProvince?.provinceID ?? 0,
        'provinceName': _selectedProvince?.provinceName ?? '',
        'phoneNumber': _addresses[_selectedAddressIndex]['phoneNumber'] ?? '',
      };
    }
  }

  void _addNewAddress() {
    _saveCurrentAddress();
    
    _addresses.add({
      'streetAddress': '',
      'wardCode': '0',
      'wardName': '',
      'districtID': 0,
      'districtName': '',
      'provinceID': 0,
      'provinceName': '',
      'phoneNumber': '',
    });
    
    setState(() {
      _selectedAddressIndex = _addresses.length - 1;
    });
    
    _loadAddressData(_selectedAddressIndex);
  }

  void _removeAddress(int index) {
    if (_addresses.length > 1) {
      setState(() {
        _addresses.removeAt(index);
        if (_selectedAddressIndex >= _addresses.length) {
          _selectedAddressIndex = _addresses.length - 1;
        }
      });
      _loadAddressData(_selectedAddressIndex);
    }
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _isLoadingProvinces = true;
    });

    try {
      final result = await _locationService.getProvinces();
      if (result.isSuccess && result.data != null) {
        setState(() {
          _provinces = result.data!.data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể tải danh sách tỉnh/thành phố'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoadingProvinces = false;
      });
    }
  }

  Future<void> _loadDistricts(int provinceId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
    });

    try {
      final result = await _locationService.getDistricts(provinceId);
      if (result.isSuccess && result.data != null) {
        setState(() {
          _districts = result.data!.data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể tải danh sách quận/huyện'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoadingDistricts = false;
      });
    }
  }

  Future<void> _loadWards(int districtId) async {
    setState(() {
      _isLoadingWards = true;
      _wards = [];
      _selectedWard = null;
    });

    try {
      final result = await _locationService.getWards(districtId);
      if (result.isSuccess && result.data != null) {
        setState(() {
          _wards = result.data!.data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể tải danh sách phường/xã'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoadingWards = false;
      });
    }
  }

  void _showProvinceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProvinceBottomSheet(),
    );
  }

  void _showDistrictBottomSheet() {
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn tỉnh/thành phố trước'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDistrictBottomSheet(),
    );
  }

  void _showWardBottomSheet() {
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn tỉnh/thành phố trước'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn quận/huyện trước'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWardBottomSheet(),
    );
  }

  // Modal-specific bottom sheet methods with StateSetter
  void _showProvinceBottomSheetForModal(StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProvinceBottomSheetForModal(setModalState),
    );
  }

  void _showDistrictBottomSheetForModal(StateSetter setModalState) {
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn tỉnh/thành phố trước'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDistrictBottomSheetForModal(setModalState),
    );
  }

  void _showWardBottomSheetForModal(StateSetter setModalState) {
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn tỉnh/thành phố trước'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn quận/huyện trước'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWardBottomSheetForModal(setModalState),
    );
  }

  Widget _buildProvinceBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Chọn Tỉnh/Thành phố',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.grey,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tỉnh/thành phố...',
                  hintStyle: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Provinces list
          Expanded(
            child: _isLoadingProvinces
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.getIconSize(context, 40),
                          height: ResponsiveHelper.getIconSize(context, 40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Đang tải danh sách...',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                    itemCount: _provinces.length,
                    itemBuilder: (context, index) {
                      final province = _provinces[index];
                      final isSelected = _selectedProvince?.provinceID == province.provinceID;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                          title: Text(
                            province.provinceName,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.primary : AppColors.text,
                            ),
                          ),
                          subtitle: Text(
                            'Mã: ${province.code}',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: AppColors.grey,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: ResponsiveHelper.getIconSize(context, 24),
                                )
                              : null,
                          onTap: () async {
                            setState(() {
                              _selectedProvince = province;
                              _cityController.text = province.provinceName;
                              _selectedDistrict = null;
                              _districtController.clear();
                              _selectedWard = null;
                              _wardController.clear();
                            });
                            
                            // Update current address data
                            _updateCurrentAddressLocation();
                            
                            Navigator.pop(context);
                            await _loadDistricts(province.provinceID);
                          },
                        ),
                      );
                    },
                  ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildDistrictBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Chọn Quận/Huyện',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.grey,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm quận/huyện...',
                  hintStyle: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Districts list
          Expanded(
            child: _isLoadingDistricts
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.getIconSize(context, 40),
                          height: ResponsiveHelper.getIconSize(context, 40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Đang tải danh sách...',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : _districts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_rounded,
                              size: ResponsiveHelper.getIconSize(context, 48),
                              color: AppColors.grey,
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context)),
                            Text(
                              'Không có quận/huyện nào',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                        itemCount: _districts.length,
                        itemBuilder: (context, index) {
                          final district = _districts[index];
                          final isSelected = _selectedDistrict?.districtID == district.districtID;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                              title: Text(
                                district.districtName,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? AppColors.primary : AppColors.text,
                                ),
                              ),
                              subtitle: Text(
                                'Mã: ${district.code}',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: ResponsiveHelper.getIconSize(context, 24),
                                    )
                                  : null,
                              onTap: () async {
                                setState(() {
                                  _selectedDistrict = district;
                                  _districtController.text = district.districtName;
                                  _selectedWard = null;
                                  _wardController.clear();
                                });
                                
                                // Update current address data
                                _updateCurrentAddressLocation();
                                
                                Navigator.pop(context);
                                await _loadWards(district.districtID);
                              },
                            ),
                          );
                        },
                      ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildWardBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Chọn Phường/Xã',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.grey,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm phường/xã...',
                  hintStyle: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Wards list
          Expanded(
            child: _isLoadingWards
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.getIconSize(context, 40),
                          height: ResponsiveHelper.getIconSize(context, 40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Đang tải danh sách...',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : _wards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_rounded,
                              size: ResponsiveHelper.getIconSize(context, 48),
                              color: AppColors.grey,
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context)),
                            Text(
                              'Không có phường/xã nào',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                        itemCount: _wards.length,
                        itemBuilder: (context, index) {
                          final ward = _wards[index];
                          final isSelected = _selectedWard?.wardCode == ward.wardCode;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                              title: Text(
                                ward.wardName,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? AppColors.primary : AppColors.text,
                                ),
                              ),
                              subtitle: Text(
                                'Mã: ${ward.wardCode}',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: ResponsiveHelper.getIconSize(context, 24),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedWard = ward;
                                  _wardController.text = ward.wardName;
                                });
                                
                                // Update current address data
                                _updateCurrentAddressLocation();
                                
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày sinh')),
      );
      return;
    }
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tỉnh/thành phố')),
      );
      return;
    }
    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn quận/huyện')),
      );
      return;
    }
    if (_selectedWard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phường/xã')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save current address before creating request
      _saveCurrentAddress();
      
      // Create ElderRequest
      final elderRequest = ElderRequest(
        fullName: _buildCombinedFullName(),
        userName: _fullNameController.text.trim(), // Using fullName as userName
        description: _buildCombinedDescription(),
        birthDate: _selectedDate!,
        spendlimit: double.tryParse(_budgetController.text) ?? 0.0,
        avatar: null, // TODO: Handle avatar upload
        emergencyPhoneNumber: _emergencyContactController.text.trim(),
        relationShip: _selectedRelationship,
        gender: _selectedGender, // Use selected gender value
        categoryValueIds: [], // Using dietary restrictions as categoryValueIds
        addresses: _addresses.map((address) => ElderAddress(
          streetAddress: address['streetAddress'] ?? '',
          wardCode: int.tryParse(address['wardCode'] ?? '0') ?? 0,
          wardName: address['wardName'] ?? '',
          districtID: address['districtID'] ?? 0,
          districtName: address['districtName'] ?? '',
          provinceID: address['provinceID'] ?? 0,
          provinceName: address['provinceName'] ?? '',
          phoneNumber: address['phoneNumber'] ?? '',
        )).toList(),
      );

      final result = await _elderService.createElder(elderRequest);

      if (mounted) {
        if (result.isSuccess) {
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Có lỗi xảy ra khi lưu thông tin'),
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

  /// Builds combined full name with nickname in format: "Họ và tên (Tên thường gọi)"
  /// This method combines the full name and nickname into a single field for API
  /// Example: "Nguyễn Văn A (Bác A)" or just "Nguyễn Văn A" if no nickname
  String _buildCombinedFullName() {
    final fullName = _fullNameController.text.trim();
    final nickname = _nicknameController.text.trim();
    
    if (nickname.isNotEmpty && nickname != fullName) {
      return '$fullName ($nickname)';
    }
    return fullName;
  }

  /// Builds combined description with medical notes and dietary restrictions
  /// This method combines medical notes and dietary restrictions into a single field for API
  /// Format: "Ghi chú y tế: [notes]\n\nHạn chế chế độ ăn: [restrictions]"
  String _buildCombinedDescription() {
    final medicalNotes = _medicalNotesController.text.trim();
    final dietaryRestrictions = _dietaryRestrictions;
    
    List<String> parts = [];
    
    // Add medical notes if available
    if (medicalNotes.isNotEmpty) {
      parts.add('Ghi chú y tế: $medicalNotes');
    }
    
    // Add dietary restrictions if available
    if (dietaryRestrictions.isNotEmpty) {
      parts.add('Hạn chế chế độ ăn: ${dietaryRestrictions.join(', ')}');
    }
    
    // If no content, return empty string
    if (parts.isEmpty) {
      return '';
    }
    
    // Join all parts with double line breaks for better readability
    return parts.join('\n\n');
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
          widget.elderly == null ? 'Thêm người thân' : 'Sửa thông tin',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        // actions: [
        //   if (_isLoading)
        //     Container(
        //       margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        //       padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        //       decoration: BoxDecoration(
        //         color: AppColors.primary.withOpacity(0.1),
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: SizedBox(
        //         width: 20,
        //         height: 20,
        //         child: CircularProgressIndicator(
        //           color: AppColors.primary,
        //           strokeWidth: 2,
        //         ),
        //       ),
        //     )
        //   else
        //     Container(
        //       margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
        //       decoration: BoxDecoration(
        //         gradient: LinearGradient(
        //           colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        //         ),
        //         borderRadius: BorderRadius.circular(12),
        //         boxShadow: [
        //           BoxShadow(
        //             color: AppColors.primary.withOpacity(0.3),
        //             blurRadius: 10,
        //             offset: const Offset(0, 4),
        //           ),
        //         ],
        //       ),
        //       child: TextButton(
        //         onPressed: _handleSave,
        //         child: Text(
        //           'Lưu',
        //           style: ResponsiveHelper.responsiveTextStyle(
        //             context: context,
        //             baseSize: 16,
        //             fontWeight: FontWeight.w600,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        //     ),
        // ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Profile Photo Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: ResponsiveHelper.getIconSize(context, 120),
                    height: ResponsiveHelper.getIconSize(context, 120),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.secondary.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
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
                                      Icons.person_add_rounded,
                                      size: ResponsiveHelper.getIconSize(context, 40),
                                      color: AppColors.primary,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                Icons.person_add_rounded,
                                size: ResponsiveHelper.getIconSize(context, 40),
                                color: AppColors.primary,
                              ),
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.getSpacing(context)),

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Chạm để chọn ảnh',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

              // Modern Section Cards
              _buildSectionCard(
                title: 'Thông tin cá nhân',
                icon: Icons.person_rounded,
                children: [
                  _buildModernTextField(
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
                  _buildModernTextField(
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
                  _buildModernDatePicker(),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildModernDropdown(
                    value: _selectedRelationship,
                    label: 'Mối quan hệ',
                    icon: Icons.family_restroom_rounded,
                    items: _relationships.map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r, style: TextStyle(color: Colors.black, fontSize: 16),),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedRelationship = value!),
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildModernGenderSelector(),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildModernTextField(
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
                  _buildModernTextField(
                    controller: _medicalNotesController,
                    label: 'Ghi chú y tế',
                    hint: 'Các bệnh lý, thuốc đang sử dụng...',
                    icon: Icons.medical_services_rounded,
                    maxLines: 3,
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildDietaryRestrictionsSection(),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  _buildModernTextField(
                    controller: _emergencyContactController,
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
                  _buildModernTextField(
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

              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

              _buildSectionCard(
                title: 'Địa chỉ giao hàng',
                icon: Icons.location_on_rounded,
                children: [
                  // Address selector
                  _buildAddressSelector(),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  
                  // Address form
                  _buildAddressForm(),
                ],
              ),

              SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),

              // Modern Save Button
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
                            Icon(
                              widget.elderly == null 
                                  ? Icons.person_add_rounded 
                                  : Icons.save_rounded,
                              size: 20,
                            ),
                            SizedBox(width: ResponsiveHelper.getSpacing(context)),
                            Text(
                              widget.elderly == null ? 'Thêm người thân' : 'Cập nhật thông tin',
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

  Widget _buildModernTextField({
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

  Widget _buildModernDatePicker() {
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

  Widget _buildModernDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
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
          child: DropdownButtonFormField<String>(
            value: value,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
            ),
            decoration: InputDecoration(
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
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildModernProvinceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tỉnh/Thành phố',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        GestureDetector(
          onTap: _showProvinceBottomSheet,
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
                  Icons.location_city_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    _selectedProvince?.provinceName ?? 'Chọn tỉnh/thành phố',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: _selectedProvince != null ? AppColors.text : AppColors.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: ResponsiveHelper.getIconSize(context, 24),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_selectedProvince == null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context)),
            child: Text(
              'Vui lòng chọn tỉnh/thành phố',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernDistrictSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quận/Huyện',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        GestureDetector(
          onTap: _showDistrictBottomSheet,
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
                  Icons.location_on_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    _selectedDistrict?.districtName ?? 'Chọn quận/huyện',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: _selectedDistrict != null ? AppColors.text : AppColors.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: ResponsiveHelper.getIconSize(context, 24),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_selectedProvince != null && _selectedDistrict == null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context)),
            child: Text(
              'Vui lòng chọn quận/huyện',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernWardSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phường/Xã',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        GestureDetector(
          onTap: _showWardBottomSheet,
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
                  Icons.location_on_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    _selectedWard?.wardName ?? 'Chọn phường/xã',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: _selectedWard != null ? AppColors.text : AppColors.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: ResponsiveHelper.getIconSize(context, 24),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_selectedDistrict != null && _selectedWard == null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context)),
            child: Text(
              'Vui lòng chọn phường/xã',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.error,
              ),
          ),
        ),
      ],
    );
  }

  // Modal-specific selectors with StateSetter
  Widget _buildModernProvinceSelectorForModal(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tỉnh/Thành phố',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        GestureDetector(
          onTap: () => _showProvinceBottomSheetForModal(setModalState),
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
                  Icons.location_city_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    _selectedProvince?.provinceName ?? 'Chọn tỉnh/thành phố',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: _selectedProvince != null ? AppColors.text : AppColors.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: ResponsiveHelper.getIconSize(context, 24),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_selectedProvince == null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context)),
            child: Text(
              'Vui lòng chọn tỉnh/thành phố',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernDistrictSelectorForModal(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quận/Huyện',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        GestureDetector(
          onTap: () => _showDistrictBottomSheetForModal(setModalState),
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
                  Icons.location_on_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    _selectedDistrict?.districtName ?? 'Chọn quận/huyện',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: _selectedDistrict != null ? AppColors.text : AppColors.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: ResponsiveHelper.getIconSize(context, 24),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_selectedProvince != null && _selectedDistrict == null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context)),
            child: Text(
              'Vui lòng chọn quận/huyện',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernWardSelectorForModal(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phường/Xã',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        GestureDetector(
          onTap: () => _showWardBottomSheetForModal(setModalState),
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
                  Icons.location_on_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    _selectedWard?.wardName ?? 'Chọn phường/xã',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: _selectedWard != null ? AppColors.text : AppColors.grey,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: ResponsiveHelper.getIconSize(context, 24),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (_selectedDistrict != null && _selectedWard == null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context)),
            child: Text(
              'Vui lòng chọn phường/xã',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                color: AppColors.error,
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

  Widget _buildModernGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới tính',
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
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = 0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getSpacing(context),
                              horizontal: ResponsiveHelper.getLargeSpacing(context),
                            ),
                            decoration: BoxDecoration(
                              color: _selectedGender == 0 
                                  ? AppColors.primary 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedGender == 0 
                                    ? AppColors.primary 
                                    : AppColors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.male_rounded,
                                  size: ResponsiveHelper.getIconSize(context, 18),
                                  color: _selectedGender == 0 
                                      ? Colors.white 
                                      : AppColors.text,
                                ),
                                SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                                Text(
                                  'Nam',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedGender == 0 
                                        ? Colors.white 
                                        : AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = 1),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getSpacing(context),
                              horizontal: ResponsiveHelper.getLargeSpacing(context),
                            ),
                            decoration: BoxDecoration(
                              color: _selectedGender == 1 
                                  ? AppColors.primary 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedGender == 1 
                                    ? AppColors.primary 
                                    : AppColors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.female_rounded,
                                  size: ResponsiveHelper.getIconSize(context, 18),
                                  color: _selectedGender == 1 
                                      ? Colors.white 
                                      : AppColors.text,
                                ),
                                SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                                Text(
                                  'Nữ',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedGender == 1 
                                        ? Colors.white 
                                        : AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSelector() {
    // If viewing existing elder, show address cards
    if (widget.elderly != null) {
      return _buildAddressCards();
    }
    
    // If creating new elder, show tab-based address selector
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Địa chỉ giao hàng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const Spacer(),
            // GestureDetector(
            //   onTap: _addNewAddress,
            //   child: Container(
            //     padding: EdgeInsets.symmetric(
            //       horizontal: ResponsiveHelper.getSpacing(context),
            //       vertical: ResponsiveHelper.getSpacing(context) / 2,
            //     ),
            //     decoration: BoxDecoration(
            //       color: AppColors.primary.withOpacity(0.1),
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         Icon(
            //           Icons.add_rounded,
            //           size: 16,
            //           color: AppColors.primary,
            //         ),
            //         SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
            //         Text(
            //           'Thêm địa chỉ',
            //           style: ResponsiveHelper.responsiveTextStyle(
            //             context: context,
            //             baseSize: 12,
            //             fontWeight: FontWeight.w600,
            //             color: AppColors.primary,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        
        // Address tabs
        // SizedBox(
        //   height: 50,
        //   child: ListView.separated(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: _addresses.length,
        //     separatorBuilder: (context, index) => 
        //         SizedBox(width: ResponsiveHelper.getSpacing(context)),
        //     itemBuilder: (context, index) {
        //       final isSelected = _selectedAddressIndex == index;
        //       final address = _addresses[index];
        //       final hasData = (address['streetAddress']?.isNotEmpty == true) ||
        //                      (address['provinceName']?.isNotEmpty == true);
              
        //       return GestureDetector(
        //         onTap: () {
        //           _saveCurrentAddress();
        //           setState(() {
        //             _selectedAddressIndex = index;
        //           });
        //           _loadAddressData(index);
        //         },
        //         child: Container(
        //           padding: EdgeInsets.symmetric(
        //             horizontal: ResponsiveHelper.getSpacing(context),
        //             vertical: ResponsiveHelper.getSpacing(context) / 2,
        //           ),
        //           decoration: BoxDecoration(
        //             color: isSelected ? AppColors.primary : Colors.white,
        //             borderRadius: BorderRadius.circular(12),
        //             border: Border.all(
        //               color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
        //               width: 1,
        //             ),
        //             boxShadow: isSelected ? [
        //               BoxShadow(
        //                 color: AppColors.primary.withOpacity(0.2),
        //                 blurRadius: 4,
        //                 offset: const Offset(0, 2),
        //               ),
        //             ] : null,
        //           ),
        //           child: Row(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               Icon(
        //                 hasData ? Icons.location_on_rounded : Icons.location_off_rounded,
        //                 size: 16,
        //                 color: isSelected ? Colors.white : AppColors.grey,
        //               ),
        //               SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
        //               Text(
        //                 'Địa chỉ ${index + 1}',
        //                 style: ResponsiveHelper.responsiveTextStyle(
        //                   context: context,
        //                   baseSize: 12,
        //                   fontWeight: FontWeight.w600,
        //                   color: isSelected ? Colors.white : AppColors.text,
        //                 ),
        //               ),
        //               if (_addresses.length > 1) ...[
        //                 SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
        //                 GestureDetector(
        //                   onTap: () => _removeAddress(index),
        //                   child: Icon(
        //                     Icons.close_rounded,
        //                     size: 14,
        //                     color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.grey,
        //                   ),
        //                 ),
        //               ],
        //             ],
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }

  Widget _buildAddressForm() {
    return Column(
      children: [
        _buildModernProvinceSelector(),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildModernDistrictSelector(),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildModernWardSelector(),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildModernTextField(
          controller: _specificAddressController,
          label: 'Địa chỉ cụ thể',
          hint: 'Số nhà, tên đường, tên khu vực',
          icon: Icons.home_rounded,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập địa chỉ cụ thể';
            }
            return null;
          },
        ),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildModernTextField(
          controller: _recipientPhoneController,
          label: 'Số điện thoại người nhận',
          hint: 'Số điện thoại để liên hệ giao hàng',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
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
      ],
    );
  }

  Widget _buildAddressFormForModal(StateSetter setModalState) {
    return Column(
      children: [
        _buildModernProvinceSelectorForModal(setModalState),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildModernDistrictSelectorForModal(setModalState),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildModernWardSelectorForModal(setModalState),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildModernTextField(
          controller: _specificAddressController,
          label: 'Địa chỉ cụ thể',
          hint: 'Số nhà, tên đường, tên khu vực',
          icon: Icons.home_rounded,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập địa chỉ cụ thể';
            }
            return null;
          },
        ),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildModernTextField(
          controller: _recipientPhoneController,
          label: 'Số điện thoại người nhận',
          hint: 'Số điện thoại để liên hệ giao hàng',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
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
      ],
    );
  }

  Widget _buildAddressCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Địa chỉ giao hàng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const Spacer(),
            Text(
              '${_addresses.length} địa chỉ',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context)),
        
        // Address cards
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _addresses.length,
          separatorBuilder: (context, index) => 
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
          itemBuilder: (context, index) {
            final address = _addresses[index];
            return _buildAddressCard(address, index);
          },
        ),
      ],
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    final fullAddress = _buildFullAddressText(address);
    final phoneNumber = address['phoneNumber'] ?? '';
    
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with address number and actions
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Địa chỉ ${index + 1}',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              // Edit button
              GestureDetector(
                onTap: () => _editAddress(index),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Delete button
              if (_addresses.length > 1)
                GestureDetector(
                  onTap: () => _deleteAddress(index),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Address details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullAddress.isNotEmpty ? fullAddress : 'Chưa có thông tin địa chỉ',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 13,
                        fontWeight: FontWeight.w500,
                        color: fullAddress.isNotEmpty ? AppColors.text : AppColors.grey,
                      ),
                    ),
                    if (phoneNumber.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 12,
                            color: AppColors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            phoneNumber,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildFullAddressText(Map<String, dynamic> address) {
    List<String> parts = [];
    
    if (address['streetAddress']?.isNotEmpty == true) {
      parts.add(address['streetAddress']);
    }
    if (address['wardName']?.isNotEmpty == true) {
      parts.add(address['wardName']);
    }
    if (address['districtName']?.isNotEmpty == true) {
      parts.add(address['districtName']);
    }
    if (address['provinceName']?.isNotEmpty == true) {
      parts.add(address['provinceName']);
    }
    
    return parts.join(', ');
  }

  void _editAddress(int index) {
    setState(() {
      _selectedAddressIndex = index;
    });
    _loadAddressData(index);
    
    // Show address form in bottom sheet with StatefulBuilder
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  
                  // Header
                  Row(
                    children: [
                      Text(
                        'Chỉnh sửa địa chỉ ${index + 1}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close_rounded,
                          size: 24,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  
                  // Address form with modal state management
                  _buildAddressFormForModal(setModalState),
                  
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveCurrentAddress();
                        Navigator.pop(context);
                        setState(() {
                          // Force refresh to update UI with new address data
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Lưu thay đổi',
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
            ),
          ),
        ),
      ),
    );
  }

  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Xóa địa chỉ',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa địa chỉ này không?',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.grey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeAddress(index);
            },
            child: Text(
              'Xóa',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modal-specific bottom sheet builders with StateSetter
  Widget _buildProvinceBottomSheetForModal(StateSetter setModalState) {
    return StatefulBuilder(
      builder: (context, setBottomSheetState) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    'Chọn Tỉnh/Thành phố',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.grey,
                      size: ResponsiveHelper.getIconSize(context, 24),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tỉnh/thành phố...',
                    hintStyle: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: AppColors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.primary,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                  ),
                  onChanged: (value) {
                    // TODO: Implement search functionality
                  },
                ),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            
            // Provinces list
            Expanded(
              child: _isLoadingProvinces
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: ResponsiveHelper.getIconSize(context, 40),
                            height: ResponsiveHelper.getIconSize(context, 40),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Đang tải danh sách...',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                      itemCount: _provinces.length,
                      itemBuilder: (context, index) {
                        final province = _provinces[index];
                        final isSelected = _selectedProvince?.provinceID == province.provinceID;
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                            title: Text(
                              province.provinceName,
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.primary : AppColors.text,
                              ),
                            ),
                            subtitle: Text(
                              'Mã: ${province.code}',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                    size: ResponsiveHelper.getIconSize(context, 24),
                                  )
                                : null,
                            onTap: () async {
                              setState(() {
                                _selectedProvince = province;
                                _cityController.text = province.provinceName;
                                _selectedDistrict = null;
                                _districtController.clear();
                                _selectedWard = null;
                                _wardController.clear();
                              });
                              
                              // Update current address data
                              _updateCurrentAddressLocation();
                              
                              // Update modal state
                              setModalState(() {});
                              
                              // Update bottom sheet state for immediate visual feedback
                              setBottomSheetState(() {});
                              
                              Navigator.pop(context);
                              await _loadDistricts(province.provinceID);
                            },
                          ),
                        );
                      },
                    ),
            ),
            
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictBottomSheetForModal(StateSetter setModalState) {
    return StatefulBuilder(
      builder: (context, setBottomSheetState) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Chọn Quận/Huyện',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.grey,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm quận/huyện...',
                  hintStyle: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                    ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Districts list
          Expanded(
            child: _isLoadingDistricts
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.getIconSize(context, 40),
                          height: ResponsiveHelper.getIconSize(context, 40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Đang tải danh sách...',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : _districts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_rounded,
                              size: ResponsiveHelper.getIconSize(context, 48),
                              color: AppColors.grey,
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context)),
                            Text(
                              'Không có quận/huyện nào',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                        itemCount: _districts.length,
                        itemBuilder: (context, index) {
                          final district = _districts[index];
                          final isSelected = _selectedDistrict?.districtID == district.districtID;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                              title: Text(
                                district.districtName,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? AppColors.primary : AppColors.text,
                                ),
                              ),
                              subtitle: Text(
                                'Mã: ${district.code}',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: ResponsiveHelper.getIconSize(context, 24),
                                    )
                                  : null,
                              onTap: () async {
                                setState(() {
                                  _selectedDistrict = district;
                                  _districtController.text = district.districtName;
                                  _selectedWard = null;
                                  _wardController.clear();
                                });
                                
                                // Update current address data
                                _updateCurrentAddressLocation();
                                
                                // Update modal state
                                setModalState(() {});
                                
                                // Update bottom sheet state for immediate visual feedback
                                setBottomSheetState(() {});
                                
                                Navigator.pop(context);
                                await _loadWards(district.districtID);
                              },
                            ),
                          );
                        },
                      ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        ],
      ),
      ),
    );
  }

  Widget _buildWardBottomSheetForModal(StateSetter setModalState) {
    return StatefulBuilder(
      builder: (context, setBottomSheetState) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Chọn Phường/Xã',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.grey,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm phường/xã...',
                  hintStyle: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Wards list
          Expanded(
            child: _isLoadingWards
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: ResponsiveHelper.getIconSize(context, 40),
                          height: ResponsiveHelper.getIconSize(context, 40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                        Text(
                          'Đang tải danh sách...',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : _wards.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_rounded,
                              size: ResponsiveHelper.getIconSize(context, 48),
                              color: AppColors.grey,
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context)),
                            Text(
                              'Không có phường/xã nào',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
                        itemCount: _wards.length,
                        itemBuilder: (context, index) {
                          final ward = _wards[index];
                          final isSelected = _selectedWard?.wardCode == ward.wardCode;
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                              title: Text(
                                ward.wardName,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? AppColors.primary : AppColors.text,
                                ),
                              ),
                              subtitle: Text(
                                'Mã: ${ward.wardCode}',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: ResponsiveHelper.getIconSize(context, 24),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedWard = ward;
                                  _wardController.text = ward.wardName;
                                });
                                
                                // Update current address data
                                _updateCurrentAddressLocation();
                                
                                // Update modal state
                                setModalState(() {});
                                
                                // Update bottom sheet state for immediate visual feedback
                                setBottomSheetState(() {});
                                
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
          ),
          
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        ],
      ),
      ),
    );
  }
} 