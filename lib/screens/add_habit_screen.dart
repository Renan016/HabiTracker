import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/habit.dart'; // Importa o modelo
import '../widgets/glass_widgets.dart'; // Importa widgets

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedEmoji = '🔥';

  final List<String> _emojis = [
    '🔥', '💧', '📚', '💪', '🧘', '💤', '🍳', '🏃', '🎸', '💻', '🌿', '☀️', '🎮', '💡',
    '💰', '🎤', '🎨', '📝', '🍎', '🥕', '🧠', '🎧', '✈️', '🐶', '🐈', '✨', '☕', '🗓️',
    '🛠️', '🔬', '🌌', '🚀', '🏡', '🧩', '📈', '📉', '🔒', '🔑', '❤️', '🩹', '🧽', '🧼'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0E),
      body: Stack(
        children: [
          Positioned(
             top: -50,
             left: -50,
             child: ImageFiltered(
               imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
               child: Container(
                 width: 200,
                 height: 200,
                 decoration: BoxDecoration(
                   color: Colors.purple.withOpacity(0.15),
                 ),
               ),
             ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GlassBackButton(onTap: () => Navigator.pop(context)),
                      const Spacer(),
                      const Text("New Habit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      const SizedBox(width: 42),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(_selectedEmoji, style: const TextStyle(fontSize: 50)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = _emojis[index];
                      final isSelected = emoji == _selectedEmoji;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = emoji),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.05))
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("HABIT NAME", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: "ex. Workout",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GestureDetector(
                    onTap: () {
                      if (_nameController.text.isNotEmpty) {
                        final newHabit = Habit(
                          id: DateTime.now().toString(),
                          title: _nameController.text,
                          emoji: _selectedEmoji,
                          userId: '', // Será preenchido na HomePage
                        );
                        Navigator.pop(context, newHabit);
                      }
                    },
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))]
                      ),
                      alignment: Alignment.center,
                      child: const Text("Create Habit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}