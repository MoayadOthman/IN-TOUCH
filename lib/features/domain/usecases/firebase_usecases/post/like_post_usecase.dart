import 'package:intouch/features/domain/entities/posts/post_entity.dart';
import 'package:intouch/features/domain/repository/firebase_repository.dart';

class LikePostUseCase {
  final FirebaseRepository repository;

  LikePostUseCase({required this.repository});

  Future<void> call(PostEntity post) {
    return repository.likePost(post);
  }
}