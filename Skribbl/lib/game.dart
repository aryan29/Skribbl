import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboardkit.dart';
import 'database.dart';
import 'drawer.dart';
import 'global.dart' as global;
import 'start_game.dart';
import 'package:timer_count_down/timer_count_down.dart';

class MyGame extends StatefulWidget {
  MyGame({Key key}) : super(key: key);

  @override
  _MyGame createState() => _MyGame();
}

class _MyGame extends State<MyGame> {
  StreamController<Map<String, dynamic>> myStream;
  @override
  void initState() {
    myStream = new StreamController();
    super.initState();
  }

  addToStream() async {
    myStream.sink.add(FirestoreService.getCurrentData());
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
        body: StreamBuilder(
            stream: myStream.stream,
            builder: (context, snapshot) {
              print("Rebulding stream builder");
              DrawingController controller;
              bool readonly = true;
              String drawingUser;
              var data = snapshot.data;
              if (data["id"] == global.key) readonly = false;
              controller =
                  new DrawingController(enableChunk: true, readonly: readonly);
              controller.onChunk().listen((chunk) {
                print("Sending chunk");
                FirestoreService.sendData(
                    global.roomid, controller.draw.toJson());
                drawingUser = data["name"];
                if (snapshot.data != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Countdown(
                            seconds: 80,
                            build: (BuildContext context, double time) =>
                                Text(time.toString()),
                            interval: Duration(milliseconds: 100),
                            onFinished: () async {
                              await FirestoreService.nextChance();
                              //Now Rebuild this widget
                              await addToStream();
                            },
                          ),
                          //Show a 100 second timer and username
                        ),
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
                  );
                } else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              });
            }));
  }
}
