class ChatRoom {
  List<MessageModel> messages;
  List<String> users;
  ChatRoom({
    required this.messages,
    required this.users,
  });
}

class MessageModel {
  String fromUser;
  DateTime sent;
  int type;
  String content;
  List<Reaction>? reactions;
  MessageModel({
    required this.fromUser,
    required this.sent,
    required this.type,
    required this.content,
    this.reactions,
  });
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
