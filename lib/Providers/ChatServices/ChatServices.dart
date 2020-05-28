import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pointycastle/api.dart' as crypto;
import '../../Model/EncounterUser.dart';
import '../UserServices/UserServices.dart';
import '../EncryptionServices/EncryptionHelpers.dart';

import '../../GlobalVariables.dart' as global;

class ChatServices {
  static Future<bool> shouldSendRequest(EncounterUser recipientUser) async {
    EncounterUser user = await UserServices.getLocalUser();
    if (user.chats != null && user.chats.contains(recipientUser.id))
      return false;
    List chatRequested = await getLocalPendingChat('chatRequested');
    if (chatRequested
            .where((element) => element['docId'] == recipientUser.id)
            .length >
        0) return false;
    List chatRequesting = await getLocalPendingChat('chatRequests');
    if (chatRequesting
            .where((element) => element['docId'] == recipientUser.id)
            .length >
        0) return false;
    return true;
  }

  static Future<int> sendRequest(EncounterUser recipientUser) async {
    EncounterUser user = await UserServices.getLocalUser();
    int returnCode = 0;
    final secureStorage = new FlutterSecureStorage();
    var keyHelper = RsaKeyHelper();
    crypto.AsymmetricKeyPair keyPair =
        await keyHelper.computeRSAKeyPair(keyHelper.getSecureRandom());
    final String publicKey =
        RsaKeyHelper().encodePublicKeyToPemPKCS1(keyPair.publicKey);
    final String privateKey =
        RsaKeyHelper().encodePrivateKeyToPemPKCS1(keyPair.privateKey);
    await secureStorage.write(key: recipientUser.id, value: privateKey);
    await Firestore.instance
        .collection('users')
        .document(recipientUser.id)
        .collection('chatRequests')
        .document(user.id)
        .setData({
      'displayName': user.displayName,
      'publicKey': publicKey,
      'profilePicUrl': user.profilePicUrl,
      'timeSent': DateTime.now().millisecondsSinceEpoch.toString()
    }).catchError((error) {
      returnCode = 1;
      print("Error: " + error.toString());
    });

    await Firestore.instance
        .collection('users')
        .document(user.id)
        .collection('chatRequested')
        .document(recipientUser.id)
        .setData({
      'displayName': recipientUser.displayName,
      'profilePicUrl': recipientUser.profilePicUrl,
      'timeSent': DateTime.now().millisecondsSinceEpoch.toString()
    }).catchError((error) {
      returnCode = 1;
      print("Error: " + error.toString());
    });

    return returnCode;
  }

  static acceptRequest(EncounterUser requesterUser) async {
    EncounterUser user = await UserServices.getLocalUser();
    String chatId;
    String peerPublicKey;
    await Firestore.instance
        .collection('users')
        .document(user.id)
        .collection('chatRequests')
        .document(requesterUser.id)
        .get()
        .then((doc) {
      peerPublicKey = doc['publicKey'];
    });
    deleteDocument(user.id, 'chatRequests', requesterUser.id);
    deleteDocument(requesterUser.id, 'chatRequested', user.id);
    if (requesterUser.id.compareTo(user.id) > 0) {
      chatId = requesterUser.id + "-" + user.id;
    } else {
      chatId = user.id + "-" + requesterUser.id;
    }
    final secureStorage = new FlutterSecureStorage();
    var keyHelper = RsaKeyHelper();
    crypto.AsymmetricKeyPair keyPair =
        await keyHelper.computeRSAKeyPair(keyHelper.getSecureRandom());
    final String publicKey =
        RsaKeyHelper().encodePublicKeyToPemPKCS1(keyPair.publicKey);
    final String privateKey =
        RsaKeyHelper().encodePrivateKeyToPemPKCS1(keyPair.privateKey);

    await secureStorage.write(key: requesterUser.id, value: privateKey);

    Firestore.instance.collection('chats').document(chatId).setData({
      'users': [user.id, requesterUser.id],
      'createdTime': DateTime.now().millisecondsSinceEpoch.toString(),
      'creatorId': user.id,
      'peerId': requesterUser.id,
      'creatorPublicKey': publicKey,
      'peerPublicKey': peerPublicKey,
      'creatorAvatar': user.profilePicUrl,
      'peerAvatar': requesterUser.profilePicUrl,
      'lastMessageText': "",
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch.toString(),
      'creatorUnread': 0,
      'peerUnread': 0,
      'creatorDisplayName': user.displayName,
      'peerDisplayName': requesterUser.displayName
    });
    Firestore.instance.collection('users').document(global.userId).updateData({
      'chats': FieldValue.arrayUnion([requesterUser.id])
    });
  }

  static denyRequest(String requesterId) async {
    deleteDocument(global.userId, 'chatRequests', requesterId);
    deleteDocument(requesterId, 'chatRequested', global.userId);
  }

  static cancelRequest(String requestingId) {
    deleteDocument(global.userId, 'chatRequested', requestingId);
    deleteDocument(requestingId, 'chatRequests', global.userId);
  }

  static deleteDocument(String user1, String collection, String user2) async {
    await Firestore.instance
        .collection('users')
        .document(user1)
        .collection(collection)
        .document(user2)
        .delete();
  }

  static Map determinatePeer(DocumentSnapshot document) {
    bool isRequester = document.data['peerId'] == global.userId ? true : false;
    if (!isRequester) {
      return {
        'profilePicUrl': document['peerAvatar'],
        'displayName': document['peerDisplayName'],
        'lastMessage': document['lastMessageText'],
        'unreadMessages': document['peerUnread'],
        'id': document['peerId'],
        'peerPublicKey': document['peerPublicKey'],
        'myPublicKey': document['creatorPublicKey']
      };
    } else {
      return {
        'profilePicUrl': document['creatorAvatar'],
        'displayName': document['creatorDisplayName'],
        'lastMessage': document['lastMessageText'],
        'unreadMessages': document['creatorUnread'],
        'id': document['creatorId'],
        'myPublicKey': document['peerPublicKey'],
        'peerPublicKey': document['creatorPublicKey']
      };
    }
  }

  static sendMessage(
      {@required String messagePeer,
      @required String messageMe,
      @required type,
      @required String chatId,
      @required idFrom,
      @required idTo,
      @required publicKey}) async {
    String timeSent = DateTime.now().millisecondsSinceEpoch.toString();
    final docMessageRef = Firestore.instance
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document(timeSent);
    final docChatRef = Firestore.instance.collection('chats').document(chatId);

    await Firestore.instance.runTransaction((transaction) async {
      await transaction.set(docMessageRef, {
        'idFrom': idFrom,
        'idTo': idTo,
        'timeSent': timeSent,
        'messagePeer': messagePeer,
        'messageMine': messageMe,
        'type': type
      });
    });
    /**
     *  TODO: last message encrypted
     */
    if (type == 0) {
      docChatRef
          .updateData({'lastMessageText': "", 'lastMessageTime': timeSent});
    } else if (type == 1) {
      docChatRef.updateData(
          {'lastMessageText': "Image", 'lastMessageTime': timeSent});
    }
  }

  static storePendingChatLocally(
      String id, List<DocumentSnapshot> docs, String collection) async {
    final prefs = await SharedPreferences.getInstance();
    List chatRequested = [];
    docs.forEach((doc) {
      final data = doc.data;
      data['docId'] = doc.documentID;
      chatRequested.add(data);
    });
    prefs.setString(collection, json.encode(chatRequested));
  }

  static Future<List> getLocalPendingChat(String collection) async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(collection));
  }
}
