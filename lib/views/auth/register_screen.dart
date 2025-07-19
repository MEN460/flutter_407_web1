import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  // Real-time validation states
  bool _emailValid = false;
  bool _passwordValid = false;
  bool _passwordsMatch = false;
  bool _nameValid = false;

  @override
  void initState() {
    super.initState();
    // Add real-time validation listeners
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePasswordMatch);
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validatePasswordMatch);
    _nameController.removeListener(_validateName);

    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final isValid = Validators.email(_emailController.text) == null;
    if (_emailValid != isValid) {
      setState(() => _emailValid = isValid);
    }
  }

  void _validatePassword() {
    final isValid = Validators.password(_passwordController.text) == null;
    if (_passwordValid != isValid) {
      setState(() => _passwordValid = isValid);
    }
    // Re-validate password match when password changes
    _validatePasswordMatch();
  }

  void _validatePasswordMatch() {
    final matches =
        _passwordController.text == _confirmPasswordController.text &&
        _confirmPasswordController.text.isNotEmpty;
    if (_passwordsMatch != matches) {
      setState(() => _passwordsMatch = matches);
    }
  }

  void _validateName() {
    final isValid = _nameController.text.trim().isNotEmpty;
    if (_nameValid != isValid) {
      setState(() => _nameValid = isValid);
    }
  }

  bool get _isFormValid =>
      _emailValid && _passwordValid && _passwordsMatch && _nameValid;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_passwordsMatch) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    try {
      // Use the AuthNotifier instead of direct service call
      final success = await ref
          .read(authStateProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _nameController.text.trim(),
          );

      if (success && mounted) {
        // Don't manually navigate - let the router handle redirection
        // based on authentication state changes
        _showSuccessSnackBar(
          'Registration successful! Welcome to Kenya Airways',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Registration failed: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for loading and error handling
    final authState = ref.watch(authStateProvider);
    final isLoading = ref.watch(isAuthLoadingProvider);
    final authError = ref.watch(authErrorProvider);

    // Show error if auth fails
    if (authError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(authError);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                const SizedBox(height: 20),
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Join Kenya Airways',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your account to start your journey',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Form fields with real-time validation feedback
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    suffixIcon: _nameValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Full name required'
                      : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email),
                    suffixIcon: _emailValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: _passwordValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    border: const OutlineInputBorder(),
                    helperText:
                        'Minimum 8 characters with uppercase, lowercase, and number',
                    helperMaxLines: 2,
                  ),
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: _passwordsMatch
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : _confirmPasswordController.text.isNotEmpty
                        ? const Icon(Icons.cancel, color: Colors.red)
                        : null,
                    border: const OutlineInputBorder(),
                    errorText:
                        _confirmPasswordController.text.isNotEmpty &&
                            !_passwordsMatch
                        ? 'Passwords do not match'
                        : null,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return Validators.password(value);
                  },
                ),
                const SizedBox(height: 32),

                // Register button with loading state
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person_add),
                    label: Text(
                      isLoading ? 'Creating Account...' : 'Create Account',
                      style: const TextStyle(fontSize: 16),
                    ),
                    onPressed: (isLoading || !_isFormValid) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login redirect with consistent navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () => context.go('/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),

                // Terms and conditions
                const SizedBox(height: 16),
                const Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
