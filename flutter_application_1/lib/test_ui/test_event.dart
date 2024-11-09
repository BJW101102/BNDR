import 'package:flutter/material.dart';
import '../services/event_service.dart';

class EventTestPage extends StatefulWidget {
  final String userID;

  EventTestPage({required this.userID});

  @override
  _EventTestPageState createState() => _EventTestPageState();
}

class _EventTestPageState extends State<EventTestPage> {
  final EventService eventService = EventService();
  late Future<List<Map<String, dynamic>>> userEvents;

  final _eventNameController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _eventTimeController = TextEditingController();
  final _eventLocationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userEvents = eventService.getAllUserEvents(userID: widget.userID);
  }

  void _createEvent() async {
    String eventName = _eventNameController.text;
    String eventDate = _eventDateController.text;
    String eventTime = _eventTimeController.text;
    List<String> eventLocations = _eventLocationsController.text.split(',');

    bool success = await eventService.createEvent(
        userID: widget.userID,
        eventName: eventName,
        date: eventDate,
        time: eventTime,
        locationIDs: eventLocations);

    if (success) {
      setState(() {
        userEvents = eventService.getAllUserEvents(
            userID: widget.userID); // Refresh events
      });
      Navigator.of(context).pop(); // Close the dialog after submission
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event. Please try again.')),
      );
    }
  }

  void _showAddEventForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: _eventDateController,
                decoration:
                    InputDecoration(labelText: 'Event Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: _eventTimeController,
                decoration: InputDecoration(labelText: 'Event Time (HH:MM)'),
              ),
              TextField(
                controller: _eventLocationsController,
                decoration:
                    InputDecoration(labelText: 'Locations (comma separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: _createEvent, // Create event when pressed
              child: Text('Add Event'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed:
                _showAddEventForm, // Show the add event form when clicked
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: userEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found.'));
          } else {
            List<Map<String, dynamic>> events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(event['eventName']),
                    subtitle: Text(
                        'Date: ${event['date']}, Time: ${event['time']}\nLocations: ${event['locations'].join(', ')}'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Event Details'),
                            content: Text(
                              'Event Name: ${event['eventName']}\n'
                              'Date: ${event['date']}\n'
                              'Time: ${event['time']}\n'
                              'Locations: ${event['locations'].join(', ')}\n'
                              'Accepted Participants: ${event['participants']['accepted'].join(', ')}\n'
                              'Requested Participants: ${event['participants']['requested'].join(', ')}\n'
                              'Declined Participants: ${event['participants']['declined'].join(', ')}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
