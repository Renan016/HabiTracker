import 'dart:ui';
import 'package:flutter/material.dart';

// --- DIALOGS ---
class GlassConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const GlassConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        backgroundColor: Colors.transparent, 
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E).withOpacity(0.85), 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(content, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DialogButton(text: cancelText, color: Colors.white.withOpacity(0.1), textColor: Colors.white.withOpacity(0.8), onTap: () => Navigator.of(context).pop()),
                      DialogButton(text: confirmText, color: const Color(0xFFFC3D39), textColor: Colors.white, onTap: onConfirm),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DialogButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const DialogButton({super.key, required this.text, required this.color, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }
}

// --- CONTAINERS & CONTROLS ---

class GlassHabitContainer extends StatelessWidget {
  final Widget child;
  const GlassHabitContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassCheckbox extends StatelessWidget {
  final bool value;
  final VoidCallback onChanged;

  const GlassCheckbox({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF30D158) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: value ? Colors.transparent : Colors.white.withOpacity(0.3), width: 2),
          boxShadow: value ? [BoxShadow(color: const Color(0xFF30D158).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 2))] : [],
        ),
        child: value ? const Icon(Icons.check, size: 20, color: Colors.black) : null,
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const GlassIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: GestureDetector(
        onTap: onTap,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Icon(icon, size: 22, color: Colors.white.withOpacity(0.85)),
          ),
        ),
      ),
    );
  }
}

class GlassToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GlassToggle({super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.16) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: isSelected ? Colors.white.withOpacity(0.24) : Colors.white.withOpacity(0.05)),
            ),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(color: Colors.white.withOpacity(isSelected ? 1.0 : 0.5), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
          ),
        ),
      ),
    );
  }
}

class EmojiBox extends StatelessWidget {
  final String emoji;
  final double size;
  const EmojiBox({super.key, required this.emoji, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

class WeekDayMarker extends StatelessWidget {
  final DateTime date;
  final bool isDone;
  final VoidCallback onTap;

  const WeekDayMarker({super.key, required this.date, required this.isDone, required this.onTap});

  String get _weekDayLetter {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( 
      onTap: onTap, 
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFF30D158) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDone ? Colors.transparent : Colors.white.withOpacity(0.1)),
        ),
        child: Center(
          child: Text(_weekDayLetter, style: TextStyle(fontSize: 10, color: isDone ? Colors.black : Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// Pequeno widget para o botão de voltar customizado
class GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const GlassBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: GestureDetector(
        onTap: onTap,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}