import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String name;
  String email;
  String password;
  String profilePhoto;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.profilePhoto,
  });

  // from map

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "name": name,
        "email": email,
        "password": password,
        "profilePhoto": profilePhoto,
      };

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
      uid: snapshot['uid'],
      name: snapshot['name'],
      email: snapshot['email'],
      password: snapshot['password'],
      profilePhoto: snapshot['profilePhoto'],
    );
  }
}
