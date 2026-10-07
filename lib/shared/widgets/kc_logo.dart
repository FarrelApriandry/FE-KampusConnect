import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Logo KampusConnect — mark persegi rounded + wordmark.
class KCLogo extends StatelessWidget {
  const KCLogo({super.key, this.size = 48, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: AppColors.onPrimary,
            size: size * 0.56,
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kampus',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
              ),
              Text(
                'Connect',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}