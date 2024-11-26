import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/account.dart';
import 'package:flutter_application_1/pages/home.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'planner.dart'; // Import the Planner page
import 'friends.dart'; // Import the Friends page
import 'event_dashboard.dart'; // Import the EventDashboard page

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _formKey = GlobalKey<FormState>();
  String _eventName = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0; // Add an index for the bottom navigation bar
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Get the current user's username and email
    // username = FirebaseAuth.instance.currentUser.displayName;
    // email = FirebaseAuth.instance.currentUser.email;
  }

  // Function to load user data
  Future<void> _loadUserData() async {
    // Get the current user's username and email
    // username = FirebaseAuth.instance.currentUser.displayName;
    // email = FirebaseAuth.instance.currentUser.email;
  }

  // Function to pick the event date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to pick the event time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Function to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  // Function to handle event submission
  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Save event to Firestore
      _firestore.collection('events').add({
        'name': _eventName,
        'date': _selectedDate,
        'time': _selectedTime.format(context),
      });

      // Navigate to Planner page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Planner(
          eventName: _eventName,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
        )),
      );
    }
  }

  // Function to format the selected date
  String _formatDate() {
    return DateFormat.yMMMd().format(_selectedDate);
  }

  // Function to format the selected time
  String _formatTime() {
    return _selectedTime.format(context);
  }

  // these are where pages for the navigation bar are stored. 
  final List<Widget> _pages = <Widget>[
    Home(),
    EventDashboard(),
    EventPage(),
    FriendPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Event Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _eventName = value!;
                },
              ),
              SizedBox(height: 20),
              // Date Picker for event date
              Row(
                children: [
                  Text(
                    'Event Date: ${_formatDate()}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Pick Date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Time Picker for event time
              Row(
                children: [
                  Text(
                    'Event Time: ${_formatTime()}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text('Pick Time'),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: Text('Save Event'),
                ),
              ),
            ],
          ),
        ),
      ),
      // Navigation bar to switch between pages
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            //color: Colors.white,
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: 2, // Pass the selected index
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Pass the onItemTapped function
      ),
    );
  }
}
