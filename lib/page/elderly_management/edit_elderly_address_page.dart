import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/user_detail_response.dart';
import '../../models/update_elder_address_request.dart';
import '../../network/service/elder_service.dart';
import '../../network/service/location_service.dart';
import '../../models/province_model.dart';
import '../../models/district_model.dart';
import '../../models/ward_model.dart';
import '../../injection.dart';

class EditElderlyAddressPage extends StatefulWidget {
  final UserDetailData userDetail;

  const EditElderlyAddressPage({
    super.key,
    required this.userDetail,
  });

  @override
  State<EditElderlyAddressPage> createState() => _EditElderlyAddressPageState();
}

class _EditElderlyAddressPageState extends State<EditElderlyAddressPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Multiple addresses support
  List<Map<String, dynamic>> _addresses = <Map<String, dynamic>>[];
  int _selectedAddressIndex = 0;
  
  // Address detail controllers for current selected address
  final _specificAddressController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  
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

  @override
  void initState() {
    super.initState();
    _locationService = getIt<LocationService>();
    _elderService = getIt<ElderService>();
    _loadProvinces();
    _initializeWithUserData();
  }

  void _initializeWithUserData() {
    final userDetail = widget.userDetail;
    
    // Initialize addresses from API data
    if (userDetail.addresses.isNotEmpty) {
      _addresses = userDetail.addresses.map((address) => _createAddressMap(
        streetAddress: address.streetAddress,
        wardCode: address.wardCode,
        wardName: address.wardName,
        districtID: address.districtID,
        districtName: address.districtName,
        provinceID: address.provinceID,
        provinceName: address.provinceName,
        phoneNumber: address.phoneNumber,
      )).toList();
      
      if (_addresses.isNotEmpty) {
        _loadAddressData(0);
      }
    } else {
      // Add default empty address
      _addresses.add(_createAddressMap());
    }
  }

  @override
  void dispose() {
    _specificAddressController.dispose();
    _recipientPhoneController.dispose();
    super.dispose();
  }

  /// Safely parse dynamic value to int
  int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    print('Warning: Unexpected type for int parsing: ${value.runtimeType}, value: $value');
    return 0;
  }

  /// Safely parse dynamic value to string
  String _safeParseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  /// Debug method to validate address data
  void _debugValidateAddress(Map<String, dynamic> address) {
    print('Address validation:');
    address.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });
  }

  /// Create a properly typed address map
  Map<String, dynamic> _createAddressMap({
    String streetAddress = '',
    String wardCode = '0',
    String wardName = '',
    int districtID = 0,
    String districtName = '',
    int provinceID = 0,
    String provinceName = '',
    String phoneNumber = '',
  }) {
    return <String, dynamic>{
      'streetAddress': streetAddress,
      'wardCode': wardCode,
      'wardName': wardName,
      'districtID': districtID,
      'districtName': districtName,
      'provinceID': provinceID,
      'provinceName': provinceName,
      'phoneNumber': phoneNumber,
    };
  }

  void _loadAddressData(int index) {
    if (index >= 0 && index < _addresses.length) {
      final address = _addresses[index];
      _specificAddressController.text = address['streetAddress'] ?? '';
      _recipientPhoneController.text = address['phoneNumber'] ?? '';
      
      // Load location data if available
      final provinceID = _safeParseInt(address['provinceID']);
      if (provinceID > 0) {
        _loadProvinces().then((_) {
          final province = _provinces.firstWhere(
            (p) => p.provinceID == provinceID,
            orElse: () => _provinces.first,
          );
          setState(() {
            _selectedProvince = province;
          });
          
          final districtID = _safeParseInt(address['districtID']);
          if (districtID > 0) {
            _loadDistricts(province.provinceID).then((_) {
              final district = _districts.firstWhere(
                (d) => d.districtID == districtID,
                orElse: () => _districts.first,
              );
              setState(() {
                _selectedDistrict = district;
              });
              
              final wardCode = (address['wardCode'] ?? '0').toString();
              if (wardCode != '0' && wardCode.isNotEmpty) {
                _loadWards(district.districtID).then((_) {
                  final ward = _wards.firstWhere(
                    (w) => w.wardCode == wardCode,
                    orElse: () => _wards.first,
                  );
                  setState(() {
                    _selectedWard = ward;
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
        });
      }
    }
  }

  void _saveCurrentAddress() {
    if (_selectedAddressIndex >= 0 && _selectedAddressIndex < _addresses.length) {
      _addresses[_selectedAddressIndex] = _createAddressMap(
        streetAddress: _specificAddressController.text.trim(),
        wardCode: _selectedWard?.wardCode ?? '0',
        wardName: _selectedWard?.wardName ?? '',
        districtID: _selectedDistrict?.districtID ?? 0,
        districtName: _selectedDistrict?.districtName ?? '',
        provinceID: _selectedProvince?.provinceID ?? 0,
        provinceName: _selectedProvince?.provinceName ?? '',
        phoneNumber: _recipientPhoneController.text.trim(),
      );
    }
  }

  void _addNewAddress() {
    _saveCurrentAddress();
    
    _addresses.add(_createAddressMap());
    
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate current address
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
      
      // Create address list for API
      final addressRequests = <UpdateElderAddressRequest>[];
      
      for (final address in _addresses) {
        try {
          // Debug validation
          _debugValidateAddress(address);
          
          final addressRequest = UpdateElderAddressRequest(
            streetAddress: _safeParseString(address['streetAddress']),
            wardCode: _safeParseString(address['wardCode'], defaultValue: '0'),
            wardName: _safeParseString(address['wardName']),
            districtID: _safeParseInt(address['districtID']),
            districtName: _safeParseString(address['districtName']),
            provinceID: _safeParseInt(address['provinceID']),
            provinceName: _safeParseString(address['provinceName']),
            phoneNumber: _safeParseString(address['phoneNumber']),
          );
          addressRequests.add(addressRequest);
        } catch (e) {
          print('Error creating address request: $e');
          print('Address data: $address');
          // Re-throw để có thể debug
          rethrow;
        }
      }

      // Validate addressRequests before sending
      if (addressRequests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không có địa chỉ nào để cập nhật'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      print('Sending ${addressRequests.length} addresses to API');
      print('Elder ID: ${widget.userDetail.id}');
      
      final result = await _elderService.updateElderAddress(
        widget.userDetail.id,
        addressRequests,
      );

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật địa chỉ thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Có lỗi xảy ra khi cập nhật địa chỉ'),
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
          'Chỉnh sửa địa chỉ',
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
                title: 'Địa chỉ giao hàng',
                icon: Icons.location_on_rounded,
                children: [
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  
                  // Address form
                  _buildAddressForm(),
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


  Widget _buildAddressForm() {
    return Column(
      children: [
        _buildLocationSelector(
          label: 'Tỉnh/Thành phố',
          value: _selectedProvince?.provinceName,
          hint: 'Chọn tỉnh/thành phố',
          icon: Icons.location_city_rounded,
          onTap: _showProvinceBottomSheet,
          isLoading: _isLoadingProvinces,
        ),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildLocationSelector(
          label: 'Quận/Huyện',
          value: _selectedDistrict?.districtName,
          hint: 'Chọn quận/huyện',
          icon: Icons.location_on_rounded,
          onTap: _showDistrictBottomSheet,
          isLoading: _isLoadingDistricts,
        ),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildLocationSelector(
          label: 'Phường/Xã',
          value: _selectedWard?.wardName,
          hint: 'Chọn phường/xã',
          icon: Icons.location_on_rounded,
          onTap: _showWardBottomSheet,
          isLoading: _isLoadingWards,
        ),
        SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
        _buildTextField(
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
        _buildTextField(
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

  Widget _buildLocationSelector({
    required String label,
    String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
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
        GestureDetector(
          onTap: isLoading ? null : onTap,
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
                  icon,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.primary,
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: value != null ? AppColors.text : AppColors.grey,
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: ResponsiveHelper.getIconSize(context, 24),
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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

  // Bottom sheet implementations (similar to elderly_profile_form_page.dart)
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
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Provinces list
          Expanded(
            child: _isLoadingProvinces
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
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
                              _selectedDistrict = null;
                              _selectedWard = null;
                            });
                            
                            Navigator.pop(context);
                            await _loadDistricts(province.provinceID);
                          },
                        ),
                      );
                    },
                  ),
          ),
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
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Districts list
          Expanded(
            child: _isLoadingDistricts
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _districts.isEmpty
                    ? Center(
                        child: Text(
                          'Không có quận/huyện nào',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
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
                                  _selectedWard = null;
                                });
                                
                                Navigator.pop(context);
                                await _loadWards(district.districtID);
                              },
                            ),
                          );
                        },
                      ),
          ),
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
          
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          
          // Wards list
          Expanded(
            child: _isLoadingWards
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _wards.isEmpty
                    ? Center(
                        child: Text(
                          'Không có phường/xã nào',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            color: AppColors.grey,
                          ),
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
                                });
                                
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
