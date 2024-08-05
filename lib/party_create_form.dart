import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart'; // for MediaType
import 'dart:io';

class PartyCreateForm extends StatefulWidget {
  @override
  _PartyCreateFormState createState() => _PartyCreateFormState();
}

class _PartyCreateFormState extends State<PartyCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _partyContactNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  bool _isLocationFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    loc.Location location = new loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      _latitudeController.text = _locationData.latitude.toString();
      _longitudeController.text = _locationData.longitude.toString();
      _isLocationFetched = true;
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(
      _locationData.latitude!,
      _locationData.longitude!,
    );

    setState(() {
      _addressController.text = placemarks.first.street!;
    });
  }

  Future<void> _submitPartyCreate() async {
    if (!_formKey.currentState!.validate() || !_isLocationFetched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enable location services and fill in all fields.')),
      );
      return;
    }

    final String apiUrl = "https://finance2024.ingenious-technologies.com/financeapp/public/api/executive/party-create";

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..fields['party_name'] = _partyNameController.text
      ..fields['party_contact_no'] = _partyContactNoController.text
      ..fields['address'] = _addressController.text
      ..fields['occupation'] = _occupationController.text
      ..fields['latitude'] = _latitudeController.text
      ..fields['longitude'] = _longitudeController.text
      ..files.add(await http.MultipartFile.fromPath(
          'party_photo', 'path/to/party_photo.jpg',
          contentType: MediaType('image', 'jpeg')))
      ..files.add(await http.MultipartFile.fromPath(
          'party_id_proof', 'path/to/party_id_proof.jpg',
          contentType: MediaType('image', 'jpeg')))
      ..files.add(await http.MultipartFile.fromPath(
          'home_photo', 'path/to/home_photo.jpg',
          contentType: MediaType('image', 'jpeg')))
      ..files.add(await http.MultipartFile.fromPath(
          'street_photo', 'path/to/street_photo.jpg',
          contentType: MediaType('image', 'jpeg')))
      ..files.add(await http.MultipartFile.fromPath(
          'home_lftr_photo', 'path/to/home_lftr_photo.jpg',
          contentType: MediaType('image', 'jpeg')))
      ..files.add(await http.MultipartFile.fromPath(
          'home_rhtr_photo', 'path/to/home_rhtr_photo.jpg',
          contentType: MediaType('image', 'jpeg')));

    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Party created successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create party')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Party Create'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextField(_partyNameController, 'Party Name'),
              _buildTextField(_partyContactNoController, 'Party Contact No'),
              _buildTextField(_addressController, 'Address'),
              _buildTextField(_occupationController, 'Occupation'),
              _buildTextField(_latitudeController, 'Latitude', readOnly: true),
              _buildTextField(_longitudeController, 'Longitude', readOnly: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPartyCreate,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
        readOnly: readOnly,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
