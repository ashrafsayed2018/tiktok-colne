import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/video_model.dart';

class VideoController extends GetxController {
  final Rx<List<VideoModel>> _videosList = Rx<List<VideoModel>>([]);

  List<VideoModel> get videosList => _videosList.value;

  @override
  void onInit() {
    super.onInit();
    _videosList.bindStream(
        firestore.collection("videos").snapshots().map((QuerySnapshot query) {
      List<VideoModel> retVal = [];
      for (var element in query.docs) {
        retVal.add(VideoModel.fromSnap(element));
      }
      return retVal;
    }));
  }

  likeVideo(String videoId) async {
    DocumentSnapshot doc =
        await firestore.collection("videos").doc(videoId).get();
    var uid = authcontroller.user.uid;
    if ((doc.data() as dynamic)['likes'].contains(uid)) {
      await firestore.collection("videos").doc(videoId).update({
        "likes": FieldValue.arrayRemove([uid])
      });
    } else {
      await firestore.collection("videos").doc(videoId).update({
        "likes": FieldValue.arrayUnion([uid])
      });
    }
  }
}
