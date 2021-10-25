import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/services/auth_services.dart';
import 'package:flutter_app_chat/shared_widgets/custom_button.dart';
import 'package:flutter_app_chat/shared_widgets/input_text.dart';
import 'package:flutter_app_chat/shared_widgets/title_text.dart';
import 'package:flutter_app_chat/values/app_assets.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPwController = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalKey = new GlobalKey<FormState>();
  bool isProcessing = false;
  late bool visible;
  late String icPath;

  AuthServices authMethods = new AuthServices();
  @override
  void initState() {
    super.initState();
    visible = false;
    icPath = AppAssets.ic_invisible;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   centerTitle: true,
      //   leading: Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 2),
      //     child: CustomBackButton(onTap: back),
      //   ),
      //   toolbarHeight: MediaQuery.of(context).size.height / 13.8,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: size.height / 9,
                child: TitleText(text: 'Register'),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      bottom: 25,
                      width: size.width - 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset:
                                  Offset(1, 1), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(27, 47, 27, 0),
                      child: Form(
                        key: globalKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: InputText(
                                label: 'Email',
                                textController: _emailController,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: InputText(
                                label: 'Password',
                                textController: _passwordController,
                                pw: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: confirmPw('Confirm password'),
                            ),
                            CustomButton(label: 'Register', onClick: register)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: size.height / 5.5,
                alignment: Alignment.center,
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: AppStyles.hintStyle.copyWith(fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 18),
                        recognizer: TapGestureRecognizer()..onTap = login,
                      ),
                      TextSpan(text: ' now!'),
                    ],
                  ),
                ),
              )
            ],
          ),
          !isProcessing
              ? Container()
              : Container(
                  height: size.height,
                  width: size.width,
                  color: Colors.grey.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget confirmPw(String hint) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      validator: (input) => input != _passwordController.text
          ? 'Confirmed password not match'
          : null,
      controller: _confirmPwController,
      keyboardType: TextInputType.emailAddress,
      style: AppStyles.fillStyle,
      obscureText: !visible,
      decoration: InputDecoration(
          suffixIcon: Container(
            height: 15,
            width: 15,
            margin: const EdgeInsets.fromLTRB(0, 1.5, 3, 1.5),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: controlVisible,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(icPath, color: AppColors.grey_text),
              ),
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 0, 8),
          labelText: hint,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.0)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.0))),
    );
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

  void login() {
    back();
  }

  void register() {
    if (validation()) {
      setState(() {
        isProcessing = true;
      });
      authMethods
          .signUpWithEmailAndPassword(
              _emailController.text, _passwordController.text)
          .then((value) {
        print(value.runtimeType);
        if (value is UserModel) {
        } else {
          String e = value.toString();
          String error = e.substring(e.indexOf(']') + 1);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error),
          ));
        }
      });
      setState(() {
        isProcessing = false;
      });
      print('sign up');
    }
  }

  void back() {
    Navigator.pop(context);
  }

  bool validation() {
    final form = globalKey.currentState;

    if (form!.validate()) {
      //print('ok');
      form.save();
      return true;
    }
    return false;
  }
}