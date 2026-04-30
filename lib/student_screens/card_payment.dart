// lib/student_screens/card_payment.dart

import 'package:flutter/material.dart';

class CardPaymentPage extends StatefulWidget {
  const CardPaymentPage({super.key});

  @override
  State<CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  final _formKey   = GlobalKey<FormState>();
  String cardNumber = '';
  String cvv        = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Payment',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 34, 78),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Enter Card Details',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (v) =>
                (v ?? '').length < 15 ? 'Invalid card number' : null,
                onChanged: (v) => cardNumber = v,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'MM/YY',
                          border: OutlineInputBorder()),
                      maxLength: 5,
                      validator: (v) =>
                      (v ?? '').length < 4 ? 'Invalid expiry' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      validator: (v) =>
                      (v ?? '').length < 3 ? 'Invalid CVV' : null,
                      onChanged: (v) => cvv = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Card Holder Name',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // ✅ Capture BEFORE Future.delayed
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      Future.delayed(const Duration(seconds: 2), () {
                        messenger.showSnackBar(const SnackBar(
                          content: Text('Successful payment!'),
                          backgroundColor: Colors.green,
                        ));
                        navigator.pushNamedAndRemoveUntil(
                            '/home', (route) => false);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color.fromARGB(255, 6, 34, 78)),
                  child: const Text('Pay',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}