import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  //Send Data
  static sendData(id, file) {
    _db.collection('rooms').doc(id).set(file);
  }

  //Get Data
  static getData(id) {
    Stream collectionStream = _db.collection('rooms').doc(id).snapshots();
    return collectionStream;
  }

  static createRoom() {
    //Creating Room
    print("COming to create room");
    var path = _db.collection('rooms').doc();
    path.set({"height": 176, "width": 360, "lines": []});
    print(path.id.toString());
    return path.id.toString();
    //And add this user to this room with score 0
  }

  static addUserRoom(roomId) {
    print("Coming to add in room");
    _db
        .collection('rooms')
        .doc(roomId)
        .collection("users")
        .add({"name": "Aryan", "score": 0});
  }

  static sendMessege(roomId, name, value) {
    print("Coming to send Message");
    _db
        .collection("rooms")
        .doc(roomId)
        .collection("messages")
        .add({"name": name, "time": DateTime.now(), "value": value});
  }

  static getMessages(roomId) {
    Stream s = _db
        .collection("rooms")
        .doc(roomId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
    return s;
  }
}
