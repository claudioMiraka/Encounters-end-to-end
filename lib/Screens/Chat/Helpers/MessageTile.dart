import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTile extends StatelessWidget {
  final DocumentSnapshot messageSnapshot;
  final bool fromMe;
  final String message;

  MessageTile(
      {@required this.messageSnapshot,
      @required this.fromMe,
      @required this.message});

  String timeSent(String timeSent) {
    final differenceTime = DateTime.fromMillisecondsSinceEpoch(
            int.parse(messageSnapshot.data['timeSent']))
        .difference(DateTime.now())
        .inDays;
    if (differenceTime < -1)
      return DateFormat('dd MMM kk:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeSent)));
    else
      return DateFormat.Hm()
          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timeSent)));
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 3 / 4;
    return Row(
      mainAxisAlignment:
          fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: fromMe ? Colors.orange[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(8.0)),
          margin: EdgeInsets.only(bottom: 5.0, right: 10.0, left: 10.0),
          constraints: message.length > 25
              ? BoxConstraints(maxWidth: maxWidth)
              : BoxConstraints(),
          child: Column(
            crossAxisAlignment:
                fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Align(
                  alignment:
                      fromMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                margin: EdgeInsets.only(bottom: 5.0, right: 5.0),
              ),
              Container(
                alignment:
                    fromMe ? Alignment.bottomRight : Alignment.bottomLeft,
                margin: EdgeInsets.only(right: 7.0, left: 7.0),
                child: Text(
                  timeSent(messageSnapshot.data['timeSent']),
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
