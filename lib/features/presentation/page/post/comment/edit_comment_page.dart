import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intouch/features/domain/entities/comment/comment_entity.dart';
import 'package:intouch/features/presentation/cubit/comment/comment_cubit.dart';
import 'package:intouch/features/presentation/page/post/comment/widgets/edit_comment_main_widget.dart';
import 'package:intouch/injection_container.dart' as di;

class EditCommentPage extends StatelessWidget {
  final CommentEntity comment;

  const EditCommentPage({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentCubit>(
      create: (context) => di.sl<CommentCubit>(),
      child: EditCommentMainWidget(comment: comment),
    );
  }
}
