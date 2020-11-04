import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:interpolate/interpolate.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
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
  Interpolate inter = Interpolate(
    inputRange: [0, 1, 2, 3],
    outputRange: [-1, -0.33333, 0.33333, 1],
    extrapolate: Extrapolate.extend,
  );

  getSimulation(to) {
    return SpringSimulation(
      SpringDescription(
        mass: 1,
        stiffness: 100,
        damping: 10,
      ),
      ctrl.value, // starting point
      to, // ending point
      1, // velocity
    );
  }

  void initState() {
    super.initState();
    ctrl = AnimationController(vsync: this, upperBound: 10, lowerBound: -10);
    ctrl.value = 0.0;
  }

  _body() {
    return Row(
      children: <Widget>[
        Container(
          child: FlatButton(
            onPressed: () {
              ctrl.animateWith(getSimulation(3.0));
            },
            child: Text('Animate'),
          ),
        ),
        AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) {
              return Text('${ctrl.value}');
            })
      ],
    );
  }

  _bottomNavigation() {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: AnimatedBuilder(
                  animation: ctrl,
                  builder: (_, __) {
                    return Stack(
                      children: <Widget>[
                        Positioned.fill(
                          left: 0,
                          bottom: 0,
                          child: FractionallySizedBox(
                            alignment: Alignment(inter.eval(ctrl.value), 0),
                            widthFactor: 0.25,
                            heightFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                color: Colors.pink,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  ctrl.animateWith(getSimulation(0.0));
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  color: Colors.orange,
                                ),
                              ),
                              flex: 1,
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  ctrl.animateWith(getSimulation(1.0));
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  color: Colors.orange,
                                ),
                              ),
                              flex: 1,
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  ctrl.animateWith(getSimulation(2.0));
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  color: Colors.orange,
                                ),
                              ),
                              flex: 1,
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  ctrl.animateWith(getSimulation(3.0));
                                },
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  color: Colors.orange,
                                ),
                              ),
                              flex: 1,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animted Bottom Tab Bar')),
      body: _body(),
      bottomNavigationBar: _bottomNavigation(),
    );
  }
}

// animation.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         controller.reverse();
//       } else if (status == AnimationStatus.dismissed) {
//         controller.forward();
//       }
//     });
