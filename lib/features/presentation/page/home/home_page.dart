import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intouch/consts.dart';
import 'package:intouch/features/domain/entities/posts/post_entity.dart';
import 'package:intouch/features/presentation/cubit/post/post_cubit.dart';
import 'package:intouch/features/presentation/page/home/widgets/single_post_card_widget.dart';
import 'package:intouch/injection_container.dart' as di;
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        backgroundColor: backGroundColor,
        title: Image.asset("assets/auth/logo.png", color: primaryColor, height: 50,),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(MaterialCommunityIcons.message_badge_outline, color: primaryColor,),
          )
        ],
      ),
      body: BlocProvider<PostCubit>(
        create: (context) =>
        di.sl<PostCubit>()
          ..getPosts(post: PostEntity()),
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, postState) {
            if (postState is PostLoading) {
              return Center(child: CircularProgressIndicator(),);
            }
            if (postState is PostFailure) {
              toast("Some Failure occured while creating the post");
            }
            if (postState is PostLoaded) {
              return postState.posts.isEmpty? _noPostsYetWidget() : ListView.builder(
                itemCount: postState.posts.length,
                itemBuilder: (context, index) {
                  final post = postState.posts[index];
                  return BlocProvider(
                    create: (context) => di.sl<PostCubit>(),
                    child: SinglePostCardWidget(post: post),
                  );
                },
              );
            }
            return Center(child: CircularProgressIndicator(),);
          },
        ),
      ),
    );
  }

  _noPostsYetWidget() {
    return Center(child: Text("No Posts Yet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),);
  }
}
