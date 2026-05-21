import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:relief_haven_mobile/common_widgets/custom_input_fields.dart';
import 'package:relief_haven_mobile/common_widgets/custom_radio_image.dart';
import 'package:relief_haven_mobile/models/donation_model.dart';
import 'package:relief_haven_mobile/providers/auth_provider.dart';
import 'package:relief_haven_mobile/providers/donation_provider.dart';
import 'package:relief_haven_mobile/services/requests/base.dart';
import 'package:relief_haven_mobile/services/requests/donation_request.dart';
import 'package:relief_haven_mobile/common_widgets/shimmer_loading.dart';
import 'package:toastification/toastification.dart';

import '../common_widgets/donation_header.dart';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  final _formAnchorKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final donationsAsync = ref.watch(donationHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          'Donation',
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
                      child: DonationHeader(),
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
                child: const Text('Donate Now'),
              ),
              Container(key: _formAnchorKey, child: const _DonationForm()),
              const SizedBox(height: 15),
              Divider(color: colors.outlineVariant, height: 1),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Donation History',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: donationsAsync.when(
                  loading: () => const DonationHistoryShimmer(),
                  error: (error, _) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: colors.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _friendlyErrorText(error),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onErrorContainer),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(donationHistoryProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),

                  data: (donations) {
                    if (donations.isEmpty) {
                      return Center(
                        child: Text(
                          "Your donations will appear after successful submissions.",
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      );
                    }

                    return Column(
                      children: donations
                          .map(
                            (donation) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _DonationHistoryCard(donation: donation),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

enum PaymentOption { mpesa, airtel }

extension PaymentOptionX on PaymentOption {
  String get displayLabel {
    switch (this) {
      case PaymentOption.mpesa:
        return 'M-Pesa';
      case PaymentOption.airtel:
        return 'Airtel Money';
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentOption.mpesa:
        return 'mpesa';
      case PaymentOption.airtel:
        return 'airtel_money';
    }
  }

  String get assetPath {
    switch (this) {
      case PaymentOption.mpesa:
        return 'assets/images/mpesa.png';
      case PaymentOption.airtel:
        return 'assets/images/airtel money.png';
    }
  }
}

class _DonationForm extends ConsumerStatefulWidget {
  const _DonationForm();

  @override
  ConsumerState<_DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends ConsumerState<_DonationForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _donationRequest = DonationRequest();

  PaymentOption _selectedPaymentOption = PaymentOption.mpesa;
  bool _useAccountPhoneNumber = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authState = ref.read(authProvider);
    final profilePhone = authState.profile?.phone;
    final rawAmount = _amountController.text.trim().replaceAll(',', '');
    final amount = double.tryParse(rawAmount);

    if (amount == null || amount <= 0) {
      toastification.show(
        type: .warning,
        style: .flatColored,
        description: Text('Please enter a valid donation amount.'),
        icon: const Icon(Icons.warning),
      );
      return;
    }

    int? phoneNumber;
    if (_useAccountPhoneNumber) {
      phoneNumber = profilePhone;
      if (phoneNumber == null) {
        toastification.show(
          type: .warning,
          style: .flatColored,
          description: Text('Your account phone number is not available yet.'),
          icon: const Icon(Icons.warning),
        );

        return;
      }
    } else {
      phoneNumber = int.tryParse(_phoneController.text.trim());

      if (phoneNumber == null) {
        toastification.show(
          type: .warning,
          style: .flatColored,
          description: Text('Please enter a valid phone number.'),
          icon: const Icon(Icons.warning),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      await _donationRequest.initiateDonation(
        request: DonationInitiateRequest(
          amountKes: amount,
          paymentService: _selectedPaymentOption.apiValue,
          phone: phoneNumber,
        ),
      );

      if (!mounted) {
        return;
      }

      _amountController.clear();
      if (!_useAccountPhoneNumber) {
        _phoneController.clear();
      }

      ref.invalidate(donationHistoryProvider);

      toastification.show(
        type: .success,
        style: .flatColored,
        description: Text('Donation successful.'),
        icon: const Icon(Icons.thumb_up),
      );
    } on RequestException catch (error) {
      if (!mounted) {
        return;
      }

      toastification.show(
        type: .error,
        style: .flatColored,
        description: Text('Donation failed: $error'),
        icon: const Icon(Icons.error),
        autoCloseDuration: const Duration(milliseconds: 2500),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      toastification.show(
        type: .error,
        style: .flatColored,
        description: Text('Unable to process donation: $error'),
        icon: const Icon(Icons.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select payment option below',
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
                  imageUrl: PaymentOption.mpesa.assetPath,
                  value: PaymentOption.mpesa,
                  groupValue: _selectedPaymentOption,
                  onChanged: (value) {
                    if (value == null || _isSubmitting) {
                      return;
                    }
                    setState(() => _selectedPaymentOption = value);
                  },
                ),
                RadioImageContainer<PaymentOption>(
                  imageUrl: PaymentOption.airtel.assetPath,
                  value: PaymentOption.airtel,
                  groupValue: _selectedPaymentOption,
                  onChanged: (value) {
                    if (value == null || _isSubmitting) {
                      return;
                    }
                    setState(() => _selectedPaymentOption = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Enter phone number:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            CustomTxtFormFields(
              controller: _phoneController,
              hintText: '+254 *** *** ***',
              enabledField: !_useAccountPhoneNumber && !_isSubmitting,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (_useAccountPhoneNumber) {
                  return null;
                }

                final phone = value?.trim() ?? '';
                if (phone.isEmpty) {
                  return 'Please enter the phone number to use.';
                }
                if (!RegExp(r'^\d{8,15}$').hasMatch(phone)) {
                  return 'Enter a valid phone number with digits only.';
                }
                return null;
              },
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _useAccountPhoneNumber,
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _useAccountPhoneNumber = value ?? false;
                            });
                          },
                    activeColor: colors.primary,
                  ),
                  Text(
                    authState.profile?.phone != null
                        ? 'Use account phone number'
                        : 'Use account phone number (not set)',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: colors.onSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enter amount (KES)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            CustomTxtFormFields(
              controller: _amountController,
              hintText: 'Amount',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              enabledField: !_isSubmitting,
              validator: (value) {
                final rawAmount = value?.trim().replaceAll(',', '') ?? '';
                if (rawAmount.isEmpty) {
                  return 'Please enter the donation amount.';
                }

                final amount = double.tryParse(rawAmount);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount.';
                }

                return null;
              },
            ),
            const SizedBox(height: 34),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                  splashFactory: InkSplash.splashFactory,
                ),
                child: Text(
                  _isSubmitting ? 'Submitting...' : 'Donate',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationHistoryCard extends StatelessWidget {
  const _DonationHistoryCard({required this.donation});

  final DonationModel donation;

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
                  _paymentLabelForService(donation.paymentService),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  donation.formattedDate,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  donation.formattedAmount,
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
            child: Center(
              child: Image.asset(
                _paymentAssetForService(donation.paymentService),
                height: 24,
                width: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _paymentAssetForService(String paymentService) {
  final normalized = paymentService.trim().toLowerCase();
  if (normalized.contains('airtel')) {
    return PaymentOption.airtel.assetPath;
  }
  return PaymentOption.mpesa.assetPath;
}

String _paymentLabelForService(String paymentService) {
  final normalized = paymentService.trim().toLowerCase();
  if (normalized.contains('airtel')) {
    return PaymentOption.airtel.displayLabel;
  }
  return PaymentOption.mpesa.displayLabel;
}

String _friendlyErrorText(Object error) => error is RequestException
    ? error.message
    : 'Unable to load your donation history right now.';
