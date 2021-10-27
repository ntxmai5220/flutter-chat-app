import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_chat/values/app_assets.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputText extends StatefulWidget {
  final String label;
  final bool pw;
  final dynamic textController;
  const InputText(
      {Key? key,
      required this.label,
      this.pw = false,
      required this.textController})
      : super(key: key);

  @override
  _InputTextState createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  late bool visible;
  late String icPath;
  @override
  void initState() {
    super.initState();
    visible = false;
    icPath = AppAssets.ic_invisible;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.done,
      validator: valid,
      controller: widget.textController,
      keyboardType: TextInputType.emailAddress,
      style: AppStyles.fillStyle,
      obscureText: widget.pw && !visible,
      decoration: InputDecoration(
          suffixIcon: widget.pw
              ? Container(
                  height: 15,
                  width: 15,
                  margin: const EdgeInsets.fromLTRB(0, 1.5, 3, 1.5),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: controlVisible,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child:
                          SvgPicture.asset(icPath, color: AppColors.grey_text),
                    ),
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 0, 8),
          labelText: widget.label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.0)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.0))),
    );
  }

  String? valid(String? input) {
    // if (widget.pw) {
    //   if (input!.length < 6) {
    //     return 'At least 6 characters';
    //     // } else if (int.tryParse(input) != null) {
    //     //   return 'Password must be contain characters';
    //   } else {
    //     return null;
    //   }
    // }
    if (!widget.pw && !input!.contains('@')) {
      if (input.length == 0) {
        return 'Email must be not empty';
      }
      return 'Invalid email';
    }
  }

  void controlVisible() {
    setState(() {
      if (visible) {
        icPath = AppAssets.ic_invisible;
      } else {
        icPath = AppAssets.ic_visible;
      }
      visible = !visible;
    });
  }
}
