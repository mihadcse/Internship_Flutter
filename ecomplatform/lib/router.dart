import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/homepage.dart';
import 'pages/addProduct.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/add_product',
      builder: (context, state) => const AddProductPage(),
    ),
  ],
);
