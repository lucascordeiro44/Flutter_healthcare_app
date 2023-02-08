import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class GoogleAuthService {

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();
  static bool isGoogleUser = false;

  static String firstName = "";
  static String fullName = "";
  static String lastName = "";
  static String email = "";
  static String imageUrl = "";
  static String idToken = "";
  static String uid = "";

  static Future<User> signInWithGoogle() async {
   await signOutGoogle();
    await Firebase.initializeApp();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    print("IdToken >>> ${googleSignInAuthentication.idToken}");

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);
      assert(user.email != null);
      assert(user.displayName != null);
      isGoogleUser = true;
      // Store the retrieved data
      fullName = user.displayName;
      email = user.email;
      imageUrl = user.photoURL != null ? user.photoURL : ""  ;
      idToken = googleSignInAuthentication.idToken;
      List<UserInfo> providers = user.providerData;
      UserInfo userInfo = providers.first;
      uid = userInfo.uid;

      if (fullName.contains(" ")) {
        List<String> splitName = fullName.split(" ");
        firstName = splitName[0];
        lastName = splitName[1];
      }
      return user;
    }

    return null;
  }

  static Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    print("Google User Signed Out");
  }
}






