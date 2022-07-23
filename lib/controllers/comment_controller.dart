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

        int len = allDocs.docs.length;

        CommentModel comment = CommentModel(
          id: "Comment $len",
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
            .doc("Comment $len")
            .set(comment.toMap());

        // update comment count
        DocumentSnapshot snap =
            await firestore.collection("videos").doc(_postId).get();

        await firestore.collection("videos").doc(_postId).update({
          "commentCount": (snap.data() as dynamic)['commentCount'] + 1,
        });
      }
    } catch (e) {
      Get.snackbar("خطاء في اضافة تعليق", e.toString());
    }
  }

  // like a comment
  likeComment(String commentId) async {
    try {
      var uid = authcontroller.user.uid;
      DocumentSnapshot doc = await firestore
          .collection("videos")
          .doc(_postId)
          .collection("comments")
          .doc(commentId)
          .get();

      if ((doc.data() as dynamic)['likes'].contains(uid)) {
        await firestore
            .collection("videos")
            .doc(_postId)
            .collection("comments")
            .doc(commentId)
            .update({
          "likes": FieldValue.arrayRemove([uid])
        });
      } else {
        await firestore
            .collection("videos")
            .doc(_postId)
            .collection("comments")
            .doc(commentId)
            .update({
          "likes": FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      Get.snackbar("خطاء في الاعجاب",
          e.toString()); // if there is an error, show the error in a snackbar
    }
  }
}
