import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get available tuk-tuks (not booked)
  Stream<QuerySnapshot> getAvailableTukTuks() {
    return _db.collection('drivers').where('isBooked', isEqualTo: false).snapshots();
  }

  // Book a tuk-tuk
  Future<void> bookTukTuk(String driverId, String name, String mobile, String pickup, String drop, String time) async {
    try {
      // Fetch driver details
      DocumentSnapshot driverSnapshot = await _db.collection('drivers').doc(driverId).get();

      if (!driverSnapshot.exists) {
        print("Driver not found!");
        return;
      }

      String driverName = driverSnapshot['name'];

      // Check if user is logged in
      User? user = _auth.currentUser;
      if (user == null) {
        print("User not logged in!");
        return;
      }

      // Add booking entry
      await _db.collection('bookings').add({
        'userId': user.uid,
        'driverId': driverId,
        'driverName': driverName,
        'customerName': name,
        'customerMobile': mobile,
        'pickupLocation': pickup,
        'dropLocation': drop,
        'timePreferred': time,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mark driver as booked
      await _db.collection('drivers').doc(driverId).update({'isBooked': true});

      print("Booking successful!");
    } catch (e) {
      print("Error booking ride: $e");
    }
  }

  // Get user's bookings
  Stream<QuerySnapshot> getUserBookings() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }
    return _db.collection('bookings').where('userId', isEqualTo: user.uid).snapshots();
  }
}
