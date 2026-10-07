import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/auth_scaffold.dart';
import '../../../shared/widgets/kc_button.dart';
import '../../../shared/widgets/kc_text_field.dart';
import 'auth_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _studentId = TextEditingController();
  final _faculty = TextEditingController();
  final _major = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _submitting = false;

  static const _campusDomains = [
    '@untidar.ac.id',
    '@students.untidar.ac.id',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _studentId.dispose();
    _faculty.dispose();
    _major.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    FocusScope.of(context).unfocus();
    try {
      await ref.read(authControllerProvider.notifier).register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            studentId: _studentId.text.trim().isEmpty
                ? null
                : _studentId.text.trim(),
            faculty:
                _faculty.text.trim().isEmpty ? null : _faculty.text.trim(),
            major: _major.text.trim().isEmpty ? null : _major.text.trim(),
            academicYear: null,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Buat akun baru',
      subtitle: 'Gunakan email kampusmu agar akun otomatis terverifikasi.',
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KCTextField(
                controller: _name,
                label: 'Nama lengkap',
                hint: 'Contoh: Budi Santoso',
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Nama wajib diisi';
                  if (value.length < 2) return 'Nama minimal 2 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              KCTextField(
                controller: _email,
                label: 'Email kampus',
                hint: 'nama@students.untidar.ac.id',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Email wajib diisi';
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  final lower = value.toLowerCase();
                  if (!_campusDomains.any(lower.endsWith)) {
                    return 'Gunakan email @untidar.ac.id / @students.untidar.ac.id';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const _CampusEmailNote(),
              const SizedBox(height: 16),
              KCTextField(
                controller: _studentId,
                label: 'NIM (opsional)',
                hint: 'Contoh: 21.11.4321',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: KCTextField(
                      controller: _faculty,
                      label: 'Fakultas (opsional)',
                      hint: 'Contoh: Teknik',
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KCTextField(
                      controller: _major,
                      label: 'Jurusan (opsional)',
                      hint: 'Contoh: Informatika',
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              KCTextField(
                controller: _password,
                label: 'Password',
                hint: 'Minimal 6 karakter',
                obscure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) {
                  final value = v ?? '';
                  if (value.isEmpty) return 'Password wajib diisi';
                  if (value.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              KCTextField(
                controller: _confirmPassword,
                label: 'Konfirmasi password',
                obscure: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) =>
                    v != _password.text ? 'Password tidak sama' : null,
              ),
              const SizedBox(height: 24),
              KCButton(
                label: 'Daftar',
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  TextButton(
                    onPressed: _submitting ? null : () => context.go('/login'),
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _CampusEmailNote extends StatelessWidget {
  const _CampusEmailNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Domain yang diizinkan: @untidar.ac.id dan @students.untidar.ac.id',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}