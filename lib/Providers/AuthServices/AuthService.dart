import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../NotificationServices/NotificationServices.dart';

class User {
  User({@required this.uid});

  final String uid;
}

abstract class AuthBase {
  Stream<User> get onAuthStateChanged;

  Future<String> signUp(String name);
}

class Auth implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(
      uid: user.uid,
    );
  }

  @override
  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  @override
  Future<String> signUp(String userName) async {
    String errorMessage;
    try {
      final authResult = await _firebaseAuth.signInAnonymously();
      await authResult.user.reload();
      final FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
      final QuerySnapshot querySnapshot = await Firestore.instance
          .collection('users')
          .where('displayName', isEqualTo: userName)
          .getDocuments();
      final List<DocumentSnapshot> docs = querySnapshot.documents;
      if (docs.length < 1) {
        await Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'displayName': userName,
          'profilePicUrl': "path to your default image",
          'chats': [],
          'onlineStatus':"online"
        });
        NotificationService();
        firebaseUser.reload();
      }
    } catch (exception) {
      errorMessage = exception.toString();
    }
    return errorMessage;
  }
}
