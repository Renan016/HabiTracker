import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/github_service.dart'; // Importe o serviço
import '../widgets/glass_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final Function(User) onUserUpdated;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onUserUpdated,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _githubController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _githubController.text = widget.user.githubUsername ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    final String githubUser = _githubController.text.trim();
    String? avatarUrl = widget.user.githubAvatarUrl;

    // Se o usuário mudou o GitHub ou não tem avatar, busca na API
    if (githubUser.isNotEmpty && (githubUser != widget.user.githubUsername || avatarUrl == null)) {
      avatarUrl = await GitHubService.fetchAvatarUrl(githubUser);
    } else if (githubUser.isEmpty) {
      avatarUrl = null; // Remove avatar se limpar o campo
    }

    final updatedUser = widget.user.copyWith(
      githubUsername: githubUser.isEmpty ? null : githubUser,
      githubAvatarUrl: avatarUrl,
    );

    await DatabaseHelper.instance.updateUser(updatedUser);
    
    widget.onUserUpdated(updatedUser);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget da Imagem de Perfil
    Widget profileImage;
    if (widget.user.githubAvatarUrl != null) {
      profileImage = ClipOval(
        child: Image.network(
          widget.user.githubAvatarUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50, color: Colors.white),
        ),
      );
    } else {
      profileImage = const Icon(Icons.person, size: 50, color: Colors.white);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0E),
      body: Stack(
        children: [
          Positioned(
             top: -50,
             right: -50,
             child: ImageFiltered(
               imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
               child: Container(
                 width: 250,
                 height: 250,
                 decoration: BoxDecoration(
                   color: Colors.blueAccent.withOpacity(0.15),
                 ),
               ),
             ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GlassBackButton(onTap: () => Navigator.pop(context)),
                      const Spacer(),
                      const Text("User Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Spacer(),
                      const SizedBox(width: 42),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Avatar Container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF30D158), width: 2),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: profileImage,
                ),
                const SizedBox(height: 16),
                Text(widget.user.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(widget.user.email, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GlassHabitContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.code, color: Colors.white),
                            SizedBox(width: 10),
                            Text("GitHub Integration", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Conecte seu GitHub para ver suas contribuições e foto de perfil.",
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _githubController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixText: "@",
                            hintText: "username",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _isLoading ? null : _saveProfile,
                          child: Container(
                            height: 45,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text("Salvar Conexão", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GestureDetector(
                    onTap: widget.onLogout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFC3D39).withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xFFFC3D39).withOpacity(0.1),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Color(0xFFFC3D39)),
                          SizedBox(width: 10),
                          Text("Sair da Conta", style: TextStyle(color: Color(0xFFFC3D39), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}