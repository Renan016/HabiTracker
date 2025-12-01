import 'dart:convert';

class Habit {
  final String id;
  final String title;
  final String emoji;
  final String userId;
  final Set<DateTime> completedDays;

  Habit({
    required this.id,
    required this.title,
    required this.emoji,
    required this.userId,
    Set<DateTime>? completedDays,
  }) : completedDays = completedDays ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'userId': userId,
      'completedDays': jsonEncode(completedDays.map((e) => e.toIso8601String()).toList()),
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    Set<DateTime> dates = {};
    if (map['completedDays'] != null) {
      try {
        List<dynamic> list = jsonDecode(map['completedDays']);
        dates = list.map((e) => DateTime.parse(e)).toSet();
      } catch (e) {
        print("Erro ao ler datas: $e");
      }
    }

    return Habit(
      id: map['id'],
      title: map['title'],
      emoji: map['emoji'],
      userId: map['userId'],
      completedDays: dates,
    );
  }

  bool isCompletedOn(DateTime date) {
    return completedDays.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  void toggleDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (isCompletedOn(normalizedDate)) {
      completedDays.removeWhere((d) =>
          d.year == normalizedDate.year && d.month == normalizedDate.month && d.day == normalizedDate.day);
    } else {
      completedDays.add(normalizedDate);
    }
  }
}