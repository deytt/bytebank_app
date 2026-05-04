import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../widgets/custom_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isLogin) {
      context.read<AuthBloc>().add(AuthSignInRequested(email: email, password: password));
    } else {
      context.read<AuthBloc>().add(AuthSignUpRequested(email: email, password: password));
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              final t = AppTheme.of(dialogContext);
              return AlertDialog(
                title: const Text('Fechar aplicativo'),
                content: const Text('Deseja realmente fechar o aplicativo?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(backgroundColor: t.error),
                    child: const Text('Fechar'),
                  ),
                ],
              );
            },
          );
          if (confirm == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          final t = AppTheme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: t.error),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final t = AppTheme.of(context);

        return Scaffold(
          backgroundColor: t.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  SlideTransition(
                    position: _logoSlideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/images/logo_splash.svg',
                            width: 120,
                            height: 60,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            _isLogin ? 'Bem-vindo de volta' : 'Crie sua conta',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLogin
                                ? 'Entre para gerenciar suas finanças'
                                : 'Comece a controlar suas finanças',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _formSlideAnimation,
                    child: FadeTransition(
                      opacity: _formFadeAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomInput(
                              label: 'E-mail',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'E-mail obrigatório';
                                if (!value.contains('@')) return 'E-mail inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Senha',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: t.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Senha obrigatória';
                                if (!_isLogin && value.length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: t.white,
                                        ),
                                      )
                                    : Text(_isLogin ? 'Entrar' : 'Criar conta'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'ou',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: isLoading ? null : _signInWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: t.textSecondary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const _GoogleIcon(),
                                label: Text(
                                  'Continuar com Google',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: _isLogin
                                          ? 'Não tem uma conta? '
                                          : 'Já tem uma conta? ',
                                    ),
                                    TextSpan(
                                      text: _isLogin ? 'Criar conta' : 'Entrar',
                                      style: TextStyle(
                                        color: t.primaryLight,
                                        fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
          ),
        );
      },
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.white,
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            color: t.googleBlue,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
