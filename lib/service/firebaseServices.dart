import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';

class firebaseServices with ChangeNotifier {
  String username = '';
  late String email;
  late String useruid;
  late DateTime sentat;
  late QuerySnapshot<Map<String, dynamic>> res;

  void getusercredentials() async {
    await FirebaseFirestore.instance
        .collection('usersdata')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      username = value.docs.first.data()['username'];
    });
  }

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

  Future<Map<String, int>> getRooms() async {
    //Looking for rooms with single user
    Map<String, int> roomlink_roomcount = {};
    String roomlink = "";
    int roomcount = 0;

    res = await FirebaseFirestore.instance
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
    //buggy
    //transaction
    var docref = res.docs.first.reference;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      var snapshot = await transaction.get(docref);

      if (!snapshot.exists) {
        print('doc not exist');
      }
      if (snapshot.data()!['users'] == 2) {
        //get new room
        print('room size exceeds');
        roomcount = 3;
        roomlink = '';
      }
      if (snapshot.data()!['users'] == 0 || snapshot.data()!['users'] == 1) {
        transaction.update(docref, {
          'users': FieldValue.increment(1),
          'usermails${snapshot.data()!['users'].toString()}': {
            FirebaseAuth.instance.currentUser!.email:
                FirebaseAuth.instance.currentUser!.uid
          },
        });
        roomcount = 1 + snapshot.data()!['users'] as int;
        roomlink = snapshot.data()!['roomlink'] as String;
      }
    }).then((value) {
      //   res.docs.first.data().forEach((key, value) {
      //   if (key == 'roomlink') {
      //     roomlink = value;
      //    // return value;
      //   }
      //   if (key == 'users') {
      //     roomcount = value ;
      //   }
      // });

      print('success');
      print(roomlink);
      print(roomcount);
    });
    print(roomlink);
    print(roomcount);

    // await FirebaseFirestore.instance
    //     .collection('rooms')
    //     .doc(res.docs[0].id)
    //     .update({'users': FieldValue.increment(1)});

    // res.docs.first.data().forEach((key, value) {
    //   if (key == 'roomlink') {
    //     roomlink = value;
    //     return value;
    //   }
    //   if (key == 'users') {
    //     roomcount = value + 1;
    //   }
    // });

    // await FirebaseFirestore.instance
    //     .collection('rooms')
    //     .doc(res.docs[0].id)
    //     .update({
    //   'usermails${roomcount.toString()}': {
    //     FirebaseAuth.instance.currentUser!.email:
    //         FirebaseAuth.instance.currentUser!.uid
    //   },
    // });

    roomlink_roomcount.addAll({roomlink: roomcount});

    notifyListeners();
    return roomlink_roomcount;
  }

  Future<void> leaveRoom() async {
    print(res.docs[0].id);
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(res.docs[0].id)
        .update({'users': FieldValue.increment(-2)});

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(res.docs[0].id)
        .update({'usermails': FieldValue.delete()});
  }

  void decrementroom() async {
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(res.docs[0].id)
        .update({'users': FieldValue.increment(-1)});
  }

  Future<String> fetchusermail() async {
    String useruid = '';
    var doc = await FirebaseFirestore.instance
        .collection('rooms')
        .doc(res.docs[0].id)
        .get();

    doc.data()!.forEach((key, value) {
      print(key.toString());
      if (key.contains('usermail')) {
        Map<String, dynamic> data = value;
        data.forEach((key, value) {
          if (value != FirebaseAuth.instance.currentUser!.uid) {
            useruid = value;

            print(useruid);
            return;
          }
        });
      }
    });
    return useruid;
  }

  void sendfriendrequest() async {
    String useruid = await fetchusermail();
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(useruid)
        .collection('requests')
        .add({
      'username': 'stranger' + Random().nextInt(1000).toString(),
      'uid': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  Future<bool> acceptfriendrequest(String peeruid, String peerusername) async {
    //check if user already your friend
    var check = await FirebaseFirestore.instance
        .collection('friends')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friendlist')
        .where('uid', isEqualTo: peeruid)
        .get();

    if (check.docs.isNotEmpty) {
      print('already friend');
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('requests')
          .where('uid', isEqualTo: peeruid)
          .get()
          .then((value) {
        value.docs.first.reference.delete();
      });

      return false;
    }
    // var check2 = await FirebaseFirestore.instance
    //     .collection('friends')
    //     .doc(peeruid)
    //     .collection('friendlist')
    //     .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //     .get();

    // if (check2.docs.isNotEmpty) {
    //   print('iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
    //   await FirebaseFirestore.instance
    //       .collection('requests')
    //       .doc(peeruid)
    //       .collection('requests')
    //       .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //       .get()
    //       .then((value) {
    //     value.docs.first.reference.delete();
    //   });
    //   return false;
    // }
    //adding to both friend friends list AND making unique chat path for both\\
    var docref = await FirebaseFirestore.instance
        .collection('friends')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    //await FirebaseFirestore.instance.runTransaction((transaction) async {});

    //
    Timestamp currenttime = Timestamp.now();
    var chatuid = const Uuid().v4();

    await FirebaseFirestore.instance
        .collection('friends')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friendlist')
        .add({
      'username': peerusername,
      'uid': peeruid,
      'becamefriendsat': currenttime,
      'chatuid': chatuid
    });

    await FirebaseFirestore.instance
        .collection('friends')
        .doc(peeruid)
        .collection('friendlist')
        .add({
      'username': peerusername,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'becamefriendsat': currenttime,
      'chatuid': chatuid
    });

    // deleting request
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('requests')
        .where('uid', isEqualTo: peeruid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
    });
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(peeruid)
        .collection('requests')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
    });
    // //making unique chat path for both
    // var chatuid = const Uuid().v4();

    // var user1 = await FirebaseFirestore.instance
    //     .collection('friends')
    //     .doc(FirebaseAuth.instance.currentUser!.uid)
    //     .collection('friendlist')
    //     .where('username', isEqualTo: peeremail)
    //     .get();
    // user1.docs.first.reference.update({'chatuid': chatuid});
    // var user2 = await FirebaseFirestore.instance
    //     .collection('friends')
    //     .doc(peeruid)
    //     .collection('friendlist')
    //     .where('username', isEqualTo: FirebaseAuth.instance.currentUser!.email)
    //     .get();
    // user2.docs.first.reference.update({'chatuid': chatuid});

    //chat status
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatuid)
        .collection('istyping')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'istyping': false,
      'useruid': FirebaseAuth.instance.currentUser!.uid
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatuid)
        .collection('istyping')
        .doc(peeruid)
        .set({'istyping': false, 'useruid': peeruid});

    //storing friend to local storage
    //  Map<String,String>
    // Hive.box('friendlist').add({
    //   'email': peeremail,
    //   'chatuid': chatuid,
    //   'uid': peeruid,
    // });

    var temp = await FirebaseFirestore.instance
        .collection('friends')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friendlist')
        .where('uid', isEqualTo: peeruid)
        .get();
    int i = 0;
    if (temp.docs.length > 1) {
      temp.docs.forEach((element) {
        if (i == 1) {
          element.reference.delete().whenComplete(() {
            print('duplicate request deleted');
          });
        }
        i++;
      });
    }
    return true;
  }

  Future<String> getchatuid(String peeremail) async {
    var user = await FirebaseFirestore.instance
        .collection('friends')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friendlist')
        .where('username', isEqualTo: peeremail)
        .get();
    String res = user.docs.first.data()['chatuid'];
    print(res);
    return res;
  }

  Future<void> sendmessage(
    String message,
    String author,
    String usermail,
    String useruid,
    String chatuid,
  ) async {
    final timestamp = Timestamp.now();
    sentat = timestamp.toDate();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatuid)
        .collection('chats')
        .add({
      'text': message,
      'author': author,
      'createdat': timestamp,
      'isreceived': false
    });
  }

  void filestracker(String peermail, String peeruid, String filename,
      String filetype, String downloadurl, String chatuid) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatuid)
        .collection('files')
        .add({
      'name': filename,
      'type': filetype,
      'createdat': Timestamp.now(),
      'author': FirebaseAuth.instance.currentUser!.email,
      'downloadurl': downloadurl
    });
  }

  Future<bool> setTypingStatus(bool status, String chatuid) async {
    print(chatuid);
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatuid)
        .collection('istyping')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'istyping': status});
    return true;
  }

  void removefriend(String peeruid, String chatuid) async {
    print(peeruid);

    //deleting locally
    await Hive.box(chatuid).deleteFromDisk().whenComplete(() {
      print('chat  deleted');
    });
    int boxlength = Hive.box('friendlist').length;

    for (int i = 0; i < boxlength; i++) {
      if (Hive.box('friendlist').getAt(i)['chatuid'] == chatuid) {
        Hive.box('friendlist').deleteAt(i);
        print('box deleted');
        break;
      }
    }
    //deleting from cloud firestore
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friendlist')
        .where('uid', isEqualTo: peeruid)
        .get()
        .then((value) async {
      await value.docs.first.reference.delete().whenComplete(() {
        print('friend removed');
      });
    });
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatuid)
        .collection('chats')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
    });
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatuid)
        .collection('istyping')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
    });
  }
}
