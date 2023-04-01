import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/utils/global_variables.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;

  ResponsiveLayout({
    super.key,
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  bool isLoadingData = false;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    setState(() {
      isLoadingData = true;
    });
    DocumentSnapshot<Map<String, dynamic>> result = await FirebaseFirestore
        .instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (result.data() != null) {
      if (mounted) {
        await Provider.of<UserProvider>(context, listen: false).refreshUser();

        isLoadingData = false;
        setState(() {});
      }
    } else {
      await Future.delayed(const Duration(seconds: 5));
      if (result.data() != null) {
        if (mounted) {
          await Provider.of<UserProvider>(context, listen: false).refreshUser();

          isLoadingData = false;
          setState(() {});
        }
      } else {
        await Future.delayed(const Duration(seconds: 5));
        if (result.data() != null) {
          if (mounted) {
            await Provider.of<UserProvider>(context, listen: false)
                .refreshUser();

            isLoadingData = false;
            setState(() {});
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoadingData == false
        ? LayoutBuilder(
            builder: (context, contraints) {
              if (contraints.maxWidth > webScreenSize) {
                // Web Screen
                return widget.webScreenLayout;
              } else {
                return widget.mobileScreenLayout;
              }
            },
          )
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
  }
}
