import '../models/session_request_model.dart';
import 'session_request_repository.dart';

class MockSessionRequestRepository implements SessionRequestRepository {
  @override
  Future<void> sendRequest({required SessionRequestModel request}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }
}

// 🔥 لما Firebase يتجهز
// class FirebaseSessionRequestRepository implements SessionRequestRepository {
//   final _db = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//
//   @override
//   Future<void> sendRequest({required SessionRequestModel request}) async {
//     final uid = _auth.currentUser!.uid;
//     await _db.collection('sessions').add({
//       ...request.toFirestore(),
//       'learnerId': uid,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }
// }
