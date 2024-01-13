import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final username = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/bg.jpg"),
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.2),
              BlendMode.dstATop,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/icon.png',
                  height: 150,
                ),
                // Replace with your logo
                const SizedBox(height: 50),
                _usernameField(),
                const SizedBox(height: 20),
                _passwordField(),
                const SizedBox(height: 20),
                _loginButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _usernameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: username,
        decoration: const InputDecoration(
          hintText: 'Username',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: password,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Password',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await _auth.signInWithEmailAndPassword(
              email: username.value.text, password: password.value.text);
          if (mounted) {
            Navigator.pop(context);
          }
        } catch (err) {
          _showMyDialog();
        }
      },
      child: const Text('Login'),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('กรุณาตรวจสอบข้อมูล'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('username หรือ password ไม่ถูกต้อง'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }
}
