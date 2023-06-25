import 'package:flutter/material.dart';
import 'dart:math'; // for 'min'

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plate Word',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var width = constraints.constrainWidth();
          var height = constraints.constrainHeight();
          // img cannot resize larger than original (1200px)
          var imgWidth = min((width / 1.2).round(), 1200);
          var imgHeight = (imgWidth / 2).round();
          var imgTop = height / 12;
          var imgLeft = width / 12;
          var pad = 120;
          var textLeft = min(imgLeft * 2, imgLeft + pad);
          var inputPadding = min(textLeft / 2, pad).toDouble();

          return Stack(
            children: <Widget>[
              Positioned(
                top: imgTop,
                left: imgLeft,
                child: Image(
                    image: ResizeImage(const AssetImage('assets/wa_plate.png'),
                        width: imgWidth, height: imgHeight)),
              ),
              Positioned(
                top: imgTop + imgHeight / 3,
                left: textLeft,
                child: DefaultTextStyle(
                  style: TextStyle(
                      color: const Color.fromRGBO(12, 19, 74, 1),
                      fontSize: imgWidth / 4,
                      fontFamily: 'LicensePlate'),
                  child: const Text('ABC1234'),
                ),
              ),
              Positioned(
                top: imgTop + imgHeight + 25,
                left: imgLeft,
                width: min(width / 1.2, 1200),
                child: TextField(
                  style: TextStyle(
                      color: const Color.fromRGBO(12, 19, 74, 1),
                      fontSize: imgWidth / 4,
                      fontFamily: 'LicensePlate'),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(
                        left: inputPadding,
                        top: inputPadding,
                        bottom: inputPadding - 15),
                    hintText: 'ABC',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
