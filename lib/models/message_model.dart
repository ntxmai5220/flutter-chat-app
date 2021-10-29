import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  //MessageModel messages;
  String docId;
  List<String> users;
  Timestamp last;
  String lastContent;
  Review({
    //required this.messages,
    required this.docId,
    required this.users,
    required this.last,
    required this.lastContent,
  });
  Map<String, dynamic> toMap() {
    return {
      //'messages': messages.map((x) => x.toMap()).toList(),
      //'chatting': messages,
      'users': users,
      'last': last,
      'lastContent': lastContent,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, String docId) {
    return Review(
      // messages: List<MessageModel>.from(
      //     map['chatting']?.map((x) => MessageModel.fromMap(x))).first,
      docId: docId,
      users: List<String>.from(map['users']),
      last: map['last'],
      lastContent: map['lastContent'],
    );
  }

  String toJson() => json.encode(toMap());

  // factory Review.fromJson(String source) => Review.fromMap(json.decode(source));
}

class ChatRoom {
  //MessageModel messages;
  List<String> users;
  Timestamp last;
  ChatRoom({
    required this.users,
    required this.last,
  });

  Map<String, dynamic> toMap() {
    return {
      'users': users,
      'last': last,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      users: List<String>.from(map['users']),
      last: map['last'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatRoom.fromJson(String source) =>
      ChatRoom.fromMap(json.decode(source));
}

class MessageModel {
  String fromUser;
  Timestamp sent;
  int type;
  String content;
  //List<Reaction>? reactions;
  MessageModel({
    //required this.sent,
    required this.fromUser,
    required this.sent,
    required this.type,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUser': fromUser,
      'sent': sent,
      'type': type,
      'content': content,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      fromUser: map['fromUser'],
      sent: map['sent'],
      type: map['type'],
      content: map['content'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));
}

class Reaction {
  String user;
  int react;
  Reaction({
    required this.user,
    required this.react,
  });
}

class MessageType {
  static const int text = 0;
  static const int image = 1;
  static const int video = 2;
  static const int file = 3;
}
