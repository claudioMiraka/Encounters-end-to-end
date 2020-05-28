import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../Model/EncounterUser.dart';
import '../../Profile/OthersProfile.dart';

class PendingChatTile extends StatelessWidget {
  final String imageURL, displayName, id;

  PendingChatTile(
      {@required this.displayName, @required this.imageURL, @required this.id});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        EncounterUser user = await EncounterUser.fromId(id);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => OthersProfile(user: user)));
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 12.0),
              child: Material(
                child: imageURL != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                          width: 40.0,
                          height: 40.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: imageURL,
                        width: 40.0,
                        height: 40.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 40.0,
                        color: Colors.grey,
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
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
