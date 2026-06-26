import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  static const Color kYellow = Color(0xFFF5B800);
  static const Color kDark = Color(0xFF1C1C1C);
  static const Color kRoadColor = Color(0xFF2D2D2D);
  static const Color kLineColor = Colors.white;
  static const Color kGrassColor = Color(0xFF4CAF50);

  // Posição do carro do jogador (0.0 = esquerda, 1.0 = direita)
  double _carX = 0.5;
  double _roadOffset = 0.0;
  int _score = 0;
  int _lives = 3;
  bool _running = false;
  bool _gameOver = false;

  Timer? _gameLoop;
  Timer? _spawnTimer;
  final Random _rng = Random();

  // Obstáculos: {x, y} em frações da tela
  final List<Map<String, double>> _obstacles = [];

  void _start() {
    setState(() {
      _carX = 0.5;
      _roadOffset = 0.0;
      _score = 0;
      _lives = 3;
      _running = true;
      _gameOver = false;
      _obstacles.clear();
    });

    _gameLoop = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      setState(() {
        _roadOffset = (_roadOffset + 0.04) % 1.0;
        _score++;

        // Move obstáculos
        for (final obs in _obstacles) {
          obs['y'] = (obs['y'] ?? 0) + 0.035;
        }

        // Detecta colisão
        _obstacles.removeWhere((obs) {
          final hit = (obs['y']! > 0.78 && obs['y']! < 0.92) &&
              (obs['x']! - _carX).abs() < 0.12;
          if (hit) {
            _lives--;
            if (_lives <= 0) _endGame();
          }
          return obs['y']! > 1.1 || hit;
        });
      });
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted || !_running) return;
      setState(() {
        _obstacles.add({
          'x': 0.2 + _rng.nextDouble() * 0.6,
          'y': -0.05,
        });
      });
    });
  }

  void _endGame() {
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
    setState(() {
      _running = false;
      _gameOver = true;
    });
  }

  void _moveLeft() {
    if (!_running) return;
    setState(() => _carX = (_carX - 0.15).clamp(0.15, 0.85));
  }

  void _moveRight() {
    if (!_running) return;
    setState(() => _carX = (_carX + 0.15).clamp(0.15, 0.85));
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
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
                      onTap: () {
                        _gameLoop?.cancel();
                        _spawnTimer?.cancel();
                        Navigator.of(context).maybePop();
                      },
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
                    // Placar
                    Text(
                      'Score: $_score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Pista ────────────────────────────────────────────────────
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              final roadLeft = w * 0.15;
              final roadWidth = w * 0.70;

              return GestureDetector(
                onTapDown: (d) {
                  if (d.localPosition.dx < w / 2) {
                    _moveLeft();
                  } else {
                    _moveRight();
                  }
                },
                child: Stack(
                  children: [
                    // Grama
                    Container(color: kGrassColor),

                    // Pista
                    Positioned(
                      left: roadLeft,
                      width: roadWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(color: kRoadColor),
                    ),

                    // Linhas da pista animadas
                    ...List.generate(6, (i) {
                      final y = ((i / 5) + _roadOffset) % 1.0;
                      return Positioned(
                        left: w * 0.5 - 3,
                        top: y * h,
                        child: Container(
                          width: 6,
                          height: h * 0.08,
                          color: kLineColor.withOpacity(0.5),
                        ),
                      );
                    }),

                    // Obstáculos
                    ..._obstacles.map((obs) {
                      return Positioned(
                        left: roadLeft + obs['x']! * roadWidth - 18,
                        top: obs['y']! * h - 22,
                        child: const _ObstacleCar(),
                      );
                    }),

                    // Carro do jogador
                    Positioned(
                      left: roadLeft + _carX * roadWidth - 20,
                      top: h * 0.82,
                      child: const _PlayerCar(),
                    ),

                    // Vidas
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Row(
                        children: List.generate(
                          3,
                          (i) => Icon(
                            Icons.favorite_rounded,
                            color: i < _lives
                                ? Colors.red
                                : Colors.grey.withOpacity(0.4),
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    // Tela inicial
                    if (!_running && !_gameOver)
                      Center(
                        child: _OverlayCard(
                          title: 'CORRIDA',
                          subtitle: 'Desvie dos obstáculos!\nToque para mover o carro.',
                          buttonLabel: 'INICIAR',
                          onTap: _start,
                        ),
                      ),

                    // Game Over
                    if (_gameOver)
                      Center(
                        child: _OverlayCard(
                          title: 'FIM DE JOGO',
                          subtitle: 'Pontuação: $_score',
                          buttonLabel: 'JOGAR NOVAMENTE',
                          onTap: _start,
                        ),
                      ),

                    // Setas de controle
                    if (_running)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: _moveLeft,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: kDark.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back_rounded,
                                    color: Colors.white, size: 28),
                              ),
                            ),
                            GestureDetector(
                              onTap: _moveRight,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: kDark.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 28),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PlayerCar extends StatelessWidget {
  const _PlayerCar();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 44),
      painter: _CarPainter(color: const Color(0xFFF5B800)),
    );
  }
}

class _ObstacleCar extends StatelessWidget {
  const _ObstacleCar();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 40),
      painter: _CarPainter(color: Colors.red.shade700),
    );
  }
}

class _CarPainter extends CustomPainter {
  final Color color;
  const _CarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Corpo
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.2,
          size.width * 0.8, size.height * 0.6),
      const Radius.circular(6),
    );
    canvas.drawRRect(body, paint);
    canvas.drawRRect(body, outline);

    // Teto
    final roof = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.05,
          size.width * 0.6, size.height * 0.3),
      const Radius.circular(4),
    );
    canvas.drawRRect(roof, paint);
    canvas.drawRRect(roof, outline);

    // Rodas
    final wheelPaint = Paint()..color = Colors.black..style = PaintingStyle.fill;
    for (final pos in [
      [0.05, 0.25], [0.05, 0.65], [0.75, 0.25], [0.75, 0.65]
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * pos[0], size.height * pos[1]),
          width: size.width * 0.22,
          height: size.height * 0.18,
        ),
        wheelPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CarPainter old) => old.color != color;
}

class _OverlayCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  static const Color kYellow = Color(0xFFF5B800);
  static const Color kDark = Color(0xFF1C1C1C);

  const _OverlayCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: const TextStyle(
                  color: kDark, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: kDark.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: kYellow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(buttonLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlowDownLogo extends StatelessWidget {
  final double size;
  const _SlowDownLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
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
    ]);
  }
}
