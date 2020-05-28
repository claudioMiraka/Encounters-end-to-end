import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/EncounterUser.dart';
import '../../GlobalVariables.dart' as globals;

class UserServices {
  static void saveUserLocally(DocumentSnapshot documentSnapshot) async {
    final prefs = await SharedPreferences.getInstance();
    EncounterUser user = EncounterUser.formFirestore(documentSnapshot);
    prefs.setString('user', json.encode(user.toJson()));
    prefs.setString('userId', documentSnapshot.documentID);
  }

  static Future<EncounterUser> getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    return EncounterUser.fromJson(json.decode(prefs.getString('user')));
  }

  static setUserOnline() async {
    await Firestore.instance
        .collection('users')
        .document(globals.userId)
        .updateData({'onlineStatus': "online"});
  }

  static setUserLastAccess() async {
    String timeNow = DateTime.now().millisecondsSinceEpoch.toString();
    await Firestore.instance
        .collection('users')
        .document(globals.userId)
        .updateData({'onlineStatus': timeNow});
  }
}
