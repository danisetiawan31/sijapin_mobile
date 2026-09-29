import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

/// Titik berdenyut (ping) untuk penanda status live antrean dan tiket aktif.
///
/// Ring transparan membesar dari titik lalu memudar, memberi kesan "live"
/// tanpa mengganggu hierarki teks di sekitarnya.
class PulseDot extends StatefulWidget {
  const PulseDot({
    super.key,
    this.color = AppColors.brandGoldenCaramel,
    this.size = 10,
    this.pulse = true,
  });

  final Color color;
  final double size;

  /// Bila `false`, hanya titik pekat tanpa cincin berdenyut.
  final bool pulse;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant PulseDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse == oldWidget.pulse) return;
    if (widget.pulse) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.4,
      height: widget.size * 2.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.pulse)
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                return Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(
                      alpha: 0.75 * (1 - _controller.value),
                    ),
                    shape: BoxShape.circle,
                  ),
                  transform: Matrix4.diagonal3Values(
                    1 + _controller.value * 1.4,
                    1 + _controller.value * 1.4,
                    1,
                  ),
                );
              },
            ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
