import 'package:flutter/material.dart';
import 'package:setap4a/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void loginChecker() {
    // Theo's turn!
    // use the line below for a valid entry
    if (usernameController.text == passwordController.text) {
      // ^^ use these two things to access the contents of the text fields :)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
    // i'll make a fail later just for now its not needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
            alignment: Alignment.center,
            child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  children: [
                    Text('Login'),
                    TextField(
                        controller: usernameController,
                        decoration: InputDecoration(labelText: 'Username')),
                    TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password')),
                    DecoratedBox(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 150, 148, 148)),
                      child: MaterialButton(
                        onPressed: loginChecker,
                        child: Text('Login'),
                      ),
                    )
                  ],
                ))));
  }
}
