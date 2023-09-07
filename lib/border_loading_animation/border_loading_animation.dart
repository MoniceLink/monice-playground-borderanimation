import 'dart:ui';

import 'package:flutter/material.dart';

// The codes below is a changed version of the original code from: https://stackoverflow.com/a/57233047/11084704
class BorderLoadingAnimationController {
  AnimationController? _animationController;

  ValueNotifier<bool> isShown = ValueNotifier(false);

  double _value = 0;

  double get value => _value;

  BorderLoadingAnimationController();

  bool get ready => _animationController != null;

  Future<void> updateValue(
    double value, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInCubic,
  }) async {
    isShown.value = true;
    _value = value;
    await _animationController
        ?.animateTo(_value, curve: curve.flipped, duration: duration)
        .then((value) {
      if (_value == 0) {
        isShown.value = false;
      }
    });
  }

  Future<void> fullAnimation({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInCubic,
  }) async {
    isShown.value = true;
    _value = 1;
    _animationController?.reset();
    await _animationController?.animateTo(
      _value,
      curve: curve.flipped,
      duration: duration,
    );
  }

  Future<void> hide() async {
    await updateValue(0);
  }

  void show() {
    isShown.value = true;
  }
}

class BorderLoadingAnimation extends StatefulWidget {
  final Widget? child;
  final BorderLoadingAnimationController _controller;
  final double strokeWidth;
  final Color color;
  final Color? glowColor;
  final double initialValue;
  final int borderRadius;

  BorderLoadingAnimation({
    super.key,
    this.child,
    BorderLoadingAnimationController? controller,
    this.strokeWidth = 2,
    this.color = Colors.black,
    this.glowColor,
    this.initialValue = 0,
    this.borderRadius = 10,
  }) : _controller = controller ?? BorderLoadingAnimationController();

  @override
  State<BorderLoadingAnimation> createState() => _BorderLoadingAnimationState();
}

class _BorderLoadingAnimationState extends State<BorderLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    widget._controller._animationController = _controller;
    widget._controller._value = widget.initialValue;

    widget._controller.isShown.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: widget._controller.isShown.value
          ? BorderLoadingAnimationPainter(
              _controller,
              color: widget.color,
              glowColor: widget.glowColor,
              strokeWidth: widget.strokeWidth,
            )
          : null,
      child: widget.child,
    );
  }
}

class BorderLoadingAnimationPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final Color? glowColor;
  final Animation<double> _animation;
  final double borderRadius;

  BorderLoadingAnimationPainter(
    this._animation, {
    required this.color,
    this.glowColor,
    this.strokeWidth = 2,
    this.borderRadius = 10,
  }) : super(repaint: _animation);

  @override
  void paint(Canvas canvas, Size size) {
    final animationPercent = _animation.value;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width - borderRadius, 0)
      ..arcToPoint(Offset(size.width, 10), radius: const Radius.circular(10))
      ..lineTo(size.width, size.height - borderRadius)
      ..arcToPoint(Offset(size.width - 10, size.height),
          radius: const Radius.circular(10))
      ..lineTo(borderRadius, size.height)
      ..arcToPoint(Offset(0, size.height - 10),
          radius: const Radius.circular(10))
      ..lineTo(0, borderRadius)
      ..arcToPoint(const Offset(10, 0), radius: const Radius.circular(10))
      ..lineTo(size.width / 2, 0);

    final totalLength = path
        .computeMetrics()
        .fold(0.0, (double prev, PathMetric metric) => prev + metric.length);

    final currentLength = totalLength * animationPercent;

    final followablePath = extractPathUntilLength(path, currentLength);

    final Paint paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = strokeWidth;
    paint.strokeCap = StrokeCap.round;
    //paint.strokeJoin = StrokeJoin.round;
    paint.isAntiAlias = true;
    paint.filterQuality = FilterQuality.high;

    canvas.drawPath(followablePath, paint);
    if (glowColor != null) {
      paint.color = glowColor!;
      paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);
      canvas.drawPath(followablePath, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  Path extractPathUntilLength(
    Path originalPath,
    double length,
  ) {
    var currentLength = 0.0;

    final path = Path();

    var metricsIterator = originalPath.computeMetrics().iterator;

    while (metricsIterator.moveNext()) {
      var metric = metricsIterator.current;

      var nextLength = currentLength + metric.length;

      final isLastSegment = nextLength > length;
      if (isLastSegment) {
        final remainingLength = length - currentLength;
        final pathSegment = metric.extractPath(0.0, remainingLength);

        path.addPath(pathSegment, Offset.zero);
        break;
      } else {
        final pathSegment = metric.extractPath(0.0, metric.length);
        path.addPath(pathSegment, Offset.zero);
      }

      currentLength = nextLength;
    }

    return path;
  }
}
