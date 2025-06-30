import 'package:flutter/material.dart';
import 'name_input_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if ((username == 'PERIOHT' && password == 'HealthPartnersMMU') ||
        (username == 'PERIOHTTL' && password == 'MMUOHTTLDEAN')) {
      final isSuperuser = username == 'PERIOHTTL';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NameInputScreen(isSuperuser: isSuperuser),
        ),
      );
    } else {
      setState(() {
        _errorText = 'Invalid credentials';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_errorText!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
