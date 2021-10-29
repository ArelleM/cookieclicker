import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import 'bounce.dart';
import 'package:circle_list/circle_list.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CupcakeClicker',
      home: MyHomePage(title: 'CupcakeClicker'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  int _counter = 0;
  int _counterAutoClick = 0;
  int _autoClickerPrice = 8;
  int _addCursorPrice = 6;
  double _waveSize = 0;
  late final AnimationController _controller;
  int _nbClick = 1;
  bool isCookieClicked = false;
  late Timer _timer;
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 10))..repeat();
    readData();

  }

  void readData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('counter') == null)
      setState(() => _counter = 0 );
    else
      setState(() => _counter = prefs.getInt('counter')!);

    if ( prefs.getInt('autoClickerPrice') == null) {
      setState(() {
        _autoClickerPrice = 8;
      });
    }
    else {
      setState(() {
        _autoClickerPrice = prefs.getInt('autoClickerPrice')!;
      });
    }

    if ( prefs.getInt('addCursorPrice') == null) {
      setState(() {
        _addCursorPrice = 6;
      });
    }
    else {
      setState(() {
        _addCursorPrice = prefs.getInt('addCursorPrice')!;
      });
    }

    if ( prefs.getInt('nbClick') == null) {
      setState(() {
        _nbClick = 1;
      });
    }
    else {
      setState(() {
        _nbClick = prefs.getInt('nbClick')!;
      });
    }
    if ( prefs.getInt('counterAutoClick') == null) {
      setState(() {
        _counterAutoClick = 0;
      });
    }
    else {
      setState(() {
        _counterAutoClick = prefs.getInt('counterAutoClick')!;
        _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => setState(() {
          _counter = _counter + _counterAutoClick;
          prefs.setInt("counter", _counter);
        }));
      });
    }
    setState(() {
      if(_counter/10.roundToDouble() < 300){
        _waveSize = _counter/10.roundToDouble();
      }
      else{
        _waveSize = 300;
      }
    });
  }

  Future<AudioPlayer> playLocalAsset(localAssetSound) async {
    AudioCache cache = new AudioCache();
    //At the next line, DO NOT pass the entire reference such as assets/yes.mp3. This will not work.
    //Just pass the file name only.
    return await cache.play("$localAssetSound",volume: 1000);
  }

  void _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isCookieClicked = true;
      _counter = _counter + _nbClick;
      if(_counter/10.roundToDouble() < 300){
        _waveSize = _counter/10.roundToDouble();
      }
      else{
        _waveSize = 300;
      }
    });
    await Future.delayed(const Duration(milliseconds: 200), (){
      setState(() {
        isCookieClicked = false;
        prefs.setInt('counter', _counter);
      });
    });
  }
  
  void _autoClicker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(_counter >= _autoClickerPrice) {
      Vibration.vibrate(duration: 1000);
      playLocalAsset("sounds/rainbow.wav");
      setState(() {
        _counter = _counter - _autoClickerPrice;
        _autoClickerPrice = _autoClickerPrice * 2;
        _counterAutoClick ++;
        prefs.setInt("autoClickerPrice", _autoClickerPrice);
        prefs.setInt("counterAutoClick", _counterAutoClick);
        _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => setState(() {
          _counter = _counter + 1;
          prefs.setInt("counter", _counter);
          if(_counter/10.roundToDouble() < 300){
            _waveSize = _counter/10.roundToDouble();
          }
          else{
            _waveSize = 300;
          }
        }));
      });
    } else {
      setState(() {

      });
    }

  }

  void _increaseNbClick() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if(_counter - _addCursorPrice >= 0) {
      Vibration.vibrate(duration: 1000);
      playLocalAsset("sounds/magicWand.wav");
      setState(() {
        _counter = _counter - _addCursorPrice;
        _addCursorPrice = _addCursorPrice * 2;
        _nbClick ++;
        prefs.setInt("addCursorPrice", _addCursorPrice);
        prefs.setInt("nbClick", _nbClick);
      });

    } else {
      setState(() {

    });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                repeat: ImageRepeat.repeatX,
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover
              )
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 400,
                  child: CircleList(
                    innerRadius: 40,
                    innerCircleRotateWithChildren: true,
                    childrenPadding: 1,
                    origin: Offset(0,0),
                    children: List.generate(_nbClick -1, (index) {
                      return Image.asset("assets/images/magicWand.png",height: 20,width: 20,);
                    }),),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 400,
                  child: CircleList(
                    initialAngle: 60,
                    innerRadius: 80,
                    innerCircleRotateWithChildren: true,
                    childrenPadding: 1,
                    origin: Offset(0,0),
                    children: List.generate(_counterAutoClick, (index) {
                      return Image.asset("assets/images/rainbow.png",height: 20,width: 20,);
                    }),),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 50),
                          height: 250, width: 500,
                          decoration:
                            const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/images/top.png'),
                                    fit: BoxFit.cover)
                            ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$_counter',style: TextStyle(color: Colors.white,fontSize: 30,fontFamily: 'Gluten',fontWeight: FontWeight.w700),),
                            const SizedBox(width: 20,),
                            const Image(
                                height: 50,
                                image: AssetImage("assets/images/cupcake.png")
                            )
                          ],
                        ),),


                        ],
                      ),

                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          height: 190,
                          decoration: const BoxDecoration(
                            image: DecorationImage(image: AssetImage("assets/images/whiteHalo.png"))
                          ),
                        ),

                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, child) {
                            return Transform.rotate(
                              angle: _controller.value * 2 * math.pi,
                              child: child,
                            );
                          },
                          child: InkWell(
                            onTap: _incrementCounter
                            ,
                            child:
                                _counter < 1000 ?
                            const Image(
                                height: 200,
                                image: AssetImage("assets/images/unicorn1.png"),
                              fit: BoxFit.contain,
                            ): _counter < 2000 ?
                                const Image(
                                  height: 200,
                                  image: AssetImage("assets/images/unicorn2.png"),
                                  fit: BoxFit.contain,
                                ):
                                const Image(
                                  height: 200,
                                  image: AssetImage("assets/images/unicorn3.png"),
                                  fit: BoxFit.contain,
                                ),
                          ),
                        ),

                        Positioned(
                          top: math.Random().nextInt(150).toDouble(),
                          left: math.Random().nextInt(300).toDouble(),
                          child: Text('+$_nbClick',style: isCookieClicked ?
                          const TextStyle(fontFamily: 'Gluten',fontSize: 50,fontWeight: FontWeight.bold, color: Colors.pinkAccent)
                              : const TextStyle(fontFamily: 'Gluten', fontSize: 20, fontWeight: FontWeight.normal, color: Colors.transparent),),

                        )
                      ],

                    ),

                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            bottom: 0,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: WaveWidget(
                                  config: CustomConfig(
                                    heightPercentages: [0.20, 0.23, 0.25, 0.30],
                                    durations: [35000, 19440, 10800, 6000],
                                    colors: [Color(0xEEB79CC7),Color(0xEEF597BC),Color(0xEEFFFFFF),Color(0xEEA9E5F0)]
                                    ,

                                  ), size: Size(MediaQuery.of(context).size.width, _waveSize)

                                ),
                              ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Bouncing(
                                onPress: () => {},
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(30),
                                      shape: const CircleBorder(),
                                      primary: Colors.white
                                  ),
                                  onPressed: _counter > _addCursorPrice ? _increaseNbClick : null,
                                  child: PowerUp(iconImage: const AssetImage("assets/images/magicWand.png"),powerUp: "x $_nbClick", price: _addCursorPrice, color: _counter > _addCursorPrice ? '1dd1a1' : 'ee5253', ),
                                ),
                              ),

                              Bouncing(
                                onPress: () => {},
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.all(30),
                                        shape: CircleBorder(),
                                        primary: Colors.white
                                    ),
                                    onPressed: _counter > _autoClickerPrice ? _autoClicker : null,
                                    child: PowerUp(iconImage: AssetImage("assets/images/rainbow.png"), powerUp: "+ ${_counterAutoClick+1}/s", price: _autoClickerPrice, color: _counter > _autoClickerPrice ? '1dd1a1' : 'ee5253', )
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    )

                    ],
                ),
              ],
            ),
        ),
      ),
    );
  }
}


class PowerUp extends StatelessWidget {
  final iconImage;
  final powerUp;
  final price;
  final color;

  const PowerUp({
    Key? key,
    required AssetImage this.iconImage,
    required String this.powerUp,
    required int this.price,
    required String this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: iconImage
                )
            ),
          ),
        ),

        const SizedBox(height: 5,),
        Text("$powerUp",style: const TextStyle(fontFamily: 'Gluten',color: Colors.black)),
        const SizedBox(height: 5,),
        Row(
          children: [
            Text("$price",style: TextStyle(fontFamily: 'Gluten', color: Color(int.parse('0xEE$color'))),),
            const SizedBox(width: 5,),
            const Image(
                height: 15,
                image: AssetImage("assets/images/cupcake.png")
            )
          ],
        )
      ],
    );
  }

}
