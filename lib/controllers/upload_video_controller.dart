import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  // method to compress the video
  _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(videoPath,
        quality: VideoQuality.MediumQuality);

    return compressedVideo?.file;
  }

  // method to get the thumbnail of the video
  _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);

    return thumbnail;
  }
  // method to upload video to storage

  _uploadVideoToStorage(String videoId, String videoPath) async {
    Reference reference = firebaseStorage.ref().child("videos").child(videoId);

    // upload the video to storage
    UploadTask uploadTask = reference.putFile(await _compressVideo(videoPath));

    TaskSnapshot snapshot = await uploadTask;

    // get the download url
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // method to upload thumbnail to firebase database

  _uploadImageToStorage(String videoId, String imagePath) async {
    Reference reference =
        firebaseStorage.ref().child("thumbnails").child(videoId);

    // upload the thumbnail to storage
    UploadTask uploadTask = reference.putFile(await _getThumbnail(imagePath));

    TaskSnapshot snapshot = await uploadTask;

    // get the download url
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // method to upload video to firebase storage
  uploadVideo(String songName, String caption, String videoPath) async {
    try {
      // user uid
      String uid = firebaseAuth.currentUser!.uid;

      //  user document reference
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(uid).get();

      // get all videos from firebase firestore
      var allDocs = await firestore.collection("videos").get();

      // the length of all videos
      int length = allDocs.docs.length;

      // upload video to storage with the name of the video
      String videoUrl = await _uploadVideoToStorage("video $length", videoPath);

      //  uplaad thumbnail to storage with the name of the video
      String thumbnailUrl =
          await _uploadImageToStorage("video $length", videoPath);

      VideoModel video = VideoModel(
        id: "video $length",
        uid: uid,
        username: (userDoc.data()! as Map<String, dynamic>)["name"],
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)["profilePhoto"],
        videoUrl: videoUrl,
        thumbnail: thumbnailUrl,
        caption: caption,
        likes: [],
        commentCount: '0',
        songName: songName,
        shareCount: 0,
      );

      // save the video to firebase firestore
      await firestore
          .collection("videos")
          .doc("video $length")
          .set(video.toJson());

      Get.back();
    } catch (e) {
      Get.snackbar(
        "خطاء في تحميل الفيديو",
        e.toString(),
      );
    }
  }
}
