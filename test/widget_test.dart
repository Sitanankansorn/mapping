import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapping_v1/app.dart';

void main() {
  testWidgets('App launches to login screen with Thailand explorer branding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MappingApp());
    await tester.pump(const Duration(milliseconds: 800));

    // Verify login screen elements are present
    expect(find.text('Thailand Mapping'), findsOneWidget);
    expect(find.text('Sign In to Explorer'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('Wrong password denies login access with error banner',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MappingApp());
    await tester.pump(const Duration(milliseconds: 800));

    // Find the password field and enter a WRONG password
    final passwordFields = find.byType(TextFormField);
    expect(passwordFields, findsNWidgets(2)); // Email and Password

    // Enter wrong password
    await tester.enterText(passwordFields.at(1), 'WrongPassword123!');
    await tester.pump();

    // Tap Sign In button
    final signInBtn = find.text('Sign In to Explorer');
    await tester.tap(signInBtn);
    await tester.pump(const Duration(milliseconds: 900));

    // Verify login was DENIED and error is shown
    expect(find.text('Access Denied'), findsOneWidget);
    expect(
      find.text('Access Denied: The password entered is incorrect for this account.'),
      findsOneWidget,
    );

    // Verify user is still on Login screen, NOT home
    expect(find.text('Sign In to Explorer'), findsOneWidget);
  });

  testWidgets('Correct password grants login access to application',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MappingApp());
    await tester.pump(const Duration(milliseconds: 800));

    final passwordFields = find.byType(TextFormField);

    // Enter correct default registered password
    await tester.enterText(passwordFields.at(1), 'Bangkok2026!');
    await tester.pump();

    // Tap Sign In
    final signInBtn = find.text('Sign In to Explorer');
    await tester.tap(signInBtn);
    await tester.pump(const Duration(milliseconds: 900));

    // Pump a single frame to transition to home/map without waiting for repeating radar animation
    await tester.pump(const Duration(milliseconds: 400));

    // Verify access granted and routed to AppShell tabs
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
  });
}
