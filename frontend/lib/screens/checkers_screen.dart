import 'package:flutter/material.dart';

class CheckersScreen extends StatefulWidget {
  const CheckersScreen({super.key});

  @override
  State<CheckersScreen> createState() => _CheckersScreenState();
}

class _CheckersScreenState extends State<CheckersScreen> {
  static const Color kYellow = Color(0xFFF5B800);
  static const Color kDark = Color(0xFF1C1C1C);
  static const Color kBgTop = Color(0xFFF5F0A0);
  static const Color kBgBottom = Color(0xFFE8E4A0);

  // 0=vazio, 1=peça jogador, 2=peça CPU, 3=dama jogador, 4=dama CPU
  late List<List<int>> _board;
  int? _selectedRow;
  int? _selectedCol;
  bool _playerTurn = true;
  String _status = 'Sua vez!';
  int _playerScore = 0;
  int _cpuScore = 0;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    _board = List.generate(8, (r) => List.generate(8, (c) {
      if ((r + c) % 2 == 1) {
        if (r < 3) return 2; // CPU (topo)
        if (r > 4) return 1; // Jogador (baixo)
      }
      return 0;
    }));
    _selectedRow = null;
    _selectedCol = null;
    _playerTurn = true;
    _status = 'Sua vez!';
  }

  bool _isPlayerPiece(int val) => val == 1 || val == 3;
  bool _isCpuPiece(int val) => val == 2 || val == 4;

  List<List<int>> _getMoves(int row, int col) {
    final piece = _board[row][col];
    final moves = <List<int>>[];
    final dirs = (piece == 1)
        ? [[-1, -1], [-1, 1]]
        : (piece == 2)
            ? [[1, -1], [1, 1]]
            : [[-1, -1], [-1, 1], [1, -1], [1, 1]];

    for (final d in dirs) {
      final nr = row + d[0];
      final nc = col + d[1];
      if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8 && _board[nr][nc] == 0) {
        moves.add([nr, nc, -1, -1]);
      }
      // Captura
      final jr = row + d[0] * 2;
      final jc = col + d[1] * 2;
      if (jr >= 0 && jr < 8 && jc >= 0 && jc < 8 && _board[jr][jc] == 0) {
        final mid = _board[nr][nc];
        if ((_isPlayerPiece(piece) && _isCpuPiece(mid)) ||
            (_isCpuPiece(piece) && _isPlayerPiece(mid))) {
          moves.add([jr, jc, nr, nc]);
        }
      }
    }
    return moves;
  }

  void _onTap(int row, int col) {
    if (!_playerTurn) return;

    final piece = _board[row][col];

    if (_selectedRow == null) {
      if (_isPlayerPiece(piece)) {
        setState(() {
          _selectedRow = row;
          _selectedCol = col;
        });
      }
      return;
    }

    final moves = _getMoves(_selectedRow!, _selectedCol!);
    final move = moves.firstWhere(
      (m) => m[0] == row && m[1] == col,
      orElse: () => [],
    );

    if (move.isNotEmpty) {
      setState(() {
        _board[row][col] = _board[_selectedRow!][_selectedCol!];
        _board[_selectedRow!][_selectedCol!] = 0;
        if (move[2] != -1) {
          _board[move[2]][move[3]] = 0;
          _playerScore++;
        }
        // Promover a dama
        if (row == 0 && _board[row][col] == 1) _board[row][col] = 3;
        _selectedRow = null;
        _selectedCol = null;
        _playerTurn = false;
        _status = 'Vez da CPU...';
      });

      Future.delayed(const Duration(milliseconds: 700), _cpuMove);
    } else {
      // Reselecionar
      if (_isPlayerPiece(piece)) {
        setState(() {
          _selectedRow = row;
          _selectedCol = col;
        });
      } else {
        setState(() {
          _selectedRow = null;
          _selectedCol = null;
        });
      }
    }
  }

  void _cpuMove() {
    if (!mounted) return;
    // Coleta todas as peças da CPU e seus movimentos
    final allMoves = <Map<String, dynamic>>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (_isCpuPiece(_board[r][c])) {
          final moves = _getMoves(r, c);
          for (final m in moves) {
            allMoves.add({'fr': r, 'fc': c, 'move': m});
          }
        }
      }
    }

    if (allMoves.isEmpty) {
      setState(() => _status = 'Você venceu! 🎉');
      return;
    }

    // Prioriza capturas
    final captures = allMoves.where((m) => m['move'][2] != -1).toList();
    final chosen = captures.isNotEmpty ? captures.first : allMoves.first;
    final m = chosen['move'] as List<int>;

    setState(() {
      _board[m[0]][m[1]] = _board[chosen['fr']][chosen['fc']];
      _board[chosen['fr']][chosen['fc']] = 0;
      if (m[2] != -1) {
        _board[m[2]][m[3]] = 0;
        _cpuScore++;
      }
      if (m[0] == 7 && _board[m[0]][m[1]] == 2) _board[m[0]][m[1]] = 4;
      _playerTurn = true;
      _status = 'Sua vez!';
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
                      onTap: () => setState(_initBoard),
                      child: const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 26),
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
              child: Column(
                children: [
                  // Placar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ScoreBox(label: 'VOCÊ', score: _playerScore, color: kDark),
                        Text(
                          _status,
                          style: TextStyle(
                            color: kDark.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _ScoreBox(label: 'CPU', score: _cpuScore, color: Colors.red.shade700),
                      ],
                    ),
                  ),

                  // Tabuleiro
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: kDark, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8),
                          itemCount: 64,
                          itemBuilder: (_, i) {
                            final row = i ~/ 8;
                            final col = i % 8;
                            final isDark = (row + col) % 2 == 1;
                            final piece = _board[row][col];
                            final isSelected =
                                row == _selectedRow && col == _selectedCol;
                            final validMoves = (_selectedRow != null)
                                ? _getMoves(_selectedRow!, _selectedCol!)
                                : <List<int>>[];
                            final isTarget = validMoves
                                .any((m) => m[0] == row && m[1] == col);

                            return GestureDetector(
                              onTap: () => _onTap(row, col),
                              child: Container(
                                color: isSelected
                                    ? kYellow.withOpacity(0.7)
                                    : isTarget && isDark
                                        ? Colors.green.withOpacity(0.4)
                                        : isDark
                                            ? const Color(0xFF5C4F8A)
                                            : const Color(0xFFE8E0FF),
                                child: piece != 0
                                    ? Center(
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: _isPlayerPiece(piece)
                                                ? kDark
                                                : Colors.red.shade700,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: piece == 3 || piece == 4
                                              ? const Icon(Icons.star_rounded,
                                                  color: Colors.white, size: 14)
                                              : null,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botão reiniciar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => setState(_initBoard),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                        child: const Text(
                          'NOVO JOGO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
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

class _ScoreBox extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const _ScoreBox(
      {required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        Text('$score',
            style: TextStyle(
                color: color, fontSize: 24, fontWeight: FontWeight.w900)),
      ],
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
