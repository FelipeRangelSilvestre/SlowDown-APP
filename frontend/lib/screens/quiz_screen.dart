import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const Color kYellow = Color(0xFFF5B800);
  static const Color kDark = Color(0xFF1C1C1C);
  static const Color kBlue = Color(0xFF1565C0);
  static const Color kBgTop = Color(0xFFBBDEFB);
  static const Color kBgBottom = Color(0xFF90CAF9);

  static final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Quantas horas de sono são recomendadas para adultos por noite?',
      'options': ['5-6 horas', '7-9 horas', '10-12 horas', '4-5 horas'],
      'correct': 1,
    },
    {
      'question': 'Qual técnica de respiração ajuda a reduzir a ansiedade rapidamente?',
      'options': ['Respirar rápido', 'Respiração 4-7-8', 'Prender o ar por 30s', 'Respirar pela boca'],
      'correct': 1,
    },
    {
      'question': 'Quantas vezes por semana é recomendado praticar exercícios físicos?',
      'options': ['1 vez', '2 vezes', 'Pelo menos 3 vezes', 'Todo dia por horas'],
      'correct': 2,
    },
    {
      'question': 'O que é mindfulness?',
      'options': [
        'Um tipo de exercício físico',
        'Atenção plena ao momento presente',
        'Uma dieta alimentar',
        'Um remédio para ansiedade'
      ],
      'correct': 1,
    },
    {
      'question': 'Qual destes hábitos contribui mais para a saúde mental?',
      'options': [
        'Usar redes sociais por horas',
        'Dormir pouco para ser produtivo',
        'Meditar regularmente',
        'Trabalhar sem pausas'
      ],
      'correct': 2,
    },
  ];

  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  void _select(int index) {
    if (_answered) return;
    setState(() {
      _selected = index;
      _answered = true;
      if (index == _questions[_current]['correct']) _score++;
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
    } else {
      setState(() => _finished = true);
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _finished = false;
    });
  }

  Color _optionColor(int index) {
    if (!_answered) return Colors.white.withOpacity(0.85);
    if (index == _questions[_current]['correct']) return const Color(0xFF4CAF50);
    if (index == _selected) return Colors.red.shade400;
    return Colors.white.withOpacity(0.5);
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
                    const Icon(Icons.menu_rounded,
                        color: Colors.white, size: 28),
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
              child: _finished ? _buildResult() : _buildQuestion(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_current];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header QUIZ!
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: kBlue,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Text(
                'QUIZ!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progresso
          Row(
            children: List.generate(_questions.length, (i) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6,
                  decoration: BoxDecoration(
                    color: i <= _current
                        ? kBlue
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 8),

          Text(
            'Pergunta ${_current + 1} de ${_questions.length}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kDark.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          // Pergunta
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              q['question'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Opções
          ...List.generate(4, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _select(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: _optionColor(i),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selected == i
                          ? (i == q['correct']
                              ? Colors.green
                              : Colors.red)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kBlue.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ['A', 'B', 'C', 'D'][i],
                            style: const TextStyle(
                              color: kBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q['options'][i],
                          style: const TextStyle(
                            color: kDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_answered && i == q['correct'])
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 20),
                      if (_answered &&
                          i == _selected &&
                          i != q['correct'])
                        const Icon(Icons.cancel_rounded,
                            color: Colors.red, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          if (_answered)
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: Text(
                  _current < _questions.length - 1
                      ? 'PRÓXIMA →'
                      : 'VER RESULTADO',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final pct = (_score / _questions.length * 100).round();
    final emoji = pct >= 80 ? '🏆' : pct >= 60 ? '😊' : '📚';
    final msg = pct >= 80
        ? 'Excelente! Você manda bem!'
        : pct >= 60
            ? 'Bom trabalho! Continue aprendendo.'
            : 'Continue estudando sobre bem-estar!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              '$_score/${_questions.length}',
              style: const TextStyle(
                color: kDark,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '$pct% de acertos',
              style: TextStyle(
                color: kDark.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _restart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text(
                  'JOGAR NOVAMENTE',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
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
