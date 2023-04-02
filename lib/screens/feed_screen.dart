import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/global_variables.dart';
import 'package:instagram_flutter/widgets/post_card.dart';
import 'dart:developer' as devtools show log;
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    String _value = 'travel';
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              title:  Image.asset("assets/ic_instagram.png",
                
                height: 32,
              ),
              actions: [
                   new DropdownButton<String>(
          value: _value,
          items: <DropdownMenuItem<String>>[
            new DropdownMenuItem(
              child: new Text('travel'),
              value: 'travel',
            ),
            new DropdownMenuItem(
              child: new Text('food'),
              value: 'food'
            ),
          ], 
          onChanged: (String? value) {
            print(value!);
            setState(() => _value = value!);
            print(_value);
          },),



                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.messenger_outline,
                  ),
                ),
            
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .orderBy("datePublished", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    final eachPost = snapshot.data!.docs[index];
                    return PostCard(
                      post: eachPost,
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: RefreshProgressIndicator(),
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
    );
  }
}
