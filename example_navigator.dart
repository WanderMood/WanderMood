import 'package:flutter/material.dart';
import 'package:wandermood/features/home/presentation/screens/main_screen.dart';

// Function to navigate to the MyDay screen from anywhere in the app
void navigateToMyDayScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MyDayScreen()),
  );
}

// Usage example:
// Just call this from any button or action where you need to navigate to MyDay screen
// Example:
// ElevatedButton(
//   onPressed: () => navigateToMyDayScreen(context),
//   child: Text('Go to My Day'),
// ) 
 
 
 