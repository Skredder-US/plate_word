import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

var color = const Color.fromRGBO(12, 19, 74, 1);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Plate Word',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        ));
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var random = Random();

  @override
  Widget build(BuildContext context) {
    // Randomly generate a Washington plate
    var plate = '';
    for (var i = 0; i < 2; i++) {
      plate += String.fromCharCode(random.nextInt(26) + 65);
    }

    // "The letters I, O, and Q will not be used in the third position on the
    //  new 7 character plates." - licenseplates.cc/WA
    String letter;
    do {
      letter = String.fromCharCode(random.nextInt(26) + 65);
    } while (letter == 'I' || letter == 'O' || letter == 'Q');
    plate += letter;

    for (var i = 0; i < 4; i++) {
      plate += random.nextInt(9).toString();
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var width = constraints.constrainWidth();
          var height = constraints.constrainHeight();
          var imgWidth = min((width / 1.2).round(), 600);
          var imgHeight = (imgWidth / 2).round();
          var imgTop = height / 12;
          var imgLeft = width / 2 - imgWidth / 2;
          var pad = 60;
          var textLeft = min(imgLeft * 2, imgLeft + pad);
          var inputPadding = min(textLeft / 2, pad).toDouble();
          var buttonTop = height / 1.2;
          var buttonLeft = width / 2;

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
                      color: color,
                      fontSize: imgWidth / 4,
                      fontFamily: 'LicensePlate'),
                  child: Text(plate),
                ),
              ),
              Positioned(
                top: imgTop + imgHeight + 25,
                left: imgLeft,
                width: imgWidth.toDouble(),
                child: TextField(
                  style: TextStyle(
                      color: color,
                      fontSize: imgWidth / 4,
                      fontFamily: 'LicensePlate'),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(
                        left: inputPadding,
                        top: inputPadding,
                        bottom: inputPadding - 15),
                    hintText: plate.substring(0, 3),
                  ),
                ),
              ),
              Positioned(
                  top: buttonTop,
                  left: buttonLeft - 50,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => _AnswerDialog(imgWidth, height));
                    },
                    child: const Text('Submit'),
                  )),
              Positioned(
                top: buttonTop - 4,
                left: buttonLeft - 100,
                child: IconButton(
                  icon: const Icon(Icons.report),
                  tooltip: 'Impossible!',
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => _AnswerDialog(imgWidth, height));
                  },
                ),
              ),
              Positioned(
                top: buttonTop - 4,
                left: buttonLeft + 50,
                child: IconButton(
                  icon: const Icon(Icons.info),
                  tooltip: 'Info',
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                                'Enter a word that contains the letters found '
                                'on the plate in the order found on the plate. '
                                'Example: "ABC1234" can be "Abacus" because '
                                'Abacus has A before B before C.'),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
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

class _AnswerDialog extends StatelessWidget {
  final int imgWidth;
  final double height;
  final _scrollController = ScrollController();

  _AnswerDialog(this.imgWidth, this.height);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DefaultTextStyle(
              style: TextStyle(
                  color: color,
                  fontSize: imgWidth / 4,
                  fontFamily: 'LicensePlate'),
              child: const Text('Correct'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (_) => Material(
                          type: MaterialType.transparency,
                          child: Center(
                            child: Container(
                              width: imgWidth / 1.2,
                              height: height / 1.4,
                              color: Colors.white,
                              child: Scrollbar(
                                controller: _scrollController,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: 50,
                                  itemBuilder: (context, index) => ListTile(
                                    title: DefaultTextStyle(
                                      style: TextStyle(
                                          color: color,
                                          fontSize: imgWidth / 12,
                                          fontFamily: 'LicensePlate'),
                                      child: Text('$index'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ));
              },
              child: const Text('See answers'),
            ),
          ],
        ),
      ),
    );
  }
}
