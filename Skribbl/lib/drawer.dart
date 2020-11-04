import 'package:flutter/material.dart';
import 'global.dart' as global;
import 'database.dart';

class ChatDrawer extends StatefulWidget {
  @override
  _ChatDrawerState createState() => _ChatDrawerState();
}

var myMessageController = new TextEditingController();

class _ChatDrawerState extends State<ChatDrawer> {
  buildItem(data) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        // height: 50,
        padding: EdgeInsets.all(5),
        width: 200,
        decoration: BoxDecoration(
            color: Colors.cyan[50], borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
        //color: Colors.cyan[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              data["name"],
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
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
                  Container(
                    height: 7 * ht / 8.0 - 50,
                    margin: EdgeInsets.all(0),
                    color: Colors.black,
                    child: StreamBuilder(
                      stream: FirestoreService.getMessages(global.roomid),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          print(snapshot.data.documents.length);
                          return ListView.builder(
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) =>
                                buildItem(snapshot.data.documents[index]),
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
                      autofocus: true,
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
                                FirestoreService.sendMessege(global.roomid,
                                    global.name, myMessageController.text);
                                myMessageController.clear();
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
