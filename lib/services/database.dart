import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_chat/models/user_model.dart';

class DatabaseServices {
  Future addUser(userInfor) async {
    FirebaseFirestore.instance
        .collection('profiles')
        .add(userInfor)
        .catchError((error) {
      print('check -------------------' + error.toString());
    });
  }

  Future<UserInfor> getUserInfor(String email) async =>
      FirebaseFirestore.instance
          .collection('profiles')
          .where('email', isEqualTo: email)
          .get()
          .then((value) {
        print('db' + '${value.docs.elementAt(0).data()}');
        value.docs.first.id;
        UserInfor infor = UserInfor.fromMap(value.docs.first.data());
        print(infor.name);
        return infor;
      });

  Future updateInfor(UserInfor user) async {
    FirebaseFirestore.instance
        .collection('profiles')
        .where('email', isEqualTo: user.email)
        .get()
        .then((value) {
      String id = value.docs.first.id;

      FirebaseFirestore.instance
          .collection('profiles')
          .doc(id)
          .set(user.toMap());
    });
  }
  
}
