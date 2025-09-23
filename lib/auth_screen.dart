import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        final user = await AuthService().signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/');
        }
      } on FirebaseAuthException catch (e) {
        showSnack(e.message ?? 'Login failed');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      showSnack("Google Sign-In failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final enteredEmail = emailController.text.trim();
              Navigator.of(context).pop(); // Close dialog
              if (enteredEmail.isNotEmpty) {
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: enteredEmail);
                  showSnack("Password reset email sent.");
                } catch (e) {
                  showSnack("Error: $e");
                }
              }
            },
            child: const Text('Send'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 132, 157, 169),
      //backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Sigh in",
        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
       backgroundColor: Colors.deepPurple,
       //backgroundColor: Colors.amber,
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
    Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text("Welcome to SpeakHive",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (val) => val!.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? "Minimum 6 characters" : null,
              ),
              TextButton(
                onPressed: showForgotPasswordDialog,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text("Login",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isLoading ? null : signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Don't have an account? Create one",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
),
    );
  }
}
