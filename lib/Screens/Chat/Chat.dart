import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encounters/Screens/Utils/CustomSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as rsa;
import 'package:intl/intl.dart';

import '../Utils/EmptyList.dart';
import '../Chat/Helpers/MessageTile.dart';
import '../../GlobalVariables.dart' as globals;
import '../../Languages/Languages.dart';
import '../../Providers/ChatServices/ChatServices.dart';
import '../../Model/EncounterUser.dart';
import '../../Providers/EncryptionServices/EncryptionHelpers.dart';

class Chat extends StatefulWidget {
  final String peerId;
  final String peerDisplayName;
  final String peerProfilePicUrl;
  final String peerPublicKey;
  final String myPublicKey;

  Chat(
      {Key key,
      @required this.peerId,
      @required this.peerDisplayName,
      @required this.peerPublicKey,
      @required this.peerProfilePicUrl,
      @required this.myPublicKey})
      : super(key: key);

  @override
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {
  final TextEditingController textEditingController =
      new TextEditingController();
  String chatId;
  String peerDisplayName;
  String peerProfilePicUrl;
  EncounterUser peerUser;
  var encryptsPeer;
  var encryptsMine;

  setEncripts() async {
    final secureStorage = new FlutterSecureStorage();
    final String privateKey = await secureStorage.read(key: widget.peerId);
    var keyHelper = RsaKeyHelper();
    encryptsPeer = keyHelper.getEncrypter(widget.peerPublicKey, privateKey);
    encryptsMine = keyHelper.getEncrypter(widget.myPublicKey, privateKey);
  }

  @override
  void initState() {
    if (widget.peerId.compareTo(globals.userId) > 0) {
      chatId = widget.peerId + "-" + globals.userId;
    } else {
      chatId = globals.userId + "-" + widget.peerId;
    }
    peerDisplayName = widget.peerDisplayName;
    peerProfilePicUrl = widget.peerProfilePicUrl;
    setEncripts();
    Firestore.instance
        .collection('users')
        .document(widget.peerId)
        .snapshots()
        .listen((doc) {
      setState(() {
        peerDisplayName = doc.data['profilePicUrl'];
        peerDisplayName = doc.data['displayName'];
        setOnlineStatus(doc.data['onlineStatus']);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: globals.appBarBackgroundColor,
        title: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(widget.peerId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ),
              );
            }
            String onlineStatus =
                setOnlineStatus(snapshot.data.data['onlineStatus']);
            return Row(children: <Widget>[
              Material(
                child: snapshot.data.data['profilePicUrl'] != null
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
                        imageUrl: peerProfilePicUrl,
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
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      snapshot.data.data['displayName'],
                      style: globals.styleText,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      onlineStatus == null ? "" : onlineStatus,
                      style: globals.styleText.copyWith(fontSize: 10),
                    ),
                  )
                ],
              )
            ]);
          },
        ),
      ),
      body: Container(
        decoration: globals.appBackground,
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('chats')
                    .document(chatId)
                    .collection("messages")
                    .orderBy('timeSent', descending: true)
                    .limit(
                        20) //TODO: scroll up to load more, change 20 to variable
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
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
                            ['chats']['empty'],
                      );
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            final fromMe = snapshot.data.documents[index]
                                    ['idFrom'] ==
                                globals.userId;
                            String message;
                            if (fromMe) {
                              message = encryptsMine.decrypt(
                                  rsa.Encrypted.fromBase64(snapshot
                                      .data.documents[index]['messageMine']));
                            } else {
                              message = encryptsPeer.decrypt(
                                  rsa.Encrypted.fromBase64(snapshot
                                      .data.documents[index]['messagePeer']));
                            }
                            return MessageTile(
                              messageSnapshot: snapshot.data.documents[index],
                              fromMe: fromMe,
                              message: message,
                            );
                          });
                    }
                  }
                },
              ),
            ),
            Container(color: Colors.white, child: buildInput()),
          ],
        ),
      ),
    );
  }

  Widget buildInput() {
    return Row(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: IconButton(
              icon: Icon(
                Icons.photo_camera,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                print("sent image ");
                CustomSnackbar(
                        message: Languages.dictionary[globals.countryCode]
                            ['chats']['picture_error'],
                        context: context)
                    .show();
              }),
        ),
        Flexible(
          child: TextField(
            controller: textEditingController,
            onChanged: (String messageText) {
              /**
               * TODO: here you caa add maybe display "user is typing..."
               */
            },
            decoration: InputDecoration.collapsed(
                hintText: Languages.dictionary[globals.countryCode]['chats']
                    ['message']),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                sendMessage(textEditingController.text);
              }),
        ),
      ],
    );
  }

  String setOnlineStatus(String status) {
    if (status == null) {
      return null;
    }
    if (status == "online") {
      return "online";
    }
    return "Last access: " +
        DateFormat('dd MMM kk:mm')
            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(status)));
  }

  void sendMessage(String messageText) async {
    if (messageText.isEmpty) return;
    final messagePeer = encryptsPeer.encrypt(messageText).base64;
    final messageMe = encryptsMine.encrypt(messageText).base64;
    await ChatServices.sendMessage(
        messagePeer: messagePeer,
        messageMe: messageMe,
        type: 0,
        chatId: chatId,
        idFrom: globals.userId,
        idTo: widget.peerId,
        publicKey: widget.peerPublicKey);
    textEditingController.clear();
  }
}
