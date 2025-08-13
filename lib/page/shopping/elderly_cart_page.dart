import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/cart_get_response.dart';
import '../../network/service/cart_service.dart';
import '../../injection.dart';

class ElderlyCartPage extends StatefulWidget {
  const ElderlyCartPage({super.key});

  @override
  State<ElderlyCartPage> createState() => _ElderlyCartPageState();
}

class _ElderlyCartPageState extends State<ElderlyCartPage> {
  late final CartService _cartService;
  CartGetData? _cartData;
  bool _isLoading = true;
  bool _isSubmittingOrder = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cartService = getIt<CartService>();
    _loadElderlyCart();
  }

  Future<void> _loadElderlyCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get elderly ID from SharedPreferences (assuming we store it for elderly users)
      final prefs = await SharedPreferences.getInstance();
      final elderId = prefs.getString('userId'); // In elderly context, userId is elderId
      
      if (elderId == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy thông tin người dùng';
          _isLoading = false;
        });
        return;
      }

      // Call API to get cart by elder ID
      final result = await _cartService.getCartByElderId(elderId, 0);
      
      if (result.isSuccess && result.data != null) {
        setState(() {
          _cartData = result.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Không thể tải giỏ hàng';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải giỏ hàng: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_cartData?.cartId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin giỏ hàng'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingOrder = true;
    });

    try {
      // Call API to change cart status to 1 (submitted)
      final result = await _cartService.changeCartStatus(_cartData!.cartId, 1);
      
      if (result.isSuccess) {
        if (mounted) {
          // Show success message
          _showSubmitSuccessDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Không thể gửi đơn hàng'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi đơn hàng: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingOrder = false;
        });
      }
    }
  }

  void _showSubmitSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Column(
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 80),
              height: ResponsiveHelper.getIconSize(context, 80),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: ResponsiveHelper.getIconSize(context, 50),
                color: AppColors.success,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
            Text(
              'Đã gửi đơn hàng!',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Đơn hàng của bạn đã được gửi thành công. Người thân sẽ xem xét và phê duyệt đơn hàng.',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            color: AppColors.text,
          ).copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.getLargeSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Hoàn tất',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Convert API data to UI format
  List<Map<String, dynamic>> get _cartItems {
    if (_cartData?.items == null) return [];
    
    return _cartData!.items.map((item) => {
      'id': item.productVariantId,
      'name': item.productName,
      'emoji': _getProductEmoji(item.productName),
      'price': item.productPrice,
      'quantity': item.quantity,
      'imageUrl': item.imageUrl,
    }).toList();
  }

  // Helper method to get product emoji
  String _getProductEmoji(String productName) {
    final name = productName.toLowerCase();
    
    if (name.contains('thuốc') || name.contains('medicine')) return '💊';
    if (name.contains('máy đo') || name.contains('monitor')) return '📊';
    if (name.contains('vitamin') || name.contains('bổ sung')) return '🌟';
    if (name.contains('gậy') || name.contains('cane')) return '🦯';
    if (name.contains('dầu gội') || name.contains('shampoo')) return '🧴';
    if (name.contains('kem') || name.contains('cream')) return '🧴';
    if (name.contains('áo') || name.contains('shirt')) return '👕';
    if (name.contains('quần') || name.contains('pants')) return '👖';
    if (name.contains('giày') || name.contains('shoes')) return '👟';
    
    return '📦'; // Default emoji
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: ResponsiveHelper.getIconSize(context, 28),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Giỏ hàng của tôi',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: ResponsiveHelper.getIconSize(context, 28),
              ),
              onPressed: _loadElderlyCart,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildElderlyLoadingState()
          : _errorMessage != null
              ? _buildElderlyErrorState()
              : _cartItems.isEmpty
                  ? _buildElderlyEmptyCart()
                  : _buildElderlyCartList(),
    );
  }

  Widget _buildElderlyLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 100),
            height: ResponsiveHelper.getIconSize(context, 100),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 6,
              ),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Đang tải giỏ hàng...',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Vui lòng đợi trong giây lát',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderlyErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 120),
              height: ResponsiveHelper.getIconSize(context, 120),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: ResponsiveHelper.getIconSize(context, 60),
                color: AppColors.error,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 1.5),
            Text(
              'Không thể tải giỏ hàng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi không xác định',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 20,
                color: AppColors.grey,
              ).copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 2),
            
            // Retry button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadElderlyCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Thử lại',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElderlyEmptyCart() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context) * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 120),
              height: ResponsiveHelper.getIconSize(context, 120),
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: ResponsiveHelper.getIconSize(context, 60),
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 1.5),
            Text(
              'Giỏ hàng trống',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context)),
            Text(
              'Chưa có sản phẩm nào trong giỏ hàng của bạn.',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 20,
                color: AppColors.grey,
              ).copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getLargeSpacing(context) * 2),
            
            // Shopping button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getLargeSpacing(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Tiếp tục mua sắm',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElderlyCartList() {
    final total = _cartItems.fold<double>(
      0, 
      (sum, item) => sum + (item['price'] * item['quantity']),
    );

    return Column(
      children: [
        // Cart items list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadElderlyCart,
            color: AppColors.primary,
            child: ListView.builder(
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                return _buildElderlyCartItem(_cartItems[index]);
              },
            ),
          ),
        ),
        
        // Total section
        if (_cartItems.isNotEmpty) _buildElderlyTotalSection(total),
        
        // Submit Order Button
        if (_cartItems.isNotEmpty) _buildSubmitOrderButton(),
      ],
    );
  }

  Widget _buildElderlyCartItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Product image/emoji
          Container(
            width: ResponsiveHelper.getIconSize(context, 80),
            height: ResponsiveHelper.getIconSize(context, 80),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: item['imageUrl'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        item['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            item['emoji'],
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getIconSize(context, 40),
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      item['emoji'],
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getIconSize(context, 40),
                      ),
                    ),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ).copyWith(height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                
                // Quantity
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Số lượng: ${item['quantity']}',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                
                // Price
                Text(
                  '${item['price']}đ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElderlyTotalSection(double total) {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 50),
            height: ResponsiveHelper.getIconSize(context, 50),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.payments_rounded,
              size: ResponsiveHelper.getIconSize(context, 28),
              color: Colors.white,
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng tiền',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  '${total.toInt()}đ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitOrderButton() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmittingOrder ? null : _submitOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.getLargeSpacing(context) * 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 8,
            shadowColor: AppColors.primary.withOpacity(0.3),
          ),
          child: _isSubmittingOrder
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: ResponsiveHelper.getIconSize(context, 24),
                      height: ResponsiveHelper.getIconSize(context, 24),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                    Text(
                      'Đang gửi...',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: ResponsiveHelper.getIconSize(context, 50),
                      height: ResponsiveHelper.getIconSize(context, 50),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: ResponsiveHelper.getIconSize(context, 28),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
                    Text(
                      'Gửi đơn hàng',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}