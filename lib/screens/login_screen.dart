import 'package:flutter/material.dart';
import 'package:setap4a/main.dart';
import 'package:setap4a/screens/home_screen.dart';
import 'package:setap4a/screens/register_screen.dart';
import 'package:setap4a/screens/user_profile_pages/set_username_page.dart';
import 'package:setap4a/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService = AuthService();

  final _darkGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0f2027),
        Color(0xFF203a43),
        Color(0xFF2c5364),
      ],
    ),
  );

  Widget _authCard({required Widget child}) => Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: child,
        ),
      );

  ButtonStyle get btnStyle => ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  Future<void> login() async {
    try {
      final user = await authService.signInWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(themeNotifier: themeNotifier),
          ),
        );
      } else {
        _showSnackBar('Login failed: Invalid credentials');
      }
    } catch (e) {
      _showSnackBar('Login error: $e');
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final result = await authService.signInWithGoogleAndCheckUsername();
      if (result == null) return;

      final hasUsername = result['hasUsername'] == true;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => hasUsername
              ? HomeScreen(themeNotifier: themeNotifier)
              : SetUsernamePage(),
        ),
      );
    } catch (e) {
      _showSnackBar('Google login failed: $e');
    }
  }

  void goToRegister() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => RegisterScreen()));

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _darkGradient,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _authCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: btnStyle,
                      onPressed: login,
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: btnStyle,
                      onPressed: loginWithGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: goToRegister,
                      child: const Text("Don't have an account? Register"),
                    ),
                  ],
                ),
              ),
            ),
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
