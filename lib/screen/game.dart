import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: SnakeGameScreen(),
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int gridCellSize = 20;
  static const Duration normalSpeed = Duration(milliseconds: 200);
  static const Duration fastSpeed = Duration(milliseconds: 80);

  late int gridWidth;
  late int gridHeight;
  bool isGridInitialized = false;

  List<Offset> snake = [Offset(10, 10)];
  Offset food = Offset(5, 5);
  String direction = 'right';
  Timer? gameTimer;
  bool isGameOver = false;
  int score = 0;
  int bestScore = 0;

  Duration currentSpeed = normalSpeed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeGrid();
      startGame();
    });
  }

  void initializeGrid() {
    if (!isGridInitialized) {
      final screenSize = MediaQuery.of(context).size;
      final appBarHeight = AppBar().preferredSize.height;
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final scoreHeight = 80.0; // Increased score height

      setState(() {
        gridWidth = (screenSize.width / gridCellSize).floor();
        gridHeight =
            ((screenSize.height - appBarHeight - statusBarHeight - scoreHeight) / gridCellSize).floor() + 2; // Increased height
        isGridInitialized = true;
      });
    }
  }

  void startGame() {
    setState(() {
      snake = [Offset(10, 10)];
      food = generateFood();
      direction = 'right';
      isGameOver = false;
      score = 0;
    });

    resetTimer(normalSpeed);
  }

  void resetTimer(Duration speed) {
    currentSpeed = speed;
    gameTimer?.cancel();
    gameTimer = Timer.periodic(speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      moveSnake();
    });
  }

  void moveSnake() {
    if (isGameOver) return;

    Offset newHead = calculateNextHead();
    if (checkCollision(newHead)) {
      gameOver();
      return;
    }

    setState(() {
      snake.insert(0, newHead);
      if (newHead == food) {
        score++;
        food = generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  Offset calculateNextHead() {
    Offset currentHead = snake.first;
    switch (direction) {
      case 'up':
        return Offset(currentHead.dx, currentHead.dy - 1);
      case 'down':
        return Offset(currentHead.dx, currentHead.dy + 1);
      case 'left':
        return Offset(currentHead.dx - 1, currentHead.dy);
      case 'right':
      default:
        return Offset(currentHead.dx + 1, currentHead.dy);
    }
  }

  bool checkCollision(Offset newHead) {
    if (newHead.dx < 0 ||
        newHead.dy < 0 ||
        newHead.dx >= gridWidth ||
        newHead.dy >= gridHeight) {
      return true;
    }

    if (snake.contains(newHead)) {
      return true;
    }

    return false;
  }

  Offset generateFood() {
    final random = Random();
    Offset newFood;
    do {
      newFood = Offset(
        random.nextInt(gridWidth).toDouble(),
        random.nextInt(gridHeight).toDouble(),
      );
    } while (snake.contains(newFood));
    return newFood;
  }

  void gameOver() {
    gameTimer?.cancel();
    setState(() {
      isGameOver = true;
      if (score > bestScore) {
        bestScore = score;
      }
    });
    showGameOverDialog();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over!', style: TextStyle(color: Colors.red)),
        content: Text('Your score: $score\nBest score: $bestScore',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: Text('Play Again', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void changeDirection(String newDirection) {
    if ((direction == 'up' && newDirection == 'down') ||
        (direction == 'down' && newDirection == 'up') ||
        (direction == 'left' && newDirection == 'right') ||
        (direction == 'right' && newDirection == 'left')) {
      return;
    }
    setState(() {
      direction = newDirection;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initializeGrid();
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          switch (event.logicalKey.keyLabel) {
            case 'Arrow Up':
              changeDirection('up');
              resetTimer(fastSpeed);
              break;
            case 'Arrow Down':
              changeDirection('down');
              resetTimer(fastSpeed);
              break;
            case 'Arrow Left':
              changeDirection('left');
              resetTimer(fastSpeed);
              break;
            case 'Arrow Right':
              changeDirection('right');
              resetTimer(fastSpeed);
              break;
          }
        } else if (event is RawKeyUpEvent) {
          resetTimer(normalSpeed);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Snake Game'),
          backgroundColor: Colors.grey[850],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  color: Colors.black,
                  width: gridWidth * gridCellSize.toDouble(),
                  height: gridHeight * gridCellSize.toDouble(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white38, width: 2),
                    ),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridWidth,
                      ),
                      itemCount: gridWidth * gridHeight,
                      itemBuilder: (context, index) {
                        int x = index % gridWidth;
                        int y = index ~/ gridWidth;
                        Offset position = Offset(x.toDouble(), y.toDouble());

                        Color color;
                        if (snake.contains(position)) {
                          color = Colors.green;
                        } else if (position == food) {
                          color = Colors.red;
                        } else {
                          color = Colors.black87;
                        }

                        return Container(
                          margin: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[850],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: $score',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text(
                      'Best: $bestScore',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}