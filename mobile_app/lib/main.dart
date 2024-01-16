import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  Future<void> _pickImage() async {
    final XFile? selected =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = selected;
    });
  }

  Future<void> _saveCategoryData() async {
    var url = Uri.parse(
        'http://10.0.0.225:3010/categories'); // Adjust the URL as needed

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        "name": _nameController.text,
        "description": _descriptionController.text,
        "category": _categoryController.text,
      }),
    );

    if (response.statusCode == 200) {
      print('Category data uploaded successfully');
    } else {
      print(
          'Failed to upload category data. Status code: ${response.statusCode}');
    }
  }

  Future<void> _saveImageData() async {
    if (_imageFile == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Image not uploaded!'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    var url =
        Uri.parse('http://10.0.0.225:3010/images'); // Adjust the URL as needed

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        "name": _nameController.text,
        "description": _descriptionController.text,
        "category": _categoryController.text,
        "value": _imageFile!.path,
      }),
    );

    if (response.statusCode == 200) {
      print('Image data uploaded successfully');
    } else {
      print('Failed to upload image data. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Input Form"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 20),
            _imageFile == null
                ? Text("No image selected.")
                : Image.file(File(_imageFile!.path)),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCategoryData,
              child: Text('Save Category Data'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveImageData,
              child: Text('Save Image'),
            ),
          ],
        ),
      ),
    );
  }
}
