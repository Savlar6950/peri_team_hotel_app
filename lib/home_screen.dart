import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'add_pin_screen.dart';
import 'list_all_entries.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final bool isSuperuser;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.isSuperuser,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = false;

  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('hotels');

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() => _isLoading = true);

    final event = await _ref.once();
    final data = event.snapshot.value as Map?;
    final markers = <Marker>{};

    if (data != null) {
      data.forEach((key, value) {
        final v = Map<String, dynamic>.from(value);
        if (v.containsKey('latitude') && v.containsKey('longitude')) {
          final fullAddress = v['fullAddress'] ?? '';
          final hotelName = v['hotelName'] ?? '';
          final postcode = v['postcode'] ?? '';
          final description = v['description'] ?? '';
          final user = v['user'] ?? '';

          markers.add(Marker(
            markerId: MarkerId(key),
            position: LatLng(v['latitude'], v['longitude']),
            infoWindow: InfoWindow(
              title: hotelName,
              snippet: 'Postcode: $postcode\nReason: $description\nAdded by: $user\n$fullAddress',
            ),
          ));
        }
      });
    }

    setState(() {
      _markers
        ..clear()
        ..addAll(markers);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels to Avoid'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadMarkers,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(54.5, -3), // Center of the UK
              zoom: 5.5,
            ),
            markers: _markers,
            onMapCreated: (controller) => mapController = controller,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddPinScreen(userName: widget.userName),
                      ),
                    );
                    _loadMarkers();
                  },
                  child: const Text('Add Hotel to Avoid', style: TextStyle(fontSize: 12)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListAllEntries(
                          isSuperuser: widget.isSuperuser,
                          onUpdate: _loadMarkers, // 🔄 refresh on delete
                        ),
                      ),
                    );
                    _loadMarkers();
                  },
                  child: const Text('View All Entries', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
