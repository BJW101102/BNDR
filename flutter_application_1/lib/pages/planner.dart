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

  void placeSelection(String input) async {
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
        var location = data['result']['geometry']['location'];
        LatLng newLocation = LatLng(location['lat'], location['lng']);

        setState(() {
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
      // Optionally, set a default newLocation or handle the error
      setState(() {
        myCurrentLocation = const LatLng(0.0, 0.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (myCurrentLocation == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: [
            // Google Map as the background layer
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
            // Positioned widget for search and list overlay
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
                        height: 200, // Adjust as necessary
                        color: Colors.white.withOpacity(0.9),
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {},
                              child: TextButton(
                                onPressed: () {
                                  placeSelection(
                                      listOfLocations[index]["place_id"]);
                                },
                                child:
                                    Text(listOfLocations[index]["description"]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom half content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.grey[200],
                height: MediaQuery.of(context).size.height / 3,
                child: Center(
                  child: Text(
                    "Bottom half of the screen",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.my_location,
            size: 30,
          ),
          onPressed: () async {
            Position position = await currentPosition();
            googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 14,
                ),
              ),
            );
            markers.clear();
            markers.add(
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: LatLng(position.latitude, position.longitude),
              ),
            );
            setState(() {});
          },
        ),
      );
    }
  }

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
}
