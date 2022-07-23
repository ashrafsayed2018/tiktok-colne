import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  String id,
      uid,
      username,
      songName,
      caption,
      videoUrl,
      commentCount,
      thumbnail,
      profilePhoto;
  List likes;
  int shareCount;
  VideoModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.likes,
    required this.commentCount,
    required this.songName,
    required this.caption,
    required this.videoUrl,
    required this.thumbnail,
    required this.profilePhoto,
    required this.shareCount,
  });

  // to json method
  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "username": username,
        "likes": likes,
        "commentCount": commentCount,
        "songName": songName,
        "caption": caption,
        "videoUrl": videoUrl,
        "thumbnail": thumbnail,
        "profilePhoto": profilePhoto,
        "shareCount": shareCount,
      };

  // from snapshot method
  static VideoModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return VideoModel(
      id: snapshot['id'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      likes: snapshot['likes'],
      commentCount: snapshot['commentCount'].toString(),
      songName: snapshot['songName'],
      caption: snapshot['caption'],
      videoUrl: snapshot['videoUrl'],
      thumbnail: snapshot['thumbnail'],
      profilePhoto: snapshot['profilePhoto'],
      shareCount: snapshot['shareCount'],
    );
  }
}
