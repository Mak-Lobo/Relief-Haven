import 'package:flutter/material.dart';

class DonationHeader extends StatelessWidget {
  const DonationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relief Haven Active Campaign',
          style: textTheme.labelSmall?.copyWith(
            color: colors.onPrimary.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Help families affected by the floods.',
          style: textTheme.titleSmall?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Your donation will go a long way in assisting all displaced people finding some relief in these times of need.\nPlease note that this is completely voluntary and you can choose to donate any amount you wish.',
          style: textTheme.labelSmall?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
