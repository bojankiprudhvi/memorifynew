import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/widgets/follow_button.dart';
import 'dart:developer' as devtools show log;

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  bool isLoading = false;
  var postLength = 0;
  var followers = 0;
  var following = 0;
  bool isFollowing = false;

  @override
  void initState() {
    // FirebaseAuth.instance.signOut();
    super.initState();
    getData();
  }

  getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      devtools.log(widget.uid);
      devtools.log(FirebaseAuth.instance.currentUser!.uid);
      // Getting user's data
      DocumentSnapshot<Map<String, dynamic>> getUserData =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(widget.uid)
              .get();
      setState(() {
        userData = getUserData.data()!;
        followers = getUserData.data()!["followers"].length;
        following = getUserData.data()!["following"].length;
        isFollowing = getUserData
            .data()!["followers"]
            .contains(FirebaseAuth.instance.currentUser!.uid);
      });

      // Getting posts length
      QuerySnapshot<Map<String, dynamic>> getPostsLength =
          await FirebaseFirestore.instance
              .collection("posts")
              .where("uid", isEqualTo: widget.uid)
              .get();

      setState(() {
        postLength = getPostsLength.docs.length;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      devtools.log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? const Center(
            child: CircularProgressIndicator(
              color: blueColor,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData["username"]),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userData["photoUrl"]),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLength, "Posts"),
                                    buildStatColumn(followers, "followers"),
                                    buildStatColumn(following, "following"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    (FirebaseAuth.instance.currentUser!.uid) ==
                                            (widget.uid)
                                        ? FollowButton(
                                            text: "Sign Out",
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            textColor: primaryColor,
                                            function: () {
                                              AuthMethods().signout();
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen(),
                                                  ));
                                            },
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                text: "Unfollow",
                                                backgroundColor: Colors.white,
                                                borderColor: Colors.grey,
                                                textColor: Colors.black,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followAndUnfollowUser(
                                                    currentUsersUid:
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                    followUid: userData["uid"],
                                                  );
                                                  isFollowing = false;
                                                  followers--;
                                                  setState(() {});
                                                },
                                              )
                                            : FollowButton(
                                                text: "Follow",
                                                backgroundColor: Colors.blue,
                                                borderColor: Colors.blue,
                                                textColor: Colors.white,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followAndUnfollowUser(
                                                    currentUsersUid:
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                    followUid: userData["uid"],
                                                  );
                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
                                              )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData["username"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          userData["bio"],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("posts")
                      .where("uid", isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        if (snapshot.hasData) {
                          return MasonryGridView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            gridDelegate:
                                const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  snapshot.data?.docs[index]["postUrl"],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: blueColor,
                            ),
                          );
                        }
                      case ConnectionState.waiting:
                        return const Center(
                          child: CircularProgressIndicator(
                            color: blueColor,
                          ),
                        );
                      default:
                        return const Center(
                          child: RefreshProgressIndicator(),
                        );
                    }
                  },
                ),
              ],
            ),
          );
  }

  Widget buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
