import 'package:swaply/features/user/data/datasources/user_remote_data_source.dart';
import 'package:swaply/features/user/data/models/user_model.dart';

class MentorDetailsRepository {
  final UserRemoteDataSource _remote = UserRemoteDataSource();

  Future<UserModel> getMentor(String uid) async {
    final user = await _remote.fetchUser(uid);

    if (user == null) {
      throw Exception("Mentor not found");
    }

    return user;
  }
}