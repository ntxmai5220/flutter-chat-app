import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/message_model.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/chat_room_page.dart';
import 'package:flutter_app_chat/services/database.dart';
import 'package:flutter_app_chat/shared_widgets/back_button.dart';
import 'package:flutter_app_chat/values/app_styles.dart';

class SearchResultPage extends StatefulWidget {
  final String text;
  final Iterable<Review> searchMessages;
  const SearchResultPage(
      {Key? key, required this.text, required this.searchMessages})
      : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  DatabaseServices databaseServices = new DatabaseServices();

  final String email = FirebaseAuth.instance.currentUser!.email!;
  late UserInfor me;
  List<UserInfor> users = [];
  getMyInfor() async {
    me = await databaseServices.getUserInfor(email);
  }

  getUsers(email) {
    databaseServices.searchPeopleByEmail(email).then((value) {
      setState(() {
        users = value;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyInfor();
    getUsers(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: Text(
              users.length != 0 ? 'People' : '',
              style: AppStyles.hintStyle.copyWith(fontSize: 20),
            ),
          ),
          _buildListPeople(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: Text(
              widget.searchMessages.length != 0 ? 'Messages' : '',
              style: AppStyles.hintStyle.copyWith(fontSize: 20),
            ),
          ),
          _buildListMessages(),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text(
        widget.text,
        style: AppStyles.fillStyle,
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: CustomBackButton(onTap: back),
      ),
      toolbarHeight: MediaQuery.of(context).size.height / 13.8,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildListMessages() {
    return Expanded(
        flex: 5,
        child: ListView.builder(
          itemCount: widget.searchMessages.length,
          itemBuilder: (context, index) {
            //print('lennnnnnn ${widget.searchMessages.length}');
            //Review item = widget.searchMessages.elementAt(index);
            return _chatItem(context, index);
          },
        ));
  }

  Widget _chatItem(BuildContext context, int index) {
    Review room = widget.searchMessages.elementAt(index);
    int user = room.users[0] == email ? 1 : 0;
    return FutureBuilder(
        future: databaseServices.getUserInfor(room.users[user]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            UserInfor friend = snapshot.data;
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomPage(
                      me: me,
                      friend: friend,
                      docID: room.docId,
                    ),
                  ),
                );
              },
              title: Text(
                //room.users[0],
                friend.name,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    room.lastContent,
                    overflow: TextOverflow.ellipsis,
                  )),
                  Text(room.last.toDate().toString().substring(0, 16))
                ],
              ),
              leading: CircleAvatar(
                child: Text(friend.name.substring(0, 1).toUpperCase(),
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
              ),
            );
          }
          return ListTile();
        });
  }

  Widget _buildListPeople() {
    // return Expanded(
    //   child: FutureBuilder<List<UserInfor>>(
    //     future: databaseServices.searchPeopleByEmail(widget.text),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return Center(child: CircularProgressIndicator());
    //       }
    //       if (snapshot.hasData) {
    //         if (snapshot.data!.length == 0) {
    //           return Center(
    //             child: Text(
    //               'No matching results',
    //               style: AppStyles.hintStyle.copyWith(fontSize: 22),
    //             ),
    //           );
    //         } else {
    //           return ListView.builder(
    //             itemCount: snapshot.data!.length,
    //             itemBuilder: (context, index) {
    //               UserInfor user = snapshot.data!.elementAt(index);
    //               return ListTile(
    //                 // leading: CircleAvatar(
    //                 //   child: Icon(Icons.face),
    //                 // ),
    //                 // title: Text('${mMessages[index].users[0]}'),
    //                 onTap: () {
    //                   Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                           builder: (_) => ChatRoomPage(
    //                               me: me, friend: user, docID: '_')));
    //                 },
    //                 title: Text(
    //                   //room.users[0],
    //                   user.name,
    //                   style:
    //                       TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
    //                 ),
    //                 subtitle: Text(user.email),
    //                 leading: CircleAvatar(
    //                   backgroundColor: Colors.deepPurple,
    //                   child: Text(user.name.substring(0, 1).toUpperCase(),
    //                       style: TextStyle(
    //                           fontWeight: FontWeight.w600,
    //                           fontSize: 24,
    //                           color: Colors.white)),
    //                 ),
    //               );
    //             },
    //           );
    //         }
    //       }
    //       return Center(
    //         child: Text(
    //           'Sorry !!',
    //           style: AppStyles.hintStyle.copyWith(fontSize: 22),
    //         ),
    //       );
    //     },
    //   ),
    // );

    return Expanded(
      flex: 4,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          UserInfor user = users[index];
          return ListTile(
            // leading: CircleAvatar(
            //   child: Icon(Icons.face),
            // ),
            // title: Text('${mMessages[index].users[0]}'),
            onTap: () {
              var check = widget.searchMessages
                  .where((element) => element.users.contains(user.email));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatRoomPage(
                          me: me,
                          friend: user,
                          docID:
                              check.length == 0 ? '_._' : check.first.docId)));
            },
            title: Text(
              //room.users[0],
              user.name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            subtitle: Text(user.email),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  void back() {
    Navigator.pop(context);
  }
}
