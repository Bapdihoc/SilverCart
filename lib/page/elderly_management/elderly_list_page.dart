import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:silvercart/page/elderly_management/elderly_profile_form_page.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/models/elderly_model.dart';
import '../../models/elder_list_response.dart';
import '../../network/service/elder_service.dart';
import '../../network/service/auth_service.dart';
import '../../injection.dart';
import 'elderly_profile_detail_page.dart';

class ElderlyListPage extends StatefulWidget {
  const ElderlyListPage({super.key});

  @override
  State<ElderlyListPage> createState() => _ElderlyListPageState();
}

class _ElderlyListPageState extends State<ElderlyListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Elderly> _allElderly = [];
  List<Elderly> _filteredElderly = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  late final ElderService _elderService;
  late final AuthService _authService;

  final List<Map<String, dynamic>> _filterOptions = [
    {'value': 'all', 'label': 'Tất cả', 'icon': Icons.group},
    {'value': 'active', 'label': 'Hoạt động', 'icon': Icons.check_circle},
    {'value': 'inactive', 'label': 'Không hoạt động', 'icon': Icons.cancel},
    {'value': 'expired_qr', 'label': 'QR hết hạn', 'icon': Icons.qr_code_scanner_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _elderService = getIt<ElderService>();
    _authService = getIt<AuthService>();
    _loadElderly();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadElderly() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _elderService.getMyElders();
      
      if (result.isSuccess && result.data != null) {
        // Convert ElderData to Elderly model
        _allElderly = result.data!.data.map((elderData) => _convertElderDataToElderly(elderData)).toList();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể tải danh sách người thân'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }

      _applyFilter();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách: ${e.toString()}'),
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

  void _applyFilter() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredElderly = _allElderly.where((elderly) {
        // Search filter
        bool matchesSearch = searchQuery.isEmpty ||
            elderly.fullName.toLowerCase().contains(searchQuery) ||
            elderly.nickname.toLowerCase().contains(searchQuery) ||
            elderly.phone.contains(searchQuery);

        if (!matchesSearch) return false;

        // Status filter
        switch (_selectedFilter) {
          case 'active':
            return elderly.isActive;
          case 'inactive':
            return !elderly.isActive;
          case 'expired_qr':
            return !elderly.hasValidQRCode;
          default:
            return true;
        }
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _applyFilter();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilter();
  }

  Future<void> _navigateToAddElderly() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ElderlyProfileFormPage(),
      ),
    );
  }

  Future<void> _navigateToElderlyDetail(Elderly elderly) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ElderlyProfileDetailPage(
          elderly: elderly,
        ),
      ),
    );
    
    _loadElderly(); // Refresh list after returning
  }

  Future<void> _navigateToEditElderly(Elderly elderly) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Đang tải chi tiết...',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Get elder detail from API
      final detailResponse = await _authService.getUserDetail(elderly.id);
      
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (detailResponse.isSuccess && detailResponse.data != null) {
        // Navigate to detail page with fetched data
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ElderlyProfileDetailPage(
              elderly: elderly,
            ),
          ),
        );
        
        _loadElderly(); // Refresh list after returning
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(detailResponse.message ?? 'Không thể tải chi tiết người thân'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải chi tiết: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _generateQRCodeForElder(Elderly elderly) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Đang tạo QR code...',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Call API to generate QR code
      final result = await _authService.generateQr(elderly.id);
      
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (result.isSuccess && result.data != null) {
        // Get token from response and show QR popup
        final token = result.data!.data.token;
        
        // Show QR code popup
        _showQRCodePopup(elderly, token);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'QR code cho ${elderly.nickname} đã được tạo thành công!',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: Colors.white,
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
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.message ?? 'Không thể tạo QR code cho ${elderly.nickname}',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lỗi tạo QR code: ${e.toString()}',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        ),
      );
    }
  }

  void _navigateToQRManagement(Elderly elderly) {
    // TODO: Navigate to QR management page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chức năng quản lý QR đang phát triển'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Future<bool> _checkAndRequestStoragePermission() async {
    // Check current permission status for different Android versions
    final storageStatus = await Permission.storage.status;
    final manageStatus = await Permission.manageExternalStorage.status;
    final mediaImagesStatus = await Permission.photos.status;
    
    // If any permission is already granted, return true
    if (storageStatus.isGranted || 
        manageStatus.isGranted || 
        mediaImagesStatus.isGranted) {
      return true;
    }
    
    // Request permissions directly without showing explanation dialog
    try {
      PermissionStatus status;
      
      // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
      if (await _isAndroid13OrHigher()) {
        status = await Permission.photos.request();
      } else {
        // For older Android versions, try storage permission first
        status = await Permission.storage.request();
        
        // If denied, try manage external storage (Android 11+)
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
      }
      
      if (status.isGranted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Đã cấp quyền truy cập bộ nhớ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return true;
      } else {
        // Show error and guide to settings
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Quyền bị từ chối',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            content: Text(
              'Quyền truy cập bộ nhớ bị từ chối. Bạn cần cấp quyền trong Cài đặt để lưu ảnh QR.',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.text,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text('Mở Cài đặt'),
              ),
            ],
          ),
        );
        
        if (openSettings == true) {
          await openAppSettings();
        }
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xin quyền: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      try {
        // Check Android version
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.version.sdkInt >= 33; // Android 13 (API 33)
      } catch (e) {
        // Fallback: assume older version
        return false;
      }
    }
    return false;
  }

  Future<void> _saveQRImageToGallery(Elderly elderly, String token) async {
    try {
      // Check and request permission first
      final hasPermission = await _checkAndRequestStoragePermission();
      if (!hasPermission) {
        return; // User denied permission
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Đang lưu ảnh QR...',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Create QR painter
      final qrPainter = QrPainter(
        data: token,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: AppColors.text,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: AppColors.text,
        ),
      );

      // Get device pixel ratio for high quality
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final size = 512.0; // High resolution
      
      // Create picture recorder
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Paint white background
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, size, size), paint);
      
      // Paint QR code
      qrPainter.paint(canvas, Size(size, size));
      
      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(
        (size * pixelRatio).round(),
        (size * pixelRatio).round(),
      );
      
      // Convert to bytes
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Get directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        // For Android, save in Downloads folder
        final downloadsPath = '/storage/emulated/0/Download';
        directory = Directory(downloadsPath);
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        // Create filename with timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'QR_${elderly.nickname}_$timestamp.png';
        final file = File('${directory.path}/$fileName');
        
        // Write file
        await file.writeAsBytes(pngBytes);
        
        // Close loading
        if (mounted) Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đã lưu ảnh QR cho ${elderly.nickname} vào thư mục Download',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Xem',
              textColor: Colors.white,
              onPressed: () {
                // Could open file manager or show file location
              },
            ),
          ),
        );
      } else {
        throw Exception('Không thể truy cập thư mục lưu trữ');
      }
    } catch (e) {
      // Close loading if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu ảnh: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showQRCodePopup(Elderly elderly, String token) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context) * 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.qr_code_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QR Code thành công',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            elderly.nickname,
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.grey,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                
                // QR Code
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                    border: Border.all(
                      color: AppColors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: QrImageView(
                    data: token,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.text,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                
                // Token display
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                    border: Border.all(
                      color: AppColors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.key_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Token:',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        token,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 11,
                          color: AppColors.text,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: token));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã copy token'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'Copy Token',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getSpacing(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _saveQRImageToGallery(elderly, token),
                        icon: Icon(
                          Icons.download_rounded,
                          size: 18,
                        ),
                        label: Text(
                          'Lưu ảnh QR',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getSpacing(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getBorderRadius(context),
                            ),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                
                // Info text
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'QR code này sẽ được sử dụng để đăng nhập cho ${elderly.nickname}',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
     
        title: Text(
          '👥 Quản lý người thân',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: _isLoading ? null : _loadElderly,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
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
                    'Đang tải...',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Compact Search and Filter Header
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context),
                  ),
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Compact Search Bar
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: '🔍 Tìm kiếm...',
                            hintStyle: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 14,
                              color: AppColors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getSpacing(context),
                              vertical: ResponsiveHelper.getSpacing(context) / 2,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: AppColors.grey,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),

                      SizedBox(height: ResponsiveHelper.getSpacing(context)),

                      // Compact Filter Chips
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filterOptions.length,
                          separatorBuilder: (context, index) => 
                              SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                          itemBuilder: (context, index) {
                            final filter = _filterOptions[index];
                            final isSelected = _selectedFilter == filter['value'];
                            
                            return GestureDetector(
                              onTap: () => _onFilterChanged(filter['value']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveHelper.getSpacing(context),
                                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      filter['icon'],
                                      size: 14,
                                      color: isSelected ? Colors.white : AppColors.primary,
                                    ),
                                    SizedBox(width: ResponsiveHelper.getSpacing(context) / 3),
                                    Text(
                                      filter['label'],
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Modern Results Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getSpacing(context),
                          vertical: ResponsiveHelper.getSpacing(context) / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '📊 ${_filteredElderly.length} người thân',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        'Tổng: ${_allElderly.length}',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ResponsiveHelper.getSpacing(context)),

                // Modern Elderly List
                Expanded(
                  child: _filteredElderly.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Icon(
                                  _allElderly.isEmpty ? Icons.group_add_rounded : Icons.search_off_rounded,
                                  size: 60,
                                  color: AppColors.grey.withOpacity(0.5),
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                              Text(
                                _allElderly.isEmpty 
                                    ? 'Chưa có người thân nào 😔'
                                    : 'Không tìm thấy kết quả 🔍',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getSpacing(context)),
                              Text(
                                _allElderly.isEmpty 
                                    ? 'Thêm người thân đầu tiên để bắt đầu!'
                                    : 'Thử thay đổi từ khóa tìm kiếm',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 16,
                                  color: AppColors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_allElderly.isEmpty) ...[
                                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: _navigateToAddElderly,
                                    icon: Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                    ),
                                    label: Text(
                                      '➕ Thêm người thân',
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ResponsiveHelper.getLargeSpacing(context) * 2,
                                        vertical: ResponsiveHelper.getLargeSpacing(context),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            left: ResponsiveHelper.getLargeSpacing(context),
                            right: ResponsiveHelper.getLargeSpacing(context),
                            top: ResponsiveHelper.getLargeSpacing(context),
                            bottom: ResponsiveHelper.getLargeSpacing(context) + 100, // Thêm padding cho FAB
                          ),
                          itemCount: _filteredElderly.length,
                          separatorBuilder: (context, index) => 
                              SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          itemBuilder: (context, index) {
                            final elderly = _filteredElderly[index];
                            return _buildModernElderlyCard(elderly);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToAddElderly,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: Icon(
            Icons.person_add_rounded,
            size: 24,
          ),
          label: Text(
            'Thêm mới',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernElderlyCard(Elderly elderly) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToElderlyDetail(elderly),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
          child: Column(
            children: [
              // Compact Header Row
              Row(
                children: [
                  // Compact Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: elderly.avatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              elderly.avatar!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  
                  // Compact Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                elderly.nickname,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.text,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: elderly.isActive 
                                    ? AppColors.success.withOpacity(0.15)
                                    : AppColors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: elderly.isActive 
                                      ? AppColors.success.withOpacity(0.4)
                                      : AppColors.grey.withOpacity(0.4),
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
                                      color: elderly.isActive ? AppColors.success : AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    elderly.isActive ? 'Active' : 'Paused',
                                    style: ResponsiveHelper.responsiveTextStyle(
                                      context: context,
                                      baseSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: elderly.isActive ? AppColors.success : AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          elderly.fullName,
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 13,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${elderly.age} tuổi',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.phone_rounded,
                              size: 12,
                              color: AppColors.grey,
                            ),
                            SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                elderly.phone,
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 11,
                                  color: AppColors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // QR Status Badge
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: elderly.hasValidQRCode 
                          ? AppColors.success.withOpacity(0.15)
                          : AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: elderly.hasValidQRCode 
                            ? AppColors.success.withOpacity(0.4)
                            : AppColors.error.withOpacity(0.4),
                      ),
                    ),
                    child: Icon(
                      elderly.hasValidQRCode ? Icons.qr_code_rounded : Icons.qr_code_scanner_outlined,
                      color: elderly.hasValidQRCode ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveHelper.getSpacing(context)),

              // Horizontal Stats Row
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF8F9FA),
                      const Color(0xFFF8F9FA).withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompactStatItem(
                      icon: Icons.shopping_cart_rounded,
                      value: elderly.totalOrders.toString(),
                      label: 'Đơn hàng',
                      color: AppColors.primary,
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.grey.withOpacity(0.1),
                            AppColors.grey.withOpacity(0.3),
                            AppColors.grey.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    _buildCompactStatItem(
                      icon: Icons.monetization_on_rounded,
                      value: '${(elderly.totalSpent / 1000000).toStringAsFixed(1)}M',
                      label: 'Chi tiêu',
                      color: AppColors.secondary,
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.grey.withOpacity(0.1),
                            AppColors.grey.withOpacity(0.3),
                            AppColors.grey.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                    _buildCompactStatItem(
                      icon: Icons.account_balance_wallet_rounded,
                      value: '${(elderly.monthlyBudgetLimit / 1000000).toStringAsFixed(1)}M',
                      label: 'Budget',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveHelper.getSpacing(context)),

              // Compact Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _generateQRCodeForElder(elderly),
                        icon: Icon(
                          Icons.qr_code_rounded,
                          size: 16,
                        ),
                        label: Text(
                          'QR Code',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                  Expanded(
                    child: Container(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToEditElderly(elderly),
                        icon: Icon(
                          Icons.edit_rounded,
                          size: 16,
                        ),
                        label: Text(
                          'Sửa',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withOpacity(0.7), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildCompactStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 9,
            color: AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Elderly _convertElderDataToElderly(ElderData elderData) {
    return Elderly(
      id: elderData.id,
      fullName: elderData.fullName,
      nickname: elderData.userName, // Using userName as nickname
      dateOfBirth: elderData.birthDate,
      relationship: elderData.relationShip,
      phone: elderData.addresses.isNotEmpty ? elderData.addresses.first.phoneNumber : '',
      avatar: elderData.avatar,
      medicalNotes: elderData.description,
      dietaryRestrictions: elderData.categories,
      emergencyContact: elderData.emergencyPhoneNumber,
      monthlyBudgetLimit: elderData.spendLimit,
      isActive: !elderData.isDelete, // Convert isDelete to isActive
      createdAt: DateTime.now().subtract(const Duration(days: 30)), // Default value
      updatedAt: DateTime.now().subtract(const Duration(days: 1)), // Default value
      managedBy: 'current_user', // Default value
      currentQRCode: 'QR_${elderData.id}', // Generate QR code from ID
      qrCodeExpiresAt: DateTime.now().add(const Duration(days: 7)), // Default value
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)), // Default value
      totalOrders: 0, // Default value - will be updated from orders API
      totalSpent: 0.0, // Default value - will be updated from orders API
    );
  }
} 