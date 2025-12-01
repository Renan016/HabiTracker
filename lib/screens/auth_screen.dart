import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/glass_widgets.dart';
import '../services/database_helper.dart';
import '../models/user_model.dart';

class AuthScreen extends StatefulWidget {
  final Function(User) onLoginSuccess; // Retorna o objeto User completo
  
  const AuthScreen({required this.onLoginSuccess, super.key});
  
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // Alterna entre Login e Cadastro
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
      // --- LOGICA DE LOGIN ---
      final user = await DatabaseHelper.instance.loginUser(email, password);
      if (user != null) {
        widget.onLoginSuccess(user);
      } else {
        setState(() => _errorMessage = "Email ou senha incorretos.");
      }
    } else {
      // --- LOGICA DE CADASTRO ---
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
        password: password,
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
          // Fundo Ambiente
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
                    
                    // Campo Nome (Só no cadastro)
                    if (!_isLogin) ...[
                      _CustomTextField(
                        controller: _usernameController,
                        hint: "Nome de Usuário",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Campo Email
                    _CustomTextField(
                      controller: _emailController,
                      hint: "Email",
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),

                    // Campo Senha
                    _CustomTextField(
                      controller: _passwordController,
                      hint: "Senha",
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    
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

                    // Botão Principal
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
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Alternar Modo
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

  const _CustomTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
  });

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