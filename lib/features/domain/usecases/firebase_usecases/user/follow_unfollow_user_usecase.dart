

import 'package:intouch/features/domain/entities/user/user_entity.dart';
import 'package:intouch/features/domain/repository/firebase_repository.dart';

class FollowUnFollowUseCase {
  final FirebaseRepository repository;

  FollowUnFollowUseCase({required this.repository});

  Future<void> call(UserEntity user) {
    return repository.followUnFollowUser(user);
  }
}