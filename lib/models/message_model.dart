import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  //MessageModel messages;
  String docId;
  List<String> users;
  Timestamp last;
  String lastContent;
  Conversation({
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

  factory Conversation.fromMap(Map<String, dynamic> map, String docId) {
    return Conversation(
      // messages: List<MessageModel>.from(
      //     map['chatting']?.map((x) => MessageModel.fromMap(x))).first,
      docId: docId,
      users: List<String>.from(map['users']),
      last: map['last'],
      lastContent: map['lastContent'],
    );
  }

  String toJson() => json.encode(toMap());

  // factory Conversation.fromJson(String source) => Conversation.fromMap(json.decode(source));
}

class MessageModel {
  String fromUser;
  Timestamp sent;
  int type;
  String content;
  List<String> reactions;
  MessageModel({
    //required this.sent,
    required this.fromUser,
    required this.sent,
    required this.type,
    required this.content,
    required this.reactions
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUser': fromUser,
      'sent': sent,
      'type': type,
      'content': content,
      'reactions': reactions,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      fromUser: map['fromUser'],
      sent: map['sent'],
      type: map['type'],
      content: map['content'],
      reactions: List<String>.from(map['reactions']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));
}

class MessageType {
  static const int text = 0;
  static const int image = 1;
  static const int video = 2;
  static const int file = 3;
}
