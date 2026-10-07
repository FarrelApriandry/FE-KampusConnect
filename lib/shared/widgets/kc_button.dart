import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tombol aksi utama KampusConnect.
enum KCButtonVariant { primary, outline, danger, soft }

class KCButton extends StatelessWidget {
  const KCButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = KCButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final KCButtonVariant variant;
  final bool loading;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final Widget child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final Widget button = switch (variant) {
      KCButtonVariant.primary => ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      KCButtonVariant.outline => OutlinedButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      KCButtonVariant.danger => ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: child,
        ),
      KCButtonVariant.soft => ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
          ),
          child: child,
        ),
    };

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}