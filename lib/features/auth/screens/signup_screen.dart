import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _loading       = false;
  bool _googleLoading = false;
  bool _obscure       = true;
  bool _obscureConfirm= true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signUp(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.hypot.hypot_news://login-callback',
      );
    } on AuthException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      if (mounted) setState(() { _googleLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s8),

              // ── Back button ───────────────────────────────────────────
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.sm_,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.arrow_back,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s6),

              // ── Header ────────────────────────────────────────────────
              Text('Create account',
                style: AppText.h2.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s1),
              Text('Start your daily briefing today',
                style: AppText.body.copyWith(color: AppColors.textMuted)),

              const SizedBox(height: AppSpacing.s8),

              // ── Google button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _googleLoading ? null : _signInWithGoogle,
                  child: _googleLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.teal600,
                        ))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.blue50,
                              borderRadius: AppRadius.sm_,
                            ),
                            alignment: Alignment.center,
                            child: const Text('G',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.blue600,
                              )),
                          ),
                          const SizedBox(width: AppSpacing.s3),
                          Text('Continue with Google',
                            style: AppText.bodySm.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            )),
                        ],
                      ),
                ),
              ),

              const SizedBox(height: AppSpacing.s6),

              // ── Divider ───────────────────────────────────────────────
              Row(children: [
                const Expanded(
                  child: Divider(color: AppColors.border, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s3),
                  child: Text('or',
                    style: AppText.caption.copyWith(
                      color: AppColors.textHint)),
                ),
                const Expanded(
                  child: Divider(color: AppColors.border, thickness: 1)),
              ]),

              const SizedBox(height: AppSpacing.s6),

              // ── Email ─────────────────────────────────────────────────
              Text('Email', style: AppText.label),
              const SizedBox(height: AppSpacing.s2),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: AppText.body.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                ),
              ),

              const SizedBox(height: AppSpacing.s5),

              // ── Password ──────────────────────────────────────────────
              Text('Password', style: AppText.label),
              const SizedBox(height: AppSpacing.s2),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                style: AppText.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Min. 6 characters',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s5),

              // ── Confirm password ──────────────────────────────────────
              Text('Confirm password', style: AppText.label),
              const SizedBox(height: AppSpacing.s2),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                style: AppText.body.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Repeat your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.s3),

              // ── Error ─────────────────────────────────────────────────
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.s3),
                  decoration: BoxDecoration(
                    color: AppColors.coral50,
                    borderRadius: AppRadius.sm_,
                    border: Border.all(color: AppColors.coral100),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                      size: 16, color: AppColors.coral600),
                    const SizedBox(width: AppSpacing.s2),
                    Expanded(
                      child: Text(_error!,
                        style: AppText.bodySm.copyWith(
                          color: AppColors.coral600))),
                  ]),
                ),
                const SizedBox(height: AppSpacing.s3),
              ],

              const SizedBox(height: AppSpacing.s5),

              // ── Create account button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signUp,
                  child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ))
                    : const Text('Create account'),
                ),
              ),

              const SizedBox(height: AppSpacing.s5),

              // ── Sign in link ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ',
                    style: AppText.bodySm.copyWith(
                      color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text('Sign in',
                      style: AppText.bodySm.copyWith(
                        color: AppColors.teal600,
                        fontWeight: FontWeight.w600,
                      )),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.s10),
            ],
          ),
        ),
      ),
    );
  }
}
