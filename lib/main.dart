import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Starfield',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Starfield'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: StarfieldPaint(size: MediaQuery.sizeOf(context))),
      backgroundColor: Colors.black,
    );
  }
}

class StarfieldPaint extends StatefulWidget {
  final Size size;
  const StarfieldPaint({super.key, required this.size});

  @override
  State<StarfieldPaint> createState() => _StarfieldPaintState();
}

class _StarfieldPaintState extends State<StarfieldPaint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Star> stars = [];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 30; i++) {
      final star = Star.random(
        z: Random().nextDouble() * widget.size.longestSide / 2,
      );

      stars.add(star);
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: 1),
    );
    _controller.addListener(() {
      for (var star in stars) {
        star.updatePosition();
        if (star.position.dx.abs() >= widget.size.width / 2) {
          star.randomize(widget.size);
        } else if (star.position.dy.abs() >= widget.size.height / 2) {
          star.randomize(widget.size);
        }
      }
      setState(() {});
    });
    _controller.forward();
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, child) => child!,
      animation: _controller,
      child: CustomPaint(painter: StarfieldPainter(stars), size: widget.size),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class StarfieldPainter extends CustomPainter {
  List<Star> stars;
  StarfieldPainter(this.stars);
  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      star.draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Star {
  double size;
  Offset position;
  double direction;
  double z;
  double dz;

  Star({
    required this.size,
    required this.position,
    required this.direction,
    required this.dz,
    required this.z,
  });

  factory Star.random({double z = 1}) {
    final size = Random().nextDouble() * 1.5 + 1;
    final direction = Random().nextDouble() * 2 * pi;
    final dz = Random().nextDouble() + 1;
    final position = Offset.fromDirection(direction, z);
    return Star(
      size: size,
      direction: direction,
      position: position,
      dz: dz,
      z: z,
    );
  }

  void draw(Canvas canvas, Size canvasSize) {
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(
        position.dx + canvasSize.width / 2,
        position.dy + canvasSize.height / 2,
      ),
      size,
      paint,
    );
  }

  void updatePosition() {
    z += dz;
    size = size + 0.03;
    dz += 0.07;
    position = Offset.fromDirection(direction, z);
  }

  void randomize(Size canvasSize) {
    size = Random().nextDouble() * 1.5 + 1;
    direction = Random().nextDouble() * 2 * pi;
    dz = Random().nextDouble() + 1;
    z = canvasSize.shortestSide * Random().nextDouble() * 0.2;
    position = Offset.fromDirection(direction, z);
  }
}
