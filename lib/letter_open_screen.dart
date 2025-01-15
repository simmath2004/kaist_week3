import 'package:flutter/material.dart';

class LetterOpenScreen extends StatefulWidget {
  const LetterOpenScreen({super.key});

  @override
  _LetterOpenScreenState createState() => _LetterOpenScreenState();
}

class _LetterOpenScreenState extends State<LetterOpenScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller!);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(3.14 * _animation!.value),
              alignment: FractionalOffset.center,
              child: Image.asset('assets/images/letter.png'),
            );
          },
        ),
      ),
    );
  }
}
