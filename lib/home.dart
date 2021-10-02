import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  File _image;
  List _output;
  final imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {
        pickimage_camera();
      });
    });
  }

  detectimage(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _output = prediction;
      loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  
    
  }

  @override
  void dispose() {
    super.dispose();
  }

  pickimage_camera() async {
    var image = await imagepicker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  pickimage_gallery() async {
    var image = await imagepicker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    //Your media queries are unable to set height and width in this project the implementation is incorrect
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Face Mask',
          style: GoogleFonts.roboto(),
        ),
      ),
      body: loading != true
                ? Container(


              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height-200,
                   // width: MediaQuery.of(context).size.width,
                      child: Image.file(_image)
                  ),
Row(
  mainAxisAlignment:MainAxisAlignment.center,
    children: [




  Container(
    padding: EdgeInsets.only(left: 10, right: 10,top: 10,bottom: 10),


    child: FloatingActionButton(
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.camera),
        onPressed: () {
          pickimage_camera();
        }),
  ),

  Container(
    padding: EdgeInsets.only(left: 10, right: 10,top: 10,bottom: 10),

    child: FloatingActionButton(
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.broken_image_outlined),
        onPressed: () {
          pickimage_gallery();
        }),
  ),

],



    ),


                  _output != null
                      ? Text(
                      (_output[0]['label']).toString().substring(2),
                      style: GoogleFonts.roboto(fontSize: 18))
                      : Text(''),
                  _output != null
                      ? Text(
                      'Confidence: ' +
                          (_output[0]['confidence']).toString(),
                      style: GoogleFonts.roboto(fontSize: 18))
                      : Text('')
                ],
              ),
            )
                : Container()



    );
  }
}
