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
      print('Error fetching user location: $e');
      // Optionally, set a default location or handle the error
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
      // Get the total height of the screen
      double screenHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        body: Container(
          margin: EdgeInsets.only(top: 60),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(hintText: "Search Places..."),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              Visibility(
                visible: searchController.text.isEmpty ? false : true,
                child: Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {},
                        child: Text(
                          listOfLocations[index]["description"],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Planner in the top half
              SizedBox(
                height: screenHeight / 2,
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
              // Bottom half content
              Expanded(
                child: Container(
                  color: Colors.grey[200],
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
