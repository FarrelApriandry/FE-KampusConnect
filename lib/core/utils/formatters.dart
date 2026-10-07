import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Format Rupiah tanpa desimal: 25000 → "Rp25.000"
String formatIdr(num value) {
  final f = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return f.format(value);
}

/// Format tanggal relatif singkat.
String formatRelativeTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return 'baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes} mnt lalu';
  if (diff.inDays < 1) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  return DateFormat('d MMM yyyy', 'id_ID').format(time);
}

/// Normalisasi string API datetime (ISO8601) menjadi [DateTime] lokal.
DateTime? parseApiDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

/// Buat inisial dari nama, contoh: "Budi Santoso" → "BS".
String initialsOf(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first)
      .toUpperCase();
}