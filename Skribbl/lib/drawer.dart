import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'global.dart' as global;
import 'database.dart';

class ChatDrawer extends StatefulWidget {
  ChatDrawer({Key key}) : super(key: key);
  @override
  _ChatDrawerState createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer>{
  var myMessageController = new TextEditingController();

  buildItem(data) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        // height: 50,
        padding: EdgeInsets.all(5),
        width: 200,
        decoration: BoxDecoration(
            color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
        //color: Colors.cyan[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              data["name"],
              style: TextStyle(
                  color: Colors.blue[900], fontWeight: FontWeight.w700),
            ),
            Text(
              data["value"],
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    double ht = MediaQuery.of(context).size.height;
    print(bottom);
    return Stack(
      children: <Widget>[
        Positioned(
          top: ht / 8,
          child: Container(
            height: 7 * ht / 8,
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                //shrinkWrap: true,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: 300,
                      //Chat Box
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          // 1st for showing messages
                          // 2nd for entering message
                          Container(
                            height: ht * 7 / 8 - 50,
                            margin: EdgeInsets.all(0),
                            color: Colors.white,
                            child: StreamBuilder(
                              stream:
                                  FirestoreService.getMessages(global.roomid),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  print(snapshot.data.documents.length);
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (context, index) => buildItem(
                                        snapshot.data.documents[index]),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                          Container(
                            height: 50,
                            child: TextField(
                              controller: myMessageController,
                              autofocus: false,
                              decoration: InputDecoration(
                                  hintText: "Type here",
                                  filled: true,
                                  fillColor: Colors.white,
                                  hoverColor: Colors.pink,
                                  suffixIcon: IconButton(
                                      icon: Icon(Icons.play_arrow),
                                      onPressed: () {
                                        print("Button pressed");
                                        //Function to send message from this user and add it to database
                                        //And show it on screen of every other user too at the same time
                                        FirestoreService.sendMessege(
                                            global.roomid,
                                            global.name,
                                            myMessageController.text);
                                        FocusScope.of(context).unfocus();
                                        Future.delayed(
                                            Duration(microseconds: 500), () {
                                          //call back after 500  microseconds
                                          myMessageController
                                              .clear(); // clear textfield
                                        });
                                      })),
                            ),
                          )
                        ],
                      )),
                  SizedBox(height: bottom),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
              height: ht / 8.0,
              width: 300,
              color: Colors.purple[100],
              child: Center(
                  child: Text("CHAT",
                      style: GoogleFonts.rockSalt(
                          color: Colors.purple[900],
                          fontSize: 20,
                          fontWeight: FontWeight.bold)))),
        ),
      ],
    );
  }
}

class UsersDrawer extends StatefulWidget {
  UsersDrawer({Key key}) : super(key: key);

  @override
  _UsersDrawerState createState() => _UsersDrawerState();
}

class _UsersDrawerState extends State<UsersDrawer> {
  customizeUserName(var x) {
    return Align(
        alignment: Alignment.center,
        child: Container(
            width: 250,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.purple[400], Colors.pink[400]]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.pink, width: 4)),
            // color: Colors.deepPurpleAccent[100],
            child: Column(
              children: <Widget>[
                Text(
                  x["name"],
                  style: GoogleFonts.alatsi(fontSize: 15, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(x["score"].toString(),
                    style: GoogleFonts.adamina(
                        fontSize: 12, color: Colors.pink[50])),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 20),
      color: Colors.white,
      child: StreamBuilder(
          stream: FirestoreService.getUsersInRoom(global.roomid),
          builder: (context, snapshot) {
            print(snapshot.data.documents.length);
            if (snapshot.data != null) {
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) =>
                      customizeUserName(snapshot.data.documents[index]));
            } else
              return Container(
                  child: Center(child: CircularProgressIndicator()));
          }),
    );
  }
}
