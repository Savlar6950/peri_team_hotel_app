import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'home_screen.dart';

class AddPinScreen extends StatefulWidget {
  final String userName;
  const AddPinScreen({super.key, required this.userName});

  @override
  State<AddPinScreen> createState() => _AddPinScreenState();
}

class _AddPinScreenState extends State<AddPinScreen> {
  final _postcodeController = TextEditingController();
  final _hotelNameController = TextEditingController();
  final _descController = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    final postcode = _postcodeController.text.trim();
    final hotelName = _hotelNameController.text.trim();
    final description = _descController.text.trim();

    if (postcode.isEmpty || hotelName.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.')));
      return;
    }

    setState(() => _loading = true);

    try {
      List<Location> locations = await locationFromAddress(postcode);
      if (locations.isEmpty) throw Exception('Location not found');
      final loc = locations.first;

      List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
      final fullAddress = placemarks.isNotEmpty
          ? "${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.postalCode}"
          : "";

      final data = {
        'hotelName': hotelName,
        'postcode': postcode,
        'description': description,
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'fullAddress': fullAddress,
        'user': widget.userName,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      await FirebaseDatabase.instance.ref().child('hotels').push().set(data);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: widget.userName, isSuperuser: false),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Hotel to Avoid')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _hotelNameController, decoration: const InputDecoration(labelText: 'Hotel Name')),
            TextField(controller: _postcodeController, decoration: const InputDecoration(labelText: 'Postcode')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Reason to Avoid')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator() : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
