import 'package:flutter/material.dart';

import 'package:relief_haven_mobile/common_widgets/custom_input_fields.dart';
import 'package:relief_haven_mobile/common_widgets/custom_radio_image.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          "Donation",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onPrimary,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Card(
                  color: Theme.of(context).colorScheme.surfaceTint,
                  child: const SizedBox(
                    width: 250,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: _DonationHeader(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              MenuItemButton(
                leadingIcon: const Icon(Icons.edit_document),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onSurface,
                  ),
                  animationDuration: const Duration(milliseconds: 200),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: () {},
                child: const Text("Donate Now"),
              ),
              const _DonationForm(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

enum PaymentOption { mpesa, airtel }

class _DonationHeader extends StatelessWidget {
  const _DonationHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Relief Haven Active Campaign",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.onPrimary.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "Help families affected by the floods.",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Your donation will go a long way in assisting all displaced people finding some relief in these times of need.\nPlease note that this is completely voluntary and you can choose to donate any amount you wish.",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DonationForm extends StatefulWidget {
  const _DonationForm();

  @override
  State<_DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<_DonationForm> {
  PaymentOption _selectedPaymentOption = PaymentOption.mpesa;
  bool _useAccountPhoneNumber = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select payment option below",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RadioImageContainer<PaymentOption>(
                  imageUrl: "assets/images/mpesa.png",
                  value: PaymentOption.mpesa,
                  groupValue: _selectedPaymentOption,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _selectedPaymentOption = value);
                  },
                ),
                RadioImageContainer<PaymentOption>(
                  imageUrl: "assets/images/airtel money.png",
                  value: PaymentOption.airtel,
                  groupValue: _selectedPaymentOption,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _selectedPaymentOption = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "Enter phone number:",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            CustomTxtFormFields(
              hintText: "+254 *** *** ***",
              enabledField: !_useAccountPhoneNumber,
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _useAccountPhoneNumber,
                    onChanged: (_) {
                      setState(() {
                        _useAccountPhoneNumber = !_useAccountPhoneNumber;
                      });
                    },
                    activeColor: colors.primary,
                  ),
                  Text(
                    "Use account phone number",
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: colors.onSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter amount (KES)",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            CustomTxtFormFields(hintText: "Amount"),
            const SizedBox(height: 34),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                  splashFactory: InkSplash.splashFactory,
                ),
                child: const Text(
                  "Donate",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 36),
            Divider(color: colors.outlineVariant, height: 1),
            const SizedBox(height: 18),
            Text(
              "Donation History",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            const _DonationHistoryCard(
              date: "30-April-2026",
              amount: "KES 2000",
              imageUrl: "assets/images/airtel money.png",
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationHistoryCard extends StatelessWidget {
  const _DonationHistoryCard({
    required this.date,
    required this.amount,
    required this.imageUrl,
  });

  final String date;
  final String amount;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(child: Image.asset(imageUrl, height: 24, width: 20)),
          ),
        ],
      ),
    );
  }
}
