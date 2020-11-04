import 'package:flutter/material.dart';

class ChatDrawer extends StatefulWidget {
  @override
  _ChatDrawerState createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
            height: 100,
            width: 300,
            color: Colors.white,
            child: Center(
                child: Text("CHAT",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)))), //Heading
        Expanded(
            child: Container(
                width: 300,
                //Chat Box
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // 1st for showing messages
                    // 2nd for entering message
                    Container(height: 600, color: Colors.black),
                    Container(
                        height: 100, color: Colors.white, child: TextField())
                  ],
                )))
      ],
    );
  }
}
