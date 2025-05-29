import 'package:flutter/material.dart';

class FormatSuccessful extends StatefulWidget {
  const FormatSuccessful({super.key});

  @override
  State<FormatSuccessful> createState() => _FormatSuccessfulState();
}

class _FormatSuccessfulState extends State<FormatSuccessful> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'تم الإكمال بنجاح!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'تم تنفيذ العملية المطلوبة بنجاح.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // أو العودة إلى الصفحة الرئيسية
                },
                icon: const Icon(Icons.home),
                label: const Text('العودة إلى الصفحة الرئيسية'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
