import 'package:flutter/material.dart';
import 'pet_skin_screen.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen>
    with TickerProviderStateMixin {
  static const Color kYellow = Color(0xFFF5B800);
  static const Color kDark = Color(0xFF1C1C1C);
  static const Color kBgTop = Color(0xFFF5F0A0);
  static const Color kBgBottom = Color(0xFFE8E4A0);

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _fireworkController;

  bool _showFireworks = false;
  String _currentSkin = 'default'; // skin selecionada
  String _currentRace = 'cat';     // raça selecionada

  // Acessórios selecionados
  String? _hat;    // chapeu, noel, bucket, mafioso, cartola
  String? _glasses; // oculos, de_grau, aviador

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fireworkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fireworkController.dispose();
    super.dispose();
  }

  void _onStart() {
    setState(() => _showFireworks = true);
    _fireworkController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showFireworks = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── AppBar ──────────────────────────────────────────────────
          Container(
            color: kYellow,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.reply_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    _SlowDownLogo(size: 28),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push<Map<String, String?>>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PetSkinScreen(
                                    currentHat: _hat,
                                    currentGlasses: _glasses,
                                    currentRace: _currentRace,
                                  )),
                        );
                        if (result != null && mounted) {
                          setState(() {
                            _hat = result['hat'];
                            _glasses = result['glasses'];
                            _currentRace = result['race'] ?? 'cat';
                          });
                        }
                      },
                      child: const Icon(Icons.style_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Corpo ────────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kBgTop, kBgBottom],
                ),
              ),
              child: Stack(
                children: [
                  // Fundo gramado
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFB8E88A),
                            Color(0xFF8BC34A),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Fogos de artifício
                  if (_showFireworks)
                    AnimatedBuilder(
                      animation: _fireworkController,
                      builder: (_, __) => _FireworksOverlay(
                        progress: _fireworkController.value,
                      ),
                    ),

                  // Conteúdo principal
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // ── Pet animado ──────────────────────────────
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pet (raça)
                            CustomPaint(
                              size: const Size(200, 200),
                              painter: _PetPainter(race: _currentRace),
                            ),

                            // Acessório: chapéu
                            if (_hat != null)
                              Positioned(
                                top: 10,
                                child: _HatWidget(hat: _hat!),
                              ),

                            // Acessório: óculos
                            if (_glasses != null)
                              Positioned(
                                top: 72,
                                child: _GlassesWidget(glasses: _glasses!),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Botão START ──────────────────────────────
                      GestureDetector(
                        onTap: _onStart,
                        child: Container(
                          width: 140,
                          height: 52,
                          decoration: BoxDecoration(
                            color: kDark,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              'START',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Botão Skins ──────────────────────────────
                      GestureDetector(
                        onTap: () async {
                          final result =
                              await Navigator.push<Map<String, String?>>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PetSkinScreen(
                                      currentHat: _hat,
                                      currentGlasses: _glasses,
                                      currentRace: _currentRace,
                                    )),
                          );
                          if (result != null && mounted) {
                            setState(() {
                              _hat = result['hat'];
                              _glasses = result['glasses'];
                              _currentRace = result['race'] ?? 'cat';
                            });
                          }
                        },
                        child: Container(
                          width: 140,
                          height: 44,
                          decoration: BoxDecoration(
                            color: kYellow,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              'SKINS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Painter: Pet ─────────────────────────────────────────────────────────────

class _PetPainter extends CustomPainter {
  final String race;
  const _PetPainter({required this.race});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Color bodyColor;
    switch (race) {
      case 'dog':
        bodyColor = const Color(0xFFD4A96A);
        break;
      case 'robot':
        bodyColor = const Color(0xFFB0BEC5);
        break;
      case 'monk':
        bodyColor = const Color(0xFFF5C842);
        break;
      case 'aviator':
        bodyColor = const Color(0xFFE8C49A);
        break;
      default:
        bodyColor = const Color(0xFFF5C842);
    }

    final bodyPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = const Color(0xFF1C1C1C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final darkFill = Paint()
      ..color = const Color(0xFF1C1C1C)
      ..style = PaintingStyle.fill;

    final whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (race == 'robot') {
      // Corpo robô quadrado
      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.65), width: w * 0.55, height: h * 0.45),
        const Radius.circular(10),
      );
      canvas.drawRRect(body, bodyPaint);
      canvas.drawRRect(body, outlinePaint);

      final head = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.34), width: w * 0.52, height: h * 0.44),
        const Radius.circular(10),
      );
      canvas.drawRRect(head, bodyPaint);
      canvas.drawRRect(head, outlinePaint);

      // Olhos LED
      canvas.drawRect(
        Rect.fromCenter(center: Offset(w * 0.38, h * 0.31), width: w * 0.10, height: h * 0.08),
        Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.fill,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(w * 0.62, h * 0.31), width: w * 0.10, height: h * 0.08),
        Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.fill,
      );
    } else {
      // Corpo padrão (gato/cachorro/monge/aviador)
      final bodyPath = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.65),
          width: w * 0.62,
          height: h * 0.52,
        ));
      canvas.drawPath(bodyPath, bodyPaint);
      canvas.drawPath(bodyPath, outlinePaint);

      final headPath = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.36),
          width: w * 0.58,
          height: h * 0.50,
        ));
      canvas.drawPath(headPath, bodyPaint);
      canvas.drawPath(headPath, outlinePaint);

      if (race == 'dog') {
        // Orelhas caídas
        final leftEar = Path()
          ..moveTo(w * 0.22, h * 0.18)
          ..cubicTo(w * 0.08, h * 0.22, w * 0.10, h * 0.40, w * 0.22, h * 0.44)
          ..lineTo(w * 0.28, h * 0.22)
          ..close();
        canvas.drawPath(leftEar, bodyPaint);
        canvas.drawPath(leftEar, outlinePaint);

        final rightEar = Path()
          ..moveTo(w * 0.78, h * 0.18)
          ..cubicTo(w * 0.92, h * 0.22, w * 0.90, h * 0.40, w * 0.78, h * 0.44)
          ..lineTo(w * 0.72, h * 0.22)
          ..close();
        canvas.drawPath(rightEar, bodyPaint);
        canvas.drawPath(rightEar, outlinePaint);
      } else {
        // Orelhas pontudas (gato / monge / aviador)
        final leftEar = Path()
          ..moveTo(w * 0.24, h * 0.22)
          ..lineTo(w * 0.16, h * 0.06)
          ..lineTo(w * 0.36, h * 0.14)
          ..close();
        canvas.drawPath(leftEar, bodyPaint);
        canvas.drawPath(leftEar, outlinePaint);

        final rightEar = Path()
          ..moveTo(w * 0.76, h * 0.22)
          ..lineTo(w * 0.84, h * 0.06)
          ..lineTo(w * 0.64, h * 0.14)
          ..close();
        canvas.drawPath(rightEar, bodyPaint);
        canvas.drawPath(rightEar, outlinePaint);
      }

      // Olhos
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.38, h * 0.33), width: w * 0.10, height: h * 0.10),
        darkFill,
      );
      canvas.drawCircle(Offset(w * 0.40, h * 0.31), w * 0.02, whiteFill);

      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.62, h * 0.33), width: w * 0.10, height: h * 0.10),
        darkFill,
      );
      canvas.drawCircle(Offset(w * 0.64, h * 0.31), w * 0.02, whiteFill);

      // Nariz
      final nosePath = Path()
        ..moveTo(w * 0.5, h * 0.40)
        ..lineTo(w * 0.46, h * 0.44)
        ..lineTo(w * 0.54, h * 0.44)
        ..close();
      canvas.drawPath(nosePath, darkFill);

      // Boca
      final mouthPaint = Paint()
        ..color = const Color(0xFF1C1C1C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(w * 0.5, h * 0.44), Offset(w * 0.44, h * 0.49), mouthPaint);
      canvas.drawLine(Offset(w * 0.5, h * 0.44), Offset(w * 0.56, h * 0.49), mouthPaint);

      // Bigodes (só gato)
      if (race != 'dog') {
        final whiskerPaint = Paint()
          ..color = const Color(0xFF1C1C1C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(w * 0.18, h * 0.40), Offset(w * 0.42, h * 0.43), whiskerPaint);
        canvas.drawLine(Offset(w * 0.18, h * 0.44), Offset(w * 0.42, h * 0.45), whiskerPaint);
        canvas.drawLine(Offset(w * 0.82, h * 0.40), Offset(w * 0.58, h * 0.43), whiskerPaint);
        canvas.drawLine(Offset(w * 0.82, h * 0.44), Offset(w * 0.58, h * 0.45), whiskerPaint);
      }

      // Rabo
      final tailPath = Path()
        ..moveTo(w * 0.72, h * 0.82)
        ..cubicTo(w * 0.90, h * 0.78, w * 0.95, h * 0.60, w * 0.80, h * 0.55);
      canvas.drawPath(tailPath, outlinePaint);

      // Patas
      for (final cx in [w * 0.38, w * 0.62]) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, h * 0.88), width: w * 0.18, height: h * 0.10),
          bodyPaint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, h * 0.88), width: w * 0.18, height: h * 0.10),
          outlinePaint,
        );
      }

      // Toga do monge
      if (race == 'monk') {
        final togaPaint = Paint()
          ..color = const Color(0xFFE57C1A)
          ..style = PaintingStyle.fill;
        final toga = Path()
          ..moveTo(w * 0.25, h * 0.55)
          ..lineTo(w * 0.20, h * 0.80)
          ..lineTo(w * 0.80, h * 0.80)
          ..lineTo(w * 0.75, h * 0.55)
          ..close();
        canvas.drawPath(toga, togaPaint);
        canvas.drawPath(toga, outlinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PetPainter old) => old.race != race;
}

// ─── Widget: Chapéu ───────────────────────────────────────────────────────────

class _HatWidget extends StatelessWidget {
  final String hat;
  const _HatWidget({required this.hat});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (hat) {
      case 'noel':
        icon = Icons.hotel_class_rounded;
        color = Colors.red;
        break;
      case 'bucket':
        icon = Icons.inbox_rounded;
        color = Colors.blue;
        break;
      case 'mafioso':
        icon = Icons.shield_rounded;
        color = Colors.black;
        break;
      case 'cartola':
        icon = Icons.looks_one_rounded;
        color = Colors.black;
        break;
      default:
        icon = Icons.hardware_rounded;
        color = const Color(0xFF8B4513);
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}

// ─── Widget: Óculos ───────────────────────────────────────────────────────────

class _GlassesWidget extends StatelessWidget {
  final String glasses;
  const _GlassesWidget({required this.glasses});

  @override
  Widget build(BuildContext context) {
    Color frameColor;
    switch (glasses) {
      case 'aviador':
        frameColor = const Color(0xFFDAA520);
        break;
      case 'de_grau':
        frameColor = Colors.black87;
        break;
      default:
        frameColor = Colors.black87;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: frameColor, width: 2.5),
            borderRadius: BorderRadius.circular(glasses == 'aviador' ? 50 : 4),
            color: frameColor.withOpacity(0.15),
          ),
        ),
        Container(width: 10, height: 2, color: frameColor),
        Container(
          width: 32,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: frameColor, width: 2.5),
            borderRadius: BorderRadius.circular(glasses == 'aviador' ? 50 : 4),
            color: frameColor.withOpacity(0.15),
          ),
        ),
      ],
    );
  }
}

// ─── Widget: Fogos de artifício ───────────────────────────────────────────────

class _FireworksOverlay extends StatelessWidget {
  final double progress;
  const _FireworksOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _FireworksPainter(progress: progress),
    );
  }
}

class _FireworksPainter extends CustomPainter {
  final double progress;
  const _FireworksPainter({required this.progress});

  static const List<Color> _colors = [
    Color(0xFFF5B800),
    Color(0xFFFF4444),
    Color(0xFF44FF44),
    Color(0xFF4444FF),
    Color(0xFFFF44FF),
  ];

  static const List<Offset> _centers = [
    Offset(0.2, 0.3),
    Offset(0.8, 0.25),
    Offset(0.5, 0.2),
    Offset(0.15, 0.5),
    Offset(0.85, 0.45),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.1) return;

    for (int f = 0; f < _centers.length; f++) {
      final delay = f * 0.15;
      final localProgress = ((progress - delay) / 0.6).clamp(0.0, 1.0);
      if (localProgress <= 0) continue;

      final cx = _centers[f].dx * size.width;
      final cy = _centers[f].dy * size.height;
      final color = _colors[f % _colors.length];
      final maxR = size.width * 0.15;

      for (int i = 0; i < 12; i++) {
        final angle = (i / 12) * 2 * 3.14159;
        final r = maxR * localProgress;
        final x = cx + r * (r < maxR ? 1.0 : 0.0) * _cos(angle);
        final y = cy + r * _sin(angle);
        final opacity = (1 - localProgress).clamp(0.0, 1.0);

        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()..color = color.withOpacity(opacity),
        );
      }
    }
  }

  double _cos(double angle) {
    // Aproximação simples
    return (angle < 3.14159) ? (1 - angle / 1.5708).clamp(-1, 1) : ((angle - 3.14159) / 1.5708 - 1).clamp(-1, 1);
  }

  double _sin(double angle) {
    return _cos(angle - 1.5708);
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter old) => old.progress != progress;
}

// ─── Widget: Logo SlowDown ────────────────────────────────────────────────────

class _SlowDownLogo extends StatelessWidget {
  final double size;
  const _SlowDownLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: size * 0.14, vertical: size * 0.08),
          decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(4)),
          child: Text('SLOW',
              style: TextStyle(
                  color: const Color(0xFFF5B800),
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w900,
                  height: 1)),
        ),
        SizedBox(width: size * 0.08),
        Text('DOWN',
            style: TextStyle(
                color: const Color(0xFF1C1C1C),
                fontSize: size * 0.72,
                fontWeight: FontWeight.w900,
                height: 1)),
      ],
    );
  }
}
