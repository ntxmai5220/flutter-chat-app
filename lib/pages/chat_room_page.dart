import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app_chat/models/message_model.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/services/database.dart';
import 'package:flutter_app_chat/shared_widgets/back_button.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';

class ChatRoomPage extends StatefulWidget {
  final UserInfor me, friend;
  final String docID;
  const ChatRoomPage(
      {Key? key, required this.me, required this.friend, required this.docID})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  DatabaseServices databaseServices = new DatabaseServices();

  TextEditingController _messageController = new TextEditingController();
  late String docId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print('init');
    setState(() {
      this.docId = widget.me.email + '_' + widget.friend.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: _roomBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildContentTest(size), _buildSendMessage(size)],
        ),
      ),
    );
  }

  _roomBar() {
    return AppBar(
      title: Text(widget.friend.name),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: CustomBackButton(
          onTap: back,
          color: Colors.white,
        ),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 13.8,
    );
  }

  void back() {
    Navigator.pop(context);
  }

  _buildContentTest(Size size) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: databaseServices.getStreamChat(this.docId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        //print('check stream + ${snapshot.data!.docs.elementAt(0).data()}');
        return Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              MessageModel message = MessageModel.fromMap(
                  snapshot.data!.docs.elementAt(index).data());
              return Column(
                crossAxisAlignment: message.fromUser == widget.friend.email
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: message.fromUser == widget.friend.email
                        ? EdgeInsets.fromLTRB(3, 2.5, size.width * 1 / 3, 2.5)
                        : EdgeInsets.fromLTRB(size.width * 1 / 3, 2.5, 3, 2.5),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: message.fromUser == widget.friend.email
                            ? AppColors.primary
                            : Colors.black12,
                        borderRadius: message.fromUser == widget.friend.email
                            ? BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15))
                            : BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15))),
                    child: Text(
                      message.content,
                      //textAlign: index % 2 == 0 ? TextAlign.left : TextAlign.right,
                      softWrap: true,
                      style: AppStyles.fillStyle.copyWith(
                          color: message.fromUser == widget.friend.email
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  _buildSendMessage(Size size) {
    return Container(
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Icon(Icons.add),
              ),
              borderRadius: BorderRadius.circular(50),
              onTap: _chooseOption,
            ),
            Container(
              width: size.width / 1.5,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                style: TextStyle(fontSize: 18),
                textInputAction: TextInputAction.newline,
                maxLines: null,
                controller: _messageController,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    hintText: 'Text . .',
                    //prefixIcon: Icon(Icons.search),
                    //suffixIcon: onChange ? Icon(Icons.cancel) : Container(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                            color: Colors.blue.shade600.withOpacity(0.5),
                            width: 1.0)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                            color: Colors.blue.shade600.withOpacity(0.5),
                            width: 1.0))),
              ),
            ),
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Icon(Icons.send),
              ),
              borderRadius: BorderRadius.circular(50),
              onTap: _sendMessage,
            )
          ],
        ));
  }

  _send(String value) {
    MessageModel sendMessage = new MessageModel(
        fromUser: widget.me.email,
        sent: Timestamp.now(),
        type: MessageType.text,
        content: value.trim());
    if (widget.docID == '_._') {
      List<String> users = [];
      users.addAll([widget.me.email, widget.friend.email]);

      databaseServices.sendMessage(this.docId, sendMessage, users: users);
    } else {
      databaseServices.sendMessage(widget.docID, sendMessage);
    }
    _messageController.text = '';
  }

  void _sendMessage() {
    if (_messageController.text.trim() != '')
      _send(_messageController.text.trim());
  }

  void _chooseOption() {
    print('choose');
  }
}
