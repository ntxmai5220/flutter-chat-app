import 'package:flutter/material.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onClick;
  final Color btnColor;
  const CustomButton(
      {Key? key,
      required this.label,
      required this.onClick,
      this.btnColor = AppColors.primary})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          fixedSize: Size(double.maxFinite, double.infinity),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          primary: this.btnColor),
      onPressed: this.onClick,
      child: Text(
        this.label,
        style: AppStyles.textButton.copyWith(
            color: this.btnColor == Colors.white
                ? AppColors.primary
                : Colors.white),
      ),
    );
  }
}
