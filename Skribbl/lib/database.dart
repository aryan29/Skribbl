import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  //Send Data
  static sendData(id, file) {
    var data = _db.collection('rooms').doc(id).set(file);
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
}
