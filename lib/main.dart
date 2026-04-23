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

    for (var i = 0; i < 20; i++) {
      final star = Star(
        size: Random().nextDouble() * 3 + 1,
        x: widget.size.width / 2,
        y: widget.size.height / 2,
        dx: 1,
        dy: 1,
      );

      star.randomize(widget.size);
      stars.add(star);
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: 1),
    );
    _controller.addListener(() {
      for (var star in stars) {
        star.updatePosition();
        if (star.x >= widget.size.width || star.x <= 0) {
          star.randomize(widget.size);
        } else if (star.y >= widget.size.height || star.y <= 0) {
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
      star.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Star {
  double size;
  double x;
  double y;
  double dx;
  double dy;

  Star({
    required this.size,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
  });

  void draw(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x, y), size, paint);
  }

  void updatePosition() {
    x = x + dx;
    y = y + dy;
  }

  void randomize(Size canvasSize) {
    double direction = Random().nextDouble() * pi * 2;
    double distance = Random().nextDouble();
    Offset center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    Offset positionOffset = Offset.fromDirection(
      direction,
      distance * canvasSize.width * 0.3,
    );
    Offset velocityOffset = Offset.fromDirection(direction, distance * 6 + 3);

    x = center.dx + positionOffset.dx;
    y = center.dy + positionOffset.dy;
    dx = velocityOffset.dx;
    dy = velocityOffset.dy;
  }
}
