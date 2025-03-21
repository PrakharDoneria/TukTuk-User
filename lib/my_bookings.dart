import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'services.dart';
import 'ride_details.dart'; // You'll need to create this file later

class MyBookingsPage extends StatefulWidget {
  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to format timestamp
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "N/A";

    if (timestamp is Timestamp) {
      final DateTime dateTime = timestamp.toDate();
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } else {
      return "N/A";
    }
  }

  // Helper method to get appropriate status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in progress':
        return Colors.blue;
      case 'scheduled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get appropriate status icon
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'in progress':
        return Icons.directions_car;
      case 'scheduled':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Bookings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.black54,
          tabs: [
            Tab(text: "All"),
            Tab(text: "Active"),
            Tab(text: "Past"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(null),
          _buildBookingsList('active'),
          _buildBookingsList('past'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String? filter) {
    return StreamBuilder(
      stream: _firestoreService.getUserBookings(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text("Something went wrong"),
                SizedBox(height: 8),
                ElevatedButton(
                  child: Text("Try Again"),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No bookings found",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  "Book a Tuk-Tuk to see your rides here",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final allBookings = snapshot.data!.docs;

        // Filter bookings based on tab
        final filteredBookings = filter == null
            ? allBookings
            : filter == 'active'
            ? allBookings.where((doc) {
          final status = (doc['status'] ?? '').toLowerCase();
          return status == 'in progress' || status == 'scheduled';
        }).toList()
            : allBookings.where((doc) {
          final status = (doc['status'] ?? '').toLowerCase();
          return status == 'completed' || status == 'cancelled';
        }).toList();

        if (filteredBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    filter == 'active' ? Icons.directions_car : Icons.history,
                    size: 64,
                    color: Colors.grey
                ),
                SizedBox(height: 16),
                Text(
                  filter == 'active'
                      ? "No active bookings"
                      : "No past bookings",
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  filter == 'active'
                      ? "Your current rides will appear here"
                      : "Your ride history will appear here",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(12),
          itemCount: filteredBookings.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            var booking = filteredBookings[index];
            var bookingData = booking.data() as Map<String, dynamic>;

            final status = bookingData['status'] ?? 'Unknown';
            final driverName = bookingData['driverName'] ?? 'Unknown Driver';
            final pickupLocation = bookingData['pickupLocation'] ?? 'N/A';
            final dropLocation = bookingData['dropLocation'] ?? 'N/A';
            final timestamp = bookingData['timestamp'];
            final fare = bookingData['fare'] ?? 'N/A';

            return GestureDetector(
              onTap: () {
                // Navigate to booking details page
                // TODO: Create the RideDetailsPage
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideDetailsPage(bookingId: booking.id),
                  ),
                );
                */

                // Until the details page is created, show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking details coming soon!'))
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Booking header with driver name and status
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  driverName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(status),
                                      size: 16,
                                      color: _getStatusColor(status),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: _getStatusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // Date and time
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                _formatDate(timestamp),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Trip details
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                  Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Pickup",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      pickupLocation,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Drop-off",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      dropLocation,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom section with fare
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Fare",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "₹$fare",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}