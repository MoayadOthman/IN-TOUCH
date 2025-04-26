import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intouch/consts.dart';
import 'package:intouch/features/domain/entities/app_entity.dart';
import 'package:intouch/features/domain/entities/posts/post_entity.dart';
import 'package:intouch/features/domain/usecases/firebase_usecases/user/get_current_uid_usecase.dart';
import 'package:intouch/features/presentation/cubit/post/get_single_post/get_single_post_cubit.dart';
import 'package:intouch/features/presentation/cubit/post/post_cubit.dart';
import 'package:intouch/features/presentation/page/post/widget/like_animation_widget.dart';
import 'package:intouch/profile_widget.dart';
import 'package:intl/intl.dart';
import 'package:intouch/injection_container.dart' as di;

class PostDetailMainWidget extends StatefulWidget {
  final String postId;
  const PostDetailMainWidget({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailMainWidget> createState() => _PostDetailMainWidgetState();
}

class _PostDetailMainWidgetState extends State<PostDetailMainWidget> {

  String _currentUid = "";

  @override
  void initState() {
    BlocProvider.of<GetSinglePostCubit>(context).getSinglePost(postId: widget.postId);
    di.sl<GetCurrentUidUseCase>().call().then((value) {
      setState(() {
        _currentUid = value;
      });
    });
    super.initState();
  }

  bool _isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: backGroundColor),
      backgroundColor: backGroundColor,
      body: BlocBuilder<GetSinglePostCubit, GetSinglePostState>(
        builder: (context, getSinglePostState) {
          if (getSinglePostState is GetSinglePostLoaded) {
            final singlePost = getSinglePostState.post;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (user info)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, PageConst.singleUserProfilePage, arguments: singlePost.creatorUid);
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: profileWidget(imageUrl: "${singlePost.userProfileUrl}"),
                              ),
                            ),
                            sizeHor(10),
                            Text("${singlePost.username}", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      singlePost.creatorUid == _currentUid
                          ? GestureDetector(
                        onTap: () {
                          _openBottomModalSheet(context, singlePost);
                        },
                        child: Icon(Icons.more_vert, color: primaryColor),
                      )
                          : SizedBox.shrink(),
                    ],
                  ),
                  sizeVer(10),

                  // Post description
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${singlePost.description}",
                          style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 12),
                          maxLines: 3,  // Set a limit to the lines
                          overflow: TextOverflow.ellipsis,  // Add ellipsis if text exceeds the limit
                        ),
                      ),
                    ],
                  ),
                  sizeVer(5),

                  // Post image and like animation
                  GestureDetector(
                    onDoubleTap: () {
                      _likePost();
                      setState(() {
                        _isLikeAnimating = true;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Post Image
                        SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: profileWidget(imageUrl: "${singlePost.postImageUrl}"),
                        ),
                        // Like animation
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 200),
                          opacity: _isLikeAnimating ? 1 : 0,
                          child: LikeAnimationWidget(
                            duration: Duration(milliseconds: 200),
                            isLikeAnimating: _isLikeAnimating,
                            onLikeFinish: () {
                              setState(() {
                                _isLikeAnimating = false;
                              });
                            },
                            child: Icon(Icons.favorite, size: 100, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom info bar with buttons (like, comment, share)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Like and comment buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _likePost,
                              child: Icon(
                                singlePost.likes!.contains(_currentUid) ? Icons.favorite : Icons.favorite_outline,
                                color: singlePost.likes!.contains(_currentUid) ? Colors.red : secondaryColor,
                              ),
                            ),
                            sizeHor(10),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, PageConst.commentPage, arguments: AppEntity(uid: _currentUid, postId: singlePost.postId));
                              },
                              child: Icon(Feather.message_square, color: secondaryColor),
                            ),
                          ],
                        ),
                        sizeHor(200),
                        Icon(Icons.bookmark_border, color: secondaryColor),
                        Icon(Icons.send_sharp, color: secondaryColor),
                      ],
                    ),
                  ),

                  // Likes, comments and post date
                  sizeVer(10),
                  Text("${singlePost.totalLikes} likes", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, PageConst.commentPage, arguments: AppEntity(uid: _currentUid, postId: singlePost.postId));
                    },
                    child: Text("View all ${singlePost.totalComments} comments", style: TextStyle(color: darkGreyColor)),
                  ),
                  sizeVer(5),
                  Text("${DateFormat("dd/MMM/yyy").format(singlePost.createAt!.toDate())}", style: TextStyle(color: darkGreyColor, fontSize: 12)),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  _openBottomModalSheet(BuildContext context, PostEntity post) {
    return showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 150,
        decoration: BoxDecoration(color: backGroundColor.withOpacity(.8)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  "More Options",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                ),
              ),
              SizedBox(height: 8),
              Divider(thickness: 1, color: secondaryColor),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  onTap: _deletePost,
                  child: Text("Delete Post", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: primaryColor)),
                ),
              ),
              sizeVer(7),
              Divider(thickness: 1, color: secondaryColor),
              sizeVer(7),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, PageConst.updatePostPage, arguments: post);
                  },
                  child: Text("Update Post", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: primaryColor)),
                ),
              ),
              sizeVer(7),
            ],
          ),
        ),
      );
    });
  }

  _deletePost() {
    BlocProvider.of<PostCubit>(context).deletePost(post: PostEntity(postId: widget.postId));
  }

  _likePost() {
    BlocProvider.of<PostCubit>(context).likePost(post: PostEntity(postId: widget.postId));
  }
}
