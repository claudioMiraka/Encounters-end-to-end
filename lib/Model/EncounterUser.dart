import 'package:cloud_firestore/cloud_firestore.dart';

class EncounterUser {
  String id;
  String displayName;
  String profilePicUrl;
  List<dynamic> chats;

  EncounterUser({this.id, this.displayName, this.profilePicUrl});

  EncounterUser.fromData(String id, Map<String, dynamic> data)
      : id = id,
        displayName = data['displayName'],
        profilePicUrl = data['profilePicUrl'];

  EncounterUser.formFirestore(DocumentSnapshot doc)
      : id = doc.documentID,
        displayName = doc['displayName'],
        profilePicUrl = doc['profilePicUrl'],
        chats = doc['chats'];

  static fromId(String id) async {
    EncounterUser user;
    await Firestore.instance.collection('users').document(id).get().then((doc) {
      user = EncounterUser.formFirestore(doc);
    }).catchError((onError) {
      print(onError);
    });
    return user;
  }

  @override
  String toString() => "Encountered user\n"
      "id: $id\n"
      "displayName: $displayName\n"
      "profilePicUrl: $profilePicUrl\n"
      "chats: list";

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'profilePicUrl': profilePicUrl,
        'chats': chats
      };

  EncounterUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        displayName = json['displayName'],
        profilePicUrl = json['profilePicUrl'],
        chats = json['chats'];
}
