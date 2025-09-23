import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grievance/auth_screen.dart';
import 'package:grievance/homescreen.dart';
import 'package:grievance/mycomplaints.dart';
import 'package:grievance/register_screen.dart';
import 'package:grievance/submitcomplaint.dart';
import 'firebase_options.dart';
import 'package:grievance/admin_screen.dart';



void main()async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:
   DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'SpeakHive',
  initialRoute: '/',
  routes: {
   '/': (context) => StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (!snapshot.hasData) {
      return const AuthScreen();
    } else {
      //  Check user role
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(snapshot.data!.uid)
            .get(),
        builder: (context, roleSnapshot) {
          if (roleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
            return const AuthScreen(); // fallback
          }

          final role = roleSnapshot.data!.get('role');
          if (role == 'admin') {
            return const AdminScreen();
          } else {
            return Homescreen();
          }
        },
      );
    }
  },
),

    '/auth': (context) => const AuthScreen(),
    '/register': (context) => const RegisterScreen(),
    '/submit': (context) => const SubmitComplaintScreen(),
    '/mycomplaints': (context) => const MyComplaints(),
    '/admin': (context) => const AdminScreen(),

    
  },
);


  }
}