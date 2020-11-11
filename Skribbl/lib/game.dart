import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:whiteboardkit/whiteboardkit.dart';
import 'database.dart';
import 'drawer.dart';
import 'global.dart' as global;
import 'start_game.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:english_words/english_words.dart';
import "dart:math";
import 'package:share/share.dart';

class MyGame extends StatefulWidget {
  MyGame({Key key}) : super(key: key);

  @override
  _MyGame createState() => _MyGame();
}

StreamController<Map<String, dynamic>> myStream;
DrawingController controller;
bool readonly = true;
String drawingUser;
int time = 50;

class _MyGame extends State<MyGame> with WidgetsBindingObserver {
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  @override
  void initState() {
    print("Coming to init state");
    WidgetsBinding.instance.addObserver(this);
    myStream = new StreamController();
    super.initState();
  }

  addToStream() async {
    print("Coming to add in stream");
    var x = await FirestoreService.getCurrentData();
    global.current = x["id"];
    myStream.sink.add(x);
  }

  @override
  Widget build(BuildContext context) {
    CountdownController c = new CountdownController();
    print("Coming to build");

    return Scaffold(
        resizeToAvoidBottomInset: false,
        // resizeToAvoidBottomPadding: false,
        appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.chat),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
            actions: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              ),
            ],
            title: Text(
              "Skribbl",
              style: GoogleFonts.pacifico(color: Colors.pink[50]),
            ),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(30))),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  colors: [Colors.purple, Colors.pink[200]],
                ),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(30)),
              ),

              // backgroundColor: Colors.purple[600],
            )),
        drawer: ChatDrawer(),
        endDrawer: UsersDrawer(),
        body: StreamBuilder(
            //initialData: {"id": 1, "name": "Buddy5455"},
            stream: myStream.stream,
            builder: (context, snapshot) {
              // print("Variables initialized");
              if (snapshot.data != null) {
                print(c.isCompleted);
                if (c.isCompleted == null || c.isCompleted == true) {
                  print("Rebulding stream builder");
                  var data = snapshot.data;
                  if (data["id"] == global.key)
                    readonly = false;
                  else
                    readonly = true;
                  print("Readonly set to " + readonly.toString());
                  controller = new DrawingController(
                      enableChunk: true, readonly: readonly);

                  controller.onChunk().listen((chunk) {
                    print("Sending chunk");
                    FirestoreService.sendData(
                        global.roomid, controller.draw.toJson());
                  });
                  drawingUser = data["name"];
                  c.restart();
                  print(drawingUser);
                }
                return Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Countdown(
                            controller: c,
                            seconds: time,
                            build: (BuildContext context, double time) =>
                                Text(time.toString()),
                            interval: Duration(milliseconds: 100),
                            onFinished: () async {
                              //Now Rebuild this widget

                              if (readonly == false) {
                                print("Wiping from here");
                                controller.streamController
                                    .add(WhiteboardDraw.fromJson({
                                  "height": 176,
                                  "width": 360,
                                  "lines": [],
                                }));
                                controller.wipe();

                                controller.streamController.close();
                                FirestoreService.nextChance().then((val) async {
                                  var x = await addToStream();
                                  return x;
                                });
                              }
                            },
                          ),
                          //Show a 100 second timer and username
                        ),
                        Container(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                //Name of person
                                //Name of word
                                Container(
                                  child: Text(
                                    drawingUser,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (readonly == false)
                                  Container(child: Text(global.random_word)),
                              ],
                            )),
                        Expanded(
                            child: StreamBuilder(
                                stream: FirestoreService.getData(global.roomid),
                                builder:
                                    (BuildContext builder, AsyncSnapshot snap) {
                                  print("Rebuilding whiteboard");
                                  if (snap.data != null) {
                                    var z = snap.data.data();
                                    if (global.current !=
                                        z["users_id"][z["current"]]) {
                                      c.isCompleted = true;
                                      FirestoreService.getCurrentData()
                                          .then((val) {
                                        global.current =
                                            z["users_id"][z["current"]];
                                        myStream.sink.add(val);
                                      });
                                    }
                                    if (controller.streamController.isClosed ==
                                        false) {
                                      controller.streamController.add(
                                          WhiteboardDraw.fromJson(z['value']));
                                    }
                                    return Whiteboard(controller: controller);
                                  } else
                                    return Whiteboard(controller: controller);
                                })),
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
                                  onPressed: () async {
                                    String link =
                                        await FirestoreService.createDeppLink(
                                            global.roomid);
                                    Share.share(
                                        "Hey lets play together join us on $link",
                                        subject: "Let's Play Together");
                                  },
                                  icon: Icon(Icons.share),
                                  label: Text("Invite")),
                            ),
                            SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width / 2.0,
                              child: FlatButton.icon(
                                  textColor: Colors.white,
                                  color: Colors.red,
                                  onPressed: () async {
                                    FirestoreService.removeUser(global.roomid);
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.delete),
                                  label: Text("Leave")),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              } else {
                //Add something to stream
                addToStream();
                return Container(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            }));
  }
}
