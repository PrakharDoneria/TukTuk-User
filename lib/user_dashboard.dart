import 'package:flutter/material.dart';
import 'services.dart';
import 'ride.dart';
import 'my_bookings.dart';

class UserDashboard extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Tuk-Tuks"),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyBookingsPage()));
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestoreService.getAvailableTukTuks(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final drivers = snapshot.data.docs;

          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              var driver = drivers[index];
              return ListTile(
                title: Text(driver['name']),
                subtitle: Text("Auto No: ${driver['plate']} | City: ${driver['city']}"),
                trailing: ElevatedButton(
                  child: Text("Book"),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RidePage(driverId: driver.id)));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
