import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  //Send Data
  static sendData() {
    var data = _db
        .collection('rooms')
        .doc('PKsj399FDmRnc4CfDZiG')
        .set({"document": "okkk"});
  }

  //Get Data
  static getData() {
    Stream collectionStream =
        _db.collection('rooms').doc('PKsj399FDmRnc4CfDZiG').snapshots();
  }
}
