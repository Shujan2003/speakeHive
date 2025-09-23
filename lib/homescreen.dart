import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  
 void signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  // Navigate to AuthScreen
  Navigator.pushReplacementNamed(context, '/auth');

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Signed out")),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 184, 154),
      appBar: AppBar(
       title: Text(
  "SpeakHive",
  style: GoogleFonts.oswald(
    textStyle: TextStyle(color: Colors.white),
  ),
  
),

        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(onPressed: () => signOut(context),
 icon: Icon(Icons.logout_sharp,color: Colors.white),
          tooltip: "Logout",)
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome, Student!",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black),
              ),
              SizedBox(height: 40,),
              ElevatedButton.icon(onPressed: ()
              {
                Navigator.pushNamed(context, '/submit');
              },
               label: Text("Submit Complaint",
              style: TextStyle(color: Colors.deepPurple),),icon: Icon(Icons.report),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.white
              ),),
              SizedBox(height: 20,),
              ElevatedButton.icon(onPressed: ()
              {
                  Navigator.pushNamed(context, '/mycomplaints');
              },
               label: Text("My Complaints",style: 
              TextStyle(color: Colors.deepPurple),),
              icon: Icon(Icons.list_sharp,),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.white
              ),
              )
              
            ],
          ),
        ),
      ),

    );
  }
}