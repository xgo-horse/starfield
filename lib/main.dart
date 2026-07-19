import 'dart:math';
import 'dart:ui' as ui;

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
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
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
    _controller.addListener(_updateStars);
    _controller.forward();
    _controller.repeat();
  }

  void _updateStars() {
    for (var star in stars) {
      star.updatePosition();
      if (star.position.dx.abs() >= widget.size.width / 2) {
        star.randomize(widget.size);
      } else if (star.position.dy.abs() >= widget.size.height / 2) {
        star.randomize(widget.size);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarfieldPainter(stars, repaint: _controller),
      size: widget.size,
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_updateStars);
    _controller.dispose();
    super.dispose();
  }
}

class StarfieldPainter extends CustomPainter {
  final List<Star> stars;

  StarfieldPainter(this.stars, {super.repaint});
  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      star.draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) {
    return oldDelegate.stars != stars;
  }
}

class Star {
  static const double stretchSensitivity = 0.18;
  static const double maxStretch = 14.0;

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

  double get _stretchFactor =>
      (1.0 + dz * stretchSensitivity).clamp(1.0, maxStretch);

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
    final center = Offset(
      position.dx + canvasSize.width / 2,
      position.dy + canvasSize.height / 2,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(direction);

    final length = size * (_stretchFactor - 1) * 4.5;

    if (length > 0) {
      // 1. Draw Ion Tail (thin, long, electric blue)
      final ionTailPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(-length * 1.8, 0),
          Offset.zero,
          [
            Colors.blue.withValues(alpha: 0.0),
            Colors.cyan.withValues(alpha: 0.5),
          ],
        )
        ..strokeWidth = size * 0.4
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(-length * 1.8, 0), Offset.zero, ionTailPaint);

      // 2. Draw Dust Tail (broad, tapering, cyan/white)
      final dustTailPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(-length, 0),
          Offset.zero,
          [
            Colors.cyan.withValues(alpha: 0.0),
            Colors.cyanAccent.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.6),
          ],
          [0.0, 0.6, 1.0],
        );

      final dustTailPath = Path()
        ..moveTo(0, -size * 1.2)
        ..quadraticBezierTo(-length * 0.3, -size * 0.8, -length, 0)
        ..quadraticBezierTo(-length * 0.3, size * 0.8, 0, size * 1.2)
        ..close();
      canvas.drawPath(dustTailPath, dustTailPaint);

      // 3. Draw Comet Head (bright glowing nucleus/coma)
      final headPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          size * 1.5,
          [
            Colors.white,
            Colors.cyanAccent.withValues(alpha: 0.8),
            Colors.blueAccent.withValues(alpha: 0.0),
          ],
          [0.0, 0.4, 1.0],
        );
      canvas.drawCircle(Offset.zero, size * 1.5, headPaint);
    } else {
      final paint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset.zero, size, paint);
    }

    canvas.restore();
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
