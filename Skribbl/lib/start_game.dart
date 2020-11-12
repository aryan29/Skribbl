import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:Skribbl/game.dart';
import 'package:flutter/material.dart';
import 'global.dart' as global;
import 'database.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StartScreen());
  }
}

class StartScreen extends StatefulWidget {
  StartScreen({Key key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

TextEditingController myController = new TextEditingController();
TextEditingController myController2 = new TextEditingController();
bool error = false;
var g = 1;

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    myController.text = "Buddy" + Random().nextInt(10000).toString();
    super.initState();
  }

  myFunction() async {
    print("myfunc start");
    var id = await FirestoreService.handleDynamicLinks();
    if (id != null) {
      print("Id is not null sending him somewhere");
      //Tell this person to join the room
      FirestoreService.addUserInRoom(id, "RandomLinkJoineee").then((value) {
        if (value == 1) {
          global.roomid = id;
          global.name = "RandomLinkJoineee";
          //Room Joined redirect to some other page
          Navigator.of(context).push(
              MaterialPageRoute(builder: (BuildContext context) => MyGame()));
        } else {
          g = 0;
        }
      });
    }
    print("Future Builder finish");
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFunction(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: Container(
                width: double.infinity,
                color: Colors.pink[50],
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                        top: 0,
                        child: Container(
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                          // width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: new LinearGradient(
                              colors: [Colors.purple, Colors.pink[200]],
                            ),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Skribbl",
                            style: GoogleFonts.pacifico(
                                fontSize: 40, color: Colors.pink[50]),
                          ),
                        )),
                    Positioned(
                      top: 200,
                      child: Flexible(
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
                                  style: TextStyle(color: Colors.pink[50]),
                                  decoration: InputDecoration(
                                    errorText:
                                        error ? "Name can't be empty" : null,
                                    filled: true,
                                    fillColor: Colors.purple[200],
                                    hintText: "Name",
                                    hintStyle:
                                        TextStyle(color: Colors.pink[900]),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                        borderSide:
                                            BorderSide(color: Colors.red)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0)),
                                        borderSide:
                                            BorderSide(color: Colors.green)),
                                  ),
                                )),
                            Container(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Container(
                                    width: 150,
                                    height: 50,
                                    child: RaisedButton(
                                      color: Colors.purple[200],
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 2,
                                              color: Colors.pink[200]),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      onPressed: () async {
                                        //  Create Room
                                        String roomId =
                                            await FirestoreService.createRoom(
                                                myController.text);
                                        global.roomid = roomId;
                                        global.name = myController.text;
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        MyGame()));
                                        //Romm created redirect to some other page
                                      },
                                      child: Text(
                                        "Create Game",
                                        style: GoogleFonts.architectsDaughter(
                                            color: Colors.pink[50]),
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    child: Text("trial"),

                                    onPressed: () async {
                                      
                                      String x = await FirestoreService
                                          .handleDynamicLinks();
                                      print(x);
                                    },
                                  ),
                                  SizedBox(height: 40),
                                  SizedBox(
                                    width: 150,
                                    //height: 50,
                                    child: TextField(
                                      controller: myController2,
                                      autofocus: false,
                                      style: TextStyle(color: Colors.pink[50]),
                                      decoration: InputDecoration(
                                        errorText:
                                            (g == 0) ? "Wrong Code" : null,
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0)),
                                            borderSide:
                                                BorderSide(color: Colors.red)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0)),
                                            borderSide: BorderSide(
                                                color: Colors.black)),
                                        hintText: "Enter code",
                                        hintStyle:
                                            TextStyle(color: Colors.pink[900]),
                                        filled: true,
                                        fillColor: Colors.purple[200],
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        suffixIcon: IconButton(
                                          icon:
                                              Icon(Icons.keyboard_arrow_right),
                                          onPressed: () {
                                            print("Button pressses");
                                            //Check if valid code
                                            FirestoreService.addUserInRoom(
                                                    myController2.text,
                                                    myController.text)
                                                .then((res) {
                                              if (res == 1) {
                                                global.roomid =
                                                    myController2.text;
                                                global.name = myController.text;
                                                //Room Joined redirect to some other page
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            MyGame()));
                                              }
                                              setState(() {
                                                g = res;
                                              });
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
