import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../Utils/LoadingScreen.dart';
import '../../Model/EncounterUser.dart';
import '../../Providers/UserServices/UserServices.dart';
import '../../GlobalVariables.dart' as global;
import '../../Languages/Languages.dart';

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _Profile createState() => _Profile();
}

class _Profile extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: UserServices.getLocalUser(),
        builder: (BuildContext context, AsyncSnapshot<EncounterUser> snapshot) {
          if (snapshot.hasData && !snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    Languages.dictionary[global.countryCode]['my_profile']
                        ['title'],
                    style: global.styleText),
                backgroundColor: global.appBarBackgroundColor,
              ),
              body: Container(
                decoration: global.appBackground,
                child: ListView(
                  children: <Widget>[
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SizedBox(height: 40),
                          GestureDetector(
                            onTap: () {
                              print("pressed");
                            },
                            child: Hero(
                              tag: "Image",
                              child: Container(
                                width: 160.0,
                                height: 160.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        snapshot.data.profilePicUrl),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(80.0),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            snapshot.data.displayName,
                            style: global.styleText,
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return LoadingScreen();
          }
        });
  }
}
