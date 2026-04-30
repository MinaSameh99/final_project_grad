// lib/student_screens/wallet_payment.dart

import 'package:flutter/material.dart';

class WalletPaymentPage extends StatefulWidget {
  const WalletPaymentPage({super.key, this.phoneNumber});

  final int? phoneNumber;

  @override
  State<WalletPaymentPage> createState() => _WalletPaymentPageState();
}

class _WalletPaymentPageState extends State<WalletPaymentPage> {
  // ignore: unused_field
  int? _phone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Wallet Payment',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                maxLength: 11,
                initialValue: widget.phoneNumber?.toString(),
                validator: (v) =>
                (v == null || v.length != 11)
                    ? 'Invalid phone number'
                    : null,
                onChanged: (v) =>
                    setState(() => _phone = int.tryParse(v)),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // ✅ Capture BEFORE Future.delayed
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  Future.delayed(const Duration(seconds: 2), () {
                    messenger.showSnackBar(const SnackBar(
                      content: Text('Payment Successful!'),
                      backgroundColor: Colors.green,
                    ));
                    navigator.pushNamedAndRemoveUntil(
                        '/home', (route) => false);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 6, 34, 78),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Pay Now - 5410 EGP',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}