import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/chat_provider.dart';
import '../services/chat_manager.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> previousSessions = [];
  late AnimationController _drawerAnimationController;

  @override
  void initState() {
    super.initState();
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadHistoryAndSessions();
  }

  Future<void> _loadHistoryAndSessions() async {
    await ref.read(chatProvider.notifier).loadHistory();
    previousSessions = await ref.read(chatProvider.notifier).getAllSessionIds();
    setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadSession(String sessionId) async {
    await ref.read(chatProvider.notifier).loadSession(sessionId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    
    // Auto-scroll when messages change
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 219, 236),
      appBar: AppBar(
        title: const Text("🧠 Local Chat"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "New Chat",
            icon: const Icon(Icons.add_comment),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Start New Chat?"),
                  content: const Text(
                      "This will start a new chat session. Previous chats will remain saved."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(chatProvider.notifier).startNewChat();
                previousSessions = await ref.read(chatProvider.notifier).getAllSessionIds();
                setState(() {});
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: AnimatedDrawerContent(
          previousSessions: previousSessions,
          currentSessionId: chatState.currentSessionId,
          onClearChat: () async {
            await ref.read(chatProvider.notifier).clearChat();
            previousSessions = await ref.read(chatProvider.notifier).getAllSessionIds();
            setState(() {});
            if (mounted) Navigator.pop(context);
          },
          onLoadSession: _loadSession,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? const Center(
                    child: Text(
                      "No messages yet. Start chatting!",
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, i) {
                      final msg = chatState.messages[i];
                      final isUser = msg.role == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color.fromARGB(255, 130, 215, 241)
                                : const Color.fromARGB(255, 137, 178, 249),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(msg.content),
                        ),
                      );
                    },
                  ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text("AI is thinking..."),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !ref.read(chatProvider).isLoading) {
      ref.read(chatProvider.notifier).sendMessage(text);
      _controller.clear();
    }
  }
}

// Separate animated drawer content widget
class AnimatedDrawerContent extends StatefulWidget {
  final List<String> previousSessions;
  final String? currentSessionId;
  final VoidCallback onClearChat;
  final Function(String) onLoadSession;

  const AnimatedDrawerContent({
    super.key,
    required this.previousSessions,
    required this.currentSessionId,
    required this.onClearChat,
    required this.onLoadSession,
  });

  @override
  State<AnimatedDrawerContent> createState() => _AnimatedDrawerContentState();
}

class _AnimatedDrawerContentState extends State<AnimatedDrawerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _setupAnimations();
    _controller.forward();
  }

  void _setupAnimations() {
    final itemCount = 3 + widget.previousSessions.length; // header + clear + divider + sessions
    _itemAnimations = List.generate(
      itemCount,
      (index) {
        final start = index * 0.05;
        final end = start + 0.3;
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(AnimatedDrawerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.previousSessions.length != widget.previousSessions.length) {
      _setupAnimations();
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Animated Header
        _buildAnimatedItem(
          index: 0,
          child: const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated Clear Chat Button
        _buildAnimatedItem(
          index: 1,
          child: AnimatedListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text("Clear Chat"),
            onTap: widget.onClearChat,
          ),
        ),
        // Animated Divider
        _buildAnimatedItem(
          index: 2,
          child: const Divider(),
        ),
        // Animated Section Header
        _buildAnimatedItem(
          index: 3,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Previous Chats",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        // Animated Session Items
        ...widget.previousSessions.asMap().entries.map((entry) {
          final index = entry.key;
          final sessionId = entry.value;
          final displayId = sessionId.length >= 8
              ? sessionId.substring(0, 8)
              : sessionId;
          final isCurrentSession = sessionId == widget.currentSessionId;

          return _buildAnimatedItem(
            index: 4 + index,
            child: AnimatedListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text("Chat: $displayId"),
              selected: isCurrentSession,
              selectedTileColor: Colors.deepPurple.withOpacity(0.1),
              onTap: () async {
                await widget.onLoadSession(sessionId);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    if (index >= _itemAnimations.length) {
      return child;
    }

    return AnimatedBuilder(
      animation: _itemAnimations[index],
      builder: (context, child) {
        return Opacity(
          opacity: _itemAnimations[index].value,
          child: Transform.translate(
            offset: Offset(
              -30 * (1 - _itemAnimations[index].value),
              0,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// Animated ListTile with hover effect
class AnimatedListTile extends StatefulWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;
  final bool selected;
  final Color? selectedTileColor;

  const AnimatedListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    this.selected = false,
    this.selectedTileColor,
  });

  @override
  State<AnimatedListTile> createState() => _AnimatedListTileState();
}

class _AnimatedListTileState extends State<AnimatedListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(_isHovered ? 4.0 : 0.0, 0.0, 0.0),
        child: ListTile(
          leading: widget.leading,
          title: widget.title,
          selected: widget.selected,
          selectedTileColor: widget.selectedTileColor,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}