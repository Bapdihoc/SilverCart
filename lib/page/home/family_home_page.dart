import 'package:flutter/material.dart';
import 'package:silvercart/page/elderly_management/elderly_list_page.dart';
import 'package:silvercart/page/address_management/address_list_page.dart';
import 'package:silvercart/page/orders/order_approval_list_page.dart';
import 'package:silvercart/page/settings/guardian_settings_page.dart';
import 'guardian_dashboard_page.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
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
      // appBar: AppBar(
      //   backgroundColor: AppColors.primary,
      //   elevation: 0,
      //   title: Text(
      //     'SilverCart',
      //     style: ResponsiveHelper.responsiveTextStyle(
      //       context: context,
      //       baseSize: 20,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(
      //         Icons.notifications_outlined,
      //         size: ResponsiveHelper.getIconSize(context, 24),
      //         color: Colors.white,
      //       ),
      //       onPressed: () {
      //         // TODO: Show notifications
      //       },
      //     ),
      //     IconButton(
      //       icon: Icon(
      //         Icons.person_outline,
      //         size: ResponsiveHelper.getIconSize(context, 24),
      //         color: Colors.white,
      //       ),
      //       onPressed: () {
      //         // TODO: Show profile
      //       },
      //     ),
      //   ],
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          GuardianDashboardPage(),
          ElderlyListPage(),
          AddressListPage(),
          OrderApprovalListPage(),
          GuardianSettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: ResponsiveHelper.responsiveTextStyle(
          context: context,
          baseSize: 14,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.family_restroom,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Người thân',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_on,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Địa chỉ',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.approval,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Duyệt đơn',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }










} 