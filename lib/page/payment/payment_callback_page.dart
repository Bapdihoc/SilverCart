import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentCallbackPage extends StatelessWidget {
  final String status;
  const PaymentCallbackPage({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(status);
      } else {
        context.go('/home');
      }
    });

    final isSuccess = status.toLowerCase() == 'success';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: isSuccess ? Colors.green : Colors.red,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(isSuccess ? 'Thanh toán thành công' : 'Thanh toán thất bại'),
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}


