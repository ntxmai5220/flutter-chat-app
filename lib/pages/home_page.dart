import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_chat/models/message_model.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/chat_room_page.dart';
import 'package:flutter_app_chat/pages/profile_page.dart';
import 'package:flutter_app_chat/services/database.dart';
import 'package:flutter_app_chat/pages/search_result_page.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = new TextEditingController();

  List<Review> conversations = [];

  DatabaseServices databaseServices = new DatabaseServices();

  final String email = FirebaseAuth.instance.currentUser!.email!;
  late UserInfor me;

  getMyInfor() async {
    me = await databaseServices.getUserInfor(email);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyInfor();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: _homeBar(),
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _searchBar(size),
                    //_addMessage(),
                  ],
                ),
              ),
              Expanded(child: _buildMain(size)),
            ],
          )),
    );
  }

  AppBar _homeBar() {
    return AppBar(
      title: Text('Messages'),
      actions: [
        Container(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            onTap: openProfile,
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: EdgeInsets.all(4),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.face,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _searchBar(Size size) {
    var findMeaage;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.centerLeft,
      //width: size.width * 5.0 / 6,
      width: size.width - 30,
      child: Center(
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: _searchDB,
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
            //suffixIcon: onChange ? Icon(Icons.cancel) : Container(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(
                  color: Colors.blue.shade600.withOpacity(0.5), width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(
                  color: Colors.blue.shade600.withOpacity(0.5), width: 1.0),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _addMessage() {
  //   return InkWell(
  //     onTap: _newMessage,
  //     borderRadius: BorderRadius.circular(50),
  //     child: Padding(
  //       padding: EdgeInsets.all(3),
  //       child: Icon(
  //         Icons.add_circle,
  //         size: 37,
  //         color: AppColors.primary,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMain(Size size) {
    // search result or list of message
    // return Container(
    //   width: size.width,
    //   //height: size.width * 3 / 2,

    //   child: _searchController.text != '' //check result de hien thi
    //       ? SearchResult(text: _searchController.text)
    //       : _buildList(),
    // );
    return Container(
      width: size.width,
      color: Colors.grey.shade100,
      child: _buildList(),
    );
  }

  Widget _buildList() {
    // return FutureBuilder(
    //   future: databaseServices.getMyRooms(email),
    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center();
    //     } else if (snapshot.hasData) {
    //       print('check list' + snapshot.data.toString());
    //       mMessages = snapshot.data;
    //       return ListView.builder(
    //         itemCount: mMessages.length,
    //         itemBuilder: (context, index) {
    //           return _chatItem(context, index);
    //         },
    //       );
    //     }

    //     return Center(child: CircularProgressIndicator());
    //   },
    // );
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: databaseServices.getAllConversations(email),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          conversations = List<Review>.from(
              snapshot.data!.docs.map((x) => Review.fromMap(x.data(), x.id)));

          conversations.sort((a, b) => b.last.compareTo(a.last));
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Review review = Review.fromMap(
              //     snapshot.data!.docs.elementAt(index).data(),
              //     snapshot.data!.docs.elementAt(index).id);
              return _chatItem(context, conversations[index]);
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _chatItem(BuildContext context, Review review) {
    Review room = review;
    int user = room.users[0] == email ? 1 : 0;
    return FutureBuilder(
        future: databaseServices.getUserInfor(room.users[user]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            UserInfor friend = snapshot.data;
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                // leading: CircleAvatar(
                //   child: Icon(Icons.face),
                // ),
                // title: Text('${mMessages[index].users[0]}'),
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
                    Container(
                        margin: EdgeInsets.only(left: 7),
                        child: Text(
                            room.last.toDate().toString().substring(0, 16)))
                  ],
                ),
                leading: CircleAvatar(
                  child: Text(friend.name.substring(0, 1).toUpperCase(),
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 24)),
                ),
              ),
            );
          }
          return ListTile();
        });
  }

  openProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => ProfilePage(infor: me)));
  }

  void _searchMessage(String text) {
    // setState(() {
    //   onChange = !onChange;
    // });
    print(text);
  }

  void goToChatDetail() {
    //Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomPage()));
  }

  void _searchDB(String value) {
    if (value.trim() != '') {
      Iterable<Review> list = conversations.where((review) =>
          review.users
              .where((user) =>
                  user != me.email && user.startsWith(value.toLowerCase()))
              .length !=
          0);
      print('check len at home ${list.length}');
      print('check len at home ${conversations.length}');
      // list.forEach((element) {
      //   print(element.users);
      // });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SearchResultPage(
                    text: value.trim(),
                    searchMessages: list,
                  )));
    }
  }
}
