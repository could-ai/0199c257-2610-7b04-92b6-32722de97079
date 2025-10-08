import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameScreen(),
    );
  }
}

class CardItem {
  String term;
  String variablePart;
  bool isFlipped;
  bool isMatched;

  CardItem({
    required this.term,
    required this.variablePart,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<CardItem> _cards;
  CardItem? _firstFlippedCard;
  bool _isChecking = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  String _getVariablePart(String term) {
    return term.replaceAll(RegExp(r'[^a-zA-Z]'), '');
  }

  void _setupGame() {
    List<String> terms = ['5xy', '3x', '2xy', '-9x', '7ab', '-2ab', '4y', '8y'];
    List<CardItem> cardItems = [];
    for (var term in terms) {
      cardItems.add(CardItem(
        term: term,
        variablePart: _getVariablePart(term),
      ));
    }
    cardItems.shuffle();
    setState(() {
      _cards = cardItems;
      _score = 0;
      _firstFlippedCard = null;
      _isChecking = false;
    });
  }

  void _onCardTapped(int index) {
    if (_isChecking || _cards[index].isFlipped || _cards[index].isMatched) {
      return;
    }

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedCard == null) {
      _firstFlippedCard = _cards[index];
    } else {
      _isChecking = true;
      // Check for match
      if (_firstFlippedCard!.variablePart == _cards[index].variablePart) {
        // Match found
        setState(() {
          _firstFlippedCard!.isMatched = true;
          _cards[index].isMatched = true;
          _score += 10;
        });
        _firstFlippedCard = null;
        _isChecking = false;
        _checkForWin();
      } else {
        // No match
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            _firstFlippedCard!.isFlipped = false;
            _cards[index].isFlipped = false;
            _firstFlippedCard = null;
            _isChecking = false;
          });
        });
      }
    }
  }

  void _checkForWin() {
    if (_cards.every((card) => card.isMatched)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Chúc mừng!'),
            content: Text('Bạn đã hoàn thành màn chơi với số điểm: $_score'),
            actions: <Widget>[
              TextButton(
                child: const Text('Chơi lại'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _setupGame();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Match - Đơn thức đồng dạng'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(child: Text('Điểm: $_score', style: const TextStyle(fontSize: 18))),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onCardTapped(index),
              child: Card(
                color: _cards[index].isMatched
                    ? Colors.green.withOpacity(0.5)
                    : (_cards[index].isFlipped ? Colors.blue.shade100 : Colors.grey.shade300),
                child: Center(
                  child: _cards[index].isFlipped || _cards[index].isMatched
                      ? Text(
                          _cards[index].term,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      : const Text(
                          '?',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
