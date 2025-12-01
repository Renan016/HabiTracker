import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para Clipboard
import 'package:path/path.dart'; // Necessário para join
import 'package:sqflite/sqflite.dart'; // Necessário para getDatabasesPath
import '../widgets/glass_widgets.dart';
import '../services/database_helper.dart';
import '../models/user_model.dart';

class AuthScreen extends StatefulWidget {
  final Function(User) onLoginSuccess; 
  
  const AuthScreen({required this.onLoginSuccess, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; 
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  void _submit() async {
    setState(() => _errorMessage = null);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Preencha email e senha.");
      return;
    }

    if (!_isLogin && username.isEmpty) {
      setState(() => _errorMessage = "Preencha o nome de usuário.");
      return;
    }

    if (_isLogin) {
      final user = await DatabaseHelper.instance.loginUser(email, password);
      if (user != null) {
        widget.onLoginSuccess(user);
      } else {
        setState(() => _errorMessage = "Email ou senha incorretos.");
      }
    } else {
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
        password: password,
        githubUsername: null,
        githubAvatarUrl: null,
      );

      final success = await DatabaseHelper.instance.registerUser(newUser);
      if (success) {
        widget.onLoginSuccess(newUser);
      } else {
        setState(() => _errorMessage = "Este email já está cadastrado.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0E),
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withOpacity(0.15),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: GlassHabitContainer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? "Bem-vindo de volta" : "Criar Conta",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 30),
                    
                    if (!_isLogin) ...[
                      _CustomTextField(controller: _usernameController, hint: "Nome de Usuário", icon: Icons.person),
                      const SizedBox(height: 16),
                    ],

                    _CustomTextField(controller: _emailController, hint: "Email", icon: Icons.email),
                    const SizedBox(height: 16),
                    _CustomTextField(controller: _passwordController, hint: "Senha", icon: Icons.lock, isPassword: true),
                    
                    const SizedBox(height: 20),
                    
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFFFC3D39), fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF30D158),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isLogin ? "Entrar" : "Cadastrar",
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isLogin ? "Não tem conta? Cadastre-se" : "Já tem conta? Faça Login",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),

                    // --- BOTÃO DE DEBUG (ADICIONADO) ---
                    const SizedBox(height: 40),
                    TextButton.icon(
                      icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                      label: const Text("DEBUG: Copiar Caminho do DB", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      onPressed: () async {
                        // Obtém o caminho do diretório de bancos de dados
                        final dbPath = await getDatabasesPath();
                        // Combina com o nome atual do seu banco (habitracker_v4.db)
                        final path = join(dbPath, 'habitracker_v4.db');
                        
                        // Copia para a área de transferência
                        await Clipboard.setData(ClipboardData(text: path));
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Caminho copiado! Vá no Finder e pressione Cmd+Shift+G."),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                    ),
                    // -----------------------------------
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;

  const _CustomTextField({required this.controller, required this.hint, required this.icon, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF30D158))),
      ),
    );
  }
}