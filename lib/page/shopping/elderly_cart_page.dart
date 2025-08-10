import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

class ElderlyCartPage extends StatefulWidget {
  const ElderlyCartPage({super.key});

  @override
  State<ElderlyCartPage> createState() => _ElderlyCartPageState();
}

class _ElderlyCartPageState extends State<ElderlyCartPage> {
  List<Map<String, dynamic>> _cartItems = [
    {
      'id': 1,
      'name': 'Gạo tẻ thơm',
      'price': 45000,
      'quantity': 1,
      'image': '🍚',
      'note': 'Gạo ngon để nấu cơm',
    },
    {
      'id': 2,
      'name': 'Rau cải xanh',
      'price': 15000,
      'quantity': 2,
      'image': '🥬',
      'note': 'Rau tươi cho bữa trưa',
    },
    {
      'id': 3,
      'name': 'Paracetamol 500mg',
      'price': 25000,
      'quantity': 1,
      'image': '💊',
      'note': 'Thuốc giảm đau',
    },
  ];

  String _note = 'Mua giúp mẹ những thứ này nhé. Cảm ơn con!';
  bool _isUrgent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary,
              size: ResponsiveHelper.getIconSize(context, 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Giỏ hàng của tôi',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete_sweep_rounded,
                color: AppColors.error,
                size: ResponsiveHelper.getIconSize(context, 20),
              ),
              onPressed: () => _showClearCartDialog(),
            ),
          ),
        ],
      ),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: _cartItems.isNotEmpty ? _buildSubmitButton() : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 120),
            height: ResponsiveHelper.getIconSize(context, 120),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: ResponsiveHelper.getIconSize(context, 60),
              color: Colors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Giỏ hàng trống',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Bạn chưa có sản phẩm nào trong giỏ hàng',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_rounded,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Tiếp tục mua sắm',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Cart Items Section
          Container(
            margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
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
              border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
                        ),
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          size: ResponsiveHelper.getIconSize(context, 20),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Text(
                        'Sản phẩm đã chọn (${_cartItems.length})',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  ..._cartItems.map((item) => _buildCartItem(item)).toList(),
                ],
              ),
            ),
          ),



          // Note Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
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
              border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
                            colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.note_rounded,
                          size: ResponsiveHelper.getIconSize(context, 20),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                      Text(
                        'Ghi chú',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                  TextField(
                    controller: TextEditingController(text: _note),
                    onChanged: (value) => _note = value,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập ghi chú cho người thân...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF8F9FA),
                      contentPadding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
                    ),
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),

          // Urgent Toggle
          Container(
            margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
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
              border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
              child: Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getIconSize(context, 40),
                    height: ResponsiveHelper.getIconSize(context, 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.priority_high_rounded,
                      size: ResponsiveHelper.getIconSize(context, 20),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Expanded(
                    child: Text(
                      'Yêu cầu khẩn cấp',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Switch(
                    value: _isUrgent,
                    onChanged: (value) {
                      setState(() {
                        _isUrgent = value;
                      });
                    },
                    activeColor: AppColors.error,
                    activeTrackColor: AppColors.error.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: ResponsiveHelper.getIconSize(context, 60),
            height: ResponsiveHelper.getIconSize(context, 60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item['image'],
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Text(
                  '${item['price'].toStringAsFixed(0)}đ',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (item['note'] != null && item['note'].isNotEmpty) ...[
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Ghi chú: ${item['note']}',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Quantity and Remove
          Column(
            children: [
              // Quantity
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context),
                  vertical: ResponsiveHelper.getSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Text(
                  'Số lượng: ${item['quantity']}',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
              
              // Remove Button
              GestureDetector(
                onTap: () => _removeFromCart(item['id']),
                child: Container(
                  width: ResponsiveHelper.getIconSize(context, 40),
                  height: ResponsiveHelper.getIconSize(context, 40),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: AppColors.error,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    double total = _cartItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));
    
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng:',
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
                  baseSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          
          // Submit Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
            child: ElevatedButton(
              onPressed: () => _submitToFamily(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send_rounded,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Gửi yêu cầu mua hàng',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromCart(int itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item['id'] == itemId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: ResponsiveHelper.getIconSize(context, 24),
              height: ResponsiveHelper.getIconSize(context, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_rounded,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: AppColors.success,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context)),
            Text('Đã xóa sản phẩm khỏi giỏ hàng'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 60),
                  height: ResponsiveHelper.getIconSize(context, 60),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    size: ResponsiveHelper.getIconSize(context, 30),
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                Text(
                  'Xóa giỏ hàng',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Text(
                  'Bạn có chắc muốn xóa tất cả sản phẩm trong giỏ hàng?',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 16,
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Hủy',
                            style: ResponsiveHelper.responsiveTextStyle(
                              context: context,
                              baseSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _cartItems.clear();
                            });
                            Navigator.pop(context);
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  void _submitToFamily() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: ResponsiveHelper.getIconSize(context, 80),
                  height: ResponsiveHelper.getIconSize(context, 80),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: ResponsiveHelper.getIconSize(context, 40),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                Text(
                  'Gửi yêu cầu thành công!',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                                 Text(
                   'Yêu cầu mua hàng đã được gửi thành công!',
                   style: ResponsiveHelper.responsiveTextStyle(
                     context: context,
                     baseSize: 16,
                     color: AppColors.grey,
                   ),
                   textAlign: TextAlign.center,
                 ),
                SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _cartItems.clear();
                      });
                      Navigator.pop(context);
                      Navigator.pop(context);
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
                      'Hoàn tất',
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
        );
      },
    );
  }
} 