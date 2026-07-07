import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/auth_controller.dart';
import '../../Utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final auth = context.read<AuthController>();
    final ok = await auth.resetPassword(_emailCtrl.text.trim());
    if (!mounted) return;

    setState(() {
      _loading = false;
      _sent = ok;
    });

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Could not send reset email.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : _formView(),
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Illustration / Icon ──────────────────
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 56,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Heading ──────────────────────────────
        Text('Forgot Password?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                )),
        const SizedBox(height: 8),
        Text(
          'Enter the email address linked to your account and we\'ll send you a link to reset your password.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textSecondaryColor, height: 1.5),
        ),
        const SizedBox(height: 32),

        // ── Email Form ───────────────────────────
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendReset(),
            decoration: const InputDecoration(
              labelText: 'Email Address',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter your email';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 28),

        // ── Send Button ──────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _sendReset,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('Send Reset Link',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),

        // ── Back to Login ────────────────────────
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            label: const Text('Back to Login'),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Success state shown after email is sent
// ──────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              size: 60, color: AppTheme.successColor),
        ),
        const SizedBox(height: 28),
        Text('Check Your Email',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textSecondaryColor, height: 1.6),
            children: [
              const TextSpan(
                  text: 'We\'ve sent a password reset link to\n'),
              TextSpan(
                text: email,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor),
              ),
              const TextSpan(
                  text:
                      '\n\nCheck your inbox (and spam folder) and follow the link to reset your password.'),
            ],
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Login',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
