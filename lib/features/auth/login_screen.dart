import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printmax_app/features/auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  static const _accent = Color(0xFFEF4444); // red-500
  static const _accentDark = Color(0xFFDC2626); // red-600

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (mounted) {
      final msg = auth.error ?? 'Đăng nhập thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    final radius = BorderRadius.circular(28);
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: _accent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _LoginCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'PRINTMAX',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Đăng Nhập Vào Hệ Thống Quản Lý',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _usernameCtrl,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                        decoration: _inputDecoration(
                          label: 'Tài khoản người dùng',
                          icon: Icons.person_outline,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nhập tài khoản'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: _inputDecoration(
                          label: 'Mật khẩu',
                          icon: Icons.lock_outline,
                        ).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.grey[600]),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Nhập mật khẩu'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Bạn chưa có tài khoản?', style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đăng ký tài khoản: tính năng sẽ sớm có.')),
                              );
                            },
                            child: const Text(
                              'Đăng ký tài khoản',
                              style: TextStyle(
                                color: _accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _GradientButton(
                        text: 'Đăng nhập',
                        loading: auth.isLoading,
                        onPressed: auth.isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          'Trần Quang Sơn - 0975142793',
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 6),
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

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // 10% black
            offset: Offset(0, 10),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: child,
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.text, required this.onPressed, this.loading = false});
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  static const _gradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF3B3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final child = SizedBox(
      height: 48,
      child: Center(
        child: loading
            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled ? _gradient : const LinearGradient(colors: [Colors.grey, Colors.grey]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: enabled
            ? const [
                BoxShadow(color: Color(0x33FF3B3B), blurRadius: 18, offset: Offset(0, 8)),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: enabled ? onPressed : null,
          child: child,
        ),
      ),
    );
  }
}
