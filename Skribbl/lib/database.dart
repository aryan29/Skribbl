import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart' as global;

class FirestoreService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  //Send Data
  static sendData(id, file) async {
    await _db.collection('rooms').doc(id).update({"value": file});
  }

  //Get Data
  static getData(id) {
    Stream collectionStream = _db.collection('rooms').doc(id).snapshots();
    return collectionStream;
  }

  static createRoom(name) async {
    //Creating Room
    print("Coming to create room");
    var path = _db.collection('rooms').doc();
    await path.set({
      "value": {
        "height": 176,
        "width": 360,
        "lines": [],
      },
      "user_id": [],
      "current": 0
    });
    print(path.id.toString());
    await addUserInRoom(path.id.toString(), name);
    return path.id.toString();
    //And add this user to this room with score 0
  }

  static Future<int> addUserInRoom(roomId, name) async {
    print("Coming to add in room");
    var z = await _db.collection('rooms').doc(roomId).get().then((doc) async {
      if (doc.exists) {
        //Add this user in room and also add this to user_id
        var snap = await _db.collection("rooms").doc(roomId).get();
        List li = snap.data()['users_id'];
        if (li.length != 0) {
          li.add(li.last + 1);
          global.key = li.last + 1;
        } else {
          li.add(1);
          global.key = 1;
        }

        var d = await _db.collection("rooms").doc(roomId).get();
        await _db
            .collection('rooms')
            .doc(roomId)
            .collection("users")
            .doc(global.key.toString())
            .set({"name": name, "score": 0, "entrytime": DateTime.now()});

        return 1;
      } else {
        print("here");
        return 0;
      }
    });
    return z;
  }

  static removeUser(roomId, name) async {
    var snap = await _db.collection("rooms").doc(roomId).get();
    var data = snap.data();
    data['users_id'].remove(global.key);
    _db.collection("rooms").doc(roomId).set(data, SetOptions(merge: true));
    //Delete the document from users
    await _db
        .collection("rooms")
        .doc(roomId)
        .collection("users")
        .doc(global.key.toString())
        .delete();
  }

  static nextChance() async {
    //Having a next chance will also decide on which user whiteboard
    //will be editale and word will be shown
    var snap = await _db.collection("rooms").doc(global.roomid).get();
    var data = snap.data();
    data['current'] += 1;
    _db
        .collection("rooms")
        .doc(global.roomid)
        .set(data, SetOptions(merge: true));
  }

  static getCurrentData() async {
    var snap = await _db.collection("rooms").doc(global.roomid).get();
    var data = snap.data();
    return data['users_id']['current'];
  }

  static sendMessege(roomId, name, value) async {
    print("Coming to send Message");
    await _db
        .collection("rooms")
        .doc(roomId)
        .collection("messages")
        .add({"name": name, "time": DateTime.now(), "value": value});
  }

  static getMessages(roomId) {
    return _db
        .collection("rooms")
        .doc(roomId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  static getUsersInRoom(roomid) {
    print(roomid);
    return _db
        .collection("rooms")
        .doc(roomid)
        .collection("users")
        .orderBy("entrytime", descending: true)
        .snapshots();
  }
}
