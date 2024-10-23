import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';


class Planner extends StatefulWidget {
  const Planner({super.key});

  @override
  State<Planner> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<Planner> {
  LatLng? myCurrentLocation;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GooglePlaceAutoCompleteTextField(
                googleAPIKey: 'AIzaSyD_eIXoIx5zyyzehtsKDcjiaAyjaZm5A0A',
                textEditingController: TextEditingController(),
                inputDecoration: InputDecoration(
                  hintText: 'Search here',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
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
