import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/helper/sharedpreferences.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/services/auth_services.dart';
import 'package:flutter_app_chat/shared_widgets/custom_button.dart';
import 'package:flutter_app_chat/shared_widgets/input_text.dart';
import 'package:flutter_app_chat/shared_widgets/title_text.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';
import 'package:path_provider/path_provider.dart';

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

  String error = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      width: size.width,
                      height: size.height / 9,
                      child: Text(
                        error,
                        style:
                            TextStyle(color: Colors.red.shade900, fontSize: 15),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      width: size.width,
                      height: size.height / 9,
                      child: TitleText(text: 'Login'),
                    ),
                  ],
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
                                  offset: Offset(
                                      1, 1), // changes position of shadow
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
                                padding: const EdgeInsets.only(bottom: 25),
                                child: InputText(
                                  label: 'Email',
                                  textController: _emailController,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25),
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
      ),
    );
  }

  void _chooseOption() {
    print('choose');
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            height: 170,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Choose type',
                        style: AppStyles.fillStyle,
                      ),
                      InkWell(
                        child: Icon(Icons.close),
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                  height: 5,
                  indent: 15,
                  endIndent: 15,
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOptions(Icons.image, 'Image', () {
                        print('Image');
                        // _pickMedia(FileType.image);
                      }),
                      _buildOptions(Icons.video_collection, 'Video', () {
                        print('video');
                        //_pickMedia(FileType.video);
                      }),
                      _buildOptions(Icons.attach_file, 'File', () {
                        print('file');
                        _pickFile();
                      }),
                      // Icon(Icons.video_collection, size: 50),
                      // Icon(Icons.attach_file, size: 50)
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  _buildOptions(IconData icon, String label, VoidCallback action) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        //margin: EdgeInsets.all(10),
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
            //color: AppColors.secondary.withOpacity(0.1),
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(
              icon,
              size: 35,
              color: AppColors.primary,
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(label,
                    style: AppStyles.fillStyle.copyWith(fontSize: 15)))
          ],
        ),
      ),
    );
  }

  _pickFile() async {
    Navigator.pop(context);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'docs', 'xlsx']);
    if (result != null) {
      File file = File(result.files.single.path!);
      print(result.files.single.name);
      print(result.files.single.size);
      print(result.files.single.extension);
      print(result.files.single.identifier);
    } else {}
  }

  void login() {
    if (validation()) {
      setState(() {
        isProcessing = true;
      });
      authServices
          .signInWithEmailAndPassword(
              _emailController.text.trim(), _passwordController.text.trim())
          .then((value) {
        print(value is UserModel);
        if (value is UserModel) {
          HelperSharedPreferences helperSharedPreferences =
              new HelperSharedPreferences();
          helperSharedPreferences.saveUserLogin(true);
          helperSharedPreferences.saveUserAccount(value.email, value.pw);
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => HomePage()), (route) => false);
        } else {
          String e = value.toString();
          setState(() {
            print('check        ' + e);
            if (e.contains('wrong-password')) {
              error = 'Email or password is incorrect';
            } else if (e.contains('user-not-found')) {
              error = 'The email is not registered';
            } else {
              error = 'Login fail';
            }
          });
          // String error = e.substring(e.indexOf(']') + 1);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text(error),
          // ));
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

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
