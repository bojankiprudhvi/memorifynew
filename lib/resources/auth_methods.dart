import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user_model.dart';
import 'dart:developer' as devtools show log;

import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:instagram_flutter/utils/show_error_dialog.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get User
  Future<MyUser> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection("users").doc(currentUser.uid).get();

    final gettingUser = MyUser.fromSnap(snapshot: snapshot.data()!);
    return gettingUser;
  }

  // Signup User
  Future<String> signupUser({
    required BuildContext context,
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some Error Occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        // registering user in auth with email and password
        UserCredential userCredentials =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        devtools.log(userCredentials.user!.uid.toString());

        final dawnloadUrlOfProfilePic =
            await StorageMethods().uploadImageToStorage(
          childName: "Profile Pics",
          file: file,
          isPost: false,
        );

        // Assigning to Model
        MyUser myUser = MyUser(
          email: email,
          uid: userCredentials.user!.uid,
          photoUrl: dawnloadUrlOfProfilePic,
          username: username,
          bio: bio,
          followers: [],
          following: [],
        );

        // adding user in our database
        await _firestore
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set(myUser.toJson());
        res = "success";
      }

      return res;
    } on FirebaseAuthException catch (e) {
      devtools.log(e.toString());
      if (e.code == 'weak-password') {
        devtools.log('The password provided is too weak.');
        await showErrorDialog(
          context,
          "Weak Password",
          "The password provided is too weak.",
        );
      } else if (e.code == 'email-already-in-use') {
        devtools.log('The account already exists for that email.');
        await showErrorDialog(
          context,
          "Email Already in Use",
          "The account already exists for that email.",
        );
      } else if (e.code == "invalid-email") {
        devtools.log("Invalid Email Address");
        await showErrorDialog(
          context,
          "Invalid Email Address",
          "Please Enter Correct Email Address it's Invalid",
        );
      }
      res = e.code;
      return res;
    } catch (e) {
      res = e.toString();
      return res;
    }
  }

  // logging in user
  Future<String> loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
        return res;
      }
      res = "Please enter all the fields";
      return res;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        devtools.log('No user found for that email.');
        await showErrorDialog(
          context,
          "User Not Found",
          "No user found for that email. Please try again.",
        );
      } else if (e.code == 'wrong-password') {
        devtools.log(
          'Wrong password provided for that user.',
        );
        await showErrorDialog(
          context,
          "Wrong Password",
          "Wrong password provided for that user. Please try again.",
        );
      } else {
        devtools.log(e.code.toString());
        await showErrorDialog(
            context, "Something Went Wrong", "Error:  ${e.code}");
      }
      res = e.code;
      return res;
    } catch (e) {
      res = e.toString();
      return res;
    }
  }

  // Sign out
  Future<void> signout() async {
    _auth.signOut();
  }
}
