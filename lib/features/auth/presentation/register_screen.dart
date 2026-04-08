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
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  String _selectedRole = 'apprenant_externe';

  Future<void> _register() async {
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
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
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