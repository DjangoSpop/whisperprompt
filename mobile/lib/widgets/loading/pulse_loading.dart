/// Pulse loading indicator
///
/// Animated pulsing indicator for recording state

import 'package:flutter/material.dart';

class PulseLoading extends StatefulWidget {
  final Color color;
  final double size;
  final String? label;

  const PulseLoading({
    super.key,
    this.color = Colors.red,
    this.size = 80,
    this.label,
  });

  @override
  State<PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<PulseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(_animation.value * 0.3),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_animation.value * 0.5),
                    blurRadius: 20 * _animation.value,
                    spreadRadius: 5 * _animation.value,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.mic,
                  size: widget.size * 0.5,
                  color: widget.color,
                ),
              ),
            );
          },
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.color,
            ),
          ),
        ],
      ],
    );
  }
}
