import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/comment_model.dart';

class CommentController extends GetxController {
  final Rx<List<CommentModel>> _commentsList = Rx<List<CommentModel>>([]);

  List<CommentModel> get commentsList => _commentsList.value;

  String _postId = "";
  updatePostId(String postId) {
    _postId = postId;

    getComment();
  }

  getComment() async {
    _commentsList.bindStream(firestore
        .collection("videos")
        .doc(_postId)
        .collection("comments")
        .snapshots()
        .map((QuerySnapshot query) {
      List<CommentModel> retVal = [];

      for (var element in query.docs) {
        retVal.add(CommentModel.fromSnap(element));
      }

      return retVal;
    }));
  }

  postComment(String commentText) async {
    try {
      if (commentText.isNotEmpty) {
        DocumentSnapshot userDoc = await firestore
            .collection("users")
            .doc(authcontroller.user.uid)
            .get();

        var allDocs = await firestore
            .collection("videos")
            .doc(_postId)
            .collection("comments")
            .get();

        CommentModel comment = CommentModel(
          id: "comment ${allDocs.docs.length}",
          uid: authcontroller.user.uid,
          username: (userDoc.data() as dynamic)['name'],
          comment: commentText.trim(),
          datePublished: DateTime.now(),
          profilePhoto: (userDoc.data() as dynamic)['profilePhoto'],
          likes: [],
        );
        await firestore
            .collection("videos")
            .doc(_postId)
            .collection("comments")
            .add(comment.toMap());

        // update comment count
        DocumentSnapshot snap =
            await firestore.collection("videos").doc(_postId).get();

        await firestore.collection("videos").doc(_postId).update(
            {"commentCount": (snap.data() as dynamic)['commentCount'] + 1});
      }
    } catch (e) {
      Get.snackbar("خطاء في اضافة تعليق", e.toString());
    }
  }

  // like a comment
  likeComment(String commentId) async {
    try {
      var uid = authcontroller.user.uid;
      DocumentSnapshot snap = await firestore
          .collection("videos")
          .doc(_postId)
          .collection("comments")
          .doc(commentId)
          .get();

      if ((snap.data() as dynamic)['likes'].contains(uid)) {
        await firestore
            .collection("videos")
            .doc(_postId)
            .collection("comments")
            .doc(commentId)
            .update({
          "likes": FieldValue.arrayRemove([uid])
        });
        Get.snackbar("نجاح", "تم الغاء الإعجاب");
      } else {
        await firestore
            .collection("videos")
            .doc(_postId)
            .collection("comments")
            .doc(commentId)
            .update({
          "likes": FieldValue.arrayUnion([uid])
        });
        Get.snackbar("نجاح", "لقد قمت بالاعجاب بالتعليق");
      }
    } catch (e) {
      Get.snackbar("خطاء في تعليق", e.toString());
    }
  }
}
