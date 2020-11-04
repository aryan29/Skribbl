import 'dart:math';

import 'package:flutter/material.dart';
import 'global.dart' as global;
import 'database.dart';

class StartScreen extends StatefulWidget {
  StartScreen({Key key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

TextEditingController myController = new TextEditingController();
bool error = false;

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    // TODO: implement initState
    myController.text = "Buddy" + Random(0).nextInt(10000).toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    validateName() {
      print(myController.text);
      return (myController.text == "");
    }

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                  width: 200,
                  child: TextField(
                    onChanged: (value) {
                      if (value == "")
                        setState(() {
                          error = true;
                        });
                      else
                        setState(() {
                          error = false;
                        });
                    },
                    controller: myController,
                    decoration: InputDecoration(
                      errorText: error ? "Name can't be empty" : null,
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Name",
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.green)),
                    ),
                  )),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {},
                      child: Text("Create Room"),
                      color: Colors.blueGrey[100],
                    ),
                    FlatButton(
                        onPressed: () {},
                        child: Text("Join Room"),
                        color: Colors.blueGrey[100])
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
