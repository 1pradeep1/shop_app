import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _hidePw = true;
  bool _loading = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  // Accepts either an email or a 10 digit phone number.
  String? _validateId(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter your email or phone number';
    if (s.contains('@')) {
      final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(s);
      return ok ? null : "That email doesn't look right";
    }
    return RegExp(r'^\d{10}$').hasMatch(s) ? null : 'Phone number must be 10 digits';
  }

  String? _validatePw(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Enter your password';
    if (s.length < 6) return 'Use at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    // No backend, so we just pretend to talk to one for a moment.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // pushReplacement so the Back button doesn't return to login.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF16161A), Color(0xFF3A1F18)],
          ),
        ),
        child: SafeArea(
          child: Center(
            // Scroll view keeps the form usable with the keyboard open
            // and on short screens; maxWidth keeps it tidy on tablets.
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(offset: Offset(0, 30 * (1 - v)), child: child),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kAccent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.shopping_bag_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 22),
                      const Text('Zenmart',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      const Text('Curated finds, delivered to you.',
                          style: TextStyle(color: Colors.white60, fontSize: 14)),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Welcome back',
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              const Text('Log in to continue shopping',
                                  style: TextStyle(color: Colors.black45)),
                              const SizedBox(height: 22),
                              TextFormField(
                                controller: _idCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateId,
                                decoration: const InputDecoration(
                                  hintText: 'Email or phone number',
                                  fillColor: kSoft,
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _pwCtrl,
                                obscureText: _hidePw,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                validator: _validatePw,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  fillColor: kSoft,
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _hidePw = !_hidePw),
                                    icon: Icon(_hidePw
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: kAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: _loading ? null : _submit,
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2.5, color: Colors.white),
                                        )
                                      : const Text('Log in',
                                          style: TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Center(
                                child: Text(
                                  'Demo: any valid email/phone + 6+ char password',
                                  style: TextStyle(fontSize: 11.5, color: Colors.black38),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
