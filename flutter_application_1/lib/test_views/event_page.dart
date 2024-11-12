import 'package:flutter/material.dart';
import '../services/event_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  void _loadUserEvents() {
    _currentEvents = _eventService.getAllUserEvents(
      userID: widget.userID,
      eventType: 'accepted',
    );
    _requestedEvents = _eventService.getAllUserEvents(
      userID: widget.userID,
      eventType: 'requested',
    );
  }

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
        _loadUserEvents();
      });
    } catch (e) {
      setState(() {
        _eventCreationStatus = 'Error: $e';
      });
    }
  }

  Future<void> _sendEventRequest(String eventID) async {
    if (eventID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid event ID.')),
      );
      return;
    }

    try {
      bool success = await _eventService.handleEventRequest(
        userID: widget.userID,
        eventID: eventID,
        accept: true, // This example assumes sending as an acceptance
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event request sent successfully!')),
        );
        _loadUserEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send event request.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _inviteFriendToEvent(String eventID) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController friendNameController = TextEditingController();

        return AlertDialog(
          title: Text('Invite Friend'),
          content: TextField(
            controller: friendNameController,
            decoration: InputDecoration(
              labelText: 'Friend\'s Username',
              hintText: 'Enter friend\'s username',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String friendName = friendNameController.text.trim();
                if (friendName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a username.')),
                  );
                  return;
                }

                try {
                  bool success = await _eventService.sendEventRequest(
                    friendName: friendName,
                    eventID: eventID,
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invite sent successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send invite.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }

                Navigator.pop(context);
              },
              child: Text('Invite'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleEventResponse(String eventID, bool accept) async {
    try {
      bool success = await _eventService.handleEventRequest(
        userID: widget.userID,
        eventID: eventID,
        accept: accept,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(accept ? 'Event accepted!' : 'Event declined!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event status.')),
        );
      }

      // Reload the events after action
      _loadUserEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Event Creation Section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _eventNameController,
                    decoration: InputDecoration(labelText: 'Event Name'),
                  ),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                        labelText: 'Location ID(s) (comma-separated)'),
                  ),
                  TextField(
                    controller: _timeController,
                    decoration: InputDecoration(labelText: 'Time'),
                  ),
                  TextField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                  ),
                  ElevatedButton(
                    onPressed: _createEvent,
                    child: Text('Create Event'),
                  ),
                  Text(_eventCreationStatus),
                ],
              ),
            ),

            // Display Current Events
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _currentEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data!.isEmpty) {
                  return Text('No current events.');
                } else {
                  return ExpansionTile(
                    title: Text('Current Events'),
                    children: snapshot.data!.map((event) {
                      return ListTile(
                        title: Text(event['eventName']),
                        subtitle: Text(
                            'Date: ${event['date']} | Time: ${event['time']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Invite button
                            IconButton(
                              icon: Icon(Icons.person_add),
                              onPressed: () =>
                                  _inviteFriendToEvent(event['id']),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),

            // Display Requested Events
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _requestedEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data!.isEmpty) {
                  return Text('No requested events.');
                } else {
                  return ExpansionTile(
                    title: Text('Requested Events'),
                    children: snapshot.data!.map((event) {
                      return ListTile(
                        title: Text(event['eventName']),
                        subtitle: Text(
                            'Date: ${event['date']} | Time: ${event['time']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Accept button
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () =>
                                  _handleEventResponse(event['id'], true),
                            ),
                            // Decline button
                            IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () =>
                                  _handleEventResponse(event['id'], false),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
