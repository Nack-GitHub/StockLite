import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_lite/main_demo.dart' as app;
import 'package:stock_lite/widgets/stock_lite_button.dart';
import 'package:stock_lite/widgets/stock_lite_input.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final uniqueId = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'e2e_$uniqueId@stocklite.com';
  const testPassword = 'Pass@word123';
  final testProductName = 'E2E Product $uniqueId';
  final testProductSKU = 'SKU-$uniqueId';

  setUpAll(() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (e) {
      // Firebase initialization might fail in mock environments, but we proceed
    }
  });

  testWidgets('End-to-End StockLite User Flow', (WidgetTester tester) async {
    // Set a consistent surface size for reliably finding widgets
    await binding.setSurfaceSize(const Size(1280, 1024));
    
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    Future<void> step(String name, Future<void> Function() action) async {
      print('[STEP] $name');
      await action();
    }

    await step('Initial UI State', () async {
      expect(find.text('Sign In'), findsOneWidget);
    });

    await step('Navigate to Sign Up', () async {
      final signUpLink = find.textContaining('Sign up');
      await tester.ensureVisible(signUpLink);
      await tester.tap(signUpLink);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Create Account'), findsOneWidget);
    });

    await step('Fill Sign Up Form', () async {
      final nameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passField = find.byType(TextFormField).at(2);
      final confirmField = find.byType(TextFormField).at(3);

      await tester.ensureVisible(nameField);
      await tester.enterText(nameField, 'E2E Test User');
      await tester.pump();
      
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, testEmail);
      await tester.pump();
      
      await tester.ensureVisible(passField);
      await tester.enterText(passField, testPassword);
      await tester.pump();
      
      await tester.ensureVisible(confirmField);
      await tester.enterText(confirmField, testPassword);
      await tester.pump();
      
      final terms = find.byType(Checkbox);
      await tester.ensureVisible(terms);
      await tester.tap(terms);
      await tester.pumpAndSettle();
    });

    await step('Submit Registration', () async {
      print('DEBUG: Tapping Sign Up Button');
      final signUpBtn = find.widgetWithText(StockLiteButton, 'Sign Up');
      await tester.ensureVisible(signUpBtn);
      await tester.tap(signUpBtn);
      // Registration and auto-login transition via AuthWrapper
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    await step('Verify Authentication Flow', () async {
      print('DEBUG: Verifying post-registration state');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      bool profileVisible = find.text('PROFILE').evaluate().isNotEmpty;

      if (!profileVisible) {
        print('DEBUG: PROFILE not visible, checking for Login/Welcome screen');
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        // If we are still at Welcome/Login, something went wrong or we need manual sign-in
        if (find.text('Welcome').evaluate().isNotEmpty) {
          print('DEBUG: Found Welcome screen, attempting manual Sign In');
          final loginEmailField = find.byType(TextFormField).at(0);
          await tester.ensureVisible(loginEmailField);
          await tester.enterText(loginEmailField, testEmail);
          await tester.pump();
          
          final loginPassField = find.byType(TextFormField).at(1);
          await tester.ensureVisible(loginPassField);
          await tester.enterText(loginPassField, testPassword);
          await tester.pump();
          
          final signInBtn = find.widgetWithText(StockLiteButton, 'Sign In');
          await tester.ensureVisible(signInBtn);
          await tester.tap(signInBtn);
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpAndSettle(const Duration(seconds: 6));
        } else {
          print('DEBUG: Current widgets: ${tester.allWidgets.take(20).map((w) => w.toStringShort()).toList()}');
        }
      }
      
      print('DEBUG: Final check for PROFILE text');
      expect(find.text('PROFILE'), findsOneWidget);
    });

    await step('Add New Product', () async {
      final addTab = find.text('ADD');
      await tester.tap(addTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text('Add Product'), findsOneWidget);
      
      final nameInput = find.byType(TextFormField).at(0);
      await tester.ensureVisible(nameInput);
      await tester.enterText(nameInput, testProductName);
      await tester.pump();
      
      final skuInput = find.byType(TextFormField).at(1);
      await tester.ensureVisible(skuInput);
      await tester.enterText(skuInput, testProductSKU);
      await tester.pump();
      
      final saveBtn = find.widgetWithText(StockLiteButton, 'Add Product to Inventory');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    await step('Verify Dashboard State', () async {
      final homeTab = find.text('HOME');
      await tester.tap(homeTab);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text(testProductName), findsOneWidget);
    });

    await step('Check Product Details', () async {
      final item = find.text(testProductName);
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      expect(find.text('CURRENT STOCK LEVEL'), findsOneWidget);
    });

    await step('Delete and Cleanup', () async {
      final delIcon = find.byIcon(Icons.delete_outline);
      await tester.tap(delIcon);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      final delBtn = find.text('Delete');
      await tester.tap(delBtn);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      expect(find.text(testProductName), findsNothing);
    });

    await step('Verify Profile and Sign Out', () async {
      final profTab = find.text('PROFILE');
      await tester.tap(profTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.text(testEmail), findsOneWidget);
      
      final outBtn = find.text('Sign Out');
      await tester.ensureVisible(outBtn);
      await tester.tap(outBtn);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
