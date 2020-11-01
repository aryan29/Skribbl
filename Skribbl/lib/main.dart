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
    widget.controller = new DrawingController(enableChunk: true);
    var _chunkSubscription = widget.controller.onChunk().listen((chunk) {
      var js = chunk.toJson();
      FirestoreService.sendData(0, widget.controller.draw.toJson());
      widget.controller1.streamController
          .add(WhiteboardDraw.fromJson(widget.controller.draw.toJson()));
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
                  FirestoreService.sendData("5", "anything for now on");
                },
                child: Text("Send Data")),
            Expanded(
                child: StreamBuilder(
                    stream: FirestoreService.getData(),
                    builder: (BuildContext builder, AsyncSnapshot snap) {
                      print("Rebuilding this widget");
                      if (snap.data != null) {
                        print(snap.data.documents.length);
                        for (int i = 0; i < 1; i++) {
                          var z = Map<String, dynamic>.from(
                              snap.data.documents[i].data());
                          print(z);
                          widget.controller1.streamController
                              .add(WhiteboardDraw.fromJson(z));
                        }
                        //print(mp);

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
    widget.s.close();
    super.dispose();
  }
}
