import 'package:flutter/material.dart';
import 'database_helper.dart';

class ScrollDialog extends StatefulWidget {
  final VoidCallback? onRecordAdded;

  const ScrollDialog({super.key, this.onRecordAdded});

  @override
  State<ScrollDialog> createState() => _ScrollDialogState();
}

class _ScrollDialogState extends State<ScrollDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  final TextEditingController _textController = TextEditingController();

  // Размеры под ваши картинки
  final double scrollWidth = 320.0;
  final double maxPaperHeight = 350.0;
  final double rollerHeight = 55.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Сохранение записи
  Future<void> _saveData() async {
    if (_textController.text.trim().isNotEmpty) {
      await DatabaseHelper.instance.insert({
        'name': _textController.text.trim(),
        'date': DateTime.now().toIso8601String(),
      });

      if (widget.onRecordAdded != null) {
        widget.onRecordAdded!();
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _heightAnimation,
          builder: (context, child) {
            double currentPaperHeight = _heightAnimation.value * maxPaperHeight;

            return SizedBox(
              width: scrollWidth,
              height: currentPaperHeight + (rollerHeight * 2),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // 1. Пергамент (растягивается)
                  Positioned(
                    top: rollerHeight - 10,
                    child: Image.asset(
                      'assets/paper_texture.png',
                      width: scrollWidth * 0.88,
                      height: currentPaperHeight + 20,
                      fit: BoxFit.fill,
                    ),
                  ),

                  // 2. Верхний роллер
                  Positioned(
                    top: 0,
                    child: Image.asset(
                      'assets/roller_top.png',
                      width: scrollWidth,
                      height: rollerHeight,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 3. Нижний роллер (уезжает вниз)
                  Positioned(
                    top: currentPaperHeight + rollerHeight - 10,
                    child: Image.asset(
                      'assets/roller_bottom.png',
                      width: scrollWidth,
                      height: rollerHeight,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 4. Поля ввода и кнопка
                  if (_controller.value > 0.7)
                    Positioned.fill(
                      top: rollerHeight + 30,
                      bottom: rollerHeight + 40,
                      child: FadeTransition(
                        opacity: _controller,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
                          child: Column(
                            children: [
                              const Text(
                                "НОВИЙ ЗАПИС",
                                style: TextStyle(
                                  color: Color(0xFF3E2723),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _textController,
                                autofocus: true,
                                cursorColor: Colors.brown,
                                style: const TextStyle(
                                    color: Color(0xFF3E2723), fontSize: 16),
                                decoration: const InputDecoration(
                                  hintText: "Що додаємо?...",
                                  hintStyle: TextStyle(
                                      color: Colors.brown, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                              const Spacer(),
                              // Пуговица-сохранялка
                              WoodenButton(onTap: _saveData),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class WoodenButton extends StatefulWidget {
  final VoidCallback onTap;
  const WoodenButton({super.key, required this.onTap});

  @override
  State<WoodenButton> createState() => _WoodenButtonState();
}

class _WoodenButtonState extends State<WoodenButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.85),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: Transform.scale(
        scale: _scale,
        child: Image.asset(
          'assets/button_add.png',
          width: 75,
          height: 75,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
