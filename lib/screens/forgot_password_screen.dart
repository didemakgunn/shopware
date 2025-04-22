import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopware/helpers/snackbar_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showShortSnack(context, 'Lütfen e-posta adresinizi girin');

      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      showShortSnack(context, 'Şifre sıfırlama bağlantısı gönderildi ✅');

      Navigator.pop(context);
    } catch (e) {
      print('Şifre sıfırlama hatası: $e');
      showShortSnack(context, 'Bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Şifremi Unuttum')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                'Şifre sıfırlama bağlantısı göndermek için e-posta adresinizi girin.'),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendResetEmail,
              child: Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}
