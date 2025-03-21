import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services.dart';
import 'ride.dart';
import 'my_bookings.dart';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedCity = 'All Cities';
  List<String> _cities = ['All Cities'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    // Load available cities from Firestore
    try {
      final citiesSnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .get();

      final citySet = <String>{};
      for (var doc in citiesSnapshot.docs) {
        if (doc.data().containsKey('city') && doc['city'] != null) {
          citySet.add(doc['city']);
        }
      }

      setState(() {
        _cities = ['All Cities', ...citySet.toList()..sort()];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cities: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tuk-Tuk Finder",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyBookingsPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              // TODO: Navigate to profile page
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile page coming soon!'))
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // City Filter Header
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _isLoading
                      ? Text("Loading cities...",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ))
                      : DropdownButton<String>(
                    value: _selectedCity,
                    isExpanded: true,
                    underline: SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                      }
                    },
                    items: _cities.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20),
                  color: Theme.of(context).primaryColor,
                  tooltip: 'Refresh',
                  onPressed: () {
                    setState(() {}); // Refresh the stream builder
                  },
                ),
              ],
            ),
          ),

          // Main Tuk-Tuk List
          Expanded(
            child: StreamBuilder(
              stream: _firestoreService.getAvailableTukTuks(),
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
                        Icon(Icons.electric_rickshaw, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No Tuk-Tuks available right now",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Please check back later",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final allDrivers = snapshot.data!.docs;
                final drivers = _selectedCity == 'All Cities'
                    ? allDrivers
                    : allDrivers.where((doc) => doc['city'] == _selectedCity).toList();

                if (drivers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No Tuk-Tuks in $_selectedCity",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          child: Text("Show All Cities"),
                          onPressed: () {
                            setState(() {
                              _selectedCity = 'All Cities';
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(12),
                  itemCount: drivers.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    var driver = drivers[index];
                    var driverData = driver.data() as Map<String, dynamic>;
                    var rating = driverData['rating'] ?? 4.0;
                    var price = driverData['pricePerKm'] ?? '₹10';

                    return Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                              child: Icon(
                                Icons.directions_bike,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            title: Text(
                              driverData['name'] ?? 'Unknown Driver',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: Colors.amber),
                                    SizedBox(width: 4),
                                    Text('$rating', style: TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text("Auto No: ${driverData['plate'] ?? 'N/A'}"),
                                Text("City: ${driverData['city'] ?? 'N/A'}"),
                              ],
                            ),
                            isThreeLine: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),

                          // Bottom section with price and book button
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.currency_rupee, size: 16, color: Colors.green),
                                    SizedBox(width: 4),
                                    Text(
                                      "$price/km",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  ),
                                  child: Text(
                                    "Book Now",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => RidePage(driverId: driver.id)
                                        )
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Add a floating action button for quick booking
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement quick booking or ride request feature
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Quick ride request coming soon!'))
          );
        },
        child: Icon(Icons.hail),
        tooltip: 'Request a ride',
      ),
    );
  }
}