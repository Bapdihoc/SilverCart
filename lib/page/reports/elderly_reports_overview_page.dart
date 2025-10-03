import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/elder_list_response.dart';
import '../../network/service/elder_service.dart';
import '../../injection.dart';
import 'elderly_report_list_page.dart';

class ElderlyReportsOverviewPage extends StatefulWidget {
  const ElderlyReportsOverviewPage({super.key});

  @override
  State<ElderlyReportsOverviewPage> createState() => _ElderlyReportsOverviewPageState();
}

class _ElderlyReportsOverviewPageState extends State<ElderlyReportsOverviewPage> {
  late final ElderService _elderService;
  List<ElderData> _elders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _elderService = getIt<ElderService>();
    _loadElders();
  }

  Future<void> _loadElders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _elderService.getMyElders();
      if (result.isSuccess && result.data != null) {
        setState(() {
          _elders = result.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải danh sách người thân';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải danh sách: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToElderlyReports(ElderData elderly) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ElderlyReportListPage(
          elderlyId: elderly.id,
          elderlyName: elderly.fullName,
        ),
      ),
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
          '📋 Lịch sử tư vấn',
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
              onPressed: _isLoading ? null : _loadElders,
            ),
          ),
          
        ],
        leading: Container(
          margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        )),
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
                    'Đang tải danh sách người thân...',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 60,
                          color: AppColors.error.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                      Text(
                        'Có lỗi xảy ra',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getSpacing(context)),
                      Text(
                        _errorMessage!,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                      ElevatedButton.icon(
                        onPressed: _loadElders,
                        icon: Icon(Icons.refresh_rounded),
                        label: Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _elders.isEmpty
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
                              Icons.family_restroom_outlined,
                              size: 60,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                          Text(
                            'Chưa có người thân',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          Text(
                            'Bạn chưa có người thân nào để xem lịch sử tư vấn',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              color: AppColors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         


                          // Elderly chips section
                          Text(
                            'Danh sách người thân',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          
                          Wrap(
                            spacing: ResponsiveHelper.getSpacing(context),
                            runSpacing: ResponsiveHelper.getSpacing(context),
                            children: _elders.map((elderly) => _buildElderlyChip(elderly)).toList(),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildElderlyChip(ElderData elderly) {
    return GestureDetector(
      onTap: () => _navigateToElderlyReports(elderly),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getLargeSpacing(context),
          vertical: ResponsiveHelper.getSpacing(context),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: elderly.avatar != null && elderly.avatar!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        elderly.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            
            // Name
            Text(
              elderly.fullName,
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
