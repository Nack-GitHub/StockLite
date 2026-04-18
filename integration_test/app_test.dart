import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_lite/main.dart' as app;
import 'package:stock_lite/widgets/stock_lite_button.dart';
import 'package:stock_lite/widgets/stock_lite_input.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final uniqueId = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'e2e_$uniqueId@demo.com';
  const testPassword = 'Pass@word123';
  final productName = 'E2E Product $uniqueId';

  setUpAll(() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Ignored if already init
    }
    await FirebaseAuth.instance.signOut();
  });

  testWidgets('End-to-End StockLite User Flow', (WidgetTester tester) async {
    app.main();
    // Heavy weight for first app loading/animations
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 1. Initial State (Login)
    print('STEP 1: Checking Login Screen');
    expect(find.text('Sign In'), findsOneWidget);

    // 2. Go to Sign Up
    print('STEP 2: Navigating to Sign Up');
    final signUpLink = find.textContaining('Sign up');
    await tester.ensureVisible(signUpLink);
    await tester.tap(signUpLink);
    // Explicit wait for page transition and animations
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 3. Sign Up flow
    print('STEP 3: Filling Sign Up Form');
    expect(find.text('Create Account'), findsOneWidget);

    final nameField = find.widgetWithText(StockLiteInput, 'FULL NAME');
    final emailField = find.widgetWithText(StockLiteInput, 'WORK EMAIL');
    final passField = find.widgetWithText(StockLiteInput, 'PASSWORD');
    final confirmField = find.widgetWithText(
      StockLiteInput,
      'CONFIRM PASSWORD',
    );

    await tester.ensureVisible(nameField);
    await tester.enterText(
      find.descendant(of: nameField, matching: find.byType(TextFormField)),
      'E2E User',
    );
    await tester.pump();

    await tester.ensureVisible(emailField);
    await tester.enterText(
      find.descendant(of: emailField, matching: find.byType(TextFormField)),
      testEmail,
    );
    await tester.pump();

    await tester.ensureVisible(passField);
    await tester.enterText(
      find.descendant(of: passField, matching: find.byType(TextFormField)),
      testPassword,
    );
    await tester.pump();

    await tester.ensureVisible(confirmField);
    await tester.enterText(
      find.descendant(of: confirmField, matching: find.byType(TextFormField)),
      testPassword,
    );
    await tester.pumpAndSettle();

    // Check terms
    print('STEP 3.1: Checking Terms');
    final termsCheckbox = find.byType(Checkbox);
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pumpAndSettle();

    // Tap Sign Up
    print('STEP 3.2: Tapping Sign Up');
    final signUpBtn = find.descendant(
      of: find.byType(StockLiteButton),
      matching: find.text('Sign Up'),
    );
    await tester.ensureVisible(signUpBtn);
    await tester.tap(signUpBtn);

    // Registration takes a moment and typically logs the user in automatically
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 4. Check for direct login or return to Login screen
    print('STEP 4: Verifying post-registration state');

    // Check if we are already on the HOME screen
    bool isAtHome = find.text('PROFILE').evaluate().isNotEmpty;

    if (!isAtHome) {
      print('DEBUG: Not at home, checking Login screen');
      expect(find.text('Welcome'), findsOneWidget);

      final loginEmailField = find.widgetWithText(StockLiteInput, 'WORK EMAIL');
      await tester.enterText(
        find.descendant(
          of: loginEmailField,
          matching: find.byType(TextFormField),
        ),
        testEmail,
      );
      await tester.pump();

      final passInput = find.byIcon(Icons.lock_outline);
      await tester.enterText(
        find.ancestor(of: passInput, matching: find.byType(TextFormField)),
        testPassword,
      );
      await tester.pump();

      final signInBtn = find.descendant(
        of: find.byType(StockLiteButton),
        matching: find.text('Sign In'),
      );
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);

      await tester.pumpAndSettle(const Duration(seconds: 6));
    } else {
      print('STEP 4.1: Direct login detected after Sign Up');
    }

    // 5. Verify Home Screen
    print('STEP 5: Verifying Home Screen');
    expect(find.text('PROFILE'), findsOneWidget);

    // 6. Navigate to Add Product
    print('STEP 6: Navigating to Add Product');
    final addNavBtn = find.text('ADD');
    await tester.tap(addNavBtn);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Add Product'), findsOneWidget);

    // 7. Fill Product Data
    print('STEP 7: Filling Product Details');
    final nameInputIcon = find.byIcon(Icons.inventory_2_outlined);
    final skuInputIcon = find.byIcon(Icons.tag);

    await tester.enterText(
      find.ancestor(of: nameInputIcon, matching: find.byType(TextFormField)),
      productName,
    );
    await tester.pump();
    await tester.enterText(
      find.ancestor(of: skuInputIcon, matching: find.byType(TextFormField)),
      'SKU-$uniqueId',
    );
    await tester.pumpAndSettle();

    // 8. Submit Product
    print('STEP 8: Saving Product');
    final saveProductBtn = find.descendant(
      of: find.byType(StockLiteButton),
      matching: find.text('Add Product to Inventory'),
    );
    await tester.ensureVisible(saveProductBtn);
    await tester.tap(saveProductBtn);

    // Firestore wait
    await tester.pumpAndSettle(const Duration(seconds: 6));

    // 9. Go Home & Verify
    print('STEP 9: Verifying Product in List');
    final homeNavBtn = find.text('HOME');
    await tester.tap(homeNavBtn);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester
        .dragUntilVisible(
          find.text(productName),
          find.byType(ListView),
          const Offset(0, -100),
        )
        .catchError((_) => null);
    expect(find.text(productName), findsOneWidget);

    // 10. Open Product Details
    print('STEP 10: Checking Product Details');
    await tester.tap(find.text(productName));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Delete icon indicates owner access
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.textContaining('SKU-$uniqueId'), findsOneWidget);

    // 11. Profile Check
    print('STEP 11: Checking Profile');
    // Custom leading back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    final profileNavBtn = find.text('PROFILE');
    await tester.tap(profileNavBtn);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('E2E User'), findsWidgets);
    expect(find.text(testEmail), findsOneWidget);

    // 12. Logout
    print('STEP 12: Logging Out');
    final logoutBtn = find.text('Sign Out');
    await tester.ensureVisible(logoutBtn);
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Back at the start
    expect(find.text('Welcome'), findsOneWidget);
    print('SUCCESS: Full E2E Flow Completed');
  });
}
