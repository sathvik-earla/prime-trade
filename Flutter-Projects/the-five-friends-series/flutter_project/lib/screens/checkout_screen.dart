import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_item.dart';
import '../models/user_models.dart';
import '../services/storage_service.dart';

class CheckoutScreen extends StatefulWidget {
  final StoryItem story;

  const CheckoutScreen({super.key, required this.story});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'upi'; // 'upi' | 'card' | 'cod'

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  void _completePurchase() async {
    if (_paymentMethod == 'cod') {
      if (_nameController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _streetController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty ||
          _postalController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all delivery address fields for COD')),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final record = PurchaseRecord(
      id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
      storyId: widget.story.id,
      storyTitle: widget.story.title,
      amount: widget.story.price,
      paymentMethod: _paymentMethod,
      timestamp: DateTime.now().toIso8601String(),
      status: _paymentMethod == 'cod' ? 'processing' : 'completed',
      deliveryAddress: _paymentMethod == 'cod'
          ? DeliveryAddress(
              fullName: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              street: _streetController.text.trim(),
              city: _cityController.text.trim(),
              postalCode: _postalController.text.trim(),
            )
          : null,
    );

    if (mounted) {
      await context.read<StorageService>().addPurchaseRecord(record);
      setState(() => _isProcessing = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF34D399)),
              SizedBox(width: 8),
              Text('Purchase Successful!', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Text(
            _paymentMethod == 'cod'
                ? 'Your Cash on Delivery order for "${widget.story.title}" has been placed and is being dispatched.'
                : 'You have successfully purchased and unlocked "${widget.story.title}". Enjoy reading!',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close checkout
              },
              child: const Text('Start Reading Now', style: TextStyle(color: Color(0xFF020617), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text('Checkout & Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book summary card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.story.coverImage,
                      width: 60,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 80,
                        color: const Color(0xFF1E293B),
                        child: const Icon(Icons.book, color: Color(0xFFF59E0B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.story.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'By ${widget.story.authorName}',
                          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Total Price: ₹${widget.story.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Options
            const Text(
              'Select Payment Method',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              value: 'upi',
              groupValue: _paymentMethod,
              activeColor: const Color(0xFFF59E0B),
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('UPI / Google Pay / PhonePe / QR', style: TextStyle(color: Colors.white, fontSize: 13)),
              secondary: const Icon(Icons.qr_code, color: Color(0xFFF59E0B)),
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              value: 'card',
              groupValue: _paymentMethod,
              activeColor: const Color(0xFFF59E0B),
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Credit / Debit Card & Net Banking', style: TextStyle(color: Colors.white, fontSize: 13)),
              secondary: const Icon(Icons.credit_card, color: Color(0xFFF59E0B)),
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              value: 'cod',
              groupValue: _paymentMethod,
              activeColor: const Color(0xFFF59E0B),
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Cash on Delivery (Print Edition)', style: TextStyle(color: Colors.white, fontSize: 13)),
              secondary: const Icon(Icons.local_shipping, color: Color(0xFFF59E0B)),
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
            const SizedBox(height: 16),

            // COD Address form if selected
            if (_paymentMethod == 'cod') ...[
              const Text(
                'Shipping Address for Print Delivery',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Recipient Full Name',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Contact Phone Number',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _streetController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'House / Street Address',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'City',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _postalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Postal PIN Code',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton(
              onPressed: _isProcessing ? null : _completePurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Color(0xFF020617), strokeWidth: 2),
                    )
                  : Text(
                      _paymentMethod == 'cod'
                          ? 'Place Order (₹${widget.story.price.toStringAsFixed(2)})'
                          : 'Pay ₹${widget.story.price.toStringAsFixed(2)} & Unlock Story',
                      style: const TextStyle(
                        color: Color(0xFF020617),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
