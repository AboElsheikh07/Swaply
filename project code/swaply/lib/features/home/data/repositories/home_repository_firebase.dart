import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swaply/features/user/data/models/user_model.dart';
import 'home_repository.dart';

class FirebaseHomeRepository implements HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> getTopMentors() async {
    final snapshot = await _firestore
        .collection('users')
        .where('skillsCanTeach', isNotEqualTo: [])
        .orderBy('balance', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }


  @override
  Future<List<UserModel>> getRecommendedMentors() async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<dynamic>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((e) => e.data()).toList();
  }
}