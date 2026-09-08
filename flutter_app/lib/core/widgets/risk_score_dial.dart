import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class RiskScoreDial extends StatefulWidget {
  final int score; // 0 to 100
  final double size;
  final bool showAnimation;
  final String? subtitle;

  const RiskScoreDial({
    super.key,
    required this.score,
    this.size = 200,
    this.showAnimation = true,
    this.subtitle,
  });

  @override
  State<RiskScoreDial> createState() => _RiskScoreDialState();
}

class _RiskScoreDialState extends State<RiskScoreDial> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    final targetValue = (widget.score.clamp(0, 100)) / 100.0;
    _animation = Tween<double>(begin: 0.0, end: targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.showAnimation) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant RiskScoreDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      final targetValue = (widget.score.clamp(0, 100)) / 100.0;
      _animation = Tween<double>(
        begin: _animation.value,
        end: targetValue,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = AppColors.getRiskColor(widget.score);
    final riskLabel = AppColors.getRiskLabel(widget.score);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animatedScore = (_animation.value * 100).round();
          return Stack(
            alignment: Alignment.center,
            children: [
              // Custom Arc Gauge
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RiskGaugePainter(
                  progress: _animation.value,
                  riskColor: riskColor,
                  backgroundColor: AppColors.surfaceBorder,
                ),
              ),

              // Glowing Center Ambient Glow
              Container(
                width: widget.size * 0.62,
                height: widget.size * 0.62,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: riskColor.withValues(alpha: 0.18),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$animatedScore',
                        style: AppTypography.displayBold.copyWith(
                          fontSize: widget.size * 0.26,
                          color: riskColor,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          riskLabel,
                          style: AppTypography.caption.copyWith(
                            color: riskColor,
                            fontSize: widget.size * 0.065,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: widget.size * 0.05,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RiskGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color riskColor;
  final Color backgroundColor;

  _RiskGaugePainter({
    required this.progress,
    required this.riskColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;
    const startAngle = 135.0 * (math.pi / 180.0);
    const sweepAngle = 270.0 * (math.pi / 180.0);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw Background Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Draw Active Progress Arc
    final activeSweep = sweepAngle * progress;
    if (activeSweep > 0) {
      final activePaint = Paint()
        ..color = riskColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweep,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RiskGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.riskColor != riskColor;
  }
}
