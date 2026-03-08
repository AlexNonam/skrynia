import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

import 'package:myapp/resursi_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge режим
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Прозрачный статус-бар
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SkryniaApp());
}

class SkryniaApp extends StatelessWidget {
  const SkryniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Скриня',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  final List<String> sections = const [
    'Ресурси',
    'Потік',
    'Закупівля',
    'План',
    'Місця',
    'Товари',
    'Дисконт',
    'Щоденник',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ФОН
            Positioned.fill(
              child: Image.asset(
                'assets/texture.jpg',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // ЗАГОЛОВОК
                    const Text(
                      'СКРИНЯ',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E1A16),
                        fontFamily: 'Serif',
                        letterSpacing: 8, // уменьшили
                      ),
                    ),

                    const SizedBox(height: 20),

                    // СЕТКА
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sections.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 10, // добавили расстояние
                          childAspectRatio: 1.35,
                        ),
                        itemBuilder: (context, index) {
                          return ScrollButton(
                            text: sections[index],
                            onTap: () {
                              if (sections[index] == 'Ресурси') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ResursiScreen(),
                                  ),
                                );
                              } else {
                                developer.log('Відкрито: ${sections[index]}');
                              }
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const ScrollButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<ScrollButton> createState() => _ScrollButtonState();
}

class _ScrollButtonState extends State<ScrollButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ТЕНЬ
            Transform.translate(
              offset: const Offset(6, 7),
              child: Opacity(
                opacity: 0.6,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Image.asset(
                    'assets/button_scroll.png',
                    color: Colors.black,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // СВИТОК
            Image.asset(
              'assets/button_scroll.png',
              fit: BoxFit.contain,
            ),

            // ТЕКСТ
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 12, right: 12),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                  fontFamily: 'Serif',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
