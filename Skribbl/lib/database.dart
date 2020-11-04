import 'package:firebase_core/firebase_core.dart';
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
    print("COming to create room");
    var path = _db.collection('rooms').doc();
    path.set({"height": 176, "width": 360, "lines": []});
    print(path.id.toString());
    return path.id.toString();
  }

  static sendMessege(room_id, name, value) {
    _db.collection("rooms").doc(room_id).collection("messages").add({
      "name":name,
      "time":DateTime.now(),
      "value":value
    });
  }

  static getMessages(room_id) {
    _db
        .collection("rooms")
        .doc(room_id)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }
}
