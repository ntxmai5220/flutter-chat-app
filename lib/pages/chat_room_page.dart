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
      this.docId = widget.docID == '_._'
          ? widget.me.email + '_' + widget.friend.email
          : widget.docID;
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'Error!!',
              style: AppStyles.hintStyle,
            ),
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

              return Stack(
                alignment: message.fromUser == widget.friend.email
                    ? AlignmentDirectional.topStart
                    : AlignmentDirectional.topEnd,
                children: [
                  Column(
                    crossAxisAlignment: message.fromUser == widget.friend.email
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Container(
                        margin: message.fromUser == widget.friend.email
                            ? EdgeInsets.only(
                                right: size.width / 3.0,
                                bottom:
                                    (message.reactions.length != 0 ? 10 : 0))
                            : EdgeInsets.only(
                                left: size.width / 3.0,
                                bottom:
                                    (message.reactions.length != 0 ? 10 : 0)),
                        child: GestureDetector(
                          onDoubleTap: () async {
                            // setState(() {
                            //   react = !react;
                            // });
                            if (!message.reactions.contains(widget.me.email)) {
                              await FirebaseFirestore.instance
                                  .collection('chat')
                                  .doc(this.docId)
                                  .collection('messages')
                                  .doc(snapshot.data!.docs.elementAt(index).id)
                                  .update({
                                'reactions':
                                    FieldValue.arrayUnion([widget.me.email])
                              });
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('chat')
                                  .doc(this.docId)
                                  .collection('messages')
                                  .doc(snapshot.data!.docs.elementAt(index).id)
                                  .update({
                                'reactions':
                                    FieldValue.arrayRemove([widget.me.email])
                              });
                            }
                          },
                          child: Container(
                            margin: message.fromUser == widget.friend.email
                                ? EdgeInsets.fromLTRB(3, 2.5, 3, 2.5)
                                : EdgeInsets.fromLTRB(3, 2.5, 3, 2.5),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: message.fromUser == widget.friend.email
                                    ? AppColors.primary
                                    : Colors.black12,
                                borderRadius:
                                    message.fromUser == widget.friend.email
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
                        ),
                      ),
                    ],
                  ),
                  message.reactions.length != 0
                      ? _buildReactions(message.reactions)
                      : Container(
                          width: 0,
                        )
                ],
              );
            },
          ),
        );
      },
    );
  }

  _buildReactions(List<String> reactions) {
    return Positioned(
      bottom: 0,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (builder) {
                return Container(
                  margin: EdgeInsets.all(17),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  height: 250,
                  child: Column(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reactions',
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
                      Expanded(
                        child: ListView.builder(
                            itemCount: reactions.length,
                            itemBuilder: (context, index) {
                              UserInfor user =
                                  reactions[index] == widget.me.email
                                      ? widget.me
                                      : widget.friend;
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                      user.name.substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 24)),
                                ),
                                title: Text(
                                  user.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                                trailing: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                );
              });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3.5),
          decoration: BoxDecoration(
              color: Colors.orange.shade50.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                size: 20,
                color: Colors.red,
              ),
              Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  '${reactions.length}',
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
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
        content: value.trim(),
        reactions: []);
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
