import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final List<dynamic> selectedLocations;
  
  const ReviewPage(
      {Key? key,
      required this.selectedLocations,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Locations"),
      ),
      body: ListView.builder(
        itemCount: selectedLocations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(selectedLocations[index]["result"]["name"]),
            subtitle:
                Text(selectedLocations[index]["result"]["formatted_address"]),
          );
        },
      ),
    );
  }
}
