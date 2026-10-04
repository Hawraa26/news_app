import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() =>
      _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _nameController =
  TextEditingController();
  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }
  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    // 1. إنشاء الحساب في Firebase Authentication
    final error = await _authService.signUp(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
      });

      _showMessage(error);
      return;
    }

    // 2. الحصول على المستخدم الذي تم إنشاؤه
    final user = _authService.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
      });

      _showMessage('تم إنشاء الحساب ولكن لم يتم العثور على المستخدم.');
      return;
    }

    // 3. حفظ المستخدم في Firestore
    try {
      await _firestoreService.createUser(
        uid: user.uid,
        name: name,
        email: user.email ?? email,
      );


    } catch (e, stackTrace) {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'تم إنشاء الحساب، لكن حدث خطأ أثناء حفظ البيانات في Firestore.',
      );

      return;
    }

    // 4. إذا وصلنا إلى هنا فهذا يعني أن Authentication
    // و Firestore نجحا معًا


    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // 5. عرض رسالة النجاح
    await _showSuccessDialog();

    if (!mounted) return;

    // 6. الانتقال إلى صفحة تسجيل الدخول
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  Future<void> _showSuccessDialog() async {
    final colorScheme =
        Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          icon: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 55,
            ),
          ),
          title: const Text(
            'تم إنشاء الحساب',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'تم إنشاء حسابك بنجاح.\nيمكنك الآن تسجيل الدخول إلى التطبيق.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          actionsAlignment:
          MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'متابعة',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    if (!email.contains('@') ||
        !email.contains('.')) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    if (password.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';

    if (confirmPassword.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }

    if (confirmPassword !=
        _passwordController.text) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 30,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(colorScheme),

                      const SizedBox(height: 35),

                      _buildNameField(colorScheme),

                      const SizedBox(height: 16),

                      _buildEmailField(colorScheme),

                      const SizedBox(height: 16),

                      _buildPasswordField(
                        colorScheme,
                      ),
                      const SizedBox(height: 16),

                      _buildConfirmPasswordField(
                        colorScheme,
                      ),

                      const SizedBox(height: 28),

                      _buildSignUpButton(),

                      const SizedBox(height: 24),

                      _buildLoginLink(colorScheme),

                      const SizedBox(height: 30),

                      Text(
                        'تطبيق الأخبار',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme
                              .onSurfaceVariant,
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
  Widget _buildNameField(
      ColorScheme colorScheme,
      ) {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      validator: _validateName,
      decoration: InputDecoration(
        labelText: 'الاسم',
        hintText: 'أدخلي اسمك',
        prefixIcon: const Icon(
          Icons.person_outline_rounded,
        ),
        filled: true,
        fillColor:
        colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'يرجى إدخال الاسم';
    }

    if (name.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    return null;
  }
  Widget _buildHeader(
      ColorScheme colorScheme,
      ) {
    return Column(
      children: [
        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius:
            BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary
                    .withValues(
                  alpha: 0.25,
                ),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            size: 55,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          'إنشاء حساب',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'أنشئي حسابك لمتابعة آخر الأخبار',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color:
            colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(
      ColorScheme colorScheme,
      ) {
    return TextFormField(
      controller: _emailController,
      keyboardType:
      TextInputType.emailAddress,
      textInputAction:
      TextInputAction.next,
      autofillHints: const [
        AutofillHints.email,
      ],
      validator: _validateEmail,
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        hintText: 'example@gmail.com',
        prefixIcon: const Icon(
          Icons.email_outlined,
        ),
        filled: true,
        fillColor:
        colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      ColorScheme colorScheme,
      ) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction:
      TextInputAction.next,
      autofillHints: const [
        AutofillHints.newPassword,
      ],
      validator: _validatePassword,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        hintText: '6 أحرف على الأقل',
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword =
              !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          tooltip: _obscurePassword
              ? 'إظهار كلمة المرور'
              : 'إخفاء كلمة المرور',
        ),
        filled: true,
        fillColor:
        colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField(
      ColorScheme colorScheme,
      ) {
    return TextFormField(
      controller:
      _confirmPasswordController,
      obscureText:
      _obscureConfirmPassword,
      textInputAction:
      TextInputAction.done,
      autofillHints: const [
        AutofillHints.newPassword,
      ],
      validator:
      _validateConfirmPassword,
      onFieldSubmitted: (_) {
        if (!_isLoading) {
          _signUp();
        }
      },
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        hintText: 'أعيدي كتابة كلمة المرور',
        prefixIcon: const Icon(
          Icons.lock_reset_rounded,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureConfirmPassword =
              !_obscureConfirmPassword;
            });
          },
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          tooltip:
          _obscureConfirmPassword
              ? 'إظهار كلمة المرور'
              : 'إخفاء كلمة المرور',
        ),
        filled: true,
        fillColor:
        colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      height: 56,
      child: FilledButton.icon(
        onPressed:
        _isLoading ? null : _signUp,
        icon: _isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child:
          CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Icon(
          Icons.person_add_rounded,
        ),
        label: Text(
          _isLoading
              ? 'جاري إنشاء الحساب...'
              : 'إنشاء الحساب',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(
      ColorScheme colorScheme,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            color:
            colorScheme.onSurfaceVariant,
          ),
        ),

        TextButton(
          onPressed: _isLoading
              ? null
              : () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const LoginScreen(),
              ),
            );
          },
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}