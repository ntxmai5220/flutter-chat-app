import 'dart:async';
import 'dart:io';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/shared_widgets/back_button.dart';

class PDFViewPage extends StatefulWidget {
  final File file;
  const PDFViewPage({Key? key, required this.file}) : super(key: key);

  @override
  _PDFViewPageState createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  late PDFDocument doc;
  bool isLoading = true;
  loadFile() async {
    print(widget.file.path);
    doc = await PDFDocument.fromFile(widget.file);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    loadFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.file.path.substring(widget.file.path.lastIndexOf('/') + 1)),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: CustomBackButton(
            onTap: back,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
          height: size.height,
          width: size.width,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(document: doc)),
    );
  }

  void back() {
    Navigator.pop(context);
  }
}
