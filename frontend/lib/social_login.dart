import 'package:frontend/user_model.dart';

abstract class SocialLogin {
  Future<UserModel> login();
  Future<bool> logout();
}
