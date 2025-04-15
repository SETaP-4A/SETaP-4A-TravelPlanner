import 'package:flutter/material.dart';
import 'package:setap4a/screens/home_screen.dart';
import 'package:setap4a/screens/register_screen.dart';
import 'package:setap4a/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();

  Future<void> login() async {
    try {
      final user = await authService.signInWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: Invalid credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final user = await authService.signInWithGoogle();

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google login was cancelled')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google login failed: $e')),
      );
    }
  }

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Login'),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                child: Text('Login'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: loginWithGoogle,
                child: Text('Continue with Google'),
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: goToRegister,
                child: Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
