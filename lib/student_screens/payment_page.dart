import 'package:flutter/material.dart';
import 'package:sams/student_screens/card_payment.dart';
import 'package:sams/student_screens/wallet_payment.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'Fawry';
  bool agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Gateway',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 6, 34, 78),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شعار الجامعة أو العنوان
            Center(
              child: Column(
                children: const [
                  Text(
                    'Sadat Academy for Management Sciences',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                 
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '5410(EGP)',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 6, 34, 78),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text(
              'Choose Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildPaymentMethod(
              title: 'Visa/MasterCard (Fawry)',
              icon: Icons.payment,
              value: 'Fawry',
            ),

            const SizedBox(height: 12),
            _buildPaymentMethod(
              title: 'E-Wallet (InstaPay - Vodafone Cash)',
              icon: Icons.phone_android,
              value: 'E-Wallet',
            ),

            const SizedBox(height: 24),

            CheckboxListTile(
              title: const Text(
                'I agree to the terms and conditions and the university\'s payment and refund policy',
                style: TextStyle(fontSize: 14),
              ),
              value: agreeToTerms,
              onChanged: (bool? value) {
                setState(() => agreeToTerms = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Color.fromARGB(255, 6, 34, 78),
            ),

            const SizedBox(height: 32),

           SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: agreeToTerms
        ? () {
            if (selectedPaymentMethod == 'Fawry') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CardPaymentPage(),
                ),
              );
            } else if (selectedPaymentMethod == 'E-Wallet') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  WalletPaymentPage(phoneNumber: 01125993315), // Example phone number
                ),
              );
            }
          }
        : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 6, 34, 78),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      disabledBackgroundColor: Colors.grey,
    ),
    child: const Text(
      'Continue to Payment',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  ),
),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildPaymentMethod({
    required String title,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Color.fromARGB(255, 6, 34, 78).withValues(alpha:0.08)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Color.fromARGB(255, 6, 34, 78), size: 28),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color.fromARGB(255, 6, 34, 78),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
