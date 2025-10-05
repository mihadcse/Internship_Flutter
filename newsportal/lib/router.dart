import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/news_list_screen.dart';
import 'screens/news_details_screen.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Hacker News', textAlign: TextAlign.center)),
          body: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/top',
          builder: (context, state) => const NewsListScreen(category: 'topstories'),
        ),
        GoRoute(
          path: '/new',
          builder: (context, state) => const NewsListScreen(category: 'newstories'),
        ),
        GoRoute(
          path: '/best',
          builder: (context, state) => const NewsListScreen(category: 'beststories'),
        ),
        GoRoute(
          path: '/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'];
            return NewsDetailsScreen(id: id);
          },
        ),
      ],
    ),
  ],
);
