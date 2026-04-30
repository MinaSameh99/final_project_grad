import 'package:flutter/material.dart';

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  LogoScreenState createState() => LogoScreenState();
}

class LogoScreenState extends State<LogoScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logo.png', width: 200, height: 200),
            SizedBox(height: 40),
            Text(
              'Welcome to Sadat Academy',
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: TextStyle(
                color: Color.fromARGB(255, 6, 34, 78),
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Let’s Get You Started...',
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                color: Color.fromARGB(255, 19, 53, 105),
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 15),
            Icon(
              Icons.arrow_right_alt_outlined,
              color: Color.fromARGB(255, 19, 53, 105),
              size: 45,
            ),
          ],
        ),
      ),
    );
  }
}
