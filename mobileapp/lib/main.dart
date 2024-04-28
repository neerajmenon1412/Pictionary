import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';
import 'package:video_compress/video_compress.dart';

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

  Future<void> _compressAndUploadVideo() async {
    if (_videoFile == null) {
      print('No video selected for upload.');
      return;
    }

    // Get the original video file size
    File originalVideoFile = File(_videoFile!.path);
    int originalSize = await originalVideoFile.length();
    print('Original video size: $originalSize bytes');

    // Compress the video
    final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
      _videoFile!.path,
      quality: VideoQuality
          .DefaultQuality, // Adjusted to default for better compatibility
      deleteOrigin: false, // Optionally delete the original file
    );

    if (compressedVideo != null && compressedVideo.file != null) {
      int compressedSize = await compressedVideo.file!.length();
      print('Original video size: $originalSize bytes');
      print('Compressed video size: $compressedSize bytes');
      print(
          'Compression reduced the video size by ${originalSize - compressedSize} bytes');
      print('Compression successful, starting upload...');
      _uploadVideo(
          compressedVideo.file!); // Pass the compressed file for upload
    } else {
      print('Failed to compress video.');
    }
  }

  Future<void> _uploadVideo(File videoFile) async {
    var uri = Uri.parse('http://172.31.28.133:3010/videos/upload');
    var request = http.MultipartRequest('POST', uri);

    try {
      // Await the creation of the MultipartFile before adding it to the request
      var multipartFile = await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
        contentType: MediaType('video', 'mp4'), // Assuming the video is MP4
      );
      request.files
          .add(multipartFile); // Add the multipart file after it's ready

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 201) {
        print('Video uploaded successfully');
      } else {
        print(
            'Failed to upload video. Status code: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      print('Error uploading video: $e');
    }
  }

  Future<void> _saveCategoryData() async {
    var url = Uri.parse('http://172.31.28.133:3010/categories');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
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
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Image not uploaded!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final filePath = _imageFile!.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final outPath =
        "${filePath.substring(0, lastIndex)}_out${filePath.substring(lastIndex)}";
    var compressedImage = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 50, // Quality adjusted for better compression
    );

    if (compressedImage != null) {
      final imageBytes = await compressedImage.readAsBytes();
      var response = await http.post(
        Uri.parse('http://172.31.28.133:3010/images'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
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
          _imageListFuture = fetchImages();
        });
      } else {
        print(
            'Failed to upload image data. Status code: ${response.statusCode}');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to compress image!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  Future<List<ImageData>> fetchImages() async {
    var response =
        await http.get(Uri.parse('http://172.31.28.133:3010/images'));
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
            children: [
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
                  onPressed: _pickImage, child: Text('Select Image')),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _saveImageData, child: Text('Save Image')),
              ElevatedButton(
                  onPressed: _saveCategoryData,
                  child: Text('Save Category Data')),
              ElevatedButton(
                  onPressed: _pickVideo, child: Text('Select Video')),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _compressAndUploadVideo,
                  child: Text('Upload Video')),
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
