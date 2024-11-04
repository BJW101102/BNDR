import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class Planner extends StatefulWidget {
  const Planner({super.key});

  @override
  State<Planner> createState() => _PlannerState();
}

class _PlannerState extends State<Planner> {
  LatLng? myCurrentLocation;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  final searchController = TextEditingController();
  var uuid = const Uuid();
  List<dynamic> listOfLocations = [];
  final String token = '1234567890';
  List<dynamic> selectedLocations = [];
  String userInput = "";

  //calls function to get current location of user
  @override
  void initState() {
    _getUserLocation();
    searchController.addListener(() {
      _onChange();
    });
    super.initState();
  }

  _onChange() {
    placeSuggestion(searchController.text);
  }

  //returns autocomplete suggestions using the google places API
  void placeSuggestion(String input) async {
    const String apiKey = "AIzaSyD_eIXoIx5zyyzehtsKDcjiaAyjaZm5A0A";
    try {
      String bassedUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request =
          '$bassedUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          listOfLocations = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception("Failed to load suggestions");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //1)move camerea to selected location and 2) if add button was pressed
  //automatically adds this place to the planner list
  void placeSelection(String input, bool add) async {
    const String apiKey = "AIzaSyD_eIXoIx5zyyzehtsKDcjiaAyjaZm5A0A";
    try {
      String bassedUrl =
          "https://maps.googleapis.com/maps/api/place/details/json";
      String request =
          '$bassedUrl?place_id=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        if (add == true) {
          selectedLocations.add(data);
        }
        var locationCoordinates = data['result']['geometry']['location'];
        LatLng newLocation =
            LatLng(locationCoordinates['lat'], locationCoordinates['lng']);

        setState(() {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                    locationCoordinates['lat'], locationCoordinates['lng']),
                zoom: 14,
              ),
            ),
          );
          markers.add(Marker(
              markerId: const MarkerId("Point of Interest"),
              position: newLocation));
        });
      } else {
        throw Exception("Failed to load location");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  //function that initializes user's location
  void _getUserLocation() async {
    try {
      Position position = await currentPosition();
      setState(() {
        myCurrentLocation = LatLng(position.latitude, position.longitude);
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: myCurrentLocation!,
          ),
        );
      });
    } catch (e) {
      print('Error fetching user newLocation: $e');
      setState(() {
        myCurrentLocation = const LatLng(0.0, 0.0);
      });
    }
  }

  //diaglog box for edit button
  void _showEditDialog(int index) {
    final TextEditingController _extraInfoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Extra Information'),
          content: TextField(
            controller: _extraInfoController,
            decoration:
                InputDecoration(hintText: "Enter additional details..."),
            autocorrect: false,
          ),
          actions: <Widget>[
            //cancel extra info addition
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            //save extra info
            TextButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  selectedLocations[index]['extraInfo'] =
                      _extraInfoController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              myLocationButtonEnabled: false,
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                googleMapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: myCurrentLocation!,
                zoom: 14,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 60, left: 16, right: 16),
              child: Column(
                children: [
                  TextField(
                    autocorrect: false,
                    controller: searchController,
                    decoration: InputDecoration(
                        hintText: "Search Places...",
                        filled: true,
                        fillColor: Colors.white),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  Visibility(
                    visible: searchController.text.isNotEmpty,
                    child: Container(
                      height: 200,
                      color: Colors.white.withOpacity(0.9),
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    placeSelection(
                                        listOfLocations[index]["place_id"],
                                        false);
                                  },
                                  child: Text(
                                      listOfLocations[index]["description"]),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  placeSelection(
                                      listOfLocations[index]["place_id"], true);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            //bottom half of the screen
            child: Container(
              color: Colors.grey[200],
              height: MediaQuery.of(context).size.height / 3,
              child: ListView.builder(
                itemCount: selectedLocations.length,
                itemBuilder: (context, index) {
                  //each entry gets its own container to store information
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //display name of location
                              Text(
                                "Location: " +
                                    selectedLocations[index]["result"]["name"],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              //display address
                              Text(
                                "Address: " +
                                    (selectedLocations[index]["result"]
                                        ["formatted_address"]),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              //display rating
                              Text(
                                "Rating: " +
                                    (selectedLocations[index]["result"]
                                                ["rating"]
                                            ?.toString() ??
                                        "No Rating"),
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              //display extra info if it exists
                              if (selectedLocations[index]
                                  .containsKey('extraInfo'))
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Notes: " +
                                        selectedLocations[index]['extraInfo'],
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        //edit button
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            _showEditDialog(index);
                          },
                        ),
                        //remove button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              selectedLocations.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.white,
      //   child: const Icon(
      //     Icons.my_location,
      //     size: 30,
      //   ),
      //   onPressed: () async {
      //     Position position = await currentPosition();
      //     googleMapController.animateCamera(
      //       CameraUpdate.newCameraPosition(
      //         CameraPosition(
      //           target: LatLng(position.latitude, position.longitude),
      //           zoom: 14,
      //         ),
      //       ),
      //     );
      //     markers.clear();
      //     markers.add(
      //       Marker(
      //         markerId: const MarkerId('currentLocation'),
      //         position: LatLng(position.latitude, position.longitude),
      //       ),
      //     );
      //     setState(() {});
      //   },
      // ),
    );
  }
}

//handles user location permissions and returns their current position
Future<Position> currentPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Location services are disabled';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permission denied';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied';
  }

  return await Geolocator.getCurrentPosition();
}
