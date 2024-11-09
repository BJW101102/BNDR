import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Import your AuthService
import '../test_ui/test_friends.dart'; // Import the Friends page
import '../test_ui/test_event.dart'; // Import the EventTestPage

class AuthTestScreen extends StatefulWidget {
  @override
  _AuthTestScreenState createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final AuthService authService = AuthService();

  bool isSignupMode = true; // Track if the user is in signup or login mode
  int _selectedIndex = 0; // Navigation index for switching between pages

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method for handling sign up
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

  // Method for handling login
  void _login() async {
    try {
      final userCredential = await authService.signin(
        email: emailController.text,
        password: passwordController.text,
      );

      // Display success message or navigate
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login successful! UID: ${userCredential.user!.uid}'),
      ));

      // Navigate to the EventTestPage and pass the UID
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventTestPage(userID: userCredential.user!.uid),
        ),
      );
    } catch (e) {
      // Display error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isSignupMode ? 'Signup Test' : 'Login Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email input
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            // Password input
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            // Show these fields only in signup mode
            if (isSignupMode) ...[
              // First name input
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              // Last name input
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              // Username input
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
            ],
            SizedBox(height: 20),
            // Button for signup or login
            ElevatedButton(
              onPressed: isSignupMode ? _signup : _login,
              child: Text(isSignupMode ? 'Sign Up' : 'Log In'),
            ),
            SizedBox(height: 20),
            // Toggle between sign-up and login
            TextButton(
              onPressed: () {
                setState(() {
                  isSignupMode = !isSignupMode;
                });
              },
              child: Text(isSignupMode
                  ? 'Already have an account? Login'
                  : 'Don\'t have an account? Sign up'),
            ),
            SizedBox(height: 20),
            // Navigation bar for event or friends
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Friends',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'Events',
                ),
              ],
            ),
            // Switch between pages based on selected index
            Expanded(
              child: _selectedIndex == 0
                  ? FriendsPage(userID: 'testUserID') // Use actual user ID here
                  : EventTestPage(
                      userID: 'testUserID'), // Pass the user ID here
            ),
          ],
        ),
      ),
    );
  }
}
