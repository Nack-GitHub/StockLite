import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:stock_lite/services/auth_service.dart';
import 'package:stock_lite/services/database_service.dart';
import 'package:stock_lite/models/product.dart';

// Initialize global settings for tests
void setupTestGlobals() {
  Animate.restartOnHotReload = true;
  Animate.defaultDuration = Duration.zero;
  HttpOverrides.global = MockHttpOverrides();
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return Future.value(MockHttpClientRequest());
  }

  @override
  set autoUncompress(bool _autoUncompress) {}
}

class MockHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() {
    return Future.value(MockHttpClientResponse());
  }
}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final transparentImage = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

class MockAuthService extends Mock implements AuthService {}
class MockDatabaseService extends Mock implements DatabaseService {}
class MockUser extends Mock implements User {}
class MockUserCredential extends Mock implements UserCredential {}

// App Wrapper for tests
extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpStockLite(
    Widget widget, {
    required MockAuthService authService,
    required MockDatabaseService databaseService,
    Map<String, WidgetBuilder> routes = const {},
  }) async {
    // Set a larger surface size for tests to avoid off-screen issues
    await binding.setSurfaceSize(const Size(800, 1200));
    
    HttpOverrides.global = MockHttpOverrides();
    await pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: authService),
          Provider<DatabaseService>.value(value: databaseService),
        ],
        child: MaterialApp(
          theme: ThemeData(primaryColor: const Color(0xFF00425E)),
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(body: Center(child: Text('Route: ${settings.name}'))),
              settings: settings,
            );
          },
          home: widget,
          routes: routes,
        ),
      ),
    );
    await pumpAndSettle();
  }
}

// Helper to create a test product
Product createTestProduct({
  String id = '1',
  String name = 'Test Product',
  String sku = 'SKU123',
  String category = 'Electronics',
  int stock = 10,
  String status = 'In Stock',
  String imageUrl = 'https://example.com/image.png',
}) {
  return Product(
    id: id,
    name: name,
    sku: sku,
    category: category,
    stock: stock,
    status: status,
    imageUrl: imageUrl,
  );
}
