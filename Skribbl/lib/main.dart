import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whiteboardkit/whiteboardkit.dart';
import 'database.dart';

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
  StreamController s;
  MyHomePage(
      {Key key,
      this.title,
      this.controller,
      this.controller1,
      this.s,
      this.controller2})
      : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    widget.s = new StreamController();
    widget.controller = new DrawingController();

    var _chunkSubscription = widget.controller.onChange().listen((chunk) {
      widget.controller1.streamController
          .add(widget.controller.draw.copyWith());
    });
    widget.controller1 = new DrawingController(enableChunk: true);
  }

  @override
  Widget build(BuildContext context) {
    print("Coming to build");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
                onPressed: () {
                  FirestoreService.sendData();
                },
                child: Text("Send Data"))
            // Expanded(
            //     child: StreamBuilder(
            //         stream: widget.s.stream,
            //         builder: (BuildContext builder, AsyncSnapshot snap) {
            //           print("Rebuilding this widget");
            //           if (snap.data != null) {
            //             return Whiteboard(controller: widget.controller1);
            //           } else
            //             return Whiteboard(controller: widget.controller1);
            //         })),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.close();
    widget.controller1.close();
    widget.s.close();
    super.dispose();
  }
}
