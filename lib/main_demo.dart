import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'models/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup Mocks
  final mockAuth = MockFirebaseAuth();
  final fakeFirestore = FakeFirebaseFirestore();
  
  final authService = AuthService(auth: mockAuth);
  final databaseService = DatabaseService(firestore: fakeFirestore);

  runApp(StockLiteDemoApp(
    authService: authService,
    databaseService: databaseService,
  ));
}

class StockLiteDemoApp extends StatelessWidget {
  final AuthService authService;
  final DatabaseService databaseService;

  const StockLiteDemoApp({
    super.key,
    required this.authService,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        Provider(create: (_) => databaseService),
      ],
      child: MaterialApp(
        title: 'StockLite Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF00425E),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00425E),
            primary: const Color(0xFF00425E),
            secondary: const Color(0xFFE9B231),
            surface: Colors.white,
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
            displayMedium: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191C1D),
              letterSpacing: -0.5,
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              color: Color(0xFF40484E),
            ),
          ),
        ),
        initialRoute: '/',
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
              return MaterialPageRoute(
                builder: (_) => const AddProductScreen(),
              );
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
