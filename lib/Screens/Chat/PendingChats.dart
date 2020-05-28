import 'package:flutter/material.dart';

import '../../GlobalVariables.dart' as global;
import '../../Languages/Languages.dart';
import 'PendingChatPages/ChatRequestsPage.dart';
import 'PendingChatPages/ChatRequestedPage.dart';

class PendingChats extends StatefulWidget {
  PendingChats({Key key}) : super(key: key);

  @override
  _PendingChats createState() => _PendingChats();
}

class _PendingChats extends State<PendingChats> {
  int currentIndex;
  Widget currentPage;
  List<Widget> pages;
  final Key chatRequests = PageStorageKey('requests');
  final Key chatRequested = PageStorageKey('requested');
  List<String> pagesName = [
    Languages.dictionary[global.countryCode]['pending_chats']
        ['requesting_chats'],
    Languages.dictionary[global.countryCode]['pending_chats']['requested_chats']
  ];

  @override
  void initState() {
    if (global.initialTab == null) {
      currentIndex = 0;
      global.initialTab = 0;
    } else {
      currentIndex = global.initialTab;
    }
    pages = [
      ChatRequestsPage(
        key: chatRequests,
      ),
      ChatRequestedPage(
        key: chatRequested,
      ),
    ];
    currentPage = pages[currentIndex];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: global.appBarBackgroundColor,
        title: Text(
          pagesName[currentIndex],
          style: global.styleText,
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              switchPage();
            },
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Icon(
                  Icons.swap_horiz,
                  color: Colors.black,
                )),
          )
        ],
      ),
      body: Container(
        decoration: global.appBackground,
        child: currentPage,
      ),
    );
  }

  void switchPage() {
    setState(() {
      if (currentIndex == 0) {
        currentIndex = 1;
      } else {
        currentIndex = 0;
      }
      currentPage = pages[currentIndex];
      global.initialTab = currentIndex;
    });
  }
}
