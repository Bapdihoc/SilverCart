import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/models/elderly_model.dart';
import '../../models/user_detail_response.dart';
import '../../models/root_category_response.dart';
import '../../network/service/category_service.dart';
import '../../network/repositories/elder/elder_repository.dart';

class CategoryPreferencesPage extends StatefulWidget {
  final Elderly elderly;
  final List<UserCategoryValue> currentCategories;

  const CategoryPreferencesPage({
    super.key,
    required this.elderly,
    required this.currentCategories,
  });

  @override
  State<CategoryPreferencesPage> createState() => _CategoryPreferencesPageState();
}

class _CategoryPreferencesPageState extends State<CategoryPreferencesPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  List<RootCategory> _allCategories = [];
  Set<String> _selectedCategoryIds = {};
  String? _errorMessage;
  
  late final CategoryService _categoryService;
  late final ElderRepository _elderRepository;

  @override
  void initState() {
    super.initState();
    _categoryService = GetIt.instance<CategoryService>();
    _elderRepository = GetIt.instance<ElderRepository>();
    
    // Initialize selected categories from current preferences
    _selectedCategoryIds = widget.currentCategories.map((cat) => cat.id).toSet();
    
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _categoryService.getRootListValueCategory();
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _allCategories = result.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải danh mục';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải danh mục: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Convert selected IDs to the required format
      final categories = _selectedCategoryIds
          .map((id) => {'categoryId': id})
          .toList();

      final result = await _elderRepository.updateElderCategory(
        widget.elderly.id,
        categories,
      );

      if (result.isSuccess) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật sở thích thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Cập nhật thất bại'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  Widget _buildLoadingState() {
    return Center(
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
            'Đang tải danh mục...',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
              'Không thể tải danh mục',
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
              onPressed: _loadCategories,
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
    );
  }

  Widget _buildCategoryItem(RootCategory category) {
    final isSelected = _selectedCategoryIds.contains(category.id);
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context),
        ),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : AppColors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (bool? value) {
          _toggleCategory(category.id);
        },
        title: Text(
          category.label,
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        subtitle: category.description.isNotEmpty 
            ? Text(
                category.description,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.grey,
                ),
              )
            : null,
        activeColor: AppColors.primary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getSpacing(context),
          vertical: ResponsiveHelper.getSpacing(context) / 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getBorderRadius(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Chỉnh sửa sở thích',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading && _allCategories.isNotEmpty)
            Container(
              margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
              child: _isSaving
                  ? Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(10),
                      child: const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _savePreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getSpacing(context),
                          vertical: ResponsiveHelper.getSpacing(context) / 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getBorderRadius(context),
                          ),
                        ),
                      ),
                      child: Text(
                        'Lưu',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading 
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : Column(
                    children: [
                      // Header info
                      Container(
                        width: double.infinity,
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
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: ResponsiveHelper.getIconSize(context, 20),
                                ),
                                SizedBox(width: ResponsiveHelper.getSpacing(context)),
                                Text(
                                  widget.elderly.fullName,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context)),
                            Text(
                              'Chọn các danh mục sản phẩm mà ${widget.elderly.fullName} quan tâm:',
                              style: ResponsiveHelper.responsiveTextStyle(
                                context: context,
                                baseSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getSpacing(context)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getSpacing(context),
                                vertical: ResponsiveHelper.getSpacing(context) / 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getBorderRadius(context),
                                ),
                              ),
                              child: Text(
                                'Đã chọn: ${_selectedCategoryIds.length} danh mục',
                                style: ResponsiveHelper.responsiveTextStyle(
                                  context: context,
                                  baseSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Categories list
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getLargeSpacing(context),
                          ),
                          child: ListView.builder(
                            itemCount: _allCategories.length,
                            itemBuilder: (context, index) {
                              return _buildCategoryItem(_allCategories[index]);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
