import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/utils/currency_utils.dart';
import '../../models/cart_get_response.dart';
import '../../models/cart_replace_request.dart';
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
          _errorMessage = null;
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

  Future<void> _removeItemFromCart(int index) async {
    if (_cartData?.items == null || index >= _cartData!.items.length) return;

    try {
      // Get elderly ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final elderId = prefs.getString('userId');

      if (elderId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Create updated cart items (remove the item at index)
      final updatedItems = <CartItem>[];
      for (int i = 0; i < _cartData!.items.length; i++) {
        if (i != index) {
          updatedItems.add(
            CartItem(
              productVariantId: _cartData!.items[i].productVariantId,
              quantity: _cartData!.items[i].quantity,
            ),
          );
        }
      }

      // Create cart request
      final cartRequest = CartReplaceRequest(
        customerId: elderId,
        items: updatedItems,
      );

      // Call API to update cart
      final result = await _cartService.replaceAllCart(cartRequest);

      if (result.isSuccess) {
        // Reload cart data to reflect changes
        await _loadElderlyCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa sản phẩm khỏi giỏ hàng'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể xóa sản phẩm'),
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
    }
  }

  Future<void> _updateItemQuantity(int index, int newQuantity) async {
    if (_cartData?.items == null || index >= _cartData!.items.length) return;
    if (newQuantity <= 0) {
      await _removeItemFromCart(index);
      return;
    }

    try {
      // Get elderly ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final elderId = prefs.getString('userId');

      if (elderId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Create updated cart items with new quantity
      final updatedItems = <CartItem>[];
      for (int i = 0; i < _cartData!.items.length; i++) {
        final item = _cartData!.items[i];
        updatedItems.add(
          CartItem(
            productVariantId: item.productVariantId,
            quantity: i == index ? newQuantity : item.quantity,
          ),
        );
      }

      // Create cart request
      final cartRequest = CartReplaceRequest(
        customerId: elderId,
        items: updatedItems,
      );

      // Call API to update cart
      final result = await _cartService.replaceAllCart(cartRequest);

      if (result.isSuccess) {
        // Reload cart data to reflect changes
        await _loadElderlyCart();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Không thể cập nhật số lượng'),
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
    }
  }

  void _removeFromCart(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 40),
              height: ResponsiveHelper.getIconSize(context, 40),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text(
              'Xóa sản phẩm',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            color: AppColors.text,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.grey,
              side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Hủy'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                await _removeItemFromCart(index);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Xóa',
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
                return _buildElderlyCartItem(_cartItems[index], index);
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

  Widget _buildElderlyCartItem(Map<String, dynamic> item, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
                    
                    // Price
                    Text(
                      CurrencyUtils.formatVND(item['price']),
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getSpacing(context)),
                    
                    // Quantity controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Số lượng:',
                          style: ResponsiveHelper.responsiveTextStyle(
                            context: context,
                            baseSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context) / 2),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    size: ResponsiveHelper.getIconSize(context, 20),
                                    color: item['quantity'] > 1
                                        ? AppColors.primary
                                        : AppColors.grey,
                                  ),
                                ),
                                onTap: item['quantity'] > 1
                                    ? () async {
                                        await _updateItemQuantity(
                                          index,
                                          item['quantity'] - 1,
                                        );
                                      }
                                    : null,
                              ),
                              Container(
                                width: 40,
                                padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                                ),
                                child: Text(
                                  '${item['quantity']}',
                                  textAlign: TextAlign.center,
                                  style: ResponsiveHelper.responsiveTextStyle(
                                    context: context,
                                    baseSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context) / 2),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: ResponsiveHelper.getIconSize(context, 20),
                                    color: AppColors.primary,
                                  ),
                                ),
                                onTap: () async {
                                  await _updateItemQuantity(
                                    index,
                                    item['quantity'] + 1,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // X button floating outside the card
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: () => _removeFromCart(index),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
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
                  CurrencyUtils.formatVND(total),
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