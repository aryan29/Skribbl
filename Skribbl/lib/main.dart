import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboardkit.dart';
import 'database.dart';

String roomid = "3owUHLDLWyrhKLxhvWi6";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  DrawingController controller, controller1;
  PlaybackController controller2;
  MyHomePage(
      {Key key,
      this.title,
      this.controller,
      this.controller1,
      this.controller2})
      : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    widget.controller = new DrawingController(enableChunk: true);

    var _chunkSubscription = widget.controller.onChunk().listen((chunk) {
      //var js = chunk.toJson();
      FirestoreService.sendData(roomid, widget.controller.draw.toJson());
    });

    widget.controller1 =
        new DrawingController(enableChunk: true, readonly: true);
  }

  @override
  Widget build(BuildContext context) {
    print("Coming to build");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: ChatDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Whiteboard(
                controller: widget.controller,
              ),
            ),
            FlatButton(
              child: Text("Create New Room and Join it"),
              onPressed: () {
                String x = FirestoreService.createRoom();
                //New room creating and joining
                setState(() {
                  widget.controller.wipe();
                  roomid = x;
                });
              },
            ),
            Expanded(
                child: StreamBuilder(
                    stream: FirestoreService.getData(roomid),
                    builder: (BuildContext builder, AsyncSnapshot snap) {
                      print("Rebuilding this widget");
                      if (snap.data != null) {
                        var z = snap.data.data();
                        widget.controller1.streamController
                            .add(WhiteboardDraw.fromJson(z));
                        return Whiteboard(controller: widget.controller1);
                      } else
                        return Whiteboard(controller: widget.controller1);
                    })),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.close();
    widget.controller1.close();
    super.dispose();
  }
}

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
                                FirestoreService.sendMessege(roomid, "Aryan",
                                    "Hey there buddy whats up");
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
