import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:line_icons/line_icons.dart';

import 'Providers/UserServices/UserServices.dart';
import 'Providers/ChatServices/ChatServices.dart';
import 'Screens/Profile/MyProfile.dart';
import 'Screens/Chat/ChatsList.dart';
import 'Screens/Chat/PendingChats.dart';
import 'GlobalVariables.dart' as global;
import 'Languages/Languages.dart';

class App extends StatefulWidget {
  final String uid;

  App({@required this.uid});

  @override
  _App createState() => _App();
}

class _App extends State<App> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      UserServices.setUserOnline();
    } else {
      UserServices.setUserLastAccess();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    UserServices.setUserLastAccess();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    global.userId = widget.uid;
    Firestore.instance
        .collection('users')
        .document(widget.uid)
        .snapshots()
        .listen((event) {
      UserServices.saveUserLocally(event);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Encounters",
      theme: ThemeData(
        primaryColor: global.primaryThemeColor,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  int currentIndex;

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentPage;
  List<Widget> pages;

  final Key chatPage = PageStorageKey('chat');
  final Key profilePage = PageStorageKey('profile');
  final Key pendingPage = PageStorageKey('pending');

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    currentIndex = 1;
    pages = [
      PendingChats(key: pendingPage),
      ChatList(key: chatPage),
      Profile(key: profilePage)
    ];
    Firestore.instance
        .collection('users')
        .document(global.userId)
        .collection('chatRequested')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .listen((event) {
      ChatServices.storePendingChatLocally(
          global.userId, event.documents, 'chatRequested');
    });
    Firestore.instance
        .collection('users')
        .document(global.userId)
        .collection('chatRequests')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .listen((event) {
      ChatServices.storePendingChatLocally(
          global.userId, event.documents, 'chatRequests');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: pages[currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: route,
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(LineIcons.clock_o),
            title: Text(Languages.dictionary[global.countryCode]['app']
                ['pending_chat']),
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.wechat),
            title:
                Text(Languages.dictionary[global.countryCode]['app']['chats']),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_identity),
            title: Text(
                Languages.dictionary[global.countryCode]['app']['profile']),
          ),
        ],
      ),
    );
  }

  void route(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}
