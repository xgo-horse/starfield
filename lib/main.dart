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

class CometColors {
  final Color ionStart;
  final Color ionEnd;
  final Color dustStart;
  final Color dustMid;
  final Color headGlow;
  final Color headOuter;

  const CometColors({
    required this.ionStart,
    required this.ionEnd,
    required this.dustStart,
    required this.dustMid,
    required this.headGlow,
    required this.headOuter,
  });
}

class Star {
  static const double stretchSensitivity = 0.18;
  static const double maxStretch = 14.0;

  static final List<CometColors> colorPatterns = [
    // 1. Classic Ice Blue
    const CometColors(
      ionStart: Colors.blue,
      ionEnd: Colors.cyan,
      dustStart: Colors.cyan,
      dustMid: Colors.cyanAccent,
      headGlow: Colors.cyanAccent,
      headOuter: Colors.blueAccent,
    ),
    // 2. Electric Teal
    const CometColors(
      ionStart: Colors.teal,
      ionEnd: Colors.cyanAccent,
      dustStart: Colors.cyanAccent,
      dustMid: Colors.tealAccent,
      headGlow: Colors.tealAccent,
      headOuter: Colors.cyan,
    ),
    // 3. Royal Indigo
    const CometColors(
      ionStart: Colors.indigo,
      ionEnd: Colors.blueAccent,
      dustStart: Colors.blueAccent,
      dustMid: Colors.lightBlueAccent,
      headGlow: Colors.lightBlueAccent,
      headOuter: Colors.blue,
    ),
    // 4. Cosmic Lavender
    const CometColors(
      ionStart: Colors.deepPurple,
      ionEnd: Colors.purpleAccent,
      dustStart: Colors.purpleAccent,
      dustMid: Colors.pinkAccent,
      headGlow: Colors.pinkAccent,
      headOuter: Colors.deepPurpleAccent,
    ),
    // 5. Starlight Cyan
    const CometColors(
      ionStart: Colors.lightBlue,
      ionEnd: Colors.cyanAccent,
      dustStart: Colors.cyanAccent,
      dustMid: Colors.white,
      headGlow: Colors.white,
      headOuter: Colors.cyanAccent,
    ),
    // 6. Soft Cobalt
    const CometColors(
      ionStart: Colors.blueAccent,
      ionEnd: Colors.indigoAccent,
      dustStart: Colors.indigoAccent,
      dustMid: Colors.blue,
      headGlow: Colors.blue,
      headOuter: Colors.blueAccent,
    ),
  ];

  double size;
  Offset position;
  double direction;
  double z;
  double dz;
  int colorPatternIndex;

  Star({
    required this.size,
    required this.position,
    required this.direction,
    required this.dz,
    required this.z,
    required this.colorPatternIndex,
  });

  double get _stretchFactor =>
      (1.0 + dz * stretchSensitivity).clamp(1.0, maxStretch);

  factory Star.random({double z = 1}) {
    final size = Random().nextDouble() * 1.5 + 1;
    final direction = Random().nextDouble() * 2 * pi;
    final dz = Random().nextDouble() + 1;
    final position = Offset.fromDirection(direction, z);
    final colorPatternIndex = Random().nextInt(colorPatterns.length);
    return Star(
      size: size,
      direction: direction,
      position: position,
      dz: dz,
      z: z,
      colorPatternIndex: colorPatternIndex,
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
    final colors = colorPatterns[colorPatternIndex];

    if (length > 0) {
      // 1. Draw Ion Tail (thin, long, specific color)
      final ionTailPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(-length * 1.8, 0),
          Offset.zero,
          [
            colors.ionStart.withValues(alpha: 0.0),
            colors.ionEnd.withValues(alpha: 0.5),
          ],
        )
        ..strokeWidth = size * 0.4
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(-length * 1.8, 0), Offset.zero, ionTailPaint);

      // 2. Draw Dust Tail (broad, tapering, specific color/white)
      final dustTailPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(-length, 0),
          Offset.zero,
          [
            colors.dustStart.withValues(alpha: 0.0),
            colors.dustMid.withValues(alpha: 0.3),
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
            colors.headGlow.withValues(alpha: 0.8),
            colors.headOuter.withValues(alpha: 0.0),
          ],
          [0.0, 0.4, 1.0],
        );
      canvas.drawCircle(Offset.zero, size * 1.5, headPaint);
    } else {
      final paint = Paint()..color = colors.headGlow;
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
    colorPatternIndex = Random().nextInt(colorPatterns.length);
  }
}
