import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/report_response.dart';
import '../../models/product_detail_response.dart';
import '../../network/service/report_service.dart';
import '../../network/service/product_service.dart';
import '../shopping/product_detail_page.dart';
import '../../injection.dart';

class ElderlyReportListPage extends StatefulWidget {
  final String elderlyId;
  final String elderlyName;

  const ElderlyReportListPage({
    super.key,
    required this.elderlyId,
    required this.elderlyName,
  });

  @override
  State<ElderlyReportListPage> createState() => _ElderlyReportListPageState();
}

class _ElderlyReportListPageState extends State<ElderlyReportListPage> {
  late final ReportService _reportService;
  late final ProductService _productService;
  List<ReportData> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Product data cache
  Map<String, ProductDetailData> _productCache = {};
  Map<String, bool> _productLoadingStates = {};
  Map<String, bool> _productErrorStates = {}; // Track failed products to avoid retry

  @override
  void initState() {
    super.initState();
    _reportService = getIt<ReportService>();
    _productService = getIt<ProductService>();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // Clear product cache and states when refreshing
      _productCache.clear();
      _productLoadingStates.clear();
      _productErrorStates.clear();
    });

    try {
      final result = await _reportService.getReportsByUserId(widget.elderlyId);
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _reports = result.data!.data;
          _isLoading = false;
        });
        
        // Don't auto-load products to avoid loading too many at once
        // Products will be loaded on-demand when user taps on product summary
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải danh sách báo cáo';
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở liên kết: $url'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Extract product IDs from HTML description
  List<String> _extractProductIds(String htmlDescription) {
    final RegExp productIdRegex = RegExp(r'/products/([A-F0-9-]+)', caseSensitive: false);
    final matches = productIdRegex.allMatches(htmlDescription);
    return matches.map((match) => match.group(1)!).toSet().toList(); // Use Set to remove duplicates
  }

  // Load product detail by ID
  Future<void> _loadProductDetail(String productId) async {
    if (_productCache.containsKey(productId) || 
        _productLoadingStates[productId] == true ||
        _productErrorStates[productId] == true) {
      return; // Already loaded, loading, or failed
    }

    setState(() {
      _productLoadingStates[productId] = true;
    });

    try {
      final result = await _productService.getProductDetail(productId);
      if (result.isSuccess && result.data != null) {
        setState(() {
          _productCache[productId] = result.data!.data;
          _productLoadingStates[productId] = false;
          _productErrorStates[productId] = false; // Clear error state on success
        });
      } else {
        setState(() {
          _productLoadingStates[productId] = false;
          _productErrorStates[productId] = true; // Mark as failed
        });
      }
    } catch (e) {
      setState(() {
        _productLoadingStates[productId] = false;
        _productErrorStates[productId] = true; // Mark as failed
      });
    }
  }


  // Show product list dialog
  void _showProductListDialog(String reportTitle, List<String> productIds) {
    // Load products when dialog is opened
    for (final productId in productIds) {
      _loadProductDetail(productId);
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sản phẩm được tư vấn',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              reportTitle,
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 12,
                                color: AppColors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.grey,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Product list
                Flexible(
                  child: ListView.separated(
                    padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                    shrinkWrap: true,
                    itemCount: productIds.length,
                    separatorBuilder: (context, index) => 
                        SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    itemBuilder: (context, index) {
                      final productId = productIds[index];
                      return _buildProductCard(productId);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Clean HTML description by removing product links
  String _cleanDescriptionFromProductLinks(String htmlDescription) {
    // Remove product links from HTML content - handle various formats
    final RegExp productLinkRegex = RegExp(
      r'<a[^>]*href="[^"]*\/products\/[A-F0-9-]+[^"]*"[^>]*>.*?<\/a>',
      caseSensitive: false,
      dotAll: true,
    );
    
    // Also remove standalone product URLs (not in anchor tags)
    final RegExp standaloneUrlRegex = RegExp(
      r'https?://[^\s]*\/products\/[A-F0-9-]+[^\s]*',
      caseSensitive: false,
    );
    
    String cleanedDescription = htmlDescription
        .replaceAll(productLinkRegex, '')
        .replaceAll(standaloneUrlRegex, '');
    
    // Clean up any empty paragraphs, line breaks, or extra whitespace
    cleanedDescription = cleanedDescription
        .replaceAll(RegExp(r'<p>\s*<\/p>'), '') // Remove empty paragraphs
        .replaceAll(RegExp(r'<br\s*\/?>\s*<br\s*\/?>'), '<br>') // Remove multiple line breaks
        .replaceAll(RegExp(r'<br\s*\/?>\s*$'), '') // Remove trailing line breaks
        .replaceAll(RegExp(r'^\s*<br\s*\/?>'), '') // Remove leading line breaks
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
    
    return cleanedDescription;
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
              onPressed: _isLoading ? null : _loadReports,
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
                    'Đang tải lịch sử tư vấn...',
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
                        onPressed: _loadReports,
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
              : _reports.isEmpty
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
                              Icons.assignment_outlined,
                              size: 60,
                              color: AppColors.grey.withOpacity(0.5),
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                          Text(
                            'Chưa có lịch sử tư vấn',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getSpacing(context)),
                          Text(
                            '${widget.elderlyName} chưa có lịch sử tư vấn nào',
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
                  : Column(
                      children: [
                        // Header with elderly info
                        Container(
                          margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                          padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
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
                                      widget.elderlyName,
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${_reports.length} báo cáo tư vấn',
                                      style: ResponsiveHelper.responsiveTextStyle(
                                        context: context,
                                        baseSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Reports list
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.only(
                              left: ResponsiveHelper.getLargeSpacing(context),
                              right: ResponsiveHelper.getLargeSpacing(context),
                              bottom: ResponsiveHelper.getLargeSpacing(context),
                            ),
                            itemCount: _reports.length,
                            separatorBuilder: (context, index) => 
                                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                            itemBuilder: (context, index) {
                              final report = _reports[index];
                              return _buildReportCard(report);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildReportCard(ReportData report) {
    final productIds = _extractProductIds(report.description);
    
    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ID: ${report.id.substring(0, 8)}...',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nội dung tư vấn:',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 200, // Limit height for long content
                  ),
                  child: SingleChildScrollView(
                    child: Html(
                      data: _cleanDescriptionFromProductLinks(report.description),
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(14),
                          color: AppColors.text,
                          lineHeight: LineHeight(1.5),
                        ),
                        "p": Style(
                          margin: Margins.only(bottom: 8),
                        ),
                        "a": Style(
                          color: AppColors.primary,
                          textDecoration: TextDecoration.underline,
                        ),
                      },
                      onLinkTap: (url, _, __) {
                        if (url != null) {
                          _launchUrl(url);
                        }
                      },
                    ),
                  ),
                ),
                
                // Product summary section
                if (productIds.isNotEmpty) ...[
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  GestureDetector(
                    onTap: () => _showProductListDialog(report.title, productIds),
                    child: Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.shopping_bag_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getSpacing(context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sản phẩm được tư vấn',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '${productIds.length} sản phẩm - Tap để xem chi tiết',
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getLargeSpacing(context),
              vertical: ResponsiveHelper.getSpacing(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 16,
                  color: AppColors.grey,
                ),
                SizedBox(width: 4),
                Text(
                  'Consultant ID: ${report.consultantId.substring(0, 8)}...',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 12,
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

  Widget _buildProductCard(String productId) {
    final product = _productCache[productId];
    final isLoading = _productLoadingStates[productId] == true;
    final hasError = _productErrorStates[productId] == true;

    // Load product if not cached, not loading, and not failed
    if (product == null && !isLoading && !hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadProductDetail(productId);
      });
    }

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: isLoading
          ? Container(
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Đang tải thông tin sản phẩm...',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            )
          : product != null
              ? _buildProductCardContent(product)
              : Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Expanded(
                        child: Text(
                          'Không thể tải thông tin sản phẩm',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 14,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _productErrorStates[productId] = false; // Reset error state
                          });
                          _loadProductDetail(productId);
                        },
                        child: Text(
                          'Thử lại',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProductCardContent(ProductDetailData product) {
    final firstVariant = product.productVariants.isNotEmpty ? product.productVariants.first : null;
    final firstImage = firstVariant?.productImages.isNotEmpty == true 
        ? firstVariant!.productImages.first.url 
        : null;

    return InkWell(
      onTap: () {
        // Navigate to product detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(productId: product.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
        child: Row(
          children: [
            // Product image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: firstImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: firstImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.image_not_supported,
                          color: AppColors.grey,
                          size: 24,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.image_not_supported,
                      color: AppColors.grey,
                      size: 24,
                    ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  if (firstVariant != null) ...[
                    SizedBox(height: 4),
                    Text(
                      CurrencyUtils.formatVND(firstVariant.discountedPrice),
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

