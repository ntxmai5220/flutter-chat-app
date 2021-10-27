import 'package:flutter/material.dart';

class SearchResult extends StatefulWidget {
  final String text;
  const SearchResult({Key? key, required this.text}) : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 100,
      color: Colors.amber.withOpacity(0.5),
      child: Text(widget.text),
    );
  }
}
