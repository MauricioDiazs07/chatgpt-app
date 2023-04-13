import 'package:chatgpt/src/pages/chat_page.dart';
import 'package:flutter/material.dart';

import '../errors/exceptions.dart';

class RouteGenerator {
  static const String chat = 'chat';
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatPage());

      default:
        throw RouteException('Route not found');
    }
  }
}
