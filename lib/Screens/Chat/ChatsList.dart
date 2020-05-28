import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encounters/Languages/Languages.dart';
import 'package:flutter/material.dart';

import '../../Model/SearchUser.dart';
import '../Utils/EmptyList.dart';
import '../../Providers/ChatServices/ChatServices.dart';
import 'Helpers/ChatListTile.dart';
import '../../GlobalVariables.dart' as globals;

class ChatList extends StatefulWidget {
  ChatList({Key key}) : super(key: key);

  @override
  _ChatList createState() => _ChatList();
}

class _ChatList extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: globals.appBarBackgroundColor,
        title: Text(
          Languages.dictionary[globals.countryCode]['chat_list']['title'],
          style: globals.styleText,
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              showSearch(context: context, delegate: SearchUser());
            },
            child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Icon(
                  Icons.search,
                  color: Colors.black,
                )),
          )
        ],
      ),
      body: Container(
        decoration: globals.appBackground,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('chats')
              .where("users", arrayContains: globals.userId)
              .orderBy('lastMessageTime', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              );
            } else {
              if (snapshot.data.documents.length < 1) {
                return EmptyList(
                  message: Languages.dictionary[globals.countryCode]
                      ['chat_list']['empty'],
                );
              } else {
                return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                          color: Colors.grey,
                        ),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return ChatListTile.fromData(ChatServices.determinatePeer(
                          snapshot.data.documents[index]));
                    });
              }
            }
          },
        ),
      ),
    );
  }
}
