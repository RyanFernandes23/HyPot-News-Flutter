import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading       = false;
  bool _googleLoading = false;
  bool _obscure       = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s16),

              // ── Brand header ──────────────────────────────────────────
              _BrandHeader(),

              const SizedBox(height: AppSpacing.s12),

              // ── Google button ─────────────────────────────────────────
              _GoogleButton(
                loading: _googleLoading,
                onTap: _signInWithGoogle,
              ),

              const SizedBox(height: AppSpacing.s6),

              // ── Divider ───────────────────────────────────────────────
              _OrDivider(),

              const SizedBox(height: AppSpacing.s6),

              // ── Email field ───────────────────────────────────────────
              _FieldLabel('Email'),
              const SizedBox(height: AppSpacing.s2),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: AppText.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'you@example.com',
                ),
              ),

              const SizedBox(height: AppSpacing.s5),

              // ── Password field ────────────────────────────────────────
              _FieldLabel('Password'),
              const SizedBox(height: AppSpacing.s2),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                style: AppText.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '••••••••',
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

              const SizedBox(height: AppSpacing.s3),

              // ── Error box ─────────────────────────────────────────────
              if (_error != null) ...[
                _ErrorBox(message: _error!),
                const SizedBox(height: AppSpacing.s3),
              ],

              const SizedBox(height: AppSpacing.s5),

              // ── Sign in button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ))
                    : const Text('Sign in'),
                ),
              ),

              const SizedBox(height: AppSpacing.s5),

              // ── Sign up link ──────────────────────────────────────────
              _SignupLink(),

              const SizedBox(height: AppSpacing.s10),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sub-widgets — each piece of the screen is its own widget
// ═══════════════════════════════════════════════════════════════════════════

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Teal accent dot + app name
        Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppColors.teal600,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.s2),
            Text('HyPot News',
              style: AppText.h1.copyWith(
                color: AppColors.teal600,
              )),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        Text(
          'Your daily briefing, hands-free.',
          style: AppText.body.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _GoogleButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: loading ? null : onTap,
        child: loading
          ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.teal600,
              ))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google G
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
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
          child: Text('or',
            style: AppText.caption.copyWith(
              color: AppColors.textHint,
            )),
        ),
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppText.label);
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.coral50,
        borderRadius: AppRadius.sm_,
        border: Border.all(color: AppColors.coral100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
            size: 16,
            color: AppColors.coral600,
          ),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(message,
              style: AppText.bodySm.copyWith(
                color: AppColors.coral600,
              )),
          ),
        ],
      ),
    );
  }
}

class _SignupLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ",
          style: AppText.bodySm.copyWith(
            color: AppColors.textMuted,
          )),
        GestureDetector(
          onTap: () => context.push('/signup'),
          child: Text('Sign up',
            style: AppText.bodySm.copyWith(
              color: AppColors.teal600,
              fontWeight: FontWeight.w600,
            )),
        ),
      ],
    );
  }
}
