
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intouch/consts.dart';
import 'package:intouch/features/domain/entities/app_entity.dart';
import 'package:intouch/features/domain/entities/posts/post_entity.dart';
import 'package:intouch/features/domain/usecases/firebase_usecases/user/get_current_uid_usecase.dart';
import 'package:intouch/features/presentation/cubit/post/post_cubit.dart';
import 'package:intouch/features/presentation/page/post/widget/like_animation_widget.dart';
import 'package:intouch/profile_widget.dart';
import 'package:intl/intl.dart';
import 'package:intouch/injection_container.dart'as di;

class SinglePostCardWidget extends StatefulWidget {
  final PostEntity post;
  const SinglePostCardWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<SinglePostCardWidget> createState() => _SinglePostCardWidgetState();
}

class _SinglePostCardWidgetState extends State<SinglePostCardWidget> {

  String _currentUid = "";

  @override
  void initState() {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Column(
        children: [
          // Header (user info)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, PageConst.singleUserProfilePage, arguments: widget.post.creatorUid);
                },
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: profileWidget(imageUrl: "${widget.post.userProfileUrl}"),
                      ),
                    ),
                    sizeHor(10),
                    Text("${widget.post.username}", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
              widget.post.creatorUid == _currentUid
                  ? GestureDetector(
                onTap: () {
                  _openBottomModalSheet(context, widget.post);
                },
                child: Icon(Icons.more_vert, color: Colors.white),
              )
                  : SizedBox.shrink(),
            ],
          ),
          sizeVer(10),
          Row(
            children: [
              Expanded(
                child: Text(
                  "${widget.post.description}",
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  maxLines: 50,  // تحديد الحد الأقصى لعدد الأسطر
                  overflow: TextOverflow.ellipsis,  // إضافة النقاط الثلاثية إذا تجاوز النص الحد
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
                // Image
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: profileWidget(imageUrl: "${widget.post.postImageUrl}"),
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
                    child: Icon(Icons.favorite, size: 100, color: Colors.white,),
                  ),
                ),
              ],
            ),
          ),

          // Information below the image with white background
          Container(
            padding: EdgeInsets.only(left: 5, right: 5, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                sizeVer(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Like button, comment button, etc.
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _likePost,
                          child: Icon(
                            widget.post.likes!.contains(_currentUid) ? Icons.favorite : Icons.favorite_outline,
                            color: widget.post.likes!.contains(_currentUid) ? Colors.red : secondaryColor,
                          ),
                        ),
                        sizeHor(10),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, PageConst.commentPage, arguments: AppEntity(uid: _currentUid, postId: widget.post.postId));
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
              ],
            ),
          ),

          // Description and comments info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizeVer(10),
              Text("${widget.post.totalLikes} likes", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              Row(
                children: [
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, PageConst.commentPage, arguments: AppEntity(uid: _currentUid, postId: widget.post.postId));
                },
                child: Text("View all ${widget.post.totalComments} comments", style: TextStyle(color: darkGreyColor)),
              ),
              sizeVer(5),
              Text("${DateFormat("dd/MMM/yyy").format(widget.post.createAt!.toDate())}", style: TextStyle(color: darkGreyColor,fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  _openBottomModalSheet(BuildContext context, PostEntity post) {
    return showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 150,
        decoration: BoxDecoration(color: backGroundColor.withOpacity(.8)),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    "More Options",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(
                  thickness: 1,
                  color: primaryColor,
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: GestureDetector(
                    onTap: _deletePost,
                    child: Text(
                      "Delete Post",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: primaryColor),
                    ),
                  ),
                ),
                sizeVer(7),
                Divider(
                  thickness: 1,
                  color: primaryColor,
                ),
                sizeVer(7),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, PageConst.updatePostPage, arguments: post);
                    },
                    child: Text(
                      "Update Post",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: primaryColor),
                    ),
                  ),
                ),
                sizeVer(7),
              ],
            ),
          ),
        ),
      );
    });
  }

  _deletePost() {
    BlocProvider.of<PostCubit>(context).deletePost(post: PostEntity(postId: widget.post.postId));
  }

  _likePost() {
    BlocProvider.of<PostCubit>(context).likePost(post: PostEntity(postId: widget.post.postId));
  }
}
