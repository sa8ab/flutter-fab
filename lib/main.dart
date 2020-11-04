import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:interpolate/interpolate.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

void main() {
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
  bool isOpen = false;

  getSimulation(to, {velocity = 1.0}) {
    return SpringSimulation(
      SpringDescription(
        mass: 1,
        stiffness: 100,
        damping: 10,
      ),
      ctrl.value, // starting point
      to, // ending point
      velocity, // velocity
    );
  }

  getCloseSimulation(to, {velocity = 1.0}) {
    return SpringSimulation(
      SpringDescription(
        mass: 1,
        stiffness: 400,
        damping: 40,
      ),
      ctrl.value, // starting point
      to, // ending point
      velocity, // velocity
    );
  }

  void initState() {
    super.initState();
    ctrl = AnimationController(vsync: this, upperBound: 1.0, lowerBound: 0);
    ctrl.value = 0.0;
    BackButtonInterceptor.add(myInterceptor);
  }

  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    if (isOpen) {
      ctrl.animateWith(getCloseSimulation(0.0));
      setState(() {
        isOpen = false;
      });
      return true;
    } else {
      return false;
    }
  }

  Widget renderContent(context) {
    return Column(
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Text(
              'Render Cutsom Widget',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Flexible(child: TextField()),
      ],
    );
  }

  Widget actionButton(context) {
    final size = MediaQuery.of(context).size;
    Interpolate width = Interpolate(
      inputRange: [0, 1],
      outputRange: [58, size.width],
    );
    Interpolate height = Interpolate(
      inputRange: [0, 1],
      outputRange: [58, size.height],
    );
    Interpolate space = Interpolate(
      inputRange: [0, 1],
      outputRange: [10, 0],
    );
    Interpolate radius = Interpolate(
      inputRange: [0, 1],
      outputRange: [40, 0],
    );
    Interpolate buttonOpacity = Interpolate(
      inputRange: [0, 1],
      outputRange: [1, 0],
    );
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final color = ctrl.value > 1
            ? Colors.pink
            : ColorTween(begin: Color(0xffF79F1F), end: Colors.pink)
                .animate(ctrl)
                .value;
        return Positioned(
          bottom: space.eval(ctrl.value),
          right: space.eval(ctrl.value),
          child: GestureDetector(
            onVerticalDragUpdate: isOpen
                ? (DragUpdateDetails e) {
                    final move = e.delta.dy;
                    final value = ctrl.value;
                    ctrl.value = (value - (move / size.height));
                  }
                : null,
            onVerticalDragEnd: isOpen
                ? (DragEndDetails e) {
                    if (e.primaryVelocity > 0) {
                      double velocity = (e.primaryVelocity / 80);
                      ctrl.animateWith(
                          getCloseSimulation(0.0, velocity: velocity));
                      setState(() {
                        isOpen = false;
                      });
                    } else {
                      isOpen = true;
                      double velocity = (e.primaryVelocity / 80);
                      ctrl.animateWith(
                          getCloseSimulation(1.0, velocity: -velocity));
                    }
                  }
                : null,
            child: Container(
              width: width.eval(ctrl.value),
              height: height.eval(ctrl.value),
              decoration: BoxDecoration(
                // color: Color(0xffF79F1F),
                color: color,
                borderRadius: BorderRadius.all(
                  Radius.circular(radius.eval(ctrl.value)),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40.2),
                    child: FlatButton(
                      onPressed: !isOpen
                          ? () {
                              setState(() {
                                isOpen = true;
                              });
                              ctrl.animateWith(getCloseSimulation(1.0));
                            }
                          : null,
                      child: Opacity(
                        opacity: buttonOpacity.eval(ctrl.value),
                        child: SizedBox.expand(
                          child: Icon(Icons.add),
                        ),
                      ),
                    ),
                  ),
                  //content
                  IgnorePointer(
                    ignoring: !isOpen,
                    child: Transform.scale(
                        scale: ctrl.value, child: renderContent(context)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _body(context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Text('$isOpen'),
              ],
            ),
          ),
        ),
        actionButton(context),
      ],
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
