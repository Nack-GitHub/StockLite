import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/profile_screen.dart';
import 'models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StockLiteApp());
}

class StockLiteApp extends StatelessWidget {
  const StockLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        title: 'StockLite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const AuthWrapper());
            case '/signup':
              return MaterialPageRoute(builder: (_) => const SignUpScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case '/product_detail':
              final product = settings.arguments as Product;
              return MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              );
            case '/add_product':
              return MaterialPageRoute(builder: (_) => const AddProductScreen());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            default:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
