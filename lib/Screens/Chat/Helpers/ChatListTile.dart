import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Chat.dart';

class ChatListTile extends StatelessWidget {
  final String profilePicUrl,
      displayName,
      message,
      id,
      peerPublicKey,
      myPublicKey;
  final int unread;

  ChatListTile.fromData(Map data)
      : displayName = data['displayName'],
        profilePicUrl = data['profilePicUrl'],
        message = data['lastMessage'],
        unread = data['unreadMessages'],
        id = data['id'],
        peerPublicKey = data['peerPublicKey'],
        myPublicKey = data['myPublicKey'];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      peerId: id,
                      peerDisplayName: displayName,
                      peerProfilePicUrl: profilePicUrl,
                      peerPublicKey: peerPublicKey,
                      myPublicKey: myPublicKey,
                    )));
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 12.0),
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                    width: 40.0,
                    height: 40.0,
                    padding: EdgeInsets.all(25.0),
                  ),
                  imageUrl: profilePicUrl,
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 6.0, right: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName,
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0),
                        child: Text(
                            message.length < 30
                                ? message
                                : message.substring(0, 27) + "...",
                            style: TextStyle(
                                color: Colors.black38,
                                fontSize: 15,
                                height: 1.1),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      )
                    ],
                  )),
            ),
            Column(
              children: <Widget>[
                _UnreadIndicator(this.unread),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _UnreadIndicator extends StatelessWidget {
  final int unread;

  _UnreadIndicator(this.unread);

  @override
  Widget build(BuildContext context) {
    if (unread == 0) {
      return Container(); // return empty container
    } else {
      return Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 30,
                color: Color(0xff3e5aeb),
                width: 30,
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                child: Text(
                  unread.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              )));
    }
  }
}
