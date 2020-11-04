import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboardkit.dart';
import 'database.dart';
import 'drawer.dart';
import 'global.dart' as global;
import 'start_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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
      FirestoreService.sendData(global.roomid, widget.controller.draw.toJson());
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
                String x = FirestoreService.createRoom(global.name);
                //New room creating and joining
                setState(() {
                  widget.controller.wipe();
                  global.roomid = x;
                });
              },
            ),
            Expanded(
                child: StreamBuilder(
                    stream: FirestoreService.getData(global.roomid),
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
