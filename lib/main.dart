import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData(
        backgroundColor: Colors.teal[100], //background color..
        accentColor: Colors.teal[200], //snake's path color..
        primaryColor: Colors.teal[900], //snake itself color..
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static List<int> snakePosition = [35, 55, 75];
  int score = 3;
  int time = 250;
  static int numOfSquares = 560;
  static var randomNum = Random();
  int food = randomNum.nextInt(numOfSquares - 1);
  bool changeLevel = false, gameIsRunning = false;
  int targetScore = 20;
  int oldTarget = 20;

  @override
  void initState() {
    super.initState();
    Timer.run(() {
      _checkLevel(0);
    });
  }

  void _checkLevel(int sel) {
    String titleText, bodyText;
    //sel=0->game is initially start..
    //sel=1->level is done and target was acheived..
    //sel=2->change level..
    //sel=3->game was Over and playagain..
    switch (sel) {
      case 0:
        {
          titleText = 'WELCOME TO SNAKE GAME!!';
          bodyText = 'Choose a Level to start the game:';
          break;
        }
      case 1:
        {
          titleText = 'YESS: The TARGET is Acheived!!';
          bodyText = 'Choose another Level to try this time:';
          break;
        }
      case 2:
        {
          titleText = 'CHANGE TO ANOTHER LEVEL:';
          bodyText = 'Choose the Level you want to try:';
          break;
        }
      case 3:
        {
          titleText = 'GAME IS OVER :( ';
          bodyText = 'TRY again you will do it this timne:';
          break;
        }
      default:
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titleText),
            content: Text(bodyText),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  time = 250;
                  targetScore = 20;
                  Navigator.of(context).pop();
                },
                child: Text('Easy'),
              ),
              FlatButton(
                onPressed: () {
                  time = 150;
                  targetScore = 25;
                  Navigator.of(context).pop();
                },
                child: Text('Medium'),
              ),
              FlatButton(
                onPressed: () {
                  time = 50;
                  targetScore = 30;
                  Navigator.of(context).pop();
                },
                child: Text('Hard'),
              )
            ],
          );
        });
  }

  void generateFood() {
    bool again = true;
    while (again) {
      food = randomNum.nextInt(numOfSquares - 1);
      for (int i = 0; i < snakePosition.length; i++) {
        if (food == snakePosition[i]) {
          again = true;
          break;
        } else
          again = false;
      }
    }
  }

  void startGame() {
    var duration = Duration(milliseconds: time);
    Timer.periodic(duration, (timer) {
      oldTarget = targetScore;
      gameIsRunning = true;
      //this is done each frame after the delay:
      updateSnake();
      if (score >= targetScore) {
        timer.cancel();
        gameIsRunning = false;
        _checkLevel(1);
      }
      if (changeLevel) {
        timer.cancel();
        gameIsRunning = false;
        _checkLevel(2);
        changeLevel = false;
      }
      if (gameOver() && snakePosition.length != 3) {
        timer.cancel();
        gameIsRunning = false;
        snakePosition = [35, 55, 75];
        _checkLevel(3);
      }
    });
  }

  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      for (int j = i + 1; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          return true;
        }
      }
    }
    //if we reached this line ->this mean the snake doen't crash into itself..
    return false;
  }

  String direction = 'down';
  void updateSnake() {
    setState(() {
      switch (direction) {
        case 'down':
          {
            if (snakePosition.last >= numOfSquares - 20) {
              //last row..
              snakePosition.add(snakePosition.last + 20 - numOfSquares);
            } else {
              snakePosition.add(snakePosition.last + 20);
            }
            break;
          }
        case 'up':
          {
            if (snakePosition.last < 20) {
              //first row..
              snakePosition.add(snakePosition.last - 20 + numOfSquares);
            } else {
              snakePosition.add(snakePosition.last - 20);
            }
            break;
          }
        case 'left':
          {
            if (snakePosition.last % 20 == 0) {
              //first col..
              snakePosition.add(snakePosition.last - 1 + 20);
            } else {
              snakePosition.add(snakePosition.last - 1);
            }
            break;
          }
        case 'right':
          {
            if ((snakePosition.last + 1) % 20 == 0) {
              //last col..
              snakePosition.add(snakePosition.last + 1 - 20);
            } else {
              snakePosition.add(snakePosition.last + 1);
            }
            break;
          }
        default:
      }
      //if snake eats the food it will be bigger with one..
      if (snakePosition.last == food) {
        generateFood();
        score = snakePosition.length -
            3; //this 3 is the initial length of the snake..
      } else
        snakePosition.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (oldTarget != targetScore) {
                        snakePosition = [35, 55, 75];
                        score = 0;
                      }
                      if (!gameIsRunning) startGame();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Run',
                        style: TextStyle(
                          color: Theme.of(context).backgroundColor,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '@ C r e a t e d  b y  L o a y M H .. ',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (direction != 'up' && details.delta.dy > 0)
                    direction = 'down';
                  else if (direction != 'down' && details.delta.dy < 0)
                    direction = 'up';
                },
                onHorizontalDragUpdate: (details) {
                  if (direction != 'right' && details.delta.dx < 0)
                    direction = 'left';
                  else if (direction != 'left' && details.delta.dx > 0)
                    direction = 'right';
                },
                child: Container(
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 20),
                    itemBuilder: (BuildContext context, int index) {
                      Color currGridColor = Theme.of(context).accentColor;
                      if (snakePosition.contains(index)) {
                        currGridColor = Theme.of(context).primaryColor;
                      }
                      if (index == food) {
                        currGridColor = Colors.red[800];
                      }
                      if (index >= numOfSquares)
                        currGridColor = Theme.of(context).backgroundColor;
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: currGridColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Your score is $score / $targetScore',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      changeLevel = true;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'Level',
                          style: TextStyle(
                            color: Theme.of(context).backgroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
