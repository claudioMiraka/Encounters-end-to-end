import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../Screens/Utils/CustomSnackbar.dart';
import '../../Providers/ChatServices/ChatServices.dart';
import '../../Model/EncounterUser.dart';
import '../../Languages/Languages.dart';
import '../../GlobalVariables.dart' as global;

class OthersProfile extends StatefulWidget {
  final EncounterUser user;

  OthersProfile({@required this.user, Key key}) : super(key: key);

  @override
  _OthersProfile createState() => _OthersProfile();
}

class _OthersProfile extends State<OthersProfile> {
  bool isLoading = false;

  Widget messageButton(BuildContext context) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: global.primaryThemeColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.fromLTRB(10.0, 7.5, 10.0, 7.5),
        onPressed: () async {
          if (!isLoading) {
            setState(() {
              isLoading = true;
            });
            bool returnValue =
                await ChatServices.shouldSendRequest(widget.user);
            if (returnValue) {
              CustomSnackbar(
                      message: Languages.dictionary[global.countryCode]
                          ['others_profile']['generating_key'],
                      context: context,
                      duration: 8)
                  .show();
              int retValue = await ChatServices.sendRequest(widget.user);
              if (retValue > 0) {
                CustomSnackbar(
                        message: Languages.dictionary[global.countryCode]
                            ['error'],
                        context: context)
                    .show();
              }
            } else {
              CustomSnackbar(
                      message: Languages.dictionary[global.countryCode]
                          ['error'],
                      context: context)
                  .show();
            }
            setState(() {
              isLoading = false;
            });
          }
        },
        child: isLoading
            ? CircularProgressIndicator(
                strokeWidth: 1.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              )
            : Text(
                Languages.dictionary[global.countryCode]['others_profile']
                    ['message'],
                textAlign: TextAlign.center,
                style: global.styleText.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.displayName, style: global.styleText),
        backgroundColor: global.appBarBackgroundColor,
      ),
      body: Container(
        decoration: global.appBackground,
        child: Stack(
          children: <Widget>[
            ListView(
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
                          /**
                           * TODO: open new screen to see image
                           */
                        },
                        child: Hero(
                          tag: "Image",
                          child: Container(
                            width: 160.0,
                            height: 160.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    widget.user.profilePicUrl),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        widget.user.displayName,
                        style: global.styleText,
                      ),
                      SizedBox(height: 40),
                      messageButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
