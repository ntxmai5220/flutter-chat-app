import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/login_page.dart';
import 'package:flutter_app_chat/services/auth_services.dart';
import 'package:flutter_app_chat/services/database.dart';

import 'helper/sharedpreferences.dart';
import 'pages/home_page.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final UserInfor infor = new UserInfor(
      email: 'xuanmai.k18@gmail.com',
      name: 'Mai',
      avatar: '',
      phone: '0123456');
  HelperSharedPreferences helperSharedPreferences =
      new HelperSharedPreferences();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: helperSharedPreferences.getUserLogin(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data == true) {
              helperSharedPreferences.getUserAccount().then((value) {
                UserModel user = value;
                AuthServices authServices = new AuthServices();
                authServices.signInWithEmailAndPassword(user.email, user.pw);
                print(user.email + '___' + user.pw);
              });
            }
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: snapshot.data == true ? HomePage() : LoginPage(),
            );
          }
        });

    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     primarySwatch: Colors.blue,
    //   ),
    //   home: LoginPage(),
    // );
  }
}
