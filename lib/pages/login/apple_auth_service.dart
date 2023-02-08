import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AppleAuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static String displayName = "";
  static String firstName = "";
  static String lastName = "";
  static String email = "";
  static String tokenId = "";
  static String uid = "";
  static String firebaseName;

  static Future<User> signInWithApple() async {
    //await Firebase.initializeApp();
    List<Scope> scopes = const [Scope.fullName, Scope.email];

    final result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);

    switch (result.status) {
      case AuthorizationStatus.authorized:
        {
          final appleIdCredential = result.credential;
          final AuthCredential credential =
              OAuthProvider('apple.com').credential(
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode),
            idToken: String.fromCharCodes(appleIdCredential.identityToken),
          );

          //Autenticação no Firebase
          final firebaseUser =
              (await _firebaseAuth.signInWithCredential(credential)).user;

          if (scopes.contains(Scope.fullName)) {
            displayName =
                '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';

            firstName = "${appleIdCredential.fullName.givenName}";
            lastName = "${appleIdCredential.fullName.familyName}";

            if (appleIdCredential.fullName.givenName != null ||
                appleIdCredential.fullName.familyName != null) {
              await firebaseUser.updateProfile(displayName: displayName);
            }

            firebaseName = firebaseUser.displayName != null
                ? firebaseUser.displayName
                : displayName;
            email = firebaseUser.providerData.first.email;
            tokenId = String.fromCharCodes(appleIdCredential.authorizationCode);
            uid = firebaseUser.providerData.first.uid;
          }

          return firebaseUser;
        }

      case AuthorizationStatus.error:
        {
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString(),
          );
        }

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
    }

    return null;
  }

  static Future<User> signOut() async {
    _firebaseAuth.signOut();
  }
}

class AppleSignInAvailable {
  AppleSignInAvailable(this.isAvailable);

  final bool isAvailable;

  static Future<AppleSignInAvailable> check() async {
    return AppleSignInAvailable(await AppleSignIn.isAvailable());
  }
}
