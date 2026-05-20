import 'package:rental_marketplace/app_config.dart';
import 'package:rental_marketplace/services/api_client.dart';
import 'package:rental_marketplace/services/auth_service.dart';
import 'package:rental_marketplace/services/order_service.dart';
import 'package:rental_marketplace/services/product_service.dart';
import 'package:rental_marketplace/services/profile_service.dart';
import 'package:rental_marketplace/services/session_store.dart';

class AppServices {
  AppServices._();

  static final api = ApiClient(baseUrl: AppConfig.baseUrl);
  static final sessionStore = SessionStore();

  static final authService = AuthService(api: api);
  static final productService = ProductService(api: api);
  static final orderService = OrderService(api: api);
  static final profileService = ProfileService(api: api);
}

