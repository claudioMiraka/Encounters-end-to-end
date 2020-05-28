import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../GlobalVariables.dart' as globals;

class NotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationDetails platformChannelSpecifics;

  NotificationService() {
    saveDeviceToken();
    initializeNotification();
    registerNotification();
  }

  registerNotification() async {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        return;
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        return;
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        return;
      },
    );
  }

  initializeNotification() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.Encounters.v0',
      'Encounters',
      'Messaging App',
      importance: Importance.Max,
      channelShowBadge: true,
      playSound: true,
      enableVibration: true,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    print("selected: " + payload);
  }

//  showPushNotification(Map<String, dynamic> message) async {
//    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
//        message['body'].toString(), platformChannelSpecifics,
//        payload: json.encode(message));
//  }

  saveDeviceToken() async {
    final String fcmToken = await fcm.getToken();
    Firestore.instance
        .collection("users")
        .document(globals.userId)
        .updateData({'deviceToken': fcmToken});
    print("device token: " + fcmToken);
  }
}
