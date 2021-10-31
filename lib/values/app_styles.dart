import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  static TextStyle hintStyle = TextStyle(
      color: AppColors.grey_text, fontSize: 18, fontWeight: FontWeight.w400);
  static TextStyle fillStyle = hintStyle.copyWith(color: Colors.black);
  static TextStyle textTitle = TextStyle(
      fontSize: 40, color: Colors.blue.shade700, fontWeight: FontWeight.w700);
  static TextStyle textButton = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
}
