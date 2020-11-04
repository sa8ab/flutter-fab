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
    ctrl = AnimationController(vsync: this, upperBound: 2.0, lowerBound: 0);
    ctrl.value = 0.0;
    BackButtonInterceptor.add(myInterceptor);
  }

  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON! ${ctrl.value}"); // Do some stuff.
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
            onTap: () {
              print('tapped');
              setState(() {
                isOpen = true;
              });
              ctrl.animateWith(getSimulation(1.0));
            },
            onVerticalDragUpdate: (DragUpdateDetails e) {
              final move = e.delta.dy;
              final value = ctrl.value;
              ctrl.value = (value - (move / size.height));
            },
            onVerticalDragEnd: (DragEndDetails e) {
              if (e.primaryVelocity > 0) {
                double velocity = (e.primaryVelocity / 80);
                ctrl.animateWith(getCloseSimulation(0.0, velocity: velocity));
                setState(() {
                  isOpen = false;
                });
              } else {
                isOpen = true;
                double velocity = (e.primaryVelocity / 80);
                ctrl.animateWith(getSimulation(1.0, velocity: -velocity));
              }
            },
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
                  Icon(Icons.add),
                  TextField(),
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
            color: Colors.lightBlue,
            child: Text('dsfsf'),
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
