import 'package:frontend/model/user_model2.dart';

abstract class SocialLogin {
  Future<UserModel2> login();
  Future<bool> logout();
}
