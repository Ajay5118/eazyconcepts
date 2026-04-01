import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/content_models.dart';

// ─── Interactive Widget Registry ─────────────────────────────────────────────
// Add new interactive widgets here. Each key maps to a builder function.
// Usage in lesson JSON: { "type": "interactive", "data": { "widgetKey": "draggable_graph", "config": {...} } }

typedef InteractiveWidgetBuilder = Widget Function(
    Map<String, dynamic> config, bool isDark);

class InteractiveRegistry {
  InteractiveRegistry._();

  static final Map<String, InteractiveWidgetBuilder> _builders = {
    'draggable_graph': (config, isDark) =>
        DraggableGraphWidget(config: config, isDark: isDark),
    'number_line': (config, isDark) =>
        NumberLineWidget(config: config, isDark: isDark),
    'pendulum': (config, isDark) =>
        PendulumSimWidget(config: config, isDark: isDark),
    'force_diagram': (config, isDark) =>
        ForceDiagramWidget(config: config, isDark: isDark),
    'function_plotter': (config, isDark) =>
        FunctionPlotterWidget(config: config, isDark: isDark),
    'drag_sort': (config, isDark) =>
        DragSortWidget(config: config, isDark: isDark),
    '3d_shape': (config, isDark) =>
        Shape3DWidget(config: config, isDark: isDark),
    'triangle_explorer': (config, isDark) =>
        TriangleExplorerWidget(config: config, isDark: isDark),
    'value_table': (config, isDark) =>
        ValueTableWidget(config: config, isDark: isDark),
    'net_folder': (config, isDark) =>
        NetFolderWidget(config: config, isDark: isDark),
    'cross_section_explorer': (config, isDark) =>
        CrossSectionExplorerWidget(config: config, isDark: isDark),
    'volume_stacker': (config, isDark) =>
        VolumeStackerWidget(config: config, isDark: isDark),
  };

  static Widget build(String key, Map<String, dynamic> config, bool isDark) {
    final builder = _builders[key];
    if (builder == null) {
      return _UnknownWidget(widgetKey: key);
    }
    return builder(config, isDark);
  }
}

// ─── Interactive Block Shell ──────────────────────────────────────────────────

class InteractiveBlock extends StatelessWidget {
  final LessonBlock block;
  final bool isDark;
  const InteractiveBlock({super.key, required this.block, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final widgetKey = block.data['widgetKey'] as String? ?? '';
    final config = Map<String, dynamic>.from(
        block.data['config'] as Map? ?? {});

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: InteractiveRegistry.build(widgetKey, config, isDark),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 1: Draggable Graph (y = mx + b)
// User drags points on a coordinate grid to explore linear functions.
// ─────────────────────────────────────────────────────────────────────────────

class DraggableGraphWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const DraggableGraphWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<DraggableGraphWidget> createState() => _DraggableGraphWidgetState();
}

class _DraggableGraphWidgetState extends State<DraggableGraphWidget> {
  // Two draggable points defining a line
  Offset _p1 = const Offset(2, 1);
  Offset _p2 = const Offset(5, 4);

  static const double _gridSize = 10; // -5 to +5 on both axes
  static const double _canvasSize = 280.0;
  static const double _cellSize = _canvasSize / _gridSize;

  Offset _toCanvas(Offset grid) => Offset(
        (grid.dx + _gridSize / 2) * _cellSize,
        (_gridSize / 2 - grid.dy) * _cellSize,
      );

  Offset _toGrid(Offset canvas) {
    final dx = (canvas.dx / _cellSize - _gridSize / 2).clamp(-4.9, 4.9);
    final dy = (_gridSize / 2 - canvas.dy / _cellSize).clamp(-4.9, 4.9);
    return Offset(dx, dy);
  }

  double get _slope =>
      (_p2.dy - _p1.dy) / (_p2.dx - _p1.dx + 0.0001);
  double get _intercept => _p1.dy - _slope * _p1.dx;

  String get _equation {
    final m = _slope;
    final b = _intercept;
    final mStr = m.toStringAsFixed(1);
    final bStr = b.abs().toStringAsFixed(1);
    final bSign = b >= 0 ? '+ $bStr' : '− $bStr';
    return 'y = ${mStr}x $bSign';
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.config['label'] as String? ?? 'Explore the line';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Interactive',
                    style: AppTextStyles.overline.copyWith(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 14),

          // Equation display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.buttonDeepVioletEnd.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              _equation,
              style: AppTextStyles.lessonEquation.copyWith(
                color: AppColors.buttonPurpleStart,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Canvas
          Center(
            child: SizedBox(
              width: _canvasSize,
              height: _canvasSize,
              child: Stack(
                children: [
                  // Grid painter
                  CustomPaint(
                    size: const Size(_canvasSize, _canvasSize),
                    painter: _GridPainter(isDark: widget.isDark),
                  ),
                  // Line painter
                  CustomPaint(
                    size: const Size(_canvasSize, _canvasSize),
                    painter: _LinePainter(
                      p1: _toCanvas(_p1),
                      p2: _toCanvas(_p2),
                    ),
                  ),
                  // Draggable point 1 (gold)
                  _DraggablePoint(
                    position: _toCanvas(_p1),
                    color: AppColors.cardGoldStart,
                    onDrag: (delta, size) {
                      setState(() {
                        final newCanvas = _toCanvas(_p1) + delta;
                        _p1 = _toGrid(newCanvas);
                      });
                    },
                  ),
                  // Draggable point 2 (purple)
                  _DraggablePoint(
                    position: _toCanvas(_p2),
                    color: AppColors.buttonPurpleStart,
                    onDrag: (delta, size) {
                      setState(() {
                        final newCanvas = _toCanvas(_p2) + delta;
                        _p2 = _toGrid(newCanvas);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Drag the points to change the line',
            style: AppTextStyles.labelSmall.copyWith(
              color: widget.isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DraggablePoint extends StatelessWidget {
  final Offset position;
  final Color color;
  final void Function(Offset delta, Size size) onDrag;
  const _DraggablePoint(
      {required this.position,
      required this.color,
      required this.onDrag});

  @override
  Widget build(BuildContext context) {
    const r = 14.0;
    return Positioned(
      left: position.dx - r,
      top: position.dy - r,
      child: GestureDetector(
        onPanUpdate: (d) => onDrag(d.delta, const Size(r * 2, r * 2)),
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final gridColor = isDark
        ? AppColors.darkBorder.withOpacity(0.6)
        : AppColors.lightBorder.withOpacity(0.8);
    final axisColor = isDark
        ? AppColors.darkTextTertiary
        : AppColors.lightTextTertiary;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;

    const cells = 10;
    final cell = size.width / cells;

    // Grid lines
    for (int i = 0; i <= cells; i++) {
      final x = i * cell;
      final y = i * cell;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Axes
    final mid = size.width / 2;
    canvas.drawLine(Offset(mid, 0), Offset(mid, size.height), axisPaint);
    canvas.drawLine(Offset(0, mid), Offset(size.width, mid), axisPaint);
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _LinePainter extends CustomPainter {
  final Offset p1;
  final Offset p2;
  _LinePainter({required this.p1, required this.p2});

  @override
  void paint(Canvas canvas, Size size) {
    // Extend line to canvas edges
    if ((p2.dx - p1.dx).abs() < 0.001) {
      // Vertical line
      canvas.drawLine(
        Offset(p1.dx, 0),
        Offset(p1.dx, size.height),
        Paint()
          ..color = AppColors.buttonPurpleStart
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    final slope = (p2.dy - p1.dy) / (p2.dx - p1.dx);
    final yAtLeft = p1.dy + slope * (0 - p1.dx);
    final yAtRight = p1.dy + slope * (size.width - p1.dx);

    canvas.drawLine(
      Offset(0, yAtLeft),
      Offset(size.width, yAtRight),
      Paint()
        ..color = AppColors.buttonPurpleStart
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.p1 != p1 || old.p2 != p2;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 2: Number Line
// User drags a point along a number line — great for fractions, inequalities
// ─────────────────────────────────────────────────────────────────────────────

class NumberLineWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const NumberLineWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<NumberLineWidget> createState() => _NumberLineWidgetState();
}

class _NumberLineWidgetState extends State<NumberLineWidget> {
  double _value = 0;

  @override
  Widget build(BuildContext context) {
    final min = (widget.config['min'] as num?)?.toDouble() ?? -5;
    final max = (widget.config['max'] as num?)?.toDouble() ?? 5;
    final label = widget.config['label'] as String? ?? 'Drag the point';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Interactive',
                    style: AppTextStyles.overline.copyWith(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                min.toInt().toString(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.buttonPurpleStart,
                    inactiveTrackColor: widget.isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    thumbColor: AppColors.cardGoldStart,
                    overlayColor:
                        AppColors.buttonPurpleStart.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: _value.clamp(min, max),
                    min: min,
                    max: max,
                    onChanged: (v) => setState(() => _value = v),
                  ),
                ),
              ),
              Text(
                max.toInt().toString(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.buttonDeepVioletEnd.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'x = ${_value.toStringAsFixed(1)}',
              style: AppTextStyles.lessonEquation.copyWith(
                  color: AppColors.buttonPurpleStart),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 3: Pendulum Simulation (Physics — Mechanics)
// ─────────────────────────────────────────────────────────────────────────────

class PendulumSimWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const PendulumSimWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<PendulumSimWidget> createState() => _PendulumSimWidgetState();
}

class _PendulumSimWidgetState extends State<PendulumSimWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _length = 150; // px
  double _gravity = 9.8;
  double _amplitude = 0.6; // radians (~34°)

  double get _period => 2 * 3.14159 * (_length / 100 / _gravity) * 15; // scaled

  double get _angle =>
      _amplitude * (1 - _controller.value * 2).abs() *
          (_controller.value < 0.5 ? 1 : -1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_period * 1000).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Simulation',
                    style: AppTextStyles.overline.copyWith(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text(
                'Pendulum motion',
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pendulum canvas
          AnimatedBuilder(
            animation: _controller,
            builder: (ctx, _) {
              return CustomPaint(
                size: const Size(double.infinity, 220),
                painter: _PendulumPainter(
                  angle: _angle,
                  length: _length,
                  isDark: widget.isDark,
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Length slider
          Row(
            children: [
              Text(
                'Length',
                style: AppTextStyles.labelSmall.copyWith(
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _length,
                  min: 60,
                  max: 200,
                  onChanged: (v) {
                    setState(() => _length = v);
                    _controller.duration =
                        Duration(milliseconds: (_period * 1000).round());
                    _controller.repeat();
                  },
                  activeColor: AppColors.buttonPurpleStart,
                  inactiveColor: widget.isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
              Text(
                '${(_length / 100).toStringAsFixed(1)}m',
                style: AppTextStyles.labelSmall.copyWith(
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          Text(
            'Period T = ${(_period).toStringAsFixed(2)}s  ·  Longer string → slower swing',
            style: AppTextStyles.labelSmall.copyWith(
              color: widget.isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PendulumPainter extends CustomPainter {
  final double angle;
  final double length;
  final bool isDark;
  _PendulumPainter(
      {required this.angle, required this.length, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final pivot = Offset(size.width / 2, 20);
    final bob = Offset(
      pivot.dx + length * (angle).clamp(-1.0, 1.0) * 0.8,
      pivot.dy + length * (1 - angle.abs() * 0.2),
    );

    // Rod
    canvas.drawLine(
      pivot,
      bob,
      Paint()
        ..color = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary
        ..strokeWidth = 2,
    );

    // Pivot
    canvas.drawCircle(
      pivot,
      5,
      Paint()
        ..color = isDark
            ? AppColors.darkTextTertiary
            : AppColors.lightTextTertiary,
    );

    // Bob
    canvas.drawCircle(
      bob,
      18,
      Paint()
        ..shader = RadialGradient(colors: [
          AppColors.cardGoldStart,
          AppColors.cardOrangeEnd,
        ]).createShader(Rect.fromCircle(center: bob, radius: 18)),
    );
  }

  @override
  bool shouldRepaint(_PendulumPainter old) => old.angle != angle;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 4: Force Diagram (Physics — Forces)
// ─────────────────────────────────────────────────────────────────────────────

class ForceDiagramWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const ForceDiagramWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<ForceDiagramWidget> createState() => _ForceDiagramWidgetState();
}

class _ForceDiagramWidgetState extends State<ForceDiagramWidget> {
  double _appliedForce = 10;
  double _friction = 4;

  double get _netForce => _appliedForce - _friction;
  double get _acceleration => _netForce / 5; // 5 kg mass

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Interactive',
                    style: AppTextStyles.overline.copyWith(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text('Newton\'s Second Law',
                  style: AppTextStyles.bodySmall.copyWith(color: subColor)),
            ],
          ),
          const SizedBox(height: 16),

          // Force diagram visual
          CustomPaint(
            size: const Size(double.infinity, 100),
            painter: _ForcePainter(
              applied: _appliedForce,
              friction: _friction,
              isDark: widget.isDark,
            ),
          ),
          const SizedBox(height: 16),

          // Net force result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _netForce > 0
                  ? AppColors.successLight
                  : AppColors.errorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'F_net = ${_netForce.toStringAsFixed(1)} N  →  a = ${_acceleration.toStringAsFixed(2)} m/s²',
              style: AppTextStyles.lessonEquation.copyWith(
                color: _netForce > 0
                    ? const Color(0xFF085041)
                    : const Color(0xFF791F1F),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 14),

          // Applied force slider
          _ForceSlider(
            label: 'Applied force',
            value: _appliedForce,
            color: AppColors.buttonPurpleStart,
            onChanged: (v) => setState(() => _appliedForce = v),
            isDark: widget.isDark,
          ),
          const SizedBox(height: 8),
          _ForceSlider(
            label: 'Friction force',
            value: _friction,
            color: AppColors.cardOrangeEnd,
            onChanged: (v) => setState(() => _friction = v),
            isDark: widget.isDark,
          ),
        ],
      ),
    );
  }
}

class _ForceSlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;
  final bool isDark;
  const _ForceSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 20,
            activeColor: color,
            inactiveColor:
                isDark ? AppColors.darkBorder : AppColors.lightBorder,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '${value.toStringAsFixed(0)} N',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ForcePainter extends CustomPainter {
  final double applied;
  final double friction;
  final bool isDark;
  _ForcePainter(
      {required this.applied,
      required this.friction,
      required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Block
    final blockRect =
        Rect.fromCenter(center: Offset(cx, cy), width: 60, height: 40);
    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect, const Radius.circular(6)),
      Paint()
        ..color = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect, const Radius.circular(6)),
      Paint()
        ..color = isDark ? AppColors.darkBorder : AppColors.lightBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final arrowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    // Applied force arrow (right)
    final apScale = (applied / 20 * 80).clamp(10.0, 80.0);
    arrowPaint.color = AppColors.buttonPurpleStart;
    canvas.drawLine(
      Offset(cx + 30, cy),
      Offset(cx + 30 + apScale, cy),
      arrowPaint,
    );
    _drawArrowhead(
        canvas, Offset(cx + 30 + apScale, cy), 0, AppColors.buttonPurpleStart);

    // Friction arrow (left)
    final frScale = (friction / 20 * 80).clamp(10.0, 80.0);
    arrowPaint.color = AppColors.cardOrangeEnd;
    canvas.drawLine(
      Offset(cx - 30, cy),
      Offset(cx - 30 - frScale, cy),
      arrowPaint,
    );
    _drawArrowhead(canvas, Offset(cx - 30 - frScale, cy), 3.14159,
        AppColors.cardOrangeEnd);

    // Labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
        text: 'F = ${applied.toStringAsFixed(0)}N',
        style: const TextStyle(
            fontSize: 10,
            color: AppColors.buttonPurpleStart,
            fontWeight: FontWeight.w600));
    tp.layout();
    tp.paint(canvas, Offset(cx + 30 + apScale / 2 - tp.width / 2, cy - 18));

    tp.text = TextSpan(
        text: 'f = ${friction.toStringAsFixed(0)}N',
        style: const TextStyle(
            fontSize: 10,
            color: AppColors.cardOrangeEnd,
            fontWeight: FontWeight.w600));
    tp.layout();
    tp.paint(
        canvas, Offset(cx - 30 - frScale / 2 - tp.width / 2, cy - 18));
  }

  void _drawArrowhead(Canvas c, Offset tip, double angle, Color color) {
    final path = Path();
    const size = 8.0;
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
        tip.dx - size * (angle == 0 ? 1 : -1),
        tip.dy - size / 2);
    path.lineTo(
        tip.dx - size * (angle == 0 ? 1 : -1),
        tip.dy + size / 2);
    path.close();
    c.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ForcePainter old) =>
      old.applied != applied || old.friction != friction;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 5: Function Plotter
// Sliders control parameters; graph updates in real time.
// JSON config: { "label": "...", "function_type": "sinusoidal|cosine|quadratic|cubic|linear|exponential|absolute",
//   "params": [{"key":"a","label":"Amplitude","min":-3,"max":3,"default":1},...],
//   "x_min": -6.3, "x_max": 6.3 }
// ─────────────────────────────────────────────────────────────────────────────

class FunctionPlotterWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const FunctionPlotterWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<FunctionPlotterWidget> createState() => _FunctionPlotterState();
}

class _FunctionPlotterState extends State<FunctionPlotterWidget> {
  final Map<String, double> _params = {};

  @override
  void initState() {
    super.initState();
    for (final p in _paramDefs) {
      _params[p['key'] as String] =
          (p['default'] as num?)?.toDouble() ?? 1.0;
    }
  }

  List<Map<String, dynamic>> get _paramDefs =>
      (widget.config['params'] as List? ?? [])
          .cast<Map<String, dynamic>>();

  String get _fnType =>
      widget.config['function_type'] as String? ?? 'sinusoidal';

  double _evaluate(double x) {
    final a = _params['a'] ?? 1.0;
    final b = _params['b'] ?? 1.0;
    final c = _params['c'] ?? 0.0;
    final d = _params['d'] ?? 0.0;
    switch (_fnType) {
      case 'sinusoidal':  return a * sin(b * x + c) + d;
      case 'cosine':      return a * cos(b * x + c) + d;
      case 'quadratic':   return a * x * x + b * x + c;
      case 'cubic':       return a * x * x * x + b * x * x + c * x + d;
      case 'exponential': return a * exp(b * x);
      case 'linear':      return a * x + b;
      case 'absolute':    return a * (x - b).abs() + c;
      default:            return sin(x);
    }
  }

  String get _equation {
    final a = (_params['a'] ?? 1.0).toStringAsFixed(1);
    final b = (_params['b'] ?? 1.0).toStringAsFixed(1);
    final c = (_params['c'] ?? 0.0).toStringAsFixed(1);
    final d = (_params['d'] ?? 0.0).toStringAsFixed(1);
    switch (_fnType) {
      case 'sinusoidal':  return 'y = ${a}·sin(${b}x + $c) + $d';
      case 'cosine':      return 'y = ${a}·cos(${b}x + $c) + $d';
      case 'quadratic':   return 'y = ${a}x² + ${b}x + $c';
      case 'cubic':       return 'y = ${a}x³ + ${b}x² + ${c}x + $d';
      case 'exponential': return 'y = ${a}·eˣ (scale $b)';
      case 'linear':      return 'y = ${a}x + $b';
      case 'absolute':    return 'y = ${a}|x − $b| + $c';
      default:            return 'y = sin(x)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.config['label'] as String? ?? 'Function Explorer';
    final xMin = (widget.config['x_min'] as num?)?.toDouble() ?? -6.3;
    final xMax = (widget.config['x_max'] as num?)?.toDouble() ?? 6.3;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InteractiveHeader(badge: 'Graph', label: label, isDark: widget.isDark),
          const SizedBox(height: 12),
          // Equation display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.buttonDeepVioletEnd.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(_equation,
                style: AppTextStyles.lessonEquation.copyWith(
                  color: AppColors.buttonPurpleStart,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(height: 12),
          // Graph canvas
          SizedBox(
            width: double.infinity,
            height: 180,
            child: CustomPaint(
              painter: _FunctionGraphPainter(
                evaluate: _evaluate,
                xMin: xMin,
                xMax: xMax,
                isDark: widget.isDark,
                repaintKey: _params.values.fold(0.0, (s, v) => s + v),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Parameter sliders
          for (final p in _paramDefs)
            _ParamSlider(
              label: p['label'] as String? ?? p['key'] as String,
              value: _params[p['key']] ?? 1.0,
              min: (p['min'] as num?)?.toDouble() ?? -3.0,
              max: (p['max'] as num?)?.toDouble() ?? 3.0,
              isDark: widget.isDark,
              onChanged: (v) =>
                  setState(() => _params[p['key'] as String] = v),
            ),
        ],
      ),
    );
  }
}

class _ParamSlider extends StatelessWidget {
  final String label;
  final double value, min, max;
  final bool isDark;
  final ValueChanged<double> onChanged;
  const _ParamSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label: ${value.toStringAsFixed(1)}',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppColors.buttonPurpleStart,
            inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _FunctionGraphPainter extends CustomPainter {
  final double Function(double) evaluate;
  final double xMin, xMax, repaintKey;
  final bool isDark;

  _FunctionGraphPainter({
    required this.evaluate,
    required this.xMin,
    required this.xMax,
    required this.isDark,
    required this.repaintKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const steps = 400;
    final dx = (xMax - xMin) / steps;

    // Compute y range from samples
    double yMin = double.infinity, yMax = double.negativeInfinity;
    for (int i = 0; i <= steps; i++) {
      final y = evaluate(xMin + i * dx);
      if (y.isFinite) {
        if (y < yMin) yMin = y;
        if (y > yMax) yMax = y;
      }
    }
    if (yMin.isInfinite) yMin = -3;
    if (yMax.isInfinite) yMax = 3;
    if ((yMax - yMin) < 0.5) { yMin -= 1; yMax += 1; }
    final yPad = (yMax - yMin) * 0.15;
    yMin -= yPad; yMax += yPad;

    Offset toCanvas(double x, double y) => Offset(
          (x - xMin) / (xMax - xMin) * size.width,
          (1 - (y - yMin) / (yMax - yMin)) * size.height,
        );

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      Paint()
        ..color = isDark ? AppColors.darkSurface2 : const Color(0xFFF7F6FE),
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = (isDark ? AppColors.darkBorder : AppColors.lightBorder)
          .withOpacity(0.6)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = yMin + i * (yMax - yMin) / 4;
      final p = toCanvas(xMin, y);
      canvas.drawLine(Offset(0, p.dy), Offset(size.width, p.dy), gridPaint);
    }
    for (int i = 0; i <= 6; i++) {
      final x = xMin + i * (xMax - xMin) / 6;
      final p = toCanvas(x, 0);
      canvas.drawLine(Offset(p.dx, 0), Offset(p.dx, size.height), gridPaint);
    }

    // Axes
    final axisPaint = Paint()
      ..color = (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)
      ..strokeWidth = 1.0;
    if (yMin < 0 && yMax > 0) {
      final y0 = toCanvas(0, 0);
      canvas.drawLine(Offset(0, y0.dy), Offset(size.width, y0.dy), axisPaint);
    }
    if (xMin < 0 && xMax > 0) {
      final x0 = toCanvas(0, 0);
      canvas.drawLine(Offset(x0.dx, 0), Offset(x0.dx, size.height), axisPaint);
    }

    // Function curve
    final curvePaint = Paint()
      ..color = AppColors.buttonPurpleStart
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool started = false;
    for (int i = 0; i <= steps; i++) {
      final x = xMin + i * dx;
      final y = evaluate(x);
      if (!y.isFinite || y < yMin - 2 || y > yMax + 2) {
        started = false;
        continue;
      }
      final p = toCanvas(x, y);
      if (!started) {
        path.moveTo(p.dx, p.dy);
        started = true;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(_FunctionGraphPainter old) =>
      old.repaintKey != repaintKey || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 6: Drag & Drop Sort
// Drag tiles into the correct order, then check.
// JSON config: { "label": "...", "items": ["Step 1", "Step 2", ...] }
// ─────────────────────────────────────────────────────────────────────────────

class DragSortWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const DragSortWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<DragSortWidget> createState() => _DragSortState();
}

class _DragSortState extends State<DragSortWidget> {
  late List<String> _order;
  bool _checked = false;
  bool _correct = false;

  List<String> get _correctOrder =>
      (widget.config['items'] as List? ?? []).cast<String>();

  @override
  void initState() {
    super.initState();
    _order = List.from(_correctOrder)
      ..shuffle(Random(42));
  }

  void _check() => setState(() {
        _checked = true;
        _correct = _order.join('||') == _correctOrder.join('||');
      });

  void _reset() => setState(() {
        _checked = false;
        _order = List.from(_correctOrder)
          ..shuffle(Random(DateTime.now().millisecondsSinceEpoch));
      });

  @override
  Widget build(BuildContext context) {
    final label =
        widget.config['label'] as String? ?? 'Sort into the correct order';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InteractiveHeader(
              badge: 'Drag & Drop', label: label, isDark: widget.isDark),
          const SizedBox(height: 12),
          if (_checked)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _correct
                    ? AppColors.successLight
                    : AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _correct
                    ? '✓  Correct order — well done!'
                    : '✗  Not quite — drag to reorder and try again.',
                style: AppTextStyles.labelMedium.copyWith(
                  color: _correct
                      ? const Color(0xFF085041)
                      : const Color(0xFF791F1F),
                ),
              ),
            ),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _checked
                ? (_, __) {}
                : (oldIdx, newIdx) {
                    setState(() {
                      if (newIdx > oldIdx) newIdx--;
                      final item = _order.removeAt(oldIdx);
                      _order.insert(newIdx, item);
                      _checked = false;
                    });
                  },
            children: [
              for (int i = 0; i < _order.length; i++)
                _SortTile(
                  key: ValueKey('${_order[i]}_$i'),
                  index: i,
                  text: _order[i],
                  isDark: widget.isDark,
                  checked: _checked,
                  isCorrect: _checked && _order[i] == _correctOrder[i],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!_checked)
                Expanded(
                  child: _ActionButton(
                    label: 'Check Order',
                    onTap: _check,
                    primary: true,
                  ),
                ),
              if (_checked) ...[
                Expanded(
                  child: _ActionButton(
                    label: 'Try Again',
                    onTap: _reset,
                    primary: false,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final int index;
  final String text;
  final bool isDark, checked, isCorrect;
  const _SortTile({
    super.key,
    required this.index,
    required this.text,
    required this.isDark,
    required this.checked,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = checked
        ? (isCorrect ? AppColors.successLight : AppColors.errorLight)
        : (isDark ? AppColors.darkSurface2 : AppColors.lightSurface2);
    final borderColor = checked
        ? (isCorrect
            ? const Color(0xFF085041).withOpacity(0.3)
            : const Color(0xFF791F1F).withOpacity(0.3))
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.buttonPurpleStart.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.buttonPurpleStart,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                )),
          ),
          if (!checked)
            Icon(Icons.drag_handle,
                size: 18,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary),
          if (checked)
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: isCorrect
                  ? const Color(0xFF085041)
                  : const Color(0xFF791F1F),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 7: 3D Shape Rotation
// Drag to rotate a wireframe 3D shape; shows Euler's formula.
// JSON config: { "shape": "cube|pyramid|tetrahedron|prism", "label": "..." }
// ─────────────────────────────────────────────────────────────────────────────

class Shape3DWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const Shape3DWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<Shape3DWidget> createState() => _Shape3DState();
}

class _Shape3DState extends State<Shape3DWidget> {
  double _rotX = 0.4;
  double _rotY = 0.6;

  static const _shapeData = <String, Map<String, Object>>{
    'cube': {
      'vertices': [
        [-1.0, -1.0, -1.0], [1.0, -1.0, -1.0],
        [1.0,  1.0, -1.0], [-1.0,  1.0, -1.0],
        [-1.0, -1.0,  1.0], [1.0, -1.0,  1.0],
        [1.0,  1.0,  1.0], [-1.0,  1.0,  1.0],
      ],
      'edges': [
        [0,1],[1,2],[2,3],[3,0],
        [4,5],[5,6],[6,7],[7,4],
        [0,4],[1,5],[2,6],[3,7],
      ],
      'faces': [
        [0,1,2,3],[4,5,6,7],
        [0,1,5,4],[2,3,7,6],
        [1,2,6,5],[0,3,7,4],
      ],
      'info': 'Cube  ·  V=8  E=12  F=6  →  V−E+F = 2',
    },
    'pyramid': {
      'vertices': [
        [-1.0,-1.0,-1.0],[1.0,-1.0,-1.0],
        [1.0,-1.0, 1.0],[-1.0,-1.0, 1.0],
        [0.0, 1.3, 0.0],
      ],
      'edges': [
        [0,1],[1,2],[2,3],[3,0],
        [0,4],[1,4],[2,4],[3,4],
      ],
      'faces': [
        [0,1,2,3],[0,1,4],[1,2,4],[2,3,4],[3,0,4],
      ],
      'info': 'Square Pyramid  ·  V=5  E=8  F=5  →  V−E+F = 2',
    },
    'tetrahedron': {
      'vertices': [
        [ 0.0, 1.2,  0.0],
        [-1.0,-0.6,  0.8],
        [ 1.0,-0.6,  0.8],
        [ 0.0,-0.6, -1.1],
      ],
      'edges': [
        [0,1],[0,2],[0,3],[1,2],[2,3],[3,1],
      ],
      'faces': [
        [0,1,2],[0,2,3],[0,3,1],[1,2,3],
      ],
      'info': 'Tetrahedron  ·  V=4  E=6  F=4  →  V−E+F = 2',
    },
    'prism': {
      'vertices': [
        [-1.0,-1.0,-1.0],[1.0,-1.0,-1.0],[0.0, 1.0,-1.0],
        [-1.0,-1.0, 1.0],[1.0,-1.0, 1.0],[0.0, 1.0, 1.0],
      ],
      'edges': [
        [0,1],[1,2],[2,0],
        [3,4],[4,5],[5,3],
        [0,3],[1,4],[2,5],
      ],
      'faces': [
        [0,1,2],[3,4,5],
        [0,1,4,3],[1,2,5,4],[2,0,3,5],
      ],
      'info': 'Triangular Prism  ·  V=6  E=9  F=5  →  V−E+F = 2',
    },
  };

  Map<String, Object> get _shape {
    final key = widget.config['shape'] as String? ?? 'cube';
    return _shapeData[key] ?? _shapeData['cube']!;
  }

  List<double> _rotate(List<dynamic> v) {
    final vx = (v[0] as num).toDouble();
    final vy = (v[1] as num).toDouble();
    final vz = (v[2] as num).toDouble();
    // Y-axis rotation
    final x1 = vx * cos(_rotY) + vz * sin(_rotY);
    final z1 = -vx * sin(_rotY) + vz * cos(_rotY);
    // X-axis rotation
    final y2 = vy * cos(_rotX) - z1 * sin(_rotX);
    final z2 = vy * sin(_rotX) + z1 * cos(_rotX);
    return [x1, y2, z2];
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.config['label'] as String? ??
        (_shape['info'] as String? ?? '3D Shape');
    final rotatedVerts = (_shape['vertices'] as List)
        .map((v) => _rotate(v as List))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InteractiveHeader(
              badge: '3D Explorer', label: label, isDark: widget.isDark),
          const SizedBox(height: 4),
          Text('Drag to rotate',
              style: AppTextStyles.labelSmall.copyWith(
                color: widget.isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              )),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onPanUpdate: (d) => setState(() {
                _rotY += d.delta.dx * 0.013;
                _rotX -= d.delta.dy * 0.013;
              }),
              child: SizedBox(
                width: 260,
                height: 220,
                child: CustomPaint(
                  painter: _Shape3DPainter(
                    vertices: rotatedVerts,
                    edges: (_shape['edges'] as List).cast<List>(),
                    faces: (_shape['faces'] as List).cast<List>(),
                    isDark: widget.isDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _shape['info'] as String? ?? '',
              style: AppTextStyles.labelSmall.copyWith(
                color: widget.isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Shape3DPainter extends CustomPainter {
  final List<List<double>> vertices;
  final List<List<dynamic>> edges;
  final List<List<dynamic>> faces;
  final bool isDark;

  _Shape3DPainter({
    required this.vertices,
    required this.edges,
    required this.faces,
    required this.isDark,
  });

  Offset _project(List<double> v, Size size) {
    const camDist = 5.0;
    final scale = size.width * 0.27;
    final z = v[2] + camDist;
    final f = camDist / (z < 0.1 ? 0.1 : z);
    return Offset(
      size.width / 2 + v[0] * f * scale,
      size.height / 2 - v[1] * f * scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final proj = vertices.map((v) => _project(v, size)).toList();

    // Sort faces back-to-front by avg z
    final sortedFaces = List<List<dynamic>>.from(faces)
      ..sort((a, b) {
        final za = a.fold<double>(
                0.0, (s, i) => s + vertices[i as int][2]) /
            a.length;
        final zb = b.fold<double>(
                0.0, (s, i) => s + vertices[i as int][2]) /
            b.length;
        return za.compareTo(zb);
      });

    // Draw faces
    for (final face in sortedFaces) {
      final avgZ = face.fold<double>(
              0.0, (s, i) => s + vertices[i as int][2]) /
          face.length;
      final t = ((avgZ + 2) / 4).clamp(0.0, 1.0);
      final faceColor = isDark
          ? Color.lerp(AppColors.darkSurface,
              AppColors.buttonDeepVioletEnd.withOpacity(0.5), t)!
          : Color.lerp(const Color(0xFFF0EEFF),
              AppColors.buttonPurpleStart.withOpacity(0.25), t)!;
      final path = Path()
        ..moveTo(proj[face[0] as int].dx, proj[face[0] as int].dy);
      for (int i = 1; i < face.length; i++) {
        path.lineTo(proj[face[i] as int].dx, proj[face[i] as int].dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = faceColor);
    }

    // Draw edges
    for (final edge in edges) {
      final avgZ =
          (vertices[edge[0] as int][2] + vertices[edge[1] as int][2]) / 2;
      final opacity = ((avgZ + 2) / 4).clamp(0.35, 1.0);
      canvas.drawLine(
        proj[edge[0] as int],
        proj[edge[1] as int],
        Paint()
          ..color = AppColors.buttonPurpleStart.withOpacity(opacity)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // Draw vertices
    for (int i = 0; i < proj.length; i++) {
      final opacity = ((vertices[i][2] + 2) / 4).clamp(0.3, 1.0);
      canvas.drawCircle(proj[i], 3.5,
          Paint()..color = AppColors.cardGoldStart.withOpacity(opacity));
    }
  }

  @override
  bool shouldRepaint(_Shape3DPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 8: Triangle Explorer
// Drag the three vertices; angles and area update live.
// JSON config: { "label": "..." }
// ─────────────────────────────────────────────────────────────────────────────

class TriangleExplorerWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const TriangleExplorerWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<TriangleExplorerWidget> createState() => _TriangleExplorerState();
}

class _TriangleExplorerState extends State<TriangleExplorerWidget> {
  static const double _cw = 280, _ch = 210, _pad = 24;

  Offset _a = const Offset(140, 28);
  Offset _b = const Offset(38, 182);
  Offset _c = const Offset(242, 182);

  Offset _clamp(Offset o) => Offset(
        o.dx.clamp(_pad, _cw - _pad),
        o.dy.clamp(_pad, _ch - _pad),
      );

  double _angleDeg(Offset p, Offset vertex, Offset q) {
    final v1 = p - vertex, v2 = q - vertex;
    final d = v1.distance * v2.distance;
    if (d < 0.01) return 0;
    final cosA = (v1.dx * v2.dx + v1.dy * v2.dy) / d;
    return acos(cosA.clamp(-1.0, 1.0)) * 180 / pi;
  }

  double get _angA => _angleDeg(_b, _a, _c);
  double get _angB => _angleDeg(_a, _b, _c);
  double get _angC => _angleDeg(_a, _c, _b);
  double get _area =>
      ((_a.dx * (_b.dy - _c.dy) + _b.dx * (_c.dy - _a.dy) + _c.dx * (_a.dy - _b.dy))
              .abs() /
          2);

  Widget _handle(Offset pos, String label, Color color, void Function(Offset) move) {
    const r = 14.0;
    return Positioned(
      left: pos.dx - r,
      top: pos.dy - r,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => move(_clamp(pos + d.delta))),
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label =
        widget.config['label'] as String? ?? 'Drag vertices to explore';
    final sum = _angA + _angB + _angC;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InteractiveHeader(
              badge: 'Geometry', label: label, isDark: widget.isDark),
          const SizedBox(height: 12),
          // Angle summary bar
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.buttonDeepVioletEnd.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AngleBadge('A', _angA, AppColors.buttonPurpleStart),
                _AngleBadge('B', _angB, AppColors.cardGoldStart),
                _AngleBadge('C', _angC, AppColors.cardOrangeEnd),
                Column(
                  children: [
                    Text('A+B+C',
                        style: AppTextStyles.overline.copyWith(
                            color: widget.isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary)),
                    Text('${sum.toStringAsFixed(0)}°',
                        style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.buttonPurpleStart,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Canvas
          Center(
            child: SizedBox(
              width: _cw,
              height: _ch,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(_cw, _ch),
                    painter: _TrianglePainter(
                        a: _a, b: _b, c: _c, isDark: widget.isDark),
                  ),
                  _handle(_a, 'A', AppColors.buttonPurpleStart, (p) => _a = p),
                  _handle(_b, 'B', AppColors.cardGoldStart, (p) => _b = p),
                  _handle(_c, 'C', AppColors.cardOrangeEnd, (p) => _c = p),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Area ≈ ${_area.toStringAsFixed(0)} px²  ·  angles always sum to 180°',
              style: AppTextStyles.labelSmall.copyWith(
                color: widget.isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AngleBadge extends StatelessWidget {
  final String name;
  final double angle;
  final Color color;
  const _AngleBadge(this.name, this.angle, this.color);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(name,
              style:
                  AppTextStyles.overline.copyWith(color: color)),
          Text('${angle.toStringAsFixed(0)}°',
              style: AppTextStyles.labelMedium.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
        ],
      );
}

class _TrianglePainter extends CustomPainter {
  final Offset a, b, c;
  final bool isDark;
  _TrianglePainter(
      {required this.a, required this.b, required this.c, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();

    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.buttonPurpleStart
              .withOpacity(isDark ? 0.13 : 0.08));
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.buttonPurpleStart.withOpacity(0.55)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Small arc at each vertex to hint at the angle
    for (final entry in [
      (a, b, c, AppColors.buttonPurpleStart),
      (b, a, c, AppColors.cardGoldStart),
      (c, a, b, AppColors.cardOrangeEnd),
    ]) {
      final vertex = entry.$1;
      final p = entry.$2, q = entry.$3;
      final color = entry.$4 as Color;
      final d1 = (p - vertex).direction;
      final d2 = (q - vertex).direction;
      double sweep = d2 - d1;
      while (sweep > pi) sweep -= 2 * pi;
      while (sweep < -pi) sweep += 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: vertex, radius: 16),
        d1, sweep, false,
        Paint()
          ..color = color.withOpacity(0.65)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_TrianglePainter old) =>
      old.a != a || old.b != b || old.c != c || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 9: Value Table Explorer
// A slider controls a parameter; a live table shows computed x → f(x) values.
// JSON config: { "label":"...", "function_type":"linear|quadratic|power",
//   "param_label":"Factor", "param_min":0.5, "param_max":5.0, "rows":6 }
// ─────────────────────────────────────────────────────────────────────────────

class ValueTableWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const ValueTableWidget(
      {super.key, required this.config, required this.isDark});

  @override
  State<ValueTableWidget> createState() => _ValueTableState();
}

class _ValueTableState extends State<ValueTableWidget> {
  double _param = 1.0;

  String get _fnType =>
      widget.config['function_type'] as String? ?? 'linear';

  double _eval(double x) {
    switch (_fnType) {
      case 'linear':    return _param * x;
      case 'quadratic': return _param * x * x;
      case 'power':     return pow(x, _param).toDouble();
      default:          return _param * x;
    }
  }

  String _expr(double x) {
    final p = _param.toStringAsFixed(1);
    final xi = x.toInt();
    switch (_fnType) {
      case 'linear':    return '$p × $xi';
      case 'quadratic': return '$p × $xi²';
      case 'power':     return '$xi ^ $p';
      default:          return '$p × $xi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.config['label'] as String? ?? 'Value Table';
    final paramLabel =
        widget.config['param_label'] as String? ?? 'Parameter';
    final pMin = (widget.config['param_min'] as num?)?.toDouble() ?? 0.5;
    final pMax = (widget.config['param_max'] as num?)?.toDouble() ?? 5.0;
    final rows = (widget.config['rows'] as int?) ?? 6;
    final xs = List.generate(rows, (i) => (i + 1).toDouble());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InteractiveHeader(
              badge: 'Table', label: label, isDark: widget.isDark),
          const SizedBox(height: 12),
          // Slider
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  '$paramLabel: ${_param.toStringAsFixed(1)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _param,
                  min: pMin,
                  max: pMax,
                  activeColor: AppColors.buttonPurpleStart,
                  inactiveColor: widget.isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  onChanged: (v) => setState(() => _param = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Table
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Table(
              border: TableBorder.all(
                color: widget.isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 0.5,
              ),
              columnWidths: const {
                0: FixedColumnWidth(36),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.2),
              },
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.buttonPurpleStart.withOpacity(0.1),
                  ),
                  children: [
                    _TCell('x', header: true, isDark: widget.isDark),
                    _TCell('Expression', header: true, isDark: widget.isDark),
                    _TCell('f(x)', header: true, highlight: true, isDark: widget.isDark),
                  ],
                ),
                // Data rows
                for (final x in xs)
                  TableRow(
                    children: [
                      _TCell(x.toInt().toString(), isDark: widget.isDark),
                      _TCell(_expr(x), isDark: widget.isDark),
                      _TCell(_eval(x).toStringAsFixed(1),
                          highlight: true, isDark: widget.isDark),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TCell extends StatelessWidget {
  final String text;
  final bool header, highlight, isDark;
  const _TCell(this.text,
      {this.header = false, this.highlight = false, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Text(
          text,
          style: AppTextStyles.labelSmall.copyWith(
            color: highlight
                ? AppColors.buttonPurpleStart
                : header
                    ? (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
            fontWeight:
                (header || highlight) ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InteractiveHeader extends StatelessWidget {
  final String badge, label;
  final bool isDark;
  const _InteractiveHeader(
      {required this.badge, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badge,
                style:
                    AppTextStyles.overline.copyWith(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                )),
          ),
        ],
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _ActionButton(
      {required this.label, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: primary
              ? AppColors.buttonPurpleStart
              : AppColors.darkSurface2,
          foregroundColor:
              primary ? Colors.white : AppColors.buttonPurpleStart,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 11),
        ),
        child: Text(label),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 10: Net Folder
// Shows a 2-D net that animates into a 3-D solid.
// JSON config: { "shape": "cube|cuboid|pyramid|prism", "label": "..." }
// ─────────────────────────────────────────────────────────────────────────────

class NetFolderWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const NetFolderWidget({super.key, required this.config, required this.isDark});
  @override
  State<NetFolderWidget> createState() => _NetFolderState();
}

class _NetFolderState extends State<NetFolderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _folded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _folded = !_folded);
    _folded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final shape = widget.config['shape'] as String? ?? 'cube';
    final label = widget.config['label'] as String? ?? 'Fold the net';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InteractiveHeader(badge: 'Net Explorer', label: label, isDark: widget.isDark),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => CustomPaint(
              size: const Size(double.infinity, 240),
              painter: _NetPainter(
                  shape: shape, fold: _anim.value, isDark: widget.isDark),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                label: _folded ? 'Unfold' : 'Fold into 3D',
                onTap: _toggle,
                primary: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _folded
                ? 'All faces come together to form the solid'
                : 'Each coloured patch is one face of the shape',
            style: AppTextStyles.labelSmall.copyWith(
              color: widget.isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NetPainter extends CustomPainter {
  final String shape;
  final double fold; // 0 = flat net, 1 = 3-D solid
  final bool isDark;
  _NetPainter({required this.shape, required this.fold, required this.isDark});

  static const _faceColors = [
    Color(0xFF8C48CD), Color(0xFFA366D4), Color(0xFFBA84DC),
    Color(0xFFCEA8E5), Color(0xFFE2CBF2), Color(0xFFF0E3F8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final u = size.width * 0.11; // unit tile size

    // Lerp between flat-net positions and folded positions
    // We show a cube cross-net for all shapes for simplicity
    // Layout (flat):
    //       [top]
    // [left][front][right][back]
    //       [bottom]
    final flat = [
      Offset(cx, cy - 2 * u),           // top
      Offset(cx - u, cy),               // left
      Offset(cx, cy),                   // front (centre)
      Offset(cx + u, cy),               // right
      Offset(cx + 2 * u, cy),           // back
      Offset(cx, cy + u),               // bottom
    ];
    // Folded: all tiles converge toward the centre (3-D illusion)
    final folded = [
      Offset(cx - u * 0.3, cy - u * 0.3),
      Offset(cx - u * 0.5, cy - u * 0.1),
      Offset(cx, cy),
      Offset(cx + u * 0.5, cy - u * 0.1),
      Offset(cx + u * 0.8, cy - u * 0.4),
      Offset(cx - u * 0.2, cy + u * 0.5),
    ];

    for (int i = 0; i < 6; i++) {
      final pos = Offset.lerp(flat[i], folded[i], fold)!;
      final alpha = fold < 0.5
          ? 1.0
          : (1.0 - (fold - 0.5) * 0.6).clamp(0.4, 1.0);
      final rect = Rect.fromCenter(
          center: pos, width: u * 0.92, height: u * 0.92);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = _faceColors[i % _faceColors.length].withOpacity(alpha),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()
          ..color = Colors.white.withOpacity(0.35 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      // Face label
      final tp = TextPainter(
        text: TextSpan(
          text: ['Top', 'Left', 'Front', 'Right', 'Back', 'Bottom'][i],
          style: TextStyle(
              fontSize: u * 0.28,
              color: Colors.white.withOpacity(alpha),
              fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          pos - Offset(tp.width / 2, tp.height / 2));
    }

    // Draw the 3-D outline when mostly folded
    if (fold > 0.7) {
      final opacity = ((fold - 0.7) / 0.3).clamp(0.0, 1.0);
      final edgePaint = Paint()
        ..color = AppColors.buttonPurpleStart.withOpacity(opacity)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      // Simple isometric cube outline
      final o = Offset(cx, cy);
      const s = 28.0;
      canvas.drawLine(o + const Offset(-s, 0), o + const Offset(0, -s * 0.6), edgePaint);
      canvas.drawLine(o + const Offset(0, -s * 0.6), o + const Offset(s, 0), edgePaint);
      canvas.drawLine(o + const Offset(s, 0), o + const Offset(0, s * 0.6), edgePaint);
      canvas.drawLine(o + const Offset(0, s * 0.6), o + const Offset(-s, 0), edgePaint);
    }
  }

  @override
  bool shouldRepaint(_NetPainter old) =>
      old.fold != fold || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 11: Cross-Section Explorer
// A slider moves a cutting plane through a 3-D shape; shows the resulting face.
// JSON config: { "shape": "cube|cylinder|cone|sphere|pyramid", "label":"..." }
// ─────────────────────────────────────────────────────────────────────────────

class CrossSectionExplorerWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const CrossSectionExplorerWidget(
      {super.key, required this.config, required this.isDark});
  @override
  State<CrossSectionExplorerWidget> createState() =>
      _CrossSectionExplorerState();
}

class _CrossSectionExplorerState extends State<CrossSectionExplorerWidget> {
  double _height = 0.5; // 0 = bottom, 1 = top

  String get _shape => widget.config['shape'] as String? ?? 'cone';

  String _sectionName(double h) {
    switch (_shape) {
      case 'cone':
        if (h < 0.05) return 'Circle (base)';
        if (h > 0.95) return 'Point (apex)';
        return 'Circle (r = ${(1 - h).toStringAsFixed(1)}R)';
      case 'cylinder':
        return 'Circle (same radius)';
      case 'sphere':
        if (h < 0.05 || h > 0.95) return 'Point (pole)';
        if ((h - 0.5).abs() < 0.05) return 'Great Circle (maximum)';
        return 'Circle (r < R)';
      case 'pyramid':
        if (h < 0.05) return 'Square (base)';
        if (h > 0.95) return 'Point (apex)';
        return 'Square (smaller)';
      case 'cube':
        return 'Rectangle / Square';
      default:
        return 'Cross-section';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label =
        widget.config['label'] as String? ?? 'Explore cross-sections';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InteractiveHeader(
              badge: 'Cross-Section', label: label, isDark: widget.isDark),
          const SizedBox(height: 12),
          // Main canvas
          SizedBox(
            width: double.infinity,
            height: 220,
            child: CustomPaint(
              painter: _CrossSectionPainter(
                  shape: _shape, height: _height, isDark: widget.isDark),
            ),
          ),
          const SizedBox(height: 8),
          // Result label
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.buttonPurpleStart.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Section at ${(_height * 100).toStringAsFixed(0)}% height: ${_sectionName(_height)}',
              style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.buttonPurpleStart,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          // Slider
          Row(
            children: [
              Text('Base',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: widget.isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary)),
              Expanded(
                child: Slider(
                  value: _height,
                  min: 0.0,
                  max: 1.0,
                  activeColor: AppColors.buttonPurpleStart,
                  inactiveColor: widget.isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  onChanged: (v) => setState(() => _height = v),
                ),
              ),
              Text('Top',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: widget.isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CrossSectionPainter extends CustomPainter {
  final String shape;
  final double height;
  final bool isDark;
  _CrossSectionPainter(
      {required this.shape, required this.height, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final solidPaint = Paint()
      ..color = (isDark ? AppColors.darkSurface2 : const Color(0xFFEEEBFC));
    final edgePaint = Paint()
      ..color = AppColors.buttonPurpleStart.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final slicePaint = Paint()
      ..color = AppColors.cardGoldStart.withOpacity(0.85);
    final sliceEdge = Paint()
      ..color = AppColors.cardGoldStart
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw the 3D shape outline (isometric)
    switch (shape) {
      case 'cone':
        _drawConeOutline(canvas, cx, cy, size, solidPaint, edgePaint);
        _drawConeSlice(canvas, cx, cy, size, slicePaint, sliceEdge);
        break;
      case 'cylinder':
        _drawCylinderOutline(canvas, cx, cy, size, solidPaint, edgePaint);
        _drawCylinderSlice(canvas, cx, cy, size, slicePaint, sliceEdge);
        break;
      case 'sphere':
        _drawSphereOutline(canvas, cx, cy, size, solidPaint, edgePaint);
        _drawSphereSlice(canvas, cx, cy, size, slicePaint, sliceEdge);
        break;
      case 'pyramid':
        _drawPyramidOutline(canvas, cx, cy, size, solidPaint, edgePaint);
        _drawPyramidSlice(canvas, cx, cy, size, slicePaint, sliceEdge);
        break;
      default: // cube
        _drawCubeOutline(canvas, cx, cy, size, solidPaint, edgePaint);
        _drawCubeSlice(canvas, cx, cy, size, slicePaint, sliceEdge);
    }
  }

  void _drawConeOutline(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const h = 90.0, r = 55.0;
    final top = Offset(cx, cy - h * 0.6);
    final bl = Offset(cx - r, cy + h * 0.4);
    final br = Offset(cx + r, cy + h * 0.4);
    final path = Path()..moveTo(top.dx, top.dy)..lineTo(bl.dx, bl.dy)
      ..lineTo(br.dx, br.dy)..close();
    c.drawPath(path, fill);
    c.drawPath(path, edge);
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.4),
        width: r * 2, height: r * 0.4), fill);
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.4),
        width: r * 2, height: r * 0.4), edge);
  }

  void _drawConeSlice(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const h = 90.0, r = 55.0;
    final y = cy + h * 0.4 - h * height;
    final sliceR = r * (1 - height);
    if (sliceR < 1) return;
    c.drawOval(Rect.fromCenter(center: Offset(cx, y),
        width: sliceR * 2, height: sliceR * 0.4), fill);
    c.drawOval(Rect.fromCenter(center: Offset(cx, y),
        width: sliceR * 2, height: sliceR * 0.4), edge);
    // dashed line indicators
    final dashed = Paint()
      ..color = AppColors.cardGoldStart.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    c.drawLine(Offset(cx - sliceR, y), Offset(cx - r + (r - sliceR), cy + h * 0.4), dashed);
    c.drawLine(Offset(cx + sliceR, y), Offset(cx + r - (r - sliceR), cy + h * 0.4), dashed);
  }

  void _drawCylinderOutline(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const h = 80.0, r = 50.0;
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: h);
    c.drawRect(rect, fill);
    c.drawRect(rect, edge);
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy - h / 2),
        width: r * 2, height: r * 0.4), fill);
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy - h / 2),
        width: r * 2, height: r * 0.4), edge);
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + h / 2),
        width: r * 2, height: r * 0.4), fill);
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy + h / 2),
        width: r * 2, height: r * 0.4), edge);
  }

  void _drawCylinderSlice(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const h = 80.0, r = 50.0;
    final y = cy + h / 2 - h * height;
    c.drawOval(Rect.fromCenter(center: Offset(cx, y),
        width: r * 2, height: r * 0.4), fill);
    c.drawOval(Rect.fromCenter(center: Offset(cx, y),
        width: r * 2, height: r * 0.4), edge);
  }

  void _drawSphereOutline(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const r = 70.0;
    c.drawCircle(Offset(cx, cy), r, fill);
    c.drawCircle(Offset(cx, cy), r, edge);
    final dashPaint = Paint()
      ..color = edge.color.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy),
        width: r * 2, height: r * 0.35), dashPaint);
  }

  void _drawSphereSlice(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const r = 70.0;
    final dy = r * (1 - 2 * height); // +r at bottom, -r at top
    final sliceR = sqrt(max(0, r * r - dy * dy));
    if (sliceR < 1) return;
    final y = cy + dy;
    c.drawOval(Rect.fromCenter(center: Offset(cx, y),
        width: sliceR * 2, height: sliceR * 0.38), fill);
    c.drawOval(Rect.fromCenter(center: Offset(cx, y),
        width: sliceR * 2, height: sliceR * 0.38), edge);
  }

  void _drawPyramidOutline(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const h = 85.0, b = 55.0;
    final apex = Offset(cx, cy - h * 0.55);
    final bl = Offset(cx - b, cy + h * 0.45);
    final br = Offset(cx + b, cy + h * 0.45);
    final bm = Offset(cx - b * 0.3, cy + h * 0.45 + b * 0.25);
    final brmid = Offset(cx + b * 0.3, cy + h * 0.45 + b * 0.25);
    c.drawPath(Path()
      ..moveTo(apex.dx, apex.dy)..lineTo(bl.dx, bl.dy)
      ..lineTo(bm.dx, bm.dy)..lineTo(brmid.dx, brmid.dy)
      ..lineTo(br.dx, br.dy)..close(), fill);
    c.drawPath(Path()
      ..moveTo(apex.dx, apex.dy)..lineTo(bl.dx, bl.dy)
      ..lineTo(bm.dx, bm.dy)..lineTo(brmid.dx, brmid.dy)
      ..lineTo(br.dx, br.dy)..close(), edge);
    c.drawLine(apex, bm, edge);
  }

  void _drawPyramidSlice(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const h = 85.0, b = 55.0;
    final f = 1 - height;
    final y = cy - h * 0.55 + h * height;
    final hw = b * f;
    if (hw < 2) return;
    c.drawOval(Rect.fromCenter(center: Offset(cx, y),
        width: hw * 2, height: hw * 0.3), fill);
    c.drawOval(Rect.fromCenter(center: Offset(cx, y),
        width: hw * 2, height: hw * 0.3), edge);
  }

  void _drawCubeOutline(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const a = 50.0;
    final front = Rect.fromCenter(center: Offset(cx, cy), width: a * 2, height: a * 2);
    c.drawRect(front, fill);
    c.drawRect(front, edge);
    // top face (isometric)
    final topPath = Path()
      ..moveTo(cx - a, cy - a)..lineTo(cx - a + 18, cy - a - 14)
      ..lineTo(cx + a + 18, cy - a - 14)..lineTo(cx + a, cy - a)..close();
    c.drawPath(topPath, fill);
    c.drawPath(topPath, edge);
    // right face
    final rightPath = Path()
      ..moveTo(cx + a, cy - a)..lineTo(cx + a + 18, cy - a - 14)
      ..lineTo(cx + a + 18, cy + a - 14)..lineTo(cx + a, cy + a)..close();
    c.drawPath(rightPath, fill);
    c.drawPath(rightPath, edge);
  }

  void _drawCubeSlice(Canvas c, double cx, double cy, Size s,
      Paint fill, Paint edge) {
    const a = 50.0;
    final y = cy + a - a * 2 * height;
    c.drawRect(
        Rect.fromCenter(center: Offset(cx, y), width: a * 2, height: 6),
        fill);
    c.drawRect(
        Rect.fromCenter(center: Offset(cx, y), width: a * 2, height: 6),
        edge);
  }

  @override
  bool shouldRepaint(_CrossSectionPainter old) =>
      old.height != height || old.shape != shape || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE WIDGET 12: Volume Stacker
// Drag a slider to add unit cubes; count = volume.
// JSON config: { "label": "...", "max_layers": 5, "base": 3 }
// ─────────────────────────────────────────────────────────────────────────────

class VolumeStackerWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isDark;
  const VolumeStackerWidget(
      {super.key, required this.config, required this.isDark});
  @override
  State<VolumeStackerWidget> createState() => _VolumeStackerState();
}

class _VolumeStackerState extends State<VolumeStackerWidget> {
  int _layers = 1;

  @override
  Widget build(BuildContext context) {
    final label = widget.config['label'] as String? ?? 'Build with unit cubes';
    final maxLayers = (widget.config['max_layers'] as int?) ?? 5;
    final base = (widget.config['base'] as int?) ?? 3;
    final total = base * base * _layers;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InteractiveHeader(badge: 'Volume', label: label, isDark: widget.isDark),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: CustomPaint(
              painter: _StackerPainter(
                  layers: _layers, base: base, isDark: widget.isDark),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.buttonDeepVioletEnd.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Volume = $base × $base × $_layers = $total unit³',
              style: AppTextStyles.lessonEquation.copyWith(
                  color: AppColors.buttonPurpleStart,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('1 layer',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: widget.isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary)),
              Expanded(
                child: Slider(
                  value: _layers.toDouble(),
                  min: 1,
                  max: maxLayers.toDouble(),
                  divisions: maxLayers - 1,
                  activeColor: AppColors.buttonPurpleStart,
                  inactiveColor: widget.isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  onChanged: (v) => setState(() => _layers = v.round()),
                ),
              ),
              Text('$maxLayers layers',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: widget.isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StackerPainter extends CustomPainter {
  final int layers, base;
  final bool isDark;
  _StackerPainter({required this.layers, required this.base, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    const cu = 22.0; // unit cube face size
    const ox = 8.0, oy = 4.0; // isometric offset per step

    final startX = size.width / 2 - (base * cu) / 2 - (base * ox) / 2;
    final startY = size.height - 20;

    for (int layer = 0; layer < layers; layer++) {
      for (int row = 0; row < base; row++) {
        for (int col = 0; col < base; col++) {
          final x = startX + col * cu + row * ox + layer * ox * 0.4;
          final y = startY - layer * (cu + oy * 0.5) - row * oy - col * 0;

          final t = (layer / (layers + 1));
          final faceColor = Color.lerp(
            AppColors.buttonPurpleStart.withOpacity(0.4),
            AppColors.buttonDeepVioletEnd.withOpacity(0.85),
            t,
          )!;

          // Front face
          canvas.drawRect(
            Rect.fromLTWH(x, y - cu, cu, cu),
            Paint()..color = faceColor,
          );
          canvas.drawRect(
            Rect.fromLTWH(x, y - cu, cu, cu),
            Paint()
              ..color = Colors.white.withOpacity(0.25)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8,
          );
          // Top face
          final topPath = Path()
            ..moveTo(x, y - cu)
            ..lineTo(x + ox, y - cu - oy)
            ..lineTo(x + cu + ox, y - cu - oy)
            ..lineTo(x + cu, y - cu)
            ..close();
          canvas.drawPath(topPath,
              Paint()..color = faceColor.withOpacity(0.65));
          canvas.drawPath(
              topPath,
              Paint()
                ..color = Colors.white.withOpacity(0.2)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.8);
          // Right face
          final rightPath = Path()
            ..moveTo(x + cu, y - cu)
            ..lineTo(x + cu + ox, y - cu - oy)
            ..lineTo(x + cu + ox, y - oy)
            ..lineTo(x + cu, y)
            ..close();
          canvas.drawPath(rightPath,
              Paint()..color = faceColor.withOpacity(0.45));
          canvas.drawPath(
              rightPath,
              Paint()
                ..color = Colors.white.withOpacity(0.15)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.8);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_StackerPainter old) =>
      old.layers != layers || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback for unregistered widget keys
// ─────────────────────────────────────────────────────────────────────────────

class _UnknownWidget extends StatelessWidget {
  final String widgetKey;
  const _UnknownWidget({required this.widgetKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Text(
        'Interactive widget "$widgetKey" not yet built.\nAdd it to InteractiveRegistry.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkTextTertiary,
        ),
      ),
    );
  }
}
