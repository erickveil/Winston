import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TarotCard {
  final String name;
  final String imagery;
  final String uprightMeaning;
  final String invertedMeaning;
  final bool isUpright;

  TarotCard({
    required this.name, 
    required this.imagery,
    required this.uprightMeaning,
    required this.invertedMeaning,
    required this.isUpright,
  });

  factory TarotCard.fromJson(Map<String, dynamic> json, bool isUpright) {
    return TarotCard(
      name: json['name'] ?? 'Unknown Card',
      imagery: json['imagery'] ?? 'No imagery description available.',
      uprightMeaning: json['uprightMeaning'] ?? 'No upright meaning available.',
      invertedMeaning: json['invertedMeaning'] ?? 'No inverted meaning available.',
      isUpright: isUpright,
    );
  }

  String get orientation => isUpright ? 'Upright' : 'Inverted';
  String get meaning => isUpright ? uprightMeaning : invertedMeaning;
} 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winston Tarot Medium',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Winston Tarot Medium'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TarotCard? _drawnCard;
  bool _isLoading = false;
  final Random _random = Random();

  // Load and parse tarot card JSON
  Future<List<dynamic>> _loadTarotCards() async {
    final String response = await rootBundle.loadString('assets/tarotData.json');
    return jsonDecode(response);
  }

  // Draw a random tarot card
  Future<void> _drawCard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _loadTarotCards();
      final int randomIndex = _random.nextInt(cards.length);
      final bool isUpright = _random.nextBool();

      // print the card details for debugging
      print('Drawing card at index $randomIndex, isUpright: $isUpright');
      print('Card data: ${cards[randomIndex]}');

      setState(() {
        _drawnCard = TarotCard.fromJson(cards[randomIndex], isUpright);
        _isLoading = false;
      });
      
    } catch(e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading tarot cards: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Hello World',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _drawCard,
        tooltip: 'Draw Card',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
