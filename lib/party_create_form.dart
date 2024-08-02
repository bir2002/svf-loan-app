import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PartyCreateForm extends StatefulWidget {
  @override
  _PartyCreateFormState createState() => _PartyCreateFormState();
}

class _PartyCreateFormState extends State<PartyCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  File? _partyPhoto;
  File? _partyIdProof;
  File? _homePhoto;
  File? _streetPhoto;
  File? _homeLftrPhoto;
  File? _homeRhtrPhoto;

  Future<void> _selectImage(ImageSource source, String imageType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        switch (imageType) {
          case 'partyPhoto':
            _partyPhoto = File(pickedFile.path);
            break;
          case 'partyIdProof':
            _partyIdProof = File(pickedFile.path);
            break;
          case 'homePhoto':
            _homePhoto = File(pickedFile.path);
            break;
          case 'streetPhoto':
            _streetPhoto = File(pickedFile.path);
            break;
          case 'homeLftrPhoto':
            _homeLftrPhoto = File(pickedFile.path);
            break;
          case 'homeRhtrPhoto':
            _homeRhtrPhoto = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<void> _showImageSourceActionSheet(BuildContext context, String imageType) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  _selectImage(ImageSource.gallery, imageType);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _selectImage(ImageSource.camera, imageType);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Party Create'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextField(_nameController, 'Party Name'),
              _buildTextField(_contactNoController, 'Party Contact No'),
              _buildTextField(_addressController, 'Address'),
              _buildTextField(_occupationController, 'Occupation'),
              _buildImageUploadBox('Party Photo', 'partyPhoto'),
              _buildImageUploadBox('Party ID Proof', 'partyIdProof'),
              _buildImageUploadBox('Home Photo', 'homePhoto'),
              _buildImageUploadBox('Street Photo', 'streetPhoto'),
              _buildImageUploadBox('Home LFTR Photo', 'homeLftrPhoto'),
              _buildImageUploadBox('Home RHTR Photo', 'homeRhtrPhoto'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Form Submitted Successfully')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 100.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
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
        keyboardType: label == 'Party Contact No' ? TextInputType.phone : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageUploadBox(String label, String imageType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 8.0),
          GestureDetector(
            onTap: () => _showImageSourceActionSheet(context, imageType),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Center(
                child: _getImageWidget(imageType),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getImageWidget(String imageType) {
    File? imageFile;
    String text;
    switch (imageType) {
      case 'partyPhoto':
        imageFile = _partyPhoto;
        text = 'Tap to upload Photo';
        break;
      case 'partyIdProof':
        imageFile = _partyIdProof;
        text = 'Tap to upload ID Proof';
        break;
      case 'homePhoto':
        imageFile = _homePhoto;
        text = 'Tap to upload Home Photo';
        break;
      case 'streetPhoto':
        imageFile = _streetPhoto;
        text = 'Tap to upload Street Photo';
        break;
      case 'homeLftrPhoto':
        imageFile = _homeLftrPhoto;
        text = 'Tap to upload Left Photo';
        break;
      case 'homeRhtrPhoto':
        imageFile = _homeRhtrPhoto;
        text = 'Tap to upload Right Photo';
        break;
      default:
        text = 'Tap to upload Image';
    }
    return imageFile == null
        ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add, size: 50, color: Colors.grey),
        SizedBox(height: 10),
        Text(text, style: TextStyle(color: Colors.grey)),
      ],
    )
        : Image.file(imageFile, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
  }
}
