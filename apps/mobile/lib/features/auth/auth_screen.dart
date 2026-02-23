import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../map/map_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Requisitos de contraseña (se evalúan reactivamente vía onChanged → setState)
  bool get _hasLength => _passwordController.text.length >= 8;
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecial => RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_]').hasMatch(_passwordController.text);
  bool get _passwordValid => _hasLength && _hasUpper && _hasNumber && _hasSpecial;
  bool get _passwordsMatch => _passwordController.text == _confirmController.text;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.izkkxdsuvjuuthtcvsvl://login-callback/',
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.izkkxdsuvjuuthtcvsvl://login-callback/',
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (!_isLogin) {
      final nick = _nicknameController.text.trim();
      if (nick.length < 3) {
        _showError('El nickname necesita al menos 3 caracteres');
        return;
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(nick)) {
        _showError('Nickname: solo letras, números y _');
        return;
      }
      if (!_passwordValid) {
        _showError('La contraseña no cumple los requisitos de seguridad');
        return;
      }
      if (!_passwordsMatch) {
        _showError('Las contraseñas no coinciden');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await _supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'name': _nicknameController.text.trim()},
        );
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;
      _nicknameController.clear();
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    bool showEye = false,
    VoidCallback? onEyeTap,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1C1C18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: showEye
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: onEyeTap,
              )
            : null,
      ),
    );
  }

  Widget _requirement(String label, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 14,
          color: met ? const Color(0xFFFF5C00) : Colors.white30,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: met ? Colors.white70 : Colors.white38),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRequirements = !_isLogin && _passwordController.text.isNotEmpty;
    final showConfirmFeedback = !_isLogin && _confirmController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A08),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                'GoBite',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFF5C00),
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Bienvenido de vuelta' : 'Crea tu cuenta',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Nickname — solo en registro
              if (!_isLogin) ...[
                _field(
                  controller: _nicknameController,
                  hint: 'Nickname (ej: foodie_mario)',
                ),
                const SizedBox(height: 12),
              ],

              // Email
              _field(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Contraseña
              _field(
                controller: _passwordController,
                hint: 'Contraseña',
                obscure: _obscurePassword,
                showEye: true,
                onEyeTap: () => setState(() => _obscurePassword = !_obscurePassword),
                onChanged: (_) => setState(() {}),
              ),

              // Requisitos — solo en registro si hay algo escrito
              if (showRequirements) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _requirement('8 caracteres mínimo', _hasLength),
                      const SizedBox(height: 5),
                      _requirement('Una letra mayúscula', _hasUpper),
                      const SizedBox(height: 5),
                      _requirement('Un número', _hasNumber),
                      const SizedBox(height: 5),
                      _requirement('Un carácter especial  (!@#\$...)', _hasSpecial),
                    ],
                  ),
                ),
              ],

              // Confirmar contraseña — solo en registro
              if (!_isLogin) ...[
                const SizedBox(height: 12),
                _field(
                  controller: _confirmController,
                  hint: 'Confirmar contraseña',
                  obscure: _obscureConfirm,
                  showEye: true,
                  onEyeTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  onChanged: (_) => setState(() {}),
                ),
                if (showConfirmFeedback)
                  Padding(
                    padding: const EdgeInsets.only(top: 7, left: 4),
                    child: Row(
                      children: [
                        Icon(
                          _passwordsMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          size: 14,
                          color: _passwordsMatch ? const Color(0xFFFF5C00) : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _passwordsMatch ? 'Las contraseñas coinciden' : 'No coinciden',
                          style: TextStyle(
                            fontSize: 12,
                            color: _passwordsMatch ? Colors.white70 : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              // Botón principal
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C00),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isLogin ? 'Entrar' : 'Crear cuenta',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: _switchMode,
                child: Text(
                  _isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Entra',
                  style: const TextStyle(color: Colors.white60),
                ),
              ),

              const SizedBox(height: 16),
              const Row(children: [
                Expanded(child: Divider(color: Colors.white24)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('o', style: TextStyle(color: Colors.white38)),
                ),
                Expanded(child: Divider(color: Colors.white24)),
              ]),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                label: const Text('Continuar con Google', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithApple,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.apple, color: Colors.white, size: 24),
                label: const Text('Continuar con Apple', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),

              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen()),
                ),
                child: const Text(
                  'Explorar sin cuenta',
                  style: TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
