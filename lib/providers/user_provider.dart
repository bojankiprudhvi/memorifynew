import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user_model.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';

class UserProvider extends ChangeNotifier {
  MyUser? _user;
  final AuthMethods _authMethods = AuthMethods();

  MyUser? get getUser => _user;

  Future<void> refreshUser() async {
    MyUser user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
