import 'package:flutter/material.dart';

class ChatDrawer extends StatefulWidget {
  @override
  _ChatDrawerState createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    double ht = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        //shrinkWrap: true,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              height: ht / 8.0,
              width: 300,
              color: Colors.white,
              child: Center(
                  child: Text("CHAT",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)))), //Heading

          Container(
              height: 7 * ht / 8.0,
              width: 300,
              //Chat Box
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // 1st for showing messages
                  // 2nd for entering message
                  Container(height: 7 * ht / 8.0 - 50, color: Colors.black),
                  Container(
                    height: 50,
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                          hintText: "Type here",
                          filled: true,
                          fillColor: Colors.white,
                          hoverColor: Colors.pink,
                          suffixIcon: IconButton(
                              icon: Icon(Icons.play_arrow),
                              onPressed: () {
                                //Function to send message from this user and add it to database
                                //And show it on screen of every other user too at the same time
                              })),
                    ),
                  )
                ],
              )),
          SizedBox(height: bottom),
        ],
      ),
    );
  }
}
