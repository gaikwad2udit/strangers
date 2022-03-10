import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobx/mobx.dart';

class firebaseServices with ChangeNotifier {
  late QuerySnapshot<Map<String, dynamic>> res;

  Future<String> getmeetinglink() async {
    var res = await FirebaseFirestore.instance.collection('rooms').get();
    String roomlink = '';

    res.docs.first.data().forEach((key, value) {
      if (key == 'roomlink') {
        roomlink = value;
        return value;
      }
    });
    notifyListeners();
    return roomlink;
  }

  Future<String> getRooms() async {
    //Looking for rooms with single user
    String roomlink = '';
    var res = await FirebaseFirestore.instance
        .collection('rooms')
        .where('users', isEqualTo: 1)
        .limit(1)
        .get();
    //Looking for empty rooms
    if (res.docs.isEmpty) {
      res = await FirebaseFirestore.instance
          .collection('rooms')
          .where('users', isEqualTo: 0)
          .limit(1)
          .get();
    }
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(res.docs[0].id)
        .update({'users': FieldValue.increment(1)});

    res.docs.first.data().forEach((key, value) {
      if (key == 'roomlink') {
        roomlink = value;
        return value;
      }
    });
    return roomlink;
  }

  void leaveRoom() async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(res.docs[0].id)
        .update({'users': FieldValue.increment(-1)});
  }
}
