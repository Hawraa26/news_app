import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final TextEditingController _emailController =
  TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final user = _authService.currentUser;

    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error = await _authService.resetPassword(
      email: email,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      _showMessage(error);
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        final colorScheme =
            Theme.of(context).colorScheme;

        return AlertDialog(
          icon: Icon(
            Icons.mark_email_read_outlined,
            size: 50,
            color: colorScheme.primary,
          ),
          title: const Text(
            'تم إرسال الرابط',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'تم إرسال رابط تغيير كلمة المرور إلى بريدك الإلكتروني.\n\n'
                'افتحي البريد واضغطي على الرابط لتعيين كلمة مرور جديدة.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'حسنًا',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تغيير كلمة المرور',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    // أيقونة الصفحة
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius:
                          BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary
                                  .withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 55,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'تغيير كلمة المرور',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'سنرسل لك رابطًا عبر البريد الإلكتروني '
                          'لتعيين كلمة مرور جديدة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color:
                        colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // البريد الإلكتروني
                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.done,
                      autofillHints: const [
                        AutofillHints.email,
                      ],
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _sendResetEmail();
                        }
                      },
                      decoration: InputDecoration(
                        labelText:
                        'البريد الإلكتروني',
                        hintText:
                        'example@gmail.com',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                        filled: true,
                        fillColor: colorScheme
                            .surfaceContainerHighest,
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
                            color:
                            colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'تأكدي من إدخال البريد المرتبط بحسابك.',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر الإرسال
                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _isLoading
                            ? null
                            : _sendResetEmail,
                        icon: _isLoading
                            ? const SizedBox(
                          width: 21,
                          height: 21,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(
                          Icons.send_rounded,
                        ),
                        label: Text(
                          _isLoading
                              ? 'جاري الإرسال...'
                              : 'إرسال رابط التغيير',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ملاحظة
                    Container(
                      padding:
                      const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primary
                            .withValues(
                          alpha: 0.08,
                        ),
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color:
                            colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'بعد إرسال الرابط، افتحي بريدك الإلكتروني '
                                  'واتبعي التعليمات لتعيين كلمة مرور جديدة.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: colorScheme
                                    .onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

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
    );
  }
}