import 'package:flutter/material.dart';
import '../../services/event_service.dart';

class EventScreen extends StatefulWidget {
  final String userID;

  EventScreen({required this.userID});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final EventService _eventService = EventService();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _eventIDController = TextEditingController();
  String _eventCreationStatus = '';

  late Future<List<Map<String, dynamic>>> _currentEvents;
  late Future<List<Map<String, dynamic>>> _requestedEvents;

  Future<void> _createEvent() async {
    String eventName = _eventNameController.text.trim();
    List<String> locationIDs = [_locationController.text.trim()];
    String time = _timeController.text.trim();
    String date = _dateController.text.trim();

    if (eventName.isEmpty ||
        locationIDs.isEmpty ||
        time.isEmpty ||
        date.isEmpty) {
      setState(() {
        _eventCreationStatus = 'Please fill in all fields.';
      });
      return;
    }

    try {
      bool success = await _eventService.createEvent(
        userID: widget.userID,
        eventName: eventName,
        locationIDs: locationIDs,
        time: time,
        date: date,
      );

      setState(() {
        _eventCreationStatus =
            success ? 'Event created successfully!' : 'Failed to create event.';
      });
    } catch (e) {
      setState(() {
        _eventCreationStatus = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create an Event',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: _locationController,
              decoration:
                  InputDecoration(labelText: 'Location IDs (comma-separated)'),
            ),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Time (HH:MM)'),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createEvent,
              child: Text('Create Event'),
            ),
            Text(
              _eventCreationStatus,
              style: TextStyle(color: Colors.red),
            ),
            Divider(height: 30, thickness: 2),
            Text(
              'Send Event Request',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _eventIDController,
              decoration: InputDecoration(labelText: 'Event ID'),
            ),
            SizedBox(height: 10),
            Divider(height: 30, thickness: 2),
            Text(
              'Current Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _currentEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No current events.');
                } else {
                  return Column(
                    children: snapshot.data!
                        .map((event) => ListTile(
                              title: Text(event['eventName']),
                              subtitle: Text(
                                  'Date: ${event['eventDate']} - Time: ${event['eventTime']}'),
                            ))
                        .toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
