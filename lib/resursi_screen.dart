
import 'package:flutter/material.dart';
import 'package:myapp/database_helper.dart';

class ResursiScreen extends StatefulWidget {
  const ResursiScreen({super.key});

  @override
  State<ResursiScreen> createState() => _ResursiScreenState();
}

class _ResursiScreenState extends State<ResursiScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _resources = [];

  @override
  void initState() {
    super.initState();
    _refreshResourceList();
  }

  void _refreshResourceList() async {
    final data = await dbHelper.queryAllResources();
    setState(() {
      _resources = data;
    });
  }

  void _showAddResourceDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      pageBuilder: (context, anim, secondaryAnim) {
        return AnimatedScrollDialog(
          onSave: (name, count) async {
            await dbHelper.insertResource({'name': name, 'count': count});
            _refreshResourceList();
          },
        );
      },
    );
  }
  
  void _deleteResource(int id) async {
    await dbHelper.deleteResource(id);
    _refreshResourceList();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ресурс видалено'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/texture.jpg', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723), size: 30),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Text(
                        'Рахунки',
                        style: TextStyle(
                          fontSize: 44, fontWeight: FontWeight.bold, color: Color(0xFF2E1A16),
                          fontFamily: 'Serif', letterSpacing: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0x993E2723), height: 1, thickness: 1, indent: 20, endIndent: 20),
                Expanded(
                  child: _resources.isEmpty
                      ? const Center(
                          child: Text(
                            'Ваша скриня порожня.', 
                            style: TextStyle(fontFamily: 'Serif', fontSize: 18, color: Color(0x993E2723)),
                          )
                        )
                      : ListView.builder(
                          itemCount: _resources.length,
                          itemBuilder: (context, index) {
                            final resource = _resources[index];
                            return Dismissible(
                              key: Key(resource['id'].toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _deleteResource(resource['id']);
                              },
                              background: Container(
                                color: Colors.red.withValues(alpha: 0.7),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                color: const Color(0xFFEFEBE9).withValues(alpha: 0.85),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Color(0x553E2723), width: 1),
                                ),
                                child: ListTile(
                                  title: Text(
                                    resource['name'],
                                    style: const TextStyle(
                                      fontFamily: 'Serif',
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3E2723),
                                      fontSize: 22,
                                    ),
                                  ),
                                  trailing: Text(
                                    '${resource['count']}',
                                    style: const TextStyle(
                                      fontFamily: 'Serif',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4E342E),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: InkResponse(
        onTap: _showAddResourceDialog,
        radius: 35,
        child: ClipOval(
          child: Image.asset(
            'assets/button_add.png',
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class AnimatedScrollDialog extends StatefulWidget {
  final Future<void> Function(String name, int count) onSave;

  const AnimatedScrollDialog({super.key, required this.onSave});

  @override
  State<AnimatedScrollDialog> createState() => _AnimatedScrollDialogState();
}

class _AnimatedScrollDialogState extends State<AnimatedScrollDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final nameController = TextEditingController();
  final countController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Увеличили время открытия (1200 мс) чтобы было хорошо видно анимацию
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    countController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    // Делаем закрытие чуть быстрее (500 мс)
    _controller.animateBack(0.0, duration: const Duration(milliseconds: 500)).then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: SizeTransition(
          sizeFactor: _animation,
          axisAlignment: 0.0, // разворачивается от центра
          child: Stack(
            alignment: Alignment.center,
            children: [
              // КАРТИНКА СВИТКА КАК ФОН
              Image.asset(
                'assets/button_scroll.png',
                width: 380, // Широкий свиток
                height: 480, // Высокий свиток
                fit: BoxFit.fill, // Растягиваем по всем краям чтобы влез контент
              ),
              // КОНТЕНТ (Форма) поверх свитка
              Container(
                width: 250, // Контент уже чем свиток (чтобы не заезжать на закрученные края картинки)
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Додати рахунок',
                      style: TextStyle(
                        fontFamily: 'Serif', 
                        color: Color(0xFF3E2723), 
                        fontSize: 24, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Назва', 
                        labelStyle: TextStyle(color: Color(0xFF5D4037)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3E2723))),
                      ),
                      style: const TextStyle(color: Color(0xFF3E2723), fontSize: 18),
                      cursorColor: const Color(0xFF3E2723),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: countController,
                      decoration: const InputDecoration(
                        labelText: 'Кількість', 
                        labelStyle: TextStyle(color: Color(0xFF5D4037)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3E2723))),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFF3E2723), fontSize: 18),
                      cursorColor: const Color(0xFF3E2723),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _closeDialog,
                          child: const Text('Скасувати', style: TextStyle(color: Color(0xFF5D4037), fontSize: 16)),
                        ),
                        const SizedBox(width: 5),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E2723),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Зберегти', style: TextStyle(fontSize: 16)),
                          onPressed: () async {
                            final name = nameController.text;
                            final count = int.tryParse(countController.text) ?? 0;
                            if (name.isNotEmpty) {
                              await widget.onSave(name, count);
                              _closeDialog();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
