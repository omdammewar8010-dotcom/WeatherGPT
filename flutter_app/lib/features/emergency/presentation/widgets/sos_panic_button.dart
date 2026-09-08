import 'package:flutter/material.dart';
import 'package:ner_landslideguard/core/theme/app_colors.dart';
import 'package:ner_landslideguard/core/theme/app_typography.dart';

class SosPanicButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isSubmitting;

  const SosPanicButton({
    super.key,
    required this.onTap,
    this.isSubmitting = false,
  });

  @override
  State<SosPanicButton> createState() => _SosPanicButtonState();
}

class _SosPanicButtonState extends State<SosPanicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFF3333),
                    AppColors.riskCritical,
                    Color(0xFF8B0000),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.riskCritical.withValues(alpha: 0.5),
                    blurRadius: 28,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.isSubmitting ? null : widget.onTap,
                  child: Center(
                    child: widget.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sos_rounded, color: Colors.white, size: 44),
                              const SizedBox(height: 2),
                              Text(
                                'TAP FOR SOS',
                                style: AppTypography.heading3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
