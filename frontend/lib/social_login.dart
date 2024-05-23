import 'package:flutter/material.dart';

abstract class SocialLogin {
  Future<String?> login(BuildContext context);
  Future<bool> logout();
}
