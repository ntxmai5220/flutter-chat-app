import 'package:flutter/material.dart';
import 'package:flutter_app_chat/values/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const CustomBackButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: this.onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 13, 14, 13),
          child: Icon(
            Icons.arrow_back_ios_new_sharp,
            color: AppColors.primary,
          ),
          //SvgPicture.asset(AppAssets.ic_back, color: Colors.white),
        ),
      ),
    );
  }
}
