import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants.dart';
import 'package:tiktok_clone/models/user_model.dart';

class SearchController extends GetxController {
  final Rx<List<UserModel>> _searchedUsers = Rx<List<UserModel>>([]);

  List<UserModel> get searchedUsers => _searchedUsers.value;

  searchUser(String username) async {
    _searchedUsers.bindStream(
      firestore
          .collection("users")
          .where("name", isGreaterThanOrEqualTo: username)
          .snapshots()
          .map(
        (QuerySnapshot query) {
          List<UserModel> retVal = [];
          for (var element in query.docs) {
            retVal.add(UserModel.fromSnap(element));
          }
          return retVal;
        },
      ),
    );
  }
}
