
import 'package:intouch/features/domain/entities/user/user_entity.dart';
import 'package:intouch/features/domain/repository/firebase_repository.dart';


class GetSingleOtherUserUseCase {
  final FirebaseRepository repository;

  GetSingleOtherUserUseCase({required this.repository});

  Stream<List<UserEntity>> call(String otherUid) {
    return repository.getSingleOtherUser(otherUid);
  }
}