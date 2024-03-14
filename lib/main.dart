import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
       ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyCpOhjn-PyAln4K-E4vEV3tM4cotqTbBj4',//please enter the api key from google_services.jsson
              appId: '1:521292734856:android:590a59a077273c6647da3d', //please enter the App Id from google_services.jsson
              messagingSenderId: '521292734856',//please enter the MessageId from google_services.jsson
              projectId: 'pic-to-text-cc19f')) //please enter the ProjectId from google_services.jsson
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Text Extraction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  String? _extractedText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Extraction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile == null
                ? const Text('No image selected.')
                : Image.file(_imageFile!),
            const SizedBox(height: 20),
            _extractedText == null
                ? const Text('No text extracted.')
                : Text('Extracted Text: $_extractedText'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _extractAndSaveText,
              child: const Text('Extract and Save Text'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _extractedText = null;
      } else {
         print('No image selected.');
      }
    });
  }

  Future<void> _extractAndSaveText() async {
    if (_imageFile == null) {
      return;
    }

    final inputImage = InputImage.fromFile(_imageFile!);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognisedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _extractedText = recognisedText.text;
    });

    await _saveExtractedTextToFirestore(_extractedText!);
  }

  //save the extracted text to firestore

  Future<void> _saveExtractedTextToFirestore(String text) async {
     {
      await Firebase.initializeApp();
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('extracted_text').add({
        'text': text, //please add the respective path from firebase/Firestore
      });
      print('Text saved to Firestore.');

    }
  }
}

//Sihab | SWE(232) | Diu
