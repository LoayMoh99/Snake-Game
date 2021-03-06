import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //list for storing the positions of the snake..
  static List<int> snakePosition = [35, 55, 75];
  int score = 3;
  //time in millisec for delay between drawing each frame
  int time = 250;
  //num of squares drawn for the playground
  static int numOfSquares = 560;
  static var randomNum = Random();
  int food = randomNum.nextInt(numOfSquares - 1);
  //all these helps in stopping the game level
  bool changeLevel = false, gameIsRunning = false;
  String targetLevel = 'Easy';
  String oldTarget = 'Easy';
  final player = AudioCache();
  SharedPreferences sharedPreferences;
  int highScore = 0;

  Future<void> _getPreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _getPreference();
    highScore = _getHighScore();
    ScreenUtil.init();
    Timer.run(() {
      _checkLevel(0);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void playLocal() {
    player.play('crunch.mp4');
  }

  ///this finction not only is diplayed at first to check the starting level
  ///
  ///it is also for showing when change level is checked
  ///and when game is over..
  void _checkLevel(int sel) {
    String titleText, bodyText;
    //*sel=0->game is initially start..
    //*sel=1->change level..
    //*sel=2->game was Over and playagain..
    switch (sel) {
      case 0:
        {
          titleText = 'WELCOME TO SNAKE GAME!!';
          bodyText = 'Choose a Level to start the game:';
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
                  targetLevel = 'Easy';
                  Navigator.of(context).pop();
                },
                child: Text('Easy'),
              ),
              FlatButton(
                onPressed: () {
                  time = 150;
                  targetLevel = 'Medium';
                  Navigator.of(context).pop();
                },
                child: Text('Medium'),
              ),
              FlatButton(
                onPressed: () {
                  time = 50;
                  targetLevel = 'Hard';
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

  int _getHighScore() {
    if (sharedPreferences != null)
      return sharedPreferences.getInt('highscore');
    else
      return 0;
  }

  void _setHighScore() {
    int prevHighScore = _getHighScore();
    if (score > prevHighScore) {
      sharedPreferences.setInt('highscore', score);
    }
    highScore = prevHighScore;
  }

  void startGame() {
    var duration = Duration(milliseconds: time);
    Timer.periodic(duration, (timer) {
      oldTarget = targetLevel;
      gameIsRunning = true;
      //this is done each frame after the delay:
      updateSnake();

      if (changeLevel) {
        timer.cancel();
        gameIsRunning = false;
        _setHighScore();
        _checkLevel(1);
        changeLevel = false;
      }
      if (gameOver() && snakePosition.length != 3) {
        timer.cancel();
        gameIsRunning = false;
        snakePosition = [35, 55, 75];
        _setHighScore();
        _checkLevel(2);
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

  String direction = 'down'; //initial direction
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
        playLocal();
        generateFood();
        score = snakePosition.length -
            3; //this 3 is the initial length of the snake..
      } else
        snakePosition.removeAt(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: screenHeight * 0.05,
              padding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (oldTarget != targetLevel) {
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
                      padding: EdgeInsets.all(2),
                      child: Text(
                        '▶️ Start ',
                        style: TextStyle(
                          color: Theme.of(context).backgroundColor,
                          fontSize: ScreenUtil().setSp(50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '@ C r e a t e d  b y  L o a y M H .. ',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: ScreenUtil().setSp(36),
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
                          width: screenWidth / 20,
                          height: (screenHeight * 0.9) / (numOfSquares / 20),
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
            Container(
              height: screenHeight * 0.05,
              padding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Your Score = $score',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: ScreenUtil().setSp(70),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '🔝{$targetLevel} = $highScore',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: ScreenUtil().setSp(40),
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
                            fontSize: ScreenUtil().setSp(50),
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
