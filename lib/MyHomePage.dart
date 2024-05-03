import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? pickedImage;
  String mytext = "";
  bool scanning = false;

  final ImagePicker _imagePicker = ImagePicker();

  getImage(ImageSource ourSource) async {
    XFile? result = await _imagePicker.pickImage(source: ourSource);

    if (result != null) {
      setState(() {
        pickedImage = result;
      });
      performTextRecognition();
    }
  }


  performTextRecognition()async{

    setState(() {
      scanning =true;
    });
    try{
      final inputImage = InputImage.fromFilePath(pickedImage!.path);
      final textRecognizer =GoogleMlKit.vision.textRecognizer();
      final recognixedText = await textRecognizer.processImage(inputImage);


      setState(() {
        mytext = recognixedText.text;
        scanning =false;
      });

      textRecognizer.close();
    }catch(e){
      print("error during text: $e ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appbar"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          pickedImage == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: ClayContainer(
                    height: 400,
                    child: Center(
                      child: Text("No image"),
                    ),
                  ),
                )
              : Center(
                  child: Image.file(
                    File(pickedImage!.path),
                    height: 400,
                  ),
                ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery")),
              ElevatedButton.icon(
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera")),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text("Recognixed text"),
          ),
          const SizedBox(
            height: 20,
          ),
          scanning
              ? const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: SpinKitThreeBounce(
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                )
              : Center(
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    animatedTexts: [
                      TypewriterAnimatedText(mytext,
                          textAlign: TextAlign.center)
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
