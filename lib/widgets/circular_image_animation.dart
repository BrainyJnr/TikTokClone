import 'package:flutter/material.dart';

class CircularImageAnimation extends StatefulWidget {
  final Widget? widgetAnimation;

  CircularImageAnimation({this.widgetAnimation});

  @override
  State<CircularImageAnimation> createState() => _CircularImageAnimationState();
}

class _CircularImageAnimationState extends State<CircularImageAnimation> with SingleTickerProviderStateMixin {
  late AnimationController controllerAnimation;

  @override
  void initState() {
    super.initState();
    controllerAnimation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000), // Corrected to milliseconds
    );
    controllerAnimation.forward();
    controllerAnimation.repeat();
  }

  @override
  void dispose() {
    controllerAnimation.dispose();
    super.dispose(); // Moved super.dispose() after disposing controller
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(controllerAnimation),
      child: widget.widgetAnimation, // Corrected typo from widgetAniamtion to widgetAnimation
    );
  }
}
