import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/homepage.dart';
import 'pages/addProduct.dart';
import 'pages/reset_password.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/productdetailspage.dart';
import 'pages/viewOrders.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  //initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isLogin = state.fullPath == '/login';
    final isRegister = state.fullPath == '/register';
    final isReset = state.fullPath == '/reset-password';

    // ✅ Detect password recovery mode (Supabase adds an access token)
    final uri = Uri.parse(state.uri.toString());
    final isPasswordRecovery = uri.queryParameters.containsKey('access_token');

    // Allow /reset-password always
    if (isReset || isPasswordRecovery) return null;

    if (!isLoggedIn && !isLogin && !isRegister) {
      return '/login';
    }

    if (isLoggedIn && (isLogin || isRegister)) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/add_product',
      builder: (context, state) => const AddProductPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: '/product_details',
      builder: (context, state) {
        final product = state.extra as Map<String, dynamic>;
        return ProductDetailsPage(product: product);
      },
    ),
    GoRoute(
      path: '/view-orders',
      builder: (context, state) => const MyOrdersPage(),
    ),
  ],
);
