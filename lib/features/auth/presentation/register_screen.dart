import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  String _selectedRole = 'apprenant_externe';
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Format email invalide';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 8) return '8 caractères minimum';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Une majuscule requise';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Une minuscule requise';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Un chiffre requis';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return 'Un caractère spécial requis';
    return null;
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();

    if (prenom.isEmpty || nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prénom et nom requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);

    if (emailError != null) {
      setState(() => _emailError = emailError);
      return;
    }
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      return;
    }
    if (password != _confirmPasswordController.text.trim()) {
      setState(() => _confirmPasswordError = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    await ref.read(authProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          role: _selectedRole,
        );

    if (ref.read(authProvider).error == null && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _prenomController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nomController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: const OutlineInputBorder(),
                errorText: _passwordError,
                helperText: '8+ caractères: majuscule, minuscule, chiffre, caractère spécial',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: const OutlineInputBorder(),
                errorText: _confirmPasswordError,
              ),
            ),
            const SizedBox(height: 12),

            // Role selector
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Type de compte',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'apprenant_externe',
                  child: Text('Apprenant externe'),
                ),
                DropdownMenuItem(
                  value: 'apprenant_loge',
                  child: Text('Apprenant logé (prioritaire)'),
                ),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 8),

            if (state.error != null)
              Text(state.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: state.isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("S'inscrire",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}