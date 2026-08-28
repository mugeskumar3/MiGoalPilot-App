import 'package:flutter/material.dart';

class AppFadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double delayInMilliseconds;
  final Offset beginOffset;

  const AppFadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 550),
    this.delayInMilliseconds = 0,
    this.beginOffset = const Offset(0.0, 0.05),
  });

  @override
  State<AppFadeInSlide> createState() => _AppFadeInSlideState();
}

class _AppFadeInSlideState extends State<AppFadeInSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.delayInMilliseconds > 0) {
      Future.delayed(
        Duration(milliseconds: widget.delayInMilliseconds.toInt()),
        () {
          if (mounted) _controller.forward();
        },
      );
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}
