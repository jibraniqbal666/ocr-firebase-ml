import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  String _text;
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.textRecognizer();

  Future getImage(bool camera) async {
    return await ImagePicker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery);
  }

  Future processImage(bool camera) async {
    final image = await getImage(camera);
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    setState(() {
      _text = visionText.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("Camera"),
                  onPressed: () {
                    processImage(true);
                  },
                ),
                RaisedButton(
                  child: Text("Gallery"),
                  onPressed: () {
                    processImage(false);
                  },
                ),
              ],
            ),
            GestureDetector(
              child: Text(_text == null ? "Pick a Image" : _text),
              onLongPress: () {
                Clipboard.setData(new ClipboardData(text: _text));
                key.currentState.showSnackBar(new SnackBar(
                  content: new Text("Copied to Clipboard"),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
