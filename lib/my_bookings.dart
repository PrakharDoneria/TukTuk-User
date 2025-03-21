import 'package:flutter/material.dart';
import 'services.dart';

class MyBookingsPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Bookings")),
      body: StreamBuilder(
        stream: _firestoreService.getUserBookings(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              return ListTile(
                title: Text(booking['driverName']),
                subtitle: Text("Pickup: ${booking['pickupLocation']} → Drop: ${booking['dropLocation']}"),
                trailing: Text(booking['status']),
              );
            },
          );
        },
      ),
    );
  }
}
