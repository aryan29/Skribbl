import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  //Send Data
  static sendData(id, file) {
    var data = _db
        .collection('rooms')
        .doc('3owUHLDLWyrhKLxhvWi6')
        .collection('drawing')
        .doc(id.toString())
        .set(file);
  }

  //Get Data
  static getData() {
    Stream collectionStream = _db
        .collection('rooms')
        .doc('3owUHLDLWyrhKLxhvWi6')
        .collection('drawing')
        .snapshots();
    return collectionStream;
  }
}
