import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/comment_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/global_variables.dart';
import 'dart:developer' as devtools show log;
import 'package:instagram_flutter/utils/show_snackbar.dart';
import 'package:instagram_flutter/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLength = 0;

  Future<int> getComments() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.post.data()["postId"])
          .collection("comments")
          .get();

      commentLength = result.docs.length;
      setState(() {
        
      });
      return commentLength;
    } catch (e) {
      devtools.log(e.toString());
      return 0;
    }
  }

  @override
  void initState() {
    getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final user = Provider.of<UserProvider>(context).getUser;
    return Container(
      margin: width > webScreenSize
          ? EdgeInsets.symmetric(horizontal: width / 3, vertical: width * 0.003)
          : null,
      decoration: BoxDecoration(
        color: mobileBackgroundColor,
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 16,
              ).copyWith(right: 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage:
                        NetworkImage(widget.post.data()["profileImg"]),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.data()["username"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              children: ["Delete"]
                                  .map(
                                    (e) => InkWell(
                                      onTap: () async {
                                        await FirestoreMethods().deletePost(
                                            widget.post.data()["postId"]);

                                        showSnackbar(
                                          context: context,
                                          content:
                                              "Post Deleted Successfully...",
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        child: Text(
                                          e.toString(),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            // Image Section
            GestureDetector(
              onDoubleTap: () async {
                setState(() {
                  isLikeAnimating = true;
                });
                await FirestoreMethods().likePost(
                  postId: widget.post.data()["postId"],
                  uid: user!.uid,
                  likes: widget.post.data()["likes"],
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    child: Image.network(
                      widget.post.data()["postUrl"],
                      fit: BoxFit.cover,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(microseconds: 200),
                    opacity: isLikeAnimating ? 1 : 0,
                    child: LikeAnimation(
                      isAnimating: isLikeAnimating,
                      smallLike: false,
                      duration: const Duration(
                        milliseconds: 400,
                      ),
                      onEnd: () {
                        setState(() {
                          isLikeAnimating = false;
                        });
                      },
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 120,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Footer Section
            Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.post.data()["likes"].contains(
                        user?.uid,
                      ),
                  smallLike: true,
                  child: IconButton(
                    onPressed: () async {
                      await FirestoreMethods().likePost(
                        postId: widget.post.data()["postId"],
                        uid: user!.uid,
                        likes: widget.post.data()["likes"],
                      );
                    },
                    icon: (widget.post.data()["likes"].contains(user?.uid))
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border_outlined,
                            color: Colors.white,
                          ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        post: widget.post,
                      ),
                    ));
                  },
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.bookmark_border,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Description and number of Comments
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    child: Text(
                      "${widget.post.data()["likes"].length.toString()} likes",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: widget.post.data()["username"],
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "  ${widget.post.data()['description']} ",
                            style: const TextStyle(
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "View all ${commentLength} comments.",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      DateFormat.yMMMd()
                          .format(widget.post.data()["datePublished"].toDate()),
                      style: const TextStyle(
                        color: secondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
