import 'package:flutter/material.dart';
import 'package:flutter_app_chat/values/app_styles.dart';

class TitleText extends StatelessWidget {
  final String text;
  const TitleText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: AppStyles.textTitle,
    );
  }
}
