import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboardkit.dart';
import 'database.dart';
import 'drawer.dart';
import 'global.dart' as global;
import 'start_game.dart';

class MyGame extends StatefulWidget {
  MyGame({Key key}) : super(key: key);

  @override
  _MyGame createState() => _MyGame();
}

class _MyGame extends State<MyGame> {
  DrawingController controller;
  @override
  void initState() {
    controller = new DrawingController(enableChunk: true);
    controller.onChunk().listen((chunk) {
      FirestoreService.sendData(global.roomid, controller.draw.toJson());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Coming to build");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Skribbl"),
      ),
      drawer: ChatDrawer(),
      endDrawer: UsersDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Whiteboard(
                controller: controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                //2 buttons
                //1 st one to invite more persons
                //2 nd one to move out of the room
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: FlatButton.icon(
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: () {},
                      icon: Icon(Icons.share),
                      label: Text("Invite")),
                ),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: FlatButton.icon(
                      textColor: Colors.white,
                      color: Colors.red,
                      onPressed: () {},
                      icon: Icon(Icons.delete),
                      label: Text("Leave")),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }
}
