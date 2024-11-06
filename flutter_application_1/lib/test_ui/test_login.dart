import 'package:flutter/material.dart';
import '../services/auth_service_2.dart'; // Import your AuthService

class SignupTestScreen extends StatefulWidget {
  @override
  _SignupTestScreenState createState() => _SignupTestScreenState();
}

class _SignupTestScreenState extends State<SignupTestScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final AuthService authService = AuthService();

  void _signup() async {
    try {
      final userCredential = await authService.signup(
        email: emailController.text,
        password: passwordController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        username: usernameController.text,
      );

      // Display success message or navigate
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Signup successful! UID: ${userCredential.user!.uid}'),
      ));
    } catch (e) {
      // Display error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Signup failed: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name')),
            TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name')),
            TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
