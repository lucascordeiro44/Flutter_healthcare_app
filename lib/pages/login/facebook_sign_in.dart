import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class FacebookAuthService {

  static final facebookLogin = FacebookLogin();
  static bool isLoggedIn = false;
  static String firstName = "";
  static String lastName = "";
  static String email = "";
  static String tokenId = "";
  static String uid = "";


  static Future<Map<String, dynamic>> signInFB() async {
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        tokenId = result.accessToken.token;
        print("Token Facebook $tokenId");
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${tokenId}');
        final Map<String, dynamic> profile = jsonDecode(graphResponse.body);
        final fullName = profile["name"];
        email = profile["email"];
        uid = profile["id"];

        if (fullName.contains(" ")) {
          List<String> splitName = fullName.split(" ");
          firstName = splitName[0];
          lastName = splitName[1];
        }
        isLoggedIn = true;
        print(profile);
        return profile;
        break;

      case FacebookLoginStatus.cancelledByUser:
        isLoggedIn = false;
        return null;
        break;
      case FacebookLoginStatus.error:
        isLoggedIn = false;
        return null;
        break;
    }
  }

  static logout(){
    facebookLogin.logOut();
    isLoggedIn = false;
    print("Facebook User Signed Out");
  }
}







