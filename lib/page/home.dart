import 'package:flutter/material.dart';
import 'home/elderly_home_page.dart';
import 'home/family_home_page.dart';

class HomePage extends StatefulWidget {
  final String? role;
  
  const HomePage({super.key, this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Determine user role from URL parameter or default to family
    final userRole = widget.role ?? 'family';
    
    // Return the appropriate home page based on user role
    if (userRole == 'elderly') {
      return const ElderlyHomePage();
    } else {
      return const FamilyHomePage();
    }
  }
}