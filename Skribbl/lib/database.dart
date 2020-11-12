import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'global.dart' as global;
import 'package:english_words/english_words.dart';
import "dart:math";
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class FirestoreService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;
  static Random random = new Random();
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

    String word = nouns[random.nextInt(nouns.length)];

    print("Coming to create room");
    print("Word is " + word);
    var path = _db.collection('rooms').doc();
    await path.set({
      "value": {
        "height": 176,
        "width": 360,
        "lines": [],
      },
      "users_id": [],
      "current": 0,
      "word": word
    });
    print(path.id.toString());
    await addUserInRoom(path.id.toString(), name);
    return path.id.toString();
    //And add this user to this room with score 0
  }

  static Future<int> addUserInRoom(roomId, name) async {
    print(roomId);
    print(name);
    print("Coming to add in room");
    var z = await _db.collection('rooms').doc(roomId).get().then((doc) async {
      if (doc.exists) {
        //Add this user in room and also add this to user_id
        var snap = await _db.collection("rooms").doc(roomId).get();
        List li = snap.data()['users_id'];
        if (li != null && li.length != 0) {
          li.add(li.last + 1);
          global.key = li.last;
        } else {
          li = [1];
          global.key = 1;
        }
        global.current = li[snap.data()['current']];
        await _db.collection("rooms").doc(roomId).update({"users_id": li});
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

  static removeUser(roomId) async {
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
    //Run it if called from creator only
    String word = nouns[random.nextInt(nouns.length)];
    print("Word is " + word);
    await _db
        .collection('rooms')
        .doc(global.roomid)
        .update({"value.lines": [], "word": word}).then((value) async {
      var snap = await _db.collection("rooms").doc(global.roomid).get();
      var data = snap.data();
      data['current'] += 1;
      if (data['current'] >= data['users_id'].length) data['current'] = 0;
      await _db
          .collection("rooms")
          .doc(global.roomid)
          .set(data, SetOptions(merge: true));
    });
  }

  static getCurrentData() async {
    print("Coming to getData");
    var snap = await _db.collection("rooms").doc(global.roomid).get();
    var data = snap.data();
    global.random_word = data["word"];
    String userid = data['users_id'][data['current']].toString();
    var snap2 = await _db
        .collection("rooms")
        .doc(global.roomid)
        .collection("users")
        .doc(userid)
        .get();
    var data2 = snap2.data();

    print(data);
    print(data2);
    return Map<String, dynamic>.from(
        {"id": data['users_id'][data['current']], "name": data2['name']});
  }

  static sendMessege(roomId, name, value) async {
    print("Coming to send Message");
    if (value != global.random_word) {
      await _db
          .collection("rooms")
          .doc(roomId)
          .collection("messages")
          .add({"name": name, "time": DateTime.now(), "value": value});
    } else {
      await _db
          .collection("rooms")
          .doc(roomId)
          .collection("users")
          .doc(global.key.toString())
          .update({"score": FieldValue.increment(1)});
    }
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

  static Future<String> createDeppLink(String id) async {
    String prefix = "https://skribbll.page.link";
    final DynamicLinkParameters par = DynamicLinkParameters(
      uriPrefix: prefix,
      link: Uri.parse("https://skribbll.page.link/room?id=$id"),
      androidParameters:
          AndroidParameters(packageName: "com.skribbl.game", minimumVersion: 0),
      iosParameters: IosParameters(
        bundleId: 'com.skribbl.game',
        minimumVersion: '1',
        appStoreId: '',
      ),
    );
    final Uri dynamicUrl = await par.buildUrl();

    print(dynamicUrl);
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(
      dynamicUrl,
      DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );
    print(shortenedLink.shortUrl);
    String url = shortenedLink.shortUrl.toString();
    return url;
  }

  static Future handleDynamicLinks() async {
    print("Coming to handle dynamic links");
    await Future.delayed(Duration(seconds: 15));
    var value = await FirebaseDynamicLinks.instance.getInitialLink();
    var x = handleDeepLinkData(value);
    print(x);
    // FirebaseDynamicLinks.instance.onLink(onSuccess: (dynamicLink) async {
    //   var x = handleDeepLinkData(dynamicLink);
    //   print("Inside listener");
    //   return x;
    // }, onError: (e) async {
    //   debugPrint('DynamicLinks onError $e');
    // });
    return x;
  }

  static handleDeepLinkData(PendingDynamicLinkData data) {
    print("Coming to handle deep link data");
    print(data);

    if (data == null) return null;
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      print(deepLink);
      if (deepLink.path.contains("room")) {
        print(deepLink.queryParametersAll);
        print(deepLink.queryParameters['id']);
        return deepLink.queryParameters['id'];
      }
    }
  }
}
//ux7Vh79cpAye2n2Sxl3m
//ux7Vh9cpAye2n2Sxl3m
//i9ikeSC0YUkAIkaOsC6p
//https://skribbll.page.link/?link=https://skribbll.page.link&apn=com.skribbl.game&id=7
