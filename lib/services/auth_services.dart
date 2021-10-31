import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_chat/models/user_model.dart';

class AuthServices {
  //final FirebaseAuth _firebaseAuth = ;

  UserModel? _userFromFirebase(User? user) {
    return user != null ? UserModel(userId: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return e;
    }
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return e;
    }
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
