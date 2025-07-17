import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  String _selectedAddress = '🏠 Nhà riêng - 123 Đường ABC, Quận 1';
  String _selectedElderly = 'Bà Nguyễn Thị A';
  String _paymentMethod = 'COD';
  String _note = '';
  
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Gạo ST25 cao cấp 5kg',
      'emoji': '🌾',
      'price': 125000,
      'originalPrice': 150000,
      'quantity': 2,
      'elderly': 'Bà Nguyễn Thị A',
    },
    {
      'id': '2',
      'name': 'Thuốc hạ huyết áp',
      'emoji': '💊',
      'price': 85000,
      'quantity': 1,
      'elderly': 'Ông Trần Văn B',
    },
    {
      'id': '3',
      'name': 'Dầu gội đầu dành cho người già',
      'emoji': '🧴',
      'price': 45000,
      'quantity': 3,
      'elderly': 'Bà Lê Thị C',
    },
  ];

  final List<String> _addresses = [
    '🏠 Nhà riêng - 123 Đường ABC, Quận 1',
    '🏢 Chung cư - 456 Tòa nhà DEF, Quận 3',
    '🏢 Văn phòng - 789 Tòa nhà GHI, Quận 7',
  ];

  final List<String> _elderlyList = [
    'Bà Nguyễn Thị A',
    'Ông Trần Văn B',
    'Bà Lê Thị C'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.text,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '🛒 Giỏ hàng (${_cartItems.length})',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _cartItems.isNotEmpty ? () {
              _showClearCartDialog();
            } : null,
            child: Text(
              'Xóa tất cả',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: _cartItems.isNotEmpty ? AppColors.error : AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: _cartItems.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🛒',
            style: TextStyle(
              fontSize: ResponsiveHelper.getIconSize(context, 80),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Text(
            'Giỏ hàng trống',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng\nđể mua sắm cho người thân',
            textAlign: TextAlign.center,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getExtraLargeSpacing(context),
                vertical: ResponsiveHelper.getLargeSpacing(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
            child: Text(
              'Tiếp tục mua sắm',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.w600,
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
          _buildCartItems(),
          _buildElderlySelection(),
          _buildAddressSelection(),
          _buildPaymentMethod(),
          _buildOrderNote(),
          _buildOrderSummary(),
          SizedBox(height: ResponsiveHelper.getExtraLargeSpacing(context)),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📦 Sản phẩm trong giỏ',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_cartItems[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
            ),
            child: Center(
              child: Text(
                item['emoji'],
                style: TextStyle(
                  fontSize: ResponsiveHelper.getIconSize(context, 24),
                ),
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
                    baseSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context) / 2),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: ResponsiveHelper.getIconSize(context, 14),
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context) / 2),
                    Text(
                      item['elderly'],
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context)),
                Row(
                  children: [
                    if (item['originalPrice'] != null) ...[
                      Text(
                        '${item['originalPrice']}đ',
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 12,
                          color: AppColors.grey,
                          // decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    ],
                    Text(
                      '${item['price']}đ',
                      style: ResponsiveHelper.responsiveTextStyle(
                        context: context,
                        baseSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Quantity Controls
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        size: ResponsiveHelper.getIconSize(context, 16),
                        color: item['quantity'] > 1 ? AppColors.primary : AppColors.grey,
                      ),
                      onPressed: item['quantity'] > 1 ? () {
                        setState(() {
                          _cartItems[index]['quantity']--;
                        });
                      } : null,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context) / 2),
                    ),
                    Container(
                      width: 30,
                      child: Text(
                        '${item['quantity']}',
                        textAlign: TextAlign.center,
                        style: ResponsiveHelper.responsiveTextStyle(
                          context: context,
                          baseSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        size: ResponsiveHelper.getIconSize(context, 16),
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _cartItems[index]['quantity']++;
                        });
                      },
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context) / 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context)),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: ResponsiveHelper.getIconSize(context, 20),
                  color: AppColors.error,
                ),
                onPressed: () {
                  _removeFromCart(index);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElderlySelection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👥 Giao hàng cho',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          Wrap(
            spacing: ResponsiveHelper.getSpacing(context),
            runSpacing: ResponsiveHelper.getSpacing(context),
            children: _elderlyList.map((elderly) {
              bool isSelected = _selectedElderly == elderly;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedElderly = elderly;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getLargeSpacing(context),
                    vertical: ResponsiveHelper.getSpacing(context),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary : AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 2),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    elderly,
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.text,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelection() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📍 Địa chỉ giao hàng',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showAddressSelection();
                },
                child: Text(
                  'Thay đổi',
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getSpacing(context)),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: ResponsiveHelper.getIconSize(context, 20),
                color: AppColors.primary,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context)),
              Expanded(
                child: Text(
                  _selectedAddress,
                  style: ResponsiveHelper.responsiveTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💳 Phương thức thanh toán',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          ListTile(
            leading: Icon(
              Icons.money,
              color: AppColors.primary,
            ),
            title: Text(
              'Thanh toán khi nhận hàng (COD)',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.text,
              ),
            ),
            trailing: Radio<String>(
              value: 'COD',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              activeColor: AppColors.primary,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            leading: Icon(
              Icons.credit_card,
              color: AppColors.secondary,
            ),
            title: Text(
              'Thanh toán online',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 14,
                color: AppColors.text,
              ),
            ),
            trailing: Radio<String>(
              value: 'Online',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              activeColor: AppColors.primary,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNote() {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 Ghi chú đơn hàng',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú cho đơn hàng (thời gian giao, hướng dẫn...)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              _note = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    double subtotal = _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    double shipping = 20000;
    double discount = 0;
    double total = subtotal + shipping - discount;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getLargeSpacing(context)),
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Tóm tắt đơn hàng',
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getLargeSpacing(context)),
          _buildSummaryRow('Tạm tính', '${subtotal.toInt()}đ'),
          _buildSummaryRow('Phí vận chuyển', '${shipping.toInt()}đ'),
          if (discount > 0)
            _buildSummaryRow('Giảm giá', '-${discount.toInt()}đ', color: AppColors.success),
          Divider(height: ResponsiveHelper.getLargeSpacing(context) * 2),
          _buildSummaryRow(
            'Tổng cộng',
            '${total.toInt()}đ',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context)),
      child: Row(
        children: [
          Text(
            label,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isTotal ? AppColors.text : AppColors.grey),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: ResponsiveHelper.responsiveTextStyle(
              context: context,
              baseSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: color ?? (isTotal ? AppColors.primary : AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    double total = 10.0;
    // _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity'])) + 20000;
    
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getLargeSpacing(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tổng thanh toán',
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.grey,
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
          SizedBox(width: ResponsiveHelper.getLargeSpacing(context)),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _checkout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.getLargeSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: ResponsiveHelper.getIconSize(context, 20),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Đặt hàng',
                    style: ResponsiveHelper.responsiveTextStyle(
                      context: context,
                      baseSize: 16,
                      fontWeight: FontWeight.w600,
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

  void _removeFromCart(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        ),
        title: Text(
          '🗑️ Xóa sản phẩm',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartItems.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
            child: Text(
              'Xóa',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        ),
        title: Text(
          '🗑️ Xóa tất cả',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa tất cả sản phẩm khỏi giỏ hàng?',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            color: AppColors.text,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartItems.clear();
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
            child: Text(
              'Xóa tất cả',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        ),
        title: Text(
          '📍 Chọn địa chỉ giao hàng',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _addresses.map((address) {
            return RadioListTile<String>(
              title: Text(
                address,
                style: ResponsiveHelper.responsiveTextStyle(
                  context: context,
                  baseSize: 14,
                  color: AppColors.text,
                ),
              ),
              value: address,
              groupValue: _selectedAddress,
              onChanged: (value) {
                setState(() {
                  _selectedAddress = value!;
                });
                Navigator.of(context).pop();
              },
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Đóng',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context) * 1.2),
        ),
        title: Text(
          '✅ Đặt hàng thành công!',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
        content: Text(
          'Đơn hàng của bạn đã được tạo thành công.\nMã đơn hàng: DH${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          style: ResponsiveHelper.responsiveTextStyle(
            context: context,
            baseSize: 16,
            color: AppColors.text,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getBorderRadius(context)),
              ),
            ),
            child: Text(
              'OK',
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 