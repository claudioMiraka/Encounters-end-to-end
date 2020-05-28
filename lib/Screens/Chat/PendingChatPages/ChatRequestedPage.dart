import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../Providers/ChatServices/ChatServices.dart';
import '../Helpers/PendingChatTile.dart';
import '../../Utils/EmptyList.dart';
import '../../../GlobalVariables.dart' as global;
import '../../../Languages/Languages.dart';

class ChatRequestedPage extends StatefulWidget {
  ChatRequestedPage({Key key}) : super(key: key);

  @override
  _ChatRequestedPage createState() => _ChatRequestedPage();
}

class _ChatRequestedPage extends State<ChatRequestedPage> {
  Future<List> users; // initial list gotten from the local data
  List usersList; // list to delete item on the list faster

  @override
  void initState() {
    users = ChatServices.getLocalPendingChat('chatRequested');
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
                      caption: Languages.dictionary[global.countryCode]
                          ['pending_chats']['cancel'],
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () {
                        ChatServices.cancelRequest(usersList[index]['docId']);
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
