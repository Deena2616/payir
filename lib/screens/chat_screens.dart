import '../models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/glass.dart';
import '../core/l10n.dart';
import '../core/units.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import 'agreements_screens.dart';
import 'common.dart';
import 'shared_bits.dart';

// The three chat types for a buyer.
enum ChatType { farmers, groups, support }

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  ChatType _type = ChatType.farmers;
  String _query = '';

  static const Map<ChatType, String> _labels = {
    ChatType.farmers: 'Farmers',
    ChatType.groups: 'Groups',
    ChatType.support: 'Support',
  };

  static const Map<ChatType, IconData> _icons = {
    ChatType.farmers: Icons.agriculture,
    ChatType.groups: Icons.groups,
    ChatType.support: Icons.support_agent,
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().loadChats();
      }
    });
  }

  String _chatTime(DateTime time) {
    final now = DateTime.now();

    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return fmtTime(time);
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (time.year == yesterday.year &&
        time.month == yesterday.month &&
        time.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _avatar(String name, ChatType type) {
    switch (type) {
      case ChatType.farmers:
        return CircleAvatar(
          backgroundColor: kGreen,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'F',
            style: const TextStyle(color: Colors.white),
          ),
        );

      case ChatType.groups:
        return const CircleAvatar(
          backgroundColor: kTeal,
          child: Icon(Icons.groups, color: Colors.white),
        );

      case ChatType.support:
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.support_agent, color: Colors.white),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final allChats = s.sortedChats;
    final q = _query.trim().toLowerCase();

    // Keep the result type consistent for every tab.
    final visibleChats = allChats.where((chat) {
      if (_type != ChatType.farmers) {
        return false;
      }

      final lastMessage =
      chat.msgs.isNotEmpty ? chat.msgs.last.text : '';

      return q.isEmpty ||
          chat.farmerName.toLowerCase().contains(q) ||
          chat.crop.toLowerCase().contains(q) ||
          lastMessage.toLowerCase().contains(q);
    }).toList();

    return FloatingScaffold(
      bottomInset: 96,
      appBar: AppBar(
        title: Text(context.tr('tab_chats')),
        actions: const [LangSwitch()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              onChanged: (value) {
                setState(() => _query = value);
              },
              decoration: deco(
                'Search chats',
                icon: Icons.search,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final type in ChatType.values)
                  ChoiceChip(
                    avatar: Icon(
                      _icons[type],
                      size: 18,
                      color: _type == type ? Colors.white : kGreen,
                    ),
                    label: Text(_labels[type]!),
                    labelStyle: TextStyle(
                      color: _type == type ? Colors.white : kInk,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedColor: kGreen,
                    showCheckmark: false,
                    selected: _type == type,
                    onSelected: (_) {
                      setState(() => _type = type);
                    },
                  ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: s.loadChats,
              child: _type != ChatType.farmers
                  ? ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'No conversations here yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              )
                  : visibleChats.isEmpty
                  ? ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'No farmer chats yet.',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Open a farmer listing and tap Chat to start.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  12,
                  4,
                  12,
                  12,
                ),
                itemCount: visibleChats.length,
                itemBuilder: (context, index) {
                  final chat = visibleChats[index];

                  final lastMessage = chat.msgs.isNotEmpty
                      ? chat.msgs.last.text
                      : 'Start a conversation';

                  return GlassCard(
                    key: ValueKey(chat.id),
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading: _avatar(
                        chat.farmerName,
                        ChatType.farmers,
                      ),
                      title: Text(
                        '${chat.farmerName} · ${chat.crop}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            _chatTime(chat.lastTime),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (chat.unread > 0)
                            Badge(
                              label: Text(
                                '${chat.unread}',
                              ),
                            ),
                          if (chat.blocked)
                            const Icon(
                              Icons.block,
                              size: 16,
                              color: Colors.red,
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Compatibility screen for older navigation references.
class ChatConversationScreen extends StatelessWidget {
  final String farmer;
  final String crop;
  final bool showListingBanner;

  const ChatConversationScreen({
    super.key,
    this.farmer = 'Farmer',
    this.crop = '',
    this.showListingBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingScaffold(
      appBar: AppBar(
        title: Text('$farmer · $crop'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'This conversation is not connected to a database chat yet. '
                'Open the farmer listing and tap Chat to start a conversation.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Database-backed conversation screen.
class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctl = TextEditingController();

  late final AppState _app;

  bool _isSending = false;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();

    _app = context.read<AppState>();
    _app.setOpenChat(widget.chatId);
  }

  @override
  void dispose() {
    _app.setOpenChat(null);
    _ctl.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _send(Chat chat) async {
    final message = _ctl.text.trim();

    if (message.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await _app.sendMessage(chat, message);

      if (!mounted) return;

      _ctl.clear();
    } catch (e) {
      _showMessage('Could not send message: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _updateChatStatus(
      Chat chat,
      String action,
      ) async {
    if (_isUpdatingStatus) return;

    setState(() => _isUpdatingStatus = true);

    try {
      if (action == 'report') {
        await _app.reportChat(chat);
        _showMessage('Chat reported successfully.');
      } else {
        await _app.blockChat(chat);
        _showMessage('Chat blocked successfully.');
      }
    } catch (e) {
      _showMessage('Could not update chat: $e');
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final chat = s.chatById(widget.chatId);

    if (chat == null) {
      return FloatingScaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Conversation not found.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => s.loadChats(),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    final listing = s.listingById(chat.listingId);
    final canSend = s.approved && !chat.blocked;
    final msgs = chat.msgs;

    return FloatingScaffold(
      appBar: AppBar(
        title: Text('${chat.farmerName} · ${chat.crop}'),
        actions: [
          if (listing != null)
            IconButton(
              icon: const Icon(Icons.handshake),
              tooltip: s.t('propose_deal'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AgreementFormScreen(
                      listingId: listing.id,
                    ),
                  ),
                );
              },
            ),

          PopupMenuButton<String>(
            enabled: !_isUpdatingStatus,
            onSelected: (value) {
              _updateChatStatus(chat, value);
            },
            itemBuilder: (_) => [
              if (!chat.reported)
                PopupMenuItem(
                  value: 'report',
                  child: Text(s.t('report')),
                ),
              if (!chat.blocked)
                PopupMenuItem(
                  value: 'block',
                  child: Text(s.t('block')),
                ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          if (listing != null)
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(10),
              child: Text(
                '${listing.crop} ${listing.variety} · '
                    '${fmtNum(listing.quantity)} '
                    '${s.t(listing.unit.key)} · '
                    '${listing.village}',
              ),
            ),

          Expanded(
            child: msgs.isEmpty
                ? const Center(
              child: Text(
                'No messages yet. Send the first message.',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: msgs.length,
              itemBuilder: (_, index) {
                final m = msgs[msgs.length - 1 - index];

                return Align(
                  alignment: m.fromBuyer
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 3,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: m.fromBuyer
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(m.text),
                        Text(
                          fmtTime(m.time),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (chat.blocked)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(s.t('blocked')),
            )
          else if (!canSend)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(s.t('chat_locked')),
            )
          else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctl,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(chat),
                        decoration: InputDecoration(
                          hintText: s.t('type_message'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: _isSending
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.send),
                      onPressed:
                      _isSending ? null : () => _send(chat),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
