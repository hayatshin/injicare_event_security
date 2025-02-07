import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injicare_event/injicare_color.dart';

class LinearProgressWidget extends ConsumerStatefulWidget {
  // final EventModel eventModel;
  final int totalScore;
  final int userScore;
  final double width;
  const LinearProgressWidget({
    super.key,
    // required this.eventModel,
    required this.totalScore,
    required this.userScore,
    required this.width,
  });

  @override
  ConsumerState<LinearProgressWidget> createState() =>
      _LinearProgressWidgetState();
}

class _LinearProgressWidgetState extends ConsumerState<LinearProgressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..forward();

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.linear,
  );

  late Animation<double> _progress = Tween(
    begin: 0.005,
    end: 1.0,
  ).animate(_curve);

  Future<void> _setProgressValues() async {
    // int targetPoint = widget.eventModel.targetScore;

    if (mounted) {
      final cal = (widget.userScore / widget.totalScore);
      setState(() {
        _progress = Tween(
          begin: 0.0,
          end: cal.isNaN
              ? 0.0
              : (cal) < 1
                  ? (cal)
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
              painter: MyProgressPainter(
                  progress: _progress.value, context: context),
              size: Size(widget.width, 20),
            );
          },
        ),
      ],
    );
  }
}

class MyProgressPainter extends CustomPainter {
  final BuildContext context;
  final double progress;

  MyProgressPainter({
    required this.context,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // final radius = size.width / 5;
    // const startingAngle = -0.5 * pi;
    const double borderRadius = 8;
    const double height = 18;
    // circle
    final backCirclePaint = Paint()
      ..color = InjicareColor(context: context).gray10
      ..style = PaintingStyle.fill
      ..strokeWidth = height;

    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, height),
        const Radius.circular(borderRadius));
    canvas.drawRRect(rrect, backCirclePaint);

    final redArcPaint = Paint()
      ..color = InjicareColor(context: context).primary50
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = height;

    // progress
    // final progressArcRect = Rect.fromCircle(
    //   center: center,
    //   radius: radius,
    // );
    // canvas.drawArc(
    //     progressArcRect, startingAngle, progress * pi, false, redArcPaint);

    final redRrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * progress, height),
        const Radius.circular(borderRadius));
    canvas.drawRRect(redRrect, redArcPaint);
  }

  @override
  bool shouldRepaint(covariant MyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
