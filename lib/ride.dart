import 'package:flutter/material.dart';
import 'services.dart';

class RidePage extends StatefulWidget {
  final String driverId;
  RidePage({required this.driverId});

  @override
  _RidePageState createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  void bookRide() {
    _firestoreService.bookTukTuk(
      widget.driverId,
      nameController.text.trim(),
      mobileController.text.trim(),
      pickupController.text.trim(),
      dropController.text.trim(),
      timeController.text.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book a Ride")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Your Name")),
            TextField(controller: mobileController, decoration: InputDecoration(labelText: "Mobile Number")),
            TextField(controller: pickupController, decoration: InputDecoration(labelText: "Pickup Location")),
            TextField(controller: dropController, decoration: InputDecoration(labelText: "Drop Location")),
            TextField(controller: timeController, decoration: InputDecoration(labelText: "Preferred Time")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: bookRide, child: Text("Confirm Booking")),
          ],
        ),
      ),
    );
  }
}
