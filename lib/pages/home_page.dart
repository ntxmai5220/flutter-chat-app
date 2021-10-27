import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/message_model.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/pages/profile_page.dart';
import 'package:flutter_app_chat/services/database.dart';
import 'package:flutter_app_chat/shared_widgets/search_result.dart';
import 'package:flutter_app_chat/values/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = new TextEditingController();
  bool onChange = false;

  List<ChatRoom> messages = [];

  DatabaseServices databaseServices = new DatabaseServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
            FutureBuilder(
                builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return _buildMain(size);
            }),
          ],
        ));
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
                  Icons.android,
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
          onChanged: _searchMessage,
          decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
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
    );
  }

  Widget _addMessage() {
    return InkWell(
      onTap: _newMessage,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: EdgeInsets.all(3),
        child: Icon(
          Icons.add_circle,
          size: 37,
          color: AppColors.primary,
        ),
      ),
    );
  }

  List<_RoomItem> _buildRoomList() {
    return messages.map((m) => _RoomItem(m)).toList();
  }

  Widget _buildMain(Size size) {
    // search result or list of message
    return Container(
      width: size.width,
      height: size.width * 3 / 2,
      color: Colors.black54,
      child: _searchController.text != '' //check result de hien thi
          ? SearchResult(text: _searchController.text)
          : null,
    );
  }

  void openProfile() {
    print('check email ' + FirebaseAuth.instance.currentUser!.email!);
    databaseServices
        .getUserInfor(FirebaseAuth.instance.currentUser!.email!)
        .then((value) {
      print(value);
      if (value is UserInfor) {
        //Future.delayed(Duration(seconds: 0), () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProfilePage(infor: value)));
        //});
      }
    });
  }

  void _searchMessage(String text) {
    setState(() {
      onChange = !onChange;
    });
    print(text);
  }

  void _newMessage() {}
}

class _RoomItem extends ListTile {
  _RoomItem(ChatRoom room)
      : super(
            title: Text(room.users[0]),
            subtitle: Text(room.messages[0].content),
            leading: CircleAvatar(
              child: Text(
                room.users[0].substring(0, 1),
              ),
            ));
}
