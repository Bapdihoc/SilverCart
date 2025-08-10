import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'responsive_helper.dart';

class ElderlyUIComponents {
  // Card lớn và dễ nhìn cho người cao tuổi
  static Widget elderlyCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? elevation,
    Color? backgroundColor,
  }) {
    return Card(
      elevation: elevation ?? 4.0,
      color: backgroundColor ?? AppColors.elderlyCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getElderlyBorderRadius(context)),
        side: BorderSide(
          color: AppColors.elderlyBorder,
          width: 2,
        ),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getElderlyPadding(context),
        vertical: ResponsiveHelper.getElderlySpacing(context),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(ResponsiveHelper.getElderlyPadding(context)),
        child: child,
      ),
    );
  }

  // Button lớn và dễ nhấn cho người cao tuổi
  static Widget elderlyButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? ResponsiveHelper.getElderlyButtonHeight(context),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.elderlyPrimary,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getElderlyBorderRadius(context)),
          ),
          elevation: 6,
          shadowColor: Colors.black26,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: ResponsiveHelper.getElderlyIconSize(context, 20),
              ),
              SizedBox(width: ResponsiveHelper.getElderlySpacing(context)),
            ],
            Text(
              text,
              style: ResponsiveHelper.elderlyTextStyle(
                context: context,
                baseSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input field lớn và dễ nhập cho người cao tuổi
  static Widget elderlyTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ResponsiveHelper.elderlyTextStyle(
            context: context,
            baseSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.elderlyText,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getElderlySpacing(context)),
        SizedBox(
          height: ResponsiveHelper.getElderlyInputHeight(context),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: ResponsiveHelper.elderlyTextStyle(
              context: context,
              baseSize: 16,
              color: AppColors.elderlyText,
            ),
            decoration: ResponsiveHelper.elderlyInputDecoration(
              context: context,
              labelText: '',
              hintText: hint,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  // Header lớn và rõ ràng cho người cao tuổi
  static Widget elderlyHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getElderlyPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.elderlyPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveHelper.getElderlyBorderRadius(context)),
          bottomRight: Radius.circular(ResponsiveHelper.getElderlyBorderRadius(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: ResponsiveHelper.elderlyTextStyle(
                    context: context,
                    baseSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: ResponsiveHelper.getElderlySpacing(context)),
            Text(
              subtitle,
              style: ResponsiveHelper.elderlyTextStyle(
                context: context,
                baseSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // List tile lớn cho người cao tuổi
  static Widget elderlyListTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    Color? backgroundColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getElderlyPadding(context),
        vertical: ResponsiveHelper.getElderlySpacing(context) / 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.elderlyCardBackground,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getElderlyBorderRadius(context)),
        border: Border.all(
          color: AppColors.elderlyBorder,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(ResponsiveHelper.getElderlyPadding(context)),
        leading: leading,
        title: Text(
          title,
          style: ResponsiveHelper.elderlyTextStyle(
            context: context,
            baseSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.elderlyText,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: EdgeInsets.only(top: ResponsiveHelper.getElderlySpacing(context)),
                child: Text(
                  subtitle,
                  style: ResponsiveHelper.elderlyTextStyle(
                    context: context,
                    baseSize: 14,
                    color: AppColors.elderlyTextSecondary,
                  ),
                ),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  // Loading indicator lớn cho người cao tuổi
  static Widget elderlyLoading({
    required BuildContext context,
    String? message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ResponsiveHelper.getElderlyIconSize(context, 60),
            height: ResponsiveHelper.getElderlyIconSize(context, 60),
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.elderlyPrimary),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: ResponsiveHelper.getElderlySpacing(context)),
            Text(
              message,
              style: ResponsiveHelper.elderlyTextStyle(
                context: context,
                baseSize: 16,
                color: AppColors.elderlyTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Alert dialog lớn cho người cao tuổi
  static Future<bool?> showElderlyAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getElderlyBorderRadius(context)),
        ),
        title: Text(
          title,
          style: ResponsiveHelper.elderlyTextStyle(
            context: context,
            baseSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.elderlyText,
          ),
        ),
        content: Text(
          message,
          style: ResponsiveHelper.elderlyTextStyle(
            context: context,
            baseSize: 16,
            color: AppColors.elderlyTextSecondary,
          ),
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: ResponsiveHelper.elderlyTextStyle(
                  context: context,
                  baseSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.elderlyTextSecondary,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.elderlyPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getElderlyBorderRadius(context)),
              ),
            ),
            child: Text(
              confirmText ?? 'OK',
              style: ResponsiveHelper.elderlyTextStyle(
                context: context,
                baseSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 