import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
class Locator extends StatelessWidget {
  Locator({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GeolocationApp(),
    );
  }
}

class GeolocationApp extends StatefulWidget {
  const GeolocationApp({super.key});

  @override
  State<GeolocationApp> createState() => _GeolocationAppState();
}

class _GeolocationAppState extends State<GeolocationApp> {
  @override
  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;
  String _currentAddress = "";
  Widget build(BuildContext context) {
    Future<Position> _getCurrentLocation() async {
      servicePermission = await Geolocator.isLocationServiceEnabled();
      if (!servicePermission) {
        print("service disabled");
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return await Geolocator.getCurrentPosition();
    }
    
    _getAddressFromCoordinates() async{
      try{
        List<Placemark> placemarks = await placemarkFromCoordinates(_currentLocation!.latitude, _currentLocation!.longitude);

        Placemark place = placemarks[0];
        setState((){
          _currentAddress = "${place.locality}, ${place.country}";
        });
      }catch(e){
        print(e);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("User Location"),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Location coordinates:"),
          Text(
              "Latitute = ${_currentLocation?.latitude} Longitude = ${_currentLocation?.longitude}"),
          Text("Location Address:"),
          Text("${_currentAddress}"),
          ElevatedButton(
              onPressed: () async {
                _currentLocation = await _getCurrentLocation();
                await _getAddressFromCoordinates();
              },
              child: Text("test")),
        ],
      )),
    );
  }
}
