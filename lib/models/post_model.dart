import 'package:flutter/material.dart';

class Post {
  // User info
  final String uid;
  final String username;
  final String profileImg;
  // Post info
  final String postId;
  final String postUrl;
  final String description;
  final datePublished;
  final likes;

  Post({
    required this.uid,
    required this.username,
    required this.profileImg,
    required this.postId,
    required this.postUrl,
    required this.description,
    required this.datePublished,
    required this.likes,
  });

  factory Post.fromSnap({required Map<String, dynamic> snapshot}) {
    return Post(
      uid: snapshot["uid"],
      username: snapshot["username"],
      profileImg: snapshot["profileImg"],
      postId: snapshot["postId"],
      postUrl: snapshot["postUrl"],
      description: snapshot["description"],
      datePublished: snapshot["datePublished"],
      likes: snapshot["likes"],
    );
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "profileImg": profileImg,
        "postId": postId,
        "postUrl": postUrl,
        "description": description,
        "datePublished": datePublished,
        "likes": likes,
      };
}
