import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  //Send Data
  static sendData(id, file) async {
    await _db.collection('rooms').doc(id).set(file);
  }

  //Get Data
  static getData(id) {
    Stream collectionStream = _db.collection('rooms').doc(id).snapshots();
    return collectionStream;
  }

  static createRoom(name) async {
    //Creating Room
    print("COming to create room");
    var path = _db.collection('rooms').doc();
    await path.set({"height": 176, "width": 360, "lines": []});
    print(path.id.toString());
    await addUserInRoom(path.id.toString(), name);
    return path.id.toString();
    //And add this user to this room with score 0
  }

  static Future<int> addUserInRoom(roomId, name) async {
    print("Coming to add in room");
    var z = await _db.collection('rooms').doc(roomId).get().then((doc) async {
      // print(doc.exists);
      if (doc.exists) {
        await _db
            .collection('rooms')
            .doc(roomId)
            .collection("users")
            .add({"name": name, "score": 0, "entrytime": DateTime.now()});
        return 1;
      } else {
        print("here");
        return 0;
      }
    });
    return z;
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
