import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import '../components/bottom_navbar.dart'; // Import the reusable bottom navbar widget

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

  // Function to format the date and time display
  String _formatDate() {
    return DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  String _formatTime() {
    return _selectedTime.format(context);
  }

  // Function to save the event details into Firestore
  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Get current user's UID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        try {
          // Reference to user's document in Firestore
          DocumentReference userDoc =
              _firestore.collection('users').doc(userId);

          // Add the event to the subcollection 'eventsList'
          await userDoc.collection('eventsList').doc(_eventName).set({
            'eventDate': _formatDate(),
            'eventTime': _formatTime(),
            'places': []
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event "$_eventName" saved successfully.')),
          );
        } catch (e) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save event. Please try again.')),
          );
        }
      }
    }
  }

  // Function to handle item tap for bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
              // Save Button
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
