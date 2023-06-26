import 'dart:convert';
import 'dart:math';
import 'dart:async' show Future;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

var color = const Color.fromRGBO(12, 19, 74, 1);
List<String> wordList = [];

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key}) {
    var futureWordList = getFileData();
    futureWordList.then((words) {
      LineSplitter ls = const LineSplitter();
      wordList = ls.convert(words);
    });
  }

  Future<String> getFileData() async {
    return await rootBundle.loadString('assets/word_list.txt');
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var random = Random();
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Randomly generate a Washington plate
    var plate = '';
    var letters = '';
    for (var i = 0; i < 2; i++) {
      var letter = String.fromCharCode(random.nextInt(26) + 65);
      plate += letter;
      letters += letter;
    }

    // "The letters I, O, and Q will not be used in the third position on the
    //  new 7 character plates." - licenseplates.cc/WA
    String letter;
    do {
      letter = String.fromCharCode(random.nextInt(26) + 65);
    } while (letter == 'I' || letter == 'O' || letter == 'Q');
    plate += letter;
    letters += letter;

    for (var i = 0; i < 4; i++) {
      plate += random.nextInt(9).toString();
    }

    var answers = _getAnswers(letters);

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
                  controller: textController,
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
                    hintText: letters,
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
                          builder: (_) => _AnswerDialog(imgWidth, height,
                              textController.text, answers, false));
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
                        builder: (_) => _AnswerDialog(imgWidth, height,
                            textController.text, answers, true));
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

  List<String> _getAnswers(var letters) {
    List<String> answers = [];
    for (String word in wordList) {
      if (_isMatch(letters, word)) {
        answers.add(word);
      }
    }

    return answers;
  }

  bool _isMatch(var letters, String word) {
    var i = 0;
    for (int j = 0; j < word.length; j++) {
      if (word[j].toUpperCase() == letters[i]) {
        i++;
      }

      if (i == 3) {
        return true;
      }
    }
    return false;
  }
}

class _AnswerDialog extends StatelessWidget {
  final int imgWidth;
  final double height;
  final String guess;
  final List<String> answers;
  final bool guessedImpossible;
  final _scrollController = ScrollController();

  _AnswerDialog(this.imgWidth, this.height, this.guess, this.answers,
      this.guessedImpossible);

  @override
  Widget build(BuildContext context) {
    String alert;
    if (guessedImpossible) {
      if (answers.isEmpty) {
        alert = 'Correct';
      } else {
        alert = 'Incorrect';
      }
    } else {
      if (answers.contains(guess.toLowerCase())) {
        alert = 'Correct';
      } else {
        alert = 'Incorrect';
      }
    }

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
                  fontSize: imgWidth / 6,
                  fontFamily: 'LicensePlate'),
              child: Text(alert),
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
                                  itemCount: answers.length,
                                  itemBuilder: (context, index) => ListTile(
                                    title: DefaultTextStyle(
                                      style: TextStyle(
                                          color: color,
                                          fontSize: imgWidth / 12,
                                          fontFamily: 'LicensePlate'),
                                      child: Text(answers[index]),
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
