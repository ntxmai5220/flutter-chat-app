import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_app_chat/models/message_model.dart';
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
        //print('db' + '${value.docs.elementAt(0).data()}');
        value.docs.first.id;
        UserInfor infor = UserInfor.fromMap(value.docs.first.data());
        //print(infor.name);
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

  Future<List<Conversation>> getMyRooms(String email) async =>
      FirebaseFirestore.instance
          .collection('chat')
          .where('users', arrayContains: email)
          .get()
          .then((value) {
        List<Conversation> list = [];
        // value.docs.forEach((element) {
        //   result.
        // });
        value.docs.forEach((element) {
          //MessageModel mess;
          //print('check db  ${element.data()}');

          list.add(Conversation.fromMap(element.data(), element.id));
        });
        list.sort((a, b) => b.last.compareTo(a.last));
        return list;
      });
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllConversations(
      String email) {
    // //Query query =
    // FirebaseFirestore.instance
    //     .collection('chat')
    //     .where('users', arrayContains: email);
    return FirebaseFirestore.instance
        .collection('chat')
        //.orderBy('last')
        .where('users', arrayContains: email)
        //must be same field
        .snapshots();
  }

  //ok
  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamChat(String doc) {
    return FirebaseFirestore.instance
        .collection('chat')
        .doc(doc)
        .collection('messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //ok
  Future sendMessage(String doc, MessageModel mess,
      {List<String>? users}) async {
    String content;
    switch (mess.type) {
      case MessageType.text:
        content = mess.content;
        break;
      case MessageType.image:
        content = 'Message attachs photo';
        break;
      case MessageType.video:
        content = 'Message attachs video';
        break;
      case MessageType.file:
        content = 'Message attachs file';
        break;
      default:
        content = '';
    }
    FirebaseFirestore.instance
        .collection('chat')
        .doc(doc)
        .collection('messages')
        .add(mess.toMap());
    if (users == null) {
      FirebaseFirestore.instance
          .collection('chat')
          .doc(doc)
          .update({'last': mess.sent, 'lastContent': content});
    } else {
      FirebaseFirestore.instance
          .collection('chat')
          .doc(doc)
          .set({'last': mess.sent, 'lastContent': content, 'users': users});
    }
  }

  Future<List<UserInfor>> searchPeopleByEmail(String key) async =>
      FirebaseFirestore.instance
          .collection('profiles')
          .where('email', isGreaterThanOrEqualTo: key)
          .where('email', isLessThanOrEqualTo: key + '\uf8ff')
          .where('email',
              isNotEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((value) {
        List<UserInfor> list = [];
        value.docs.forEach((element) {
          list.add(UserInfor.fromMap(element.data()));
        });
        return list;
      });

  UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (_) {
      return null;
    }
  }
}
