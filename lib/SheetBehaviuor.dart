import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

void main() {
  debugPrintGestureArenaDiagnostics = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: MyApp2(),
    );
  }
}

class MyApp2 extends StatefulWidget {
  @override
  _MyApp2State createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> with SingleTickerProviderStateMixin {
  AnimationController ctrl;
  ScrollController scrollController;
  ScrollPhysics scrollPhysics;
  bool canSetState = true;
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(initialScrollOffset: 100.0);
    scrollPhysics = AlwaysScrollableScrollPhysics();
    ctrl = AnimationController(lowerBound: 0, upperBound: 10000, vsync: this);
    ctrl.value = 0;
  }

  _renderContent() {
    return Column(
      children: <Widget>[
        Container(
          height: 100,
          color: Colors.lime,
          margin: EdgeInsets.all(4.0),
        ),
        Container(
          height: 100,
          color: Colors.lime,
          margin: EdgeInsets.all(4.0),
        ),
        Container(
          height: 100,
          color: Colors.lime,
          margin: EdgeInsets.all(4.0),
          child: FlatButton(onPressed: () {}, child: Text('sdfds')),
        ),
        Container(
          height: 100,
          color: Colors.lime,
          margin: EdgeInsets.all(4.0),
        ),
      ],
    );
  }

  _body(context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (context, snapshot) {
        return Column(
          children: <Widget>[
            Container(
              height: ctrl.value,
              color: Colors.red,
            ),
            Expanded(
              child: RawGestureDetector(
                gestures: <Type, GestureRecognizerFactory>{
                  CustomGestureOne:
                      GestureRecognizerFactoryWithHandlers<CustomGestureOne>(
                    () => CustomGestureOne(),
                    (instance) {
                      instance.onUpdate = (details) {
                        print('dragging');
                        if (scrollController.position.atEdge) {
                          // if (canSetState) {
                          //   setState(() {
                          //     scrollPhysics = NeverScrollableScrollPhysics();
                          //     canSetState = false;
                          //   });
                          // }

                          // if (ctrl.value < 2) {
                          //   setState(() {
                          //     scrollPhysics = AlwaysScrollableScrollPhysics();
                          //   });
                          // }
                          ctrl.value = ctrl.value + details.delta.dy;
                        } else {
                          // user is not at the edge but is red
                          ctrl.value = ctrl.value + details.delta.dy;
                          if (canSetState) {
                            setState(() {
                              scrollPhysics = NeverScrollableScrollPhysics();
                              canSetState = false;
                            });
                          }
                        }
                      };
                    },
                  ),
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: scrollPhysics,
                  child: Container(
                    height: 4000,
                    child: Container(
                      color: Colors.lightBlue,
                      width: 200,
                      height: 200,
                      child: _renderContent(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Animted Bottom Tab Bar'),
      //   backgroundColor: Colors.black45,
      //   elevation: 2,
      // ),
      body: _body(context),
    );
  }
}

class CustomGestureOne extends PanGestureRecognizer {
  bool reject = false;
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }

  // void customFunction() {
  //   rejectGesture(10);
  // }
}
