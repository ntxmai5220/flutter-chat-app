import 'dart:io';

import 'package:flutter_app_chat/pages/pdf_view_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app_chat/models/message_model.dart';
import 'package:flutter_app_chat/models/user_model.dart';
import 'package:flutter_app_chat/services/database.dart';
import 'package:flutter_app_chat/shared_widgets/back_button.dart';
import 'package:flutter_app_chat/values/app_colors.dart';
import 'package:flutter_app_chat/values/app_styles.dart';
import 'package:video_player/video_player.dart';

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
  bool isPlaying = true;

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
                                right: size.width / 4.0,
                                bottom:
                                    (message.reactions.length != 0 ? 10 : 0))
                            : EdgeInsets.only(
                                left: size.width / 4.0,
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
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5, color: Colors.grey.shade200),
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
                            child: ClipRRect(
                              borderRadius:
                                  message.fromUser == widget.friend.email
                                      ? BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15))
                                      : BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomLeft: Radius.circular(15)),
                              child: _buildContentMessage(message, size),
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

  _buildContentMessage(MessageModel message, Size size) {
    switch (message.type) {
      case MessageType.text:
        return Container(
          padding: EdgeInsets.all(15),
          child: Text(
            message.content,
            //textAlign: index % 2 == 0 ? TextAlign.left : TextAlign.right,
            softWrap: true,
            style: AppStyles.fillStyle.copyWith(
                color: message.fromUser == widget.friend.email
                    ? Colors.white
                    : Colors.black),
          ),
        );
      case MessageType.image:
        return ConstrainedBox(
          constraints: new BoxConstraints(
            minHeight: 5.0,
            minWidth: 5.0,
            maxHeight: size.width,
            maxWidth: size.width * 3 / 4,
          ),
          child: Image.network(
            message.content,
            //'https://tranhtreotuonghanoi.com/wp-content/uploads/2020/05/tranh-vinh-ha-long-kho-lon-ban-chay-nhat.jpg',
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder:
                (BuildContext context, Object obj, StackTrace? stackTrace) {
              return Container(
                  width: size.width * 3 / 4,
                  height: size.width * 2 / 4,
                  alignment: Alignment.center,
                  color: Colors.grey.shade300,
                  child: Text(
                    'Cannot load image',
                    style: TextStyle(color: Colors.black87),
                  ));
            },
          ),
        );
      case MessageType.video:
        VideoPlayerController _videoPlayerController =
            VideoPlayerController.network(message.content);

        // VideoPlayerController.file(File(
        //     '/data/user/0/com.example.flutter_app_chat/cache/file_picker/Record_2021-10-26-22-17-12_f386c697998959b0a8bffbe9155aa1aa.mp4'));
        // VideoPlayerController.file(File(
        //     '/data/user/0/com.example.flutter_app_chat/cache/file_picker/VID_20211030_084034.mp4'));
        // VideoPlayerController.network(
        //     'https://doc-14-7k-docs.googleusercontent.com/docs/securesc/onhc7uf88at3sfan14u0hqqun820hphc/him66grlbc0lfa2q375iqmh5hln2tlvm/1635600900000/17515865301253485067/00548885795770392741Z/1_eFT6i3LFxK-zDaeocdGm5qZTm3ocRZj?e=view&nonce=8893sgpdu7f40&user=00548885795770392741Z&hash=ei5v4fneilgjkfvfu3f4n7k90o32qt6b');
        //bool isPlaying = false;
        //
        // return ConstrainedBox(
        //   constraints: new BoxConstraints(
        //     minHeight: 5.0,
        //     minWidth: 5.0,
        //     maxHeight: size.width * 4 / 3,
        //     maxWidth: size.width * 2 / 3,
        //   ),
        //   child: AspectRatio(
        //       aspectRatio: _videoPlayerController.value.aspectRatio,
        //       child: VideoPlayer(_videoPlayerController)),
        // );
        // return AspectRatio(
        //     aspectRatio: _videoPlayerController.value.aspectRatio,
        //     child: VideoPlayer(_videoPlayerController));
        Future<bool> getVideo() async {
          await _videoPlayerController.initialize();
          return true;
        }
        return FutureBuilder(
          future: getVideo(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return InkWell(
                onTap: () {
                  //_bottomSheetVideo(_videoPlayerController);
                  if (_videoPlayerController.value.isPlaying) {
                    _videoPlayerController.pause();
                  } else {
                    _videoPlayerController.play();
                  }
                },
                child: AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                ),
              );
            }
            return Container(
              color: Colors.grey.shade100,
              height: size.width * 3 / 4,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );

      case MessageType.file:
        String name = message.content.substring(
            message.content.indexOf('[') + 1, message.content.indexOf(']'));
        String url =
            message.content.substring(message.content.indexOf(']') + 1);
        return InkWell(
          onTap: () async {
            //download file
            final dir = await getApplicationDocumentsDirectory();

            Reference ref = FirebaseStorage.instance
                //.ref('ha@gmail.com_xuanmai.k18@gmail.com_1635666251');
                // .refFromURL(
                //     'https://firebasestorage.googleapis.com/v0/b/chat-app-386c6.appspot.com/o/ha%40gmail.com_xuanmai.k18%40gmail.com_1635577673.jpg?alt=media&token=cd41514d-c31b-4b7a-ab4f-422956121ff1');
                .refFromURL(url);
            // if(ref!=null){
            // }
            //final bytes = await ref.getData();

            File file = File('${dir.path}/$name');
            print('${dir.path}/$name');

            //await file.writeAsBytes(bytes!, flush: true);
            await ref
                .writeToFile(file)
                .whenComplete(() => print('ok'))
                .catchError((e) {
              print(e);
            });

            print(dir.path);
            // File file = File('$appDocPath/check.txt');

            // await file.writeAsString('testtttttttt').catchError((e) {
            //   print(e);
            // });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Downloaded file'),
            ));

            //customBottomSheet(file, 'FileType.image', 'pdf');
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => PDFViewPage(file: file)));
          },
          child: Container(
            width: size.width * 3 / 4,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.file_present_rounded,
                  color: message.fromUser == widget.me.email
                      ? Colors.black
                      : Colors.white,
                  size: 40,
                ),
                Expanded(
                  //width: size.width * 3 / 4 - 120,
                  child: Text(
                    //https://firebasestorage.googleapis.com/v0/b/flutter-chat-app-766c6.appspot.com/o/Cohota.pdf?alt=media&token=965a0967-6173-49e0-9a0b-2e27a26cd064
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: message.fromUser == widget.me.email
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                )
              ],
            ),
          ),
        );
    }
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
                  margin: EdgeInsets.all(12),
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
                child: Icon(
                  Icons.add,
                  //color: AppColors.secondary,
                ),
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
                child: Icon(
                  Icons.send,
                  //color: AppColors.secondary,
                ),
              ),
              borderRadius: BorderRadius.circular(50),
              onTap: _sendTextMessage,
            )
          ],
        ));
  }

  _send(String value, {type: MessageType.text}) {
    print('content    $value');
    MessageModel sendMessage = new MessageModel(
        fromUser: widget.me.email,
        sent: Timestamp.now(),
        type: type,
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

  void _sendTextMessage() {
    if (_messageController.text.trim() != '')
      _send(_messageController.text.trim());
  }

  ///////////////////////////////////////////////
  void _chooseOption() {
    print('choose');
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
            height: 170,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Choose type',
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
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOptions(Icons.image, 'Image', () {
                        print('Image');
                        _pickMedia(FileType.image);
                      }),
                      _buildOptions(Icons.video_collection, 'Video', () {
                        print('video');
                        _pickMedia(FileType.video);
                      }),
                      _buildOptions(Icons.attach_file, 'File', () {
                        print('file');
                        _pickFile();
                      }),
                      // Icon(Icons.video_collection, size: 50),
                      // Icon(Icons.attach_file, size: 50)
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  _buildOptions(IconData icon, String label, VoidCallback action) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        //margin: EdgeInsets.all(10),
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
            //color: AppColors.secondary.withOpacity(0.1),
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(
              icon,
              size: 35,
              color: AppColors.primary,
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(label,
                    style: AppStyles.fillStyle.copyWith(fontSize: 15)))
          ],
        ),
      ),
    );
  }

  _pickFile() async {
    Navigator.pop(context);
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File file = File(result.files.single.path!);
      print('link ${result.files.single.path!}');
      String des = '${widget.me.email}_${widget.friend.email}_' +
          Timestamp.now().seconds.toString() +
          '.' +
          result.files.single.extension!;
      UploadTask? task = databaseServices.uploadFile(des, file);

      var snapshot = await task!.whenComplete(() {});
      snapshot.ref.getDownloadURL().then((value) {
        _send('[${result.files.single.name}]${value}', type: MessageType.file);
        //Navigator.pop(context);
      });
    } else {}
  }

  _pickMedia(FileType chooseType) async {
    Navigator.pop(context);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: chooseType);
    if (result != null) {
      print(chooseType.toString());
      File file = File(result.files.single.path!);

      customBottomSheet(
          file, chooseType.toString(), result.files.single.extension!);
    } else {}
  }

  customBottomSheet(File file, String type, String extension) {
    late VideoPlayerController _videoPlayerController;
    if (type == 'FileType.video') {
      print('link       ${file.path}');
      //setState(() {
      _videoPlayerController = VideoPlayerController.file(file);
      //});
    }
    Future started() async {
      await _videoPlayerController.initialize();
      await _videoPlayerController.play();

      return true;
    }

    _video() {
      return FutureBuilder(
        future: started(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == true) {
            return AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            );
          } else {
            //startedPlaying = false;
            return Center(
              child: Text(
                'Error',
                style: AppStyles.fillStyle.copyWith(color: Colors.white),
              ),
            );
          }
        },
      );
    }

    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return Container(
            margin: EdgeInsets.fromLTRB(0, 100, 00, 0),
            padding: EdgeInsets.only(bottom: 1),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preview',
                            style: AppStyles.fillStyle
                                .copyWith(color: Colors.white),
                          ),
                          InkWell(
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Center(
                          child: type == 'FileType.image'
                              ? Image.file(file)
                              : _video(),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 25,
                  bottom: 25,
                  child: InkWell(
                    onTap: () async {
                      String des =
                          '${widget.me.email}_${widget.friend.email}_' +
                              Timestamp.now().seconds.toString() +
                              '.$extension';
                      UploadTask? task = databaseServices.uploadFile(des, file);

                      var snapshot = await task!.whenComplete(() {});
                      var url = snapshot.ref.getDownloadURL().then((value) {
                        _send(value, type: checkType(type));
                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white, //AppColors.primary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.send,
                        color: AppColors.primary, //Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  int checkType(String type) {
    switch (type) {
      case 'FileType.image':
        return MessageType.image;
      case 'FileType.video':
        return MessageType.video;
      case 'FileType.file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  // _bottomSheetVideo(VideoPlayerController controller) {
  //   controller.play();
  //   return showModalBottomSheet(
  //       isScrollControlled: true,
  //       context: context,
  //       builder: (builder) {
  //         return Stack(
  //           children: [
  //             Container(
  //               decoration: BoxDecoration(
  //                   color: Colors.black,
  //                   borderRadius: BorderRadius.circular(15)),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
  //                 child: AspectRatio(
  //                   aspectRatio: controller.value.aspectRatio,
  //                   child: VideoPlayer(controller),
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               bottom: 50,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   InkWell(
  //                     onTap: () {
  //                       // setState(() {
  //                       //   // If the video is playing, pause it.

  //                       // });
  //                       setState(() {
  //                         if (controller.value.isPlaying) {
  //                           controller.pause();
  //                         } else {
  //                           // If the video is paused, play it.
  //                           controller.play();
  //                         }
  //                         isPlaying = !isPlaying;
  //                       });
  //                     },
  //                     child: Icon(
  //                       isPlaying ? Icons.pause_circle : Icons.play_circle,
  //                       color: Colors.black.withOpacity(0.7),
  //                       size: 40,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             )
  //           ],
  //         );
  //       });
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    super.dispose();
  }
}
