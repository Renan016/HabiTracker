import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/github_service.dart'; // Importe o serviço
import '../widgets/glass_widgets.dart';
import 'auth_screen.dart';
import 'add_habit_screen.dart';
import 'profile_screen.dart'; // Importe a tela de perfil

enum ViewMode { day, weekly, overall }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ViewMode selected = ViewMode.day;
  User? _currentUser;
  List<Habit> _habits = [];
  bool _isLoading = false;

  void _onLoginSuccess(User user) async {
    setState(() {
      _currentUser = user;
      _isLoading = true;
    });
    await _refreshHabits();
    setState(() => _isLoading = false);
  }

  void _logout() {
    setState(() {
      _currentUser = null;
      _habits = [];
    });
  }

  // Atualiza o usuário na memória quando volta da tela de perfil
  void _updateUser(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
    _refreshHabits(); // Recarrega hábitos (incluindo o do GitHub se foi adicionado)
  }

  Future<void> _refreshHabits() async {
    if (_currentUser != null) {
      // 1. Busca hábitos normais do SQLite
      List<Habit> data = await DatabaseHelper.instance.readHabits(_currentUser!.id);

      // 2. Busca dados do GitHub se o usuário tiver configurado
      if (_currentUser!.githubUsername != null && _currentUser!.githubUsername!.isNotEmpty) {
        try {
          final githubDates = await GitHubService.fetchContributions(_currentUser!.githubUsername!);
          
          // Cria um hábito "Virtual" (não salvo no banco habits, apenas visualização)
          final githubHabit = Habit(
            id: 'github_virtual_habit', // ID fixo para identificar
            title: 'GitHub Contributions',
            emoji: '🐙',
            userId: _currentUser!.id,
            completedDays: githubDates,
          );

          // Adiciona no topo da lista
          data.insert(0, githubHabit);
        } catch (e) {
          print("Erro ao carregar GitHub: $e");
        }
      }

      setState(() => _habits = data);
    }
  }

  Future<void> _addHabit(Habit tempHabit) async {
    final habit = Habit(
      id: tempHabit.id,
      title: tempHabit.title,
      emoji: tempHabit.emoji,
      userId: _currentUser!.id, 
      completedDays: tempHabit.completedDays,
    );
    await DatabaseHelper.instance.createHabit(habit);
    _refreshHabits();
  }

  Future<void> _toggleHabitForDate(Habit habit, DateTime date) async {
    // Impede marcar manualmente o hábito do GitHub
    if (habit.id == 'github_virtual_habit') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O hábito do GitHub é atualizado automaticamente!")),
      );
      return;
    }

    setState(() => habit.toggleDate(date));
    await DatabaseHelper.instance.updateHabit(habit);
  }

  Future<void> _deleteHabit(String id) async {
    await DatabaseHelper.instance.deleteHabit(id);
    _refreshHabits();
  }

  void _showDeleteConfirmationDialog(Habit habit) {
    // Impede deletar o hábito do GitHub
    if (habit.id == 'github_virtual_habit') return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GlassConfirmationDialog(
          title: 'Excluir Hábito?',
          content: 'Tem certeza que deseja excluir o hábito "${habit.title}"?',
          confirmText: 'Excluir',
          cancelText: 'Cancelar',
          onConfirm: () {
            _deleteHabit(habit.id);
            Navigator.of(context).pop(); 
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return AuthScreen(onLoginSuccess: _onLoginSuccess);
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF0B0B0E), body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.1))),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassIconButton(
                        icon: Icons.add,
                        onTap: () async {
                          final newHabit = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddHabitScreen()));
                          if (newHabit != null && newHabit is Habit) {
                            _addHabit(newHabit);
                          }
                        },
                      ),
                      Column(
                        children: [
                          const Text("HabiTracker", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                          Text("Olá, ${_currentUser!.username}", style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                        ],
                      ),
                      
                      GlassIconButton(
                        icon: Icons.person, 
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProfileScreen(
                              user: _currentUser!, 
                              onUserUpdated: _updateUser,
                              onLogout: _logout,
                            )),
                          );
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassToggle(label: 'Day', isSelected: selected == ViewMode.day, onTap: () => setState(() => selected = ViewMode.day)),
                      GlassToggle(label: 'Weekly', isSelected: selected == ViewMode.weekly, onTap: () => setState(() => selected = ViewMode.weekly)),
                      GlassToggle(label: 'Overall', isSelected: selected == ViewMode.overall, onTap: () => setState(() => selected = ViewMode.overall)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _habits.isEmpty
                      ? const Center(child: Text('Nenhum hábito encontrado.\nAdicione um novo ou conecte o GitHub no perfil!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white54)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildHabitCard(habit),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final viewSpecificWidget = _buildViewSpecificContent(habit);
    Widget content;

    if (selected == ViewMode.day) {
      content = Row(
        children: [
          EmojiBox(emoji: habit.emoji),
          const SizedBox(width: 16),
          Expanded(child: Text(habit.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
          viewSpecificWidget,
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EmojiBox(emoji: habit.emoji),
              const SizedBox(width: 16),
              Expanded(child: Text(habit.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 16),
          viewSpecificWidget,
        ],
      );
    }

    Widget card = GlassHabitContainer(child: content);

    if (selected == ViewMode.day) {
      return GestureDetector(
        onLongPress: () => _showDeleteConfirmationDialog(habit),
        child: card,
      );
    }
    return card;
  }

  Widget _buildViewSpecificContent(Habit habit) {
     switch (selected) {
      case ViewMode.day:
        final today = DateTime.now();
        return GlassCheckbox(value: habit.isCompletedOn(today), onChanged: () => _toggleHabitForDate(habit, today));
      
      case ViewMode.weekly:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final date = DateTime.now().subtract(Duration(days: 6 - index));
            return WeekDayMarker(date: date, isDone: habit.isCompletedOn(date), onTap: () {});
          }),
        );
      
      case ViewMode.overall:
        // AJUSTE: Aumentei para 24 semanas para preencher a tela inteira
        const int weeksToShow = 24; 
        const int totalDays = weeksToShow * 7;

        return Align(
          alignment: Alignment.centerRight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true, 
            child: Row(
              children: List.generate(weeksToShow, (colIndex) {
                // Cada coluna representa uma semana
                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: Column(
                    children: List.generate(7, (rowIndex) {
                      // Calcula o índice do dia (0 a totalDays-1)
                      final int itemIndex = (colIndex * 7) + rowIndex;
                      
                      // Ajuste do cálculo: (totalDays - 1) garante que o último índice seja 0 dias atrás (hoje)
                      final date = DateTime.now().subtract(Duration(days: (totalDays - 1) - itemIndex));
                      final isDone = habit.isCompletedOn(date);
                      
                      return Container(
                        width: 14, 
                        height: 14, 
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isDone 
                              ? const Color(0xFF30D158).withOpacity(0.8) 
                              : Colors.white.withOpacity(0.05), 
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
    }
  }
}