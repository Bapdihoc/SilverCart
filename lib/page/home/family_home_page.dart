import 'package:flutter/material.dart';
import 'package:silvercart/page/elderly_management/elderly_list_page.dart';
import 'package:silvercart/page/address_management/address_list_page.dart';
import 'package:silvercart/page/orders/order_approval_list_page.dart';
import 'package:silvercart/page/orders/user_order_list_page.dart';
import 'package:silvercart/page/settings/guardian_settings_page.dart';
import 'guardian_dashboard_page.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_helper.dart';

class FamilyHomePage extends StatefulWidget {
  const FamilyHomePage({super.key});

  @override
  State<FamilyHomePage> createState() => _FamilyHomePageState();
}

class _FamilyHomePageState extends State<FamilyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          GuardianDashboardPage(),
          ElderlyListPage(),
          AddressListPage(),
          UserOrderListPage(),
          OrderApprovalListPage(),
          GuardianSettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNavigation(),
    );
  }

  Widget _buildModernBottomNavigation() {
    return Container(
      margin: EdgeInsets.only(
        left: ResponsiveHelper.getLargeSpacing(context),
        right: ResponsiveHelper.getLargeSpacing(context),
        bottom: ResponsiveHelper.getLargeSpacing(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getSpacing(context),
            vertical: ResponsiveHelper.getSpacing(context) / 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Tổng quan',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.family_restroom_rounded,
                label: 'Người thân',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.location_on_rounded,
                label: 'Địa chỉ',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Đơn hàng',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.approval_rounded,
                label: 'Duyệt đơn',
                index: 4,
              ),
              _buildNavItem(
                icon: Icons.settings_rounded,
                label: 'Cài đặt',
                index: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getSpacing(context) / 2,
          vertical: ResponsiveHelper.getSpacing(context) / 2,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon với animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context) / 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, 20),
                color: isSelected
                    ? Colors.white
                    : AppColors.grey,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context) / 3),
            // Label với animation
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: ResponsiveHelper.responsiveTextStyle(
                context: context,
                baseSize: isSelected ? 10 : 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 