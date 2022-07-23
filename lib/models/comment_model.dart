import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String id;
  String username;
  String uid;
  String profilePhoto;
  String comment;
  final datePublished;
  List<dynamic> likes;
  CommentModel({
    required this.id,
    required this.username,
    required this.uid,
    required this.profilePhoto,
    required this.comment,
    this.datePublished,
    required this.likes,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "username": username,
        "uid": uid,
        "profilePhoto": profilePhoto,
        "comment": comment,
        "datePublished": datePublished,
        "likes": likes,
      };

  factory CommentModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return CommentModel(
      id: snapshot['id'],
      username: snapshot['username'],
      uid: snapshot['uid'],
      profilePhoto: snapshot['profilePhoto'],
      comment: snapshot['comment'],
      datePublished: snapshot['datePublished'],
      likes: snapshot['likes'],
    );
  }
}
