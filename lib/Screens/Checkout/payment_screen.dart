import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../Controllers/cart_controller.dart';
import '../../Controllers/order_controller.dart';
import '../../Models/order_model.dart';
import '../../Utils/app_theme.dart';
import 'checkout_widgets.dart';
import 'order_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final OrderAddress address;

  const PaymentScreen({super.key, required this.address});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'Cash on Delivery'; // or 'Card'

  // Card form controllers
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _cardFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_method == 'Card') {
      if (!_cardFormKey.currentState!.validate()) return;
    }

    final cart = context.read<CartController>();
    final orderCtrl = context.read<OrderController>();

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    try {
      final order = await orderCtrl.placeOrder(
        cartItems: cart.items.toList(),
        address: widget.address,
        paymentMethod: _method,
        totalPrice: cart.subtotal,
      );

      // Clear cart after successful order
      await cart.clearCart();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(order: order),
        ),
            (route) => route.settings.name == '/user-home' || route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final orderCtrl = context.watch<OrderController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Column(
        children: [
          CheckoutStepIndicator(current: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Delivery address summary ──
                  _SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Delivering to',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.address.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(widget.address.phone,
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text(widget.address.formatted,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Order summary ──
                  _SectionCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order Summary',
                    child: Column(
                      children: [
                        ...cart.items.map(
                              (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} × ${item.quantity}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '\$${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Text('Total',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text(
                              '\$${cart.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.successColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Payment method ──
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _PaymentOption(
                    value: 'Cash on Delivery',
                    groupValue: _method,
                    icon: Icons.money,
                    label: 'Cash on Delivery',
                    subtitle: 'Pay when your order arrives',
                    onChanged: (v) => setState(() => _method = v!),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOption(
                    value: 'Card',
                    groupValue: _method,
                    icon: Icons.credit_card,
                    label: 'Debit / Credit Card',
                    subtitle: 'Visa, Mastercard accepted',
                    onChanged: (v) => setState(() => _method = v!),
                  ),

                  // ── Card form (shown only if Card selected) ──
                  if (_method == 'Card') ...[]
                  const SizedBox(height: 16),
                  _CardForm(
                    formKey: _cardFormKey,
                    cardNumberCtrl: _cardNumberCtrl,
                    cardNameCtrl: _cardNameCtrl,
                    expiryCtrl: _expiryCtrl,
                    cvvCtrl: _cvvCtrl,
                  ),
                ],
                const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          CheckoutBottomBar(
            label: orderCtrl.isPlacing ? 'Placing Order…' : 'Place Order',
            onPressed: orderCtrl.isPlacing ? null : _placeOrder,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Payment Option Row
// ──────────────────────────────────────────────
class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final String label;
  final String subtitle;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor.withValues(alpha: 0.06)
              : Colors.white,
          border: Border.all(
            color: selected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: RadioListTile<String>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          title: Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimaryColor,
                  )),
            ],
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Section Card
// ──────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 6),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Dummy Card Form
// ──────────────────────────────────────────────
class _CardForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cardNumberCtrl;
  final TextEditingController cardNameCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;

  const _CardForm({
    required this.formKey,
    required this.cardNumberCtrl,
    required this.cardNameCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: cardNumberCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                maxLength: 19,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: '0000 0000 0000 0000',
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.replaceAll(' ', '').length < 16) {
                    return 'Enter a valid 16-digit card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cardNameCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'AS ON CARD',
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      maxLength: 5,
                      decoration: const InputDecoration(
                        labelText: 'MM / YY',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        counterText: '',
                      ),
                      validator: (v) {
                        if (v == null || v.length < 5) {
                          return 'Invalid expiry';
                        }
                        // Validate that expiry is in future
                        try {
                          final parts = v.split('/');
                          final month = int.parse(parts[0]);
                          final year = int.parse('20${parts[1]}');
                          final now = DateTime.now();
                          final expiryDate =
                          DateTime(year, month + 1, 0); // Last day of month
                          if (expiryDate.isBefore(now)) {
                            return 'Card has expired';
                          }
                        } catch (e) {
                          return 'Invalid date format';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: cvvCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      maxLength: 3,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        prefixIcon: Icon(Icons.security),
                        counterText: '',
                      ),
                      validator: (v) {
                        if (v == null || v.length < 3) return 'Invalid CVV';
                        return null;
                      },
                    ),
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

// ── Formatters ──
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digitsOnly[i]);
    }
    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
