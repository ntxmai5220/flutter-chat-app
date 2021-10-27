import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/services/auth_services.dart';
import 'package:flutter_app_chat/shared_widgets/custom_button.dart';
import 'package:flutter_app_chat/shared_widgets/input_text.dart';
import 'package:flutter_app_chat/shared_widgets/title_text.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';

import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalKey = new GlobalKey<FormState>();

  bool isProcessing = false;
  AuthServices authServices = new AuthServices();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: size.height / 9,
                child: TitleText(text: 'Login'),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
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
                            ]),
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
                            CustomButton(label: 'Login', onClick: login)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: size.height / 10,
                alignment: Alignment.bottomCenter,
                child: RichText(
                  text: TextSpan(
                    text: 'Don\'t have an account? ',
                    style: AppStyles.hintStyle.copyWith(fontSize: 16),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Register',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 18),
                        recognizer: TapGestureRecognizer()..onTap = register,
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
              : Stack(
                  children: [
                    Container(
                      height: size.height,
                      width: size.width,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                    Positioned(
                      top: size.height / 2 - size.width / 4.4,
                      left: size.width / 2 - size.width / 3,
                      child: Container(
                        height: size.width / 2.2,
                        width: size.width / 1.5,
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
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void login() {
    if (validation()) {
      setState(() {
        isProcessing = true;
      });
      authServices
          .signInWithEmailAndPassword(
              _emailController.text, _passwordController.text)
          .then((value) {
        print(value is UserModel);
        if (value is UserModel) {
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => HomePage()), (route) => false);
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

  void register() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
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
