import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';

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

class ImageData {
  final String name;
  final String description;
  final String category;
  final String value; // Base64-encoded string of the image

  ImageData({
    required this.name,
    required this.description,
    required this.category,
    required this.value,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      name: json['name'],
      description: json['description'],
      category: json['category'],
      value: json['value'],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<ImageData>>? _imageListFuture;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  XFile? _videoFile;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imageListFuture = fetchImages();
  }

  Future<void> _pickImage() async {
    final XFile? selected =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = selected;
    });
  }

  Future<void> _pickVideo() async {
    final XFile? selected =
        await _picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      _videoFile = selected;
    });
  }

  Future<void> _saveVideoData() async {
    if (_videoFile == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Video not uploaded!'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    var uri = Uri.parse(
        'http://172.31.16.116:3010/videos/upload'); // Adjust the URL as needed
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile(
        'video',
        _videoFile!.readAsBytes().asStream(),
        await _videoFile!.length(),
        filename: _videoFile!.name,
        contentType: MediaType('video', 'mp4'), // Assuming the video is MP4
      ),
    );

    var streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('Video uploaded successfully');
      // You can perform additional actions here, such as refreshing the UI
    } else {
      print('Failed to upload video data. Status code: ${response.statusCode}');
      // Handle error, possibly showing an alert to the user
    }
  }

  Future<void> _saveCategoryData() async {
    var url = Uri.parse(
        'http://172.31.200.20:3010/categories'); // Adjust the URL as needed

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
            title: const Text('Error'),
            content: const Text('Image not uploaded!'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    // Compress the image
    final filePath = _imageFile!.path;
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var compressedImage = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 50, // You can adjust the quality as needed
    );

    if (compressedImage == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to compress image!'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }
    // Log the file sizes for comparison
    print("Original size: ${await File(filePath).length()}");
    print("Compressed size: ${await compressedImage.length()}");

    // Read the compressed image bytes
    final imageBytes = await compressedImage.readAsBytes();
    if (imageBytes == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to read compressed image bytes!'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    var url = Uri.parse(
        'http://172.31.200.20:3010/images'); // Adjust the URL as needed

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        "name": _nameController.text,
        "description": _descriptionController.text,
        "category": _categoryController.text,
        "value": base64Encode(imageBytes),
      }),
    );

    if (response.statusCode == 200) {
      print('Image data uploaded successfully');
      setState(() {
        // Refresh the list of images
        _imageListFuture = fetchImages();
      });
    } else {
      print('Failed to upload image data. Status code: ${response.statusCode}');
    }
  }

  Future<List<ImageData>> fetchImages() async {
    var url = Uri.parse(
        'http://172.31.200.20:3010/images'); // Adjust the URL as needed
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> imageList = json.decode(response.body);
      return imageList.map((image) => ImageData.fromJson(image)).toList();
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pictionary"),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                onPressed: _saveImageData,
                child: Text('Save Image'),
              ),
              ElevatedButton(
                onPressed: _saveCategoryData,
                child: Text('Save Category Data'),
              ),
              ElevatedButton(
                onPressed: _pickVideo,
                child: Text('Select Video'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVideoData,
                child: Text('Save Video'),
              ),
              SizedBox(height: 20),
              Text('Uploaded Images:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              FutureBuilder<List<ImageData>>(
                future: _imageListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var imageData = snapshot.data![index];
                        return Image.memory(base64Decode(imageData.value));
                      },
                    );
                  } else {
                    return Text('No images found.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
