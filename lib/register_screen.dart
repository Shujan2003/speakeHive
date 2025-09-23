import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;

  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final credential =await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'email': email.trim(),
        'role': 'user', // You can later change this to 'admin' in Firestore manually
      });

        // Sign out immediately after registering
        await FirebaseAuth.instance.signOut();

        // Show success and go to login screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully! Please log in.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 132, 157, 169),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Create Account',
        style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
    body: Stack(
  children: [
    Positioned.fill(
      child: Image.asset(
        'assets/bgscreen.png', 
        fit: BoxFit.cover,
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(25.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Email is required' : null,
              onChanged: (value) => email = value,
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => value != null && value.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
              onChanged: (value) => password = value,
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/auth');
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),


    );
  }
}
