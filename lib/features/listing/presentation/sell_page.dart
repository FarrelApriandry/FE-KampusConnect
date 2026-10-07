import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import 'listing_providers.dart';

/// Sell — form buat listing baru (FR-04: posting barang/jasa).
/// Foto: placeholder URL bebas diisi; upload file belum di MVP.
class SellPage extends ConsumerStatefulWidget {
  const SellPage({super.key});

  @override
  ConsumerState<SellPage> createState() => _SellPageState();
}

class _SellPageState extends ConsumerState<SellPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _location = TextEditingController();

  String _type = 'PRODUCT';
  String? _categoryId;
  String _condition = 'USED_GOOD';

  bool _submitting = false;

  static const _conditions = [
    ('USED_LIKE_NEW', 'Seperti baru'),
    ('USED_GOOD', 'Bekas · baik'),
    ('USED_FAIR', 'Bekas · layak pakai'),
    ('NEW', 'Baru'),
    ('FOR_PARTS', 'Spare part'),
  ];

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _price.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final listing = await createListing(
        ref,
        title: _title.text.trim(),
        price: num.parse(_price.text.trim()),
        description:
            _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        categoryId: _categoryId,
        type: _type,
        condition: _type == 'PRODUCT' ? _condition : null,
        meetupLocation:
            _location.text.trim().isEmpty ? null : _location.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing berhasil diposting')),
      );
      context.push('/listings/${listing.id}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cats = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Jual')),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Posting barang atau jasamu',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Isi detailnya, mahasiswa lain langsung bisa lihat.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Tipe: barang / jasa.
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'PRODUCT', label: Text('Barang')),
                  ButtonSegment(value: 'SERVICE', label: Text('Jasa')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Contoh: Modul Praktikum Jaringan',
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.length < 3) return 'Minimal 3 karakter';
                  if (t.length > 120) return 'Maksimal 120 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Kategori.
              cats.maybeWhen(
                data: (list) => DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                  ),
                  items: [
                    for (final c in list)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) =>
                      v == null ? 'Pilih kategori dulu' : null,
                ),
                orElse: () => const LinearProgressIndicator(minHeight: 2),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp)',
                  hintText: '45000',
                  prefixText: 'Rp ',
                ),
                validator: (v) {
                  final n = num.tryParse((v ?? '').trim());
                  if (n == null) return 'Harga harus angka';
                  if (n < 0) return 'Harga tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              if (_type == 'PRODUCT') ...[
                DropdownButtonFormField<String>(
                  initialValue: _condition,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi',
                  ),
                  items: [
                    for (final (value, label) in _conditions)
                      DropdownMenuItem(value: value, child: Text(label)),
                  ],
                  onChanged: (v) =>
                      setState(() => _condition = v ?? 'USED_GOOD'),
                ),
                const SizedBox(height: 14),
              ],

              TextFormField(
                controller: _location,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Titik temu (opsional)',
                  hintText: 'Contoh: Gedung C Kampus Untidar',
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _desc,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  hintText: 'Kondisi barang, alasan jual, dll.',
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(strokeWidth: 2.2),
                      )
                    : const Icon(Icons.storefront_rounded),
                label: Text(_submitting
                    ? 'Memposting…'
                    : 'Posting Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
