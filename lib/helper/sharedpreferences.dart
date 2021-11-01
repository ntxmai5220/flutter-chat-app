import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/values/app_shared_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelperSharedPreferences {
  Future<bool> saveUserLogin(bool isLogin) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return await preferences.setBool(AppSharedKeys.isLogin, isLogin);
  }

  Future<bool> saveUserAccount(String email, String pw) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return await preferences.setString(AppSharedKeys.email, email) &&
        await preferences.setString(AppSharedKeys.pw, pw);
  }

  Future<bool> getUserLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getBool(AppSharedKeys.isLogin) ?? false;
  }

  Future<UserModel> getUserAccount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    //return preferences.getBool(AppSharedKeys.isLogin) ?? false;
    return UserModel(
        email: preferences.getString(AppSharedKeys.email) ?? '',
        pw: preferences.getString(AppSharedKeys.pw) ?? '');
  }
}
