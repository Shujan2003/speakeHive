import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService 
{

  final FirebaseAuth auth=FirebaseAuth.instance;

  //Email login
  Future<User?> signInWithEmail(String email,String password) async
  {
    final result= await auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }
  //Register
Future<User?> registerWithEmail(String email, String password) async {
  final result = await auth.createUserWithEmailAndPassword(
      email: email, password: password);
  final user = result.user;

  // Save user role in Firestore
  if (user != null) {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': email,
      'role': 'user',
    });
  }
  return user;
}

  //Google Sign in
  Future<User?> signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  if (googleUser == null) return null;

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final result = await auth.signInWithCredential(credential);
  final user = result.user;

  if(user != null)
  {
    final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .get();

    if(!userDoc.exists)
    {
      await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({'email':'user.email','role':'user'});
    }
  }
  return user;
}

  //Sign out
  Future<void> signOut() async{
    await auth.signOut();
  }
}

