import 'package:batchit/models/chat_message.dart';
import 'package:batchit/providers/auth_provider.dart';
import 'package:batchit/services/chat_service.dart';
import 'package:batchit/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BatchChatScreen extends StatefulWidget {
  const BatchChatScreen({super.key, required this.batchId, required this.batchName});

  final String batchId;
  final String batchName;

  @override
  State<BatchChatScreen> createState() => _BatchChatScreenState();
}

class _BatchChatScreenState extends State<BatchChatScreen> {
  final ChatService _service = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  ChatMessage? _replyTo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _service.joinRoom(widget.batchId);
    final msgs = await _service.fetchMessages(widget.batchId);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    _controller.clear();
    setState(() => _isSending = true);
    try {
      final msg = await _service.sendMessage(widget.batchId, text);
      setState(() => _messages = [..._messages, msg]);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().user?.id ?? '';
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.batchName, overflow: TextOverflow.ellipsis),
            Text('Batch Chat',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background/chat.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text('No messages yet. Say hello!',
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMe = msg.senderId == myId;
                          return _SwipeToReply(
                            isMe: isMe,
                            onReply: () => setState(() => _replyTo = msg),
                            child: _MessageBubble(
                              message: msg,
                              isMe: isMe,
                              scheme: scheme,
                            ),
                          );
                        },
                      ),
          ),
          _InputBar(
            controller: _controller,
            isSending: _isSending,
            onSend: _send,
            scheme: scheme,
            replyTo: _replyTo,
            onCancelReply: () => setState(() => _replyTo = null),
          ),
        ],
      ),
        ]
    )
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.scheme,
  });

  final ChatMessage message;
  final bool isMe;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isMe ? scheme.primary : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isMe ? 'me' : message.senderName,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isMe
                                    ? scheme.onPrimary.withOpacity(0.95)
                                    : scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(message.sentAt),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: isMe
                                  ? scheme.onPrimary.withOpacity(0.85)
                                  : scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.content,
                    style: TextStyle(
                        color: isMe ? scheme.onPrimary : scheme.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.scheme,
    this.replyTo,
    required this.onCancelReply,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final ColorScheme scheme;
  final ChatMessage? replyTo;
  final VoidCallback onCancelReply;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surface,
      elevation: 4,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyTo != null)
              Container(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
                color: scheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Icon(Icons.reply_rounded, size: 16, color: scheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        replyTo!.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: onCancelReply,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.xs, AppSpacing.sm, AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : IconButton.filled(
                          onPressed: onSend,
                          icon: const Icon(Icons.send_rounded),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeToReply extends StatefulWidget {
  const _SwipeToReply({
    required this.child,
    required this.isMe,
    required this.onReply,
  });

  final Widget child;
  final bool isMe;
  final VoidCallback onReply;

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply> {
  double _dragOffset = 0;
  bool _triggered = false;
  static const _threshold = 60.0;

  void _onUpdate(DragUpdateDetails d) {
    final delta = widget.isMe ? -d.delta.dx : d.delta.dx;
    if (delta < 0) return;
    setState(() => _dragOffset = (_dragOffset + delta).clamp(0.0, _threshold));
    if (!_triggered && _dragOffset >= _threshold) {
      _triggered = true;
      widget.onReply();
    }
  }

  void _onEnd(DragEndDetails _) {
    setState(() {
      _dragOffset = 0;
      _triggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onHorizontalDragUpdate: _onUpdate,
      onHorizontalDragEnd: _onEnd,
      child: Stack(
        children: [
          if (_dragOffset > 0)
            Positioned(
              left: widget.isMe ? null : 0,
              right: widget.isMe ? 0 : null,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: (_dragOffset / _threshold).clamp(0.0, 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.reply_rounded,
                      color: scheme.primary, size: 20),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(widget.isMe ? -_dragOffset : _dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
