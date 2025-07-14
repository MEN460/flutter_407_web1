import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/providers.dart';

class PaymentGatewayScreen extends ConsumerStatefulWidget {
  final Booking booking;

  const PaymentGatewayScreen({super.key, required this.booking});

  @override
  ConsumerState<PaymentGatewayScreen> createState() =>
      _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends ConsumerState<PaymentGatewayScreen> {
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flight: ${widget.booking.flight?.number ?? 'N/A'}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('Amount: KES ${_calculateTotal()}'),
            const SizedBox(height: 30),
            TextFormField(
              controller: _cardController,
              decoration: const InputDecoration(labelText: 'Card Number'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(labelText: 'MM/YY'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(labelText: 'CVV'),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : const Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal() {
    // Simplified pricing logic
    const prices = {'executive': 25000.0, 'middle': 15000.0, 'economy': 8000.0};
    return prices[widget.booking.seatNumber] ?? 0.0;
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    final paymentService = ref.read(paymentServiceProvider);
    try {
      await paymentService.processPayment(
        amount: _calculateTotal(),
        cardNumber: _cardController.text,
        expiry: _expiryController.text,
        cvv: _cvvController.text,
        bookingId: widget.booking.id,
      );
      if (mounted) {
        context.push('/booking-confirm', extra: widget.booking);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
