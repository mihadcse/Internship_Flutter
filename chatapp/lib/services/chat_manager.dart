
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:sembast/sembast.dart';
import '../models/message.dart';
import '../db/sembast_db.dart';

// State class to hold chat data
class ChatState {
  final List<Message> messages;
  final String currentSessionId;
  final bool isLoading;

  ChatState({
    required this.messages,
    required this.currentSessionId,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<Message>? messages,
    String? currentSessionId,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Chat Notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final SembastDB _db = SembastDB();

  ChatNotifier() : super(ChatState(
    messages: [],
    currentSessionId: const Uuid().v4(),
  ));

  // Load messages for the current session
  Future<void> loadHistory() async {
    final data = await _db.getMessagesBySession(state.currentSessionId, limit: 50);
    final messages = data.map((e) => Message.fromMap(e)).toList();
    state = state.copyWith(messages: messages);
  }

  // Clear messages of current session
  Future<void> clearChat() async {
    final db = await _db.database;
    final store = intMapStoreFactory.store('messages');
    final finder = Finder(filter: Filter.equals('sessionId', state.currentSessionId));
    await store.delete(db, finder: finder);
    
    state = state.copyWith(messages: []);
  }

  // Start a new chat session
  void startNewChat() {
    state = ChatState(
      messages: [],
      currentSessionId: const Uuid().v4(),
    );
  }

  // Get all previous session IDs
  Future<List<String>> getAllSessionIds() async {
    final db = await _db.database;
    final store = intMapStoreFactory.store('messages');
    final records = await store.find(db);
    final sessionIds = records.map((e) => e.value['sessionId'].toString()).toSet().toList();
    return sessionIds.reversed.toList();
  }

  // Load a specific session
  Future<void> loadSession(String sessionId) async {
    state = state.copyWith(currentSessionId: sessionId);
    await loadHistory();
  }

  // Send a message and get bot reply
  Future<void> sendMessage(String text) async {
    // Add user message
    final userMsg = Message(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
      sessionId: state.currentSessionId,
    );
    
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );
    
    await _db.insertMessageWithSession(userMsg);

    final url = Uri.parse('http://127.0.0.1:11434/api/chat');

    final body = {
      "model": "llama3:latest",
      "messages": state.messages
          .takeLast(10)
          .map((m) => {"role": m.role, "content": m.content})
          .toList(),
      "stream": true,
    };

    try {
      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);

      final streamedResponse = await request.send();
      final buffer = StringBuffer();
      await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
      }

      final lines = buffer.toString().split('\n').where((l) => l.trim().isNotEmpty);
      String finalReply = '';

      for (var line in lines) {
        try {
          final data = jsonDecode(line);
          if (data['message'] != null) finalReply += data['message']['content'];
        } catch (_) {}
      }

      if (finalReply.isEmpty) finalReply = "⚠️ No response received.";

      final botMsg = Message(
        role: 'assistant',
        content: finalReply.trim(),
        timestamp: DateTime.now(),
        sessionId: state.currentSessionId,
      );
      
      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
      
      await _db.insertMessageWithSession(botMsg);
    } catch (e) {
      final errorMsg = Message(
        role: 'assistant',
        content: "⚠️ Error: Could not connect to local model.",
        timestamp: DateTime.now(),
        sessionId: state.currentSessionId,
      );
      
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
      );
    }
  }
}

// Extension for list operations
extension ListTail<T> on List<T> {
  List<T> takeLast(int n) => skip(length > n ? length - n : 0).toList();
}

// Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});