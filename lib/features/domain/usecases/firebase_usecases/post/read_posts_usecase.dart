import 'package:intouch/features/domain/entities/posts/post_entity.dart';
import 'package:intouch/features/domain/repository/firebase_repository.dart';

class ReadPostsUseCase {
  final FirebaseRepository repository;

  ReadPostsUseCase({required this.repository});

  Stream<List<PostEntity>> call(PostEntity post) {
    return repository.readPosts(post);
  }
}