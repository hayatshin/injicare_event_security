import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injicare_event/models/event_model.dart';

class CircleProgressWidget extends ConsumerStatefulWidget {
  final EventModel eventModel;
  final int userScore;
  const CircleProgressWidget({
    super.key,
    required this.eventModel,
    required this.userScore,
  });

  @override
  ConsumerState<CircleProgressWidget> createState() =>
      _CircleProgressWidgetState();
}

class _CircleProgressWidgetState extends ConsumerState<CircleProgressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..forward();

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.bounceOut,
  );

  late Animation<double> _progress = Tween(
    begin: 0.005,
    end: 1.0,
  ).animate(_curve);

  Future<void> _setProgressValues() async {
    int targetPoint = widget.eventModel.targetScore;

    if (mounted) {
      setState(() {
        _progress = Tween(
          begin: 0.0,
          end: (widget.userScore / targetPoint) < 1
              ? (widget.userScore / targetPoint)
              : 1.0,
        ).animate(_curve);
      });
    }

    _animationController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();

    _setProgressValues();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return CustomPaint(
              painter: CircleProgressPainter(
                  progress: _progress.value, context: context),
              size: Size(size.width * 0.5, size.width * 0.3),
            );
          },
        ),
      ],
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final BuildContext context;
  final double progress;

  CircleProgressPainter({
    required this.context,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 5;
    const startingAngle = -0.5 * pi;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    // circle
    final backCirclePaint = Paint()
      ..color = Theme.of(context).primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawCircle(center, radius, backCirclePaint);

    final redArcPaint = Paint()
      ..color = Theme.of(context).primaryColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;

    // progress
    final progressArcRect = Rect.fromCircle(
      center: center,
      radius: radius,
    );
    canvas.drawArc(
        progressArcRect, startingAngle, progress * 2 * pi, false, redArcPaint);
  }

  @override
  bool shouldRepaint(covariant CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
