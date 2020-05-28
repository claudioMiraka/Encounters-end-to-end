import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../Model/EncounterUser.dart';
import '../../../Screens/Utils/CustomSnackbar.dart';
import '../../../Providers/ChatServices/ChatServices.dart';
import '../Helpers/PendingChatTile.dart';
import '../../Utils/EmptyList.dart';
import '../../../Languages/Languages.dart';
import '../../../GlobalVariables.dart' as global;

class ChatRequestsPage extends StatefulWidget {
  ChatRequestsPage({Key key}) : super(key: key);

  @override
  _ChatRequestsPage createState() => _ChatRequestsPage();
}

class _ChatRequestsPage extends State<ChatRequestsPage> {
  Future<List> users;
  List usersList;

  Future<List> getUsers() {
    return ChatServices.getLocalPendingChat('chatRequests');
  }

  @override
  void initState() {
    users = getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: users,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          );
        } else {
          usersList = snapshot.data;
          if (usersList.length < 1) {
            return EmptyList(
                message: Languages.dictionary[global.countryCode]
                    ['pending_chats']['empty']);
          }
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.black,
            ),
            itemCount: usersList.length,
            itemBuilder: (context, index) {
              return Slidable(
                actionPane: SlidableStrechActionPane(),
                actionExtentRatio: 0.25,
                child: PendingChatTile(
                    imageURL: usersList[index]['profilePicUrl'],
                    displayName: usersList[index]['displayName'],
                    id: usersList[index]['docId']),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    caption: Languages.dictionary[global.countryCode]['pending_chats']['accept'],
                    color: Colors.black45,
                    icon: Icons.done,
                    onTap: () async {
                      EncounterUser user =
                          await EncounterUser.fromId(usersList[index]['docId']);
                      ChatServices.acceptRequest(user);
                      CustomSnackbar(
                              message: Languages.dictionary[global.countryCode]['pending_chats']['generating_key'],
                              context: context,
                              duration: 8)
                          .show();
                      setState(() {
                        usersList.removeAt(index);
                      });
                    },
                  ),
                  IconSlideAction(
                      caption: Languages.dictionary[global.countryCode]['pending_chats']['deny'],
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        ChatServices.denyRequest(usersList[index]['docId']);
                        setState(() {
                          usersList.removeAt(index);
                        });
                      }),
                ],
              );
            },
          );
        }
      },
    );
  }
}
