import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:relief_haven_mobile/providers/auth_provider.dart';
import 'package:relief_haven_mobile/providers/chat_provider.dart';
import 'package:relief_haven_mobile/utils/elevated_button.dart';
import 'package:relief_haven_mobile/common_widgets/shimmer_loading.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chatState = ref.watch(chatProvider);
    final authState = ref.watch(authProvider);
    final firstName = authState.displayName.trim().split(RegExp(r'\s+')).first;

    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.pendingPrompt != next.pendingPrompt) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colors.error,
          ),
        );
        ref.read(chatProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          'HavenBot',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onPrimary,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: colors.surfaceContainerHigh,
        actions: [
          IconButton(
            onPressed: () => ref.read(chatProvider.notifier).fetchHistory(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatState.isLoading && chatState.messages.isEmpty
                  ? const ChatShimmer()
                  : chatState.messages.isEmpty &&
                        chatState.pendingPrompt == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _WelcomeCopy(firstName: firstName),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount:
                          chatState.messages.length +
                          (chatState.pendingPrompt != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < chatState.messages.length) {
                          final message = chatState.messages[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ChatBubble(
                                text: message.prompt,
                                isUser: true,
                                chatId: message.chatId,
                              ),
                              _ChatBubble(
                                text: message.response,
                                isUser: false,
                                chatId: message.chatId,
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ChatBubble(
                                text: chatState.pendingPrompt!,
                                isUser: true,
                                chatId: 'pending',
                              ),
                              const ChatResponseLoadingShimmer(),
                            ],
                          );
                        }
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _PromptInput(
                controller: _messageController,
                isSending: chatState.isSending,
                onSend: () {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty) {
                    ref.read(chatProvider.notifier).sendMessage(text);
                    _messageController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends ConsumerWidget {
  const _ChatBubble({
    required this.text,
    required this.isUser,
    required this.chatId,
  });

  final String text;
  final bool isUser;
  final String chatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final maxWidth = MediaQuery.of(context).size.width * 0.78;
    void deleteHandler() {
      if (chatId == 'pending') return;
      showModalBottomSheet<void>(
        context: context,
        builder: (context) => SafeArea(
          child: ListTile(
            leading: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
            title: const Text('Delete from history'),
            onTap: () {
              ref.read(chatProvider.notifier).deleteMessage(chatId);
              Navigator.pop(context);
            },
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: isUser
            ? BubbleNormal(
                text: text,
                isSender: true,
                color: colors.primary,
                tail: true,
                bubbleRadius: 15,
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                constraints: BoxConstraints(maxWidth: maxWidth),
                onLongPress: deleteHandler,
                textStyle: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 15,
                  height: 1.35,
                ),
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: deleteHandler,
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      bottomLeft: Radius.circular(2),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: MarkdownBody(
                    data: text,
                    selectable: true,
                    fitContent: true,
                    shrinkWrap: true,
                    softLineBreak: true,
                    styleSheet: _markdownStyleSheet(context),
                  ),
                ),
              ),
      ),
    );
  }
}

MarkdownStyleSheet _markdownStyleSheet(BuildContext context) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final base = MarkdownStyleSheet.fromTheme(theme);

  return base.copyWith(
    p: base.p?.copyWith(
      color: colors.onPrimaryContainer,
      fontSize: 15,
      height: 1.35,
    ),
    // h1: base.h1?.copyWith(color: colors.onPrimaryContainer),
    // h2: base.h2?.copyWith(color: colors.onPrimaryContainer),
    h3: base.h3?.copyWith(color: colors.onPrimaryContainer),
    h4: base.h4?.copyWith(color: colors.onPrimaryContainer),
    // h5: base.h5?.copyWith(color: colors.onSurfaceVariant),
    // h6: base.h6?.copyWith(color: colors.onSurfaceVariant),
    a: base.a?.copyWith(
      color: colors.primary,
      decoration: TextDecoration.underline,
    ),
    listBullet: base.listBullet?.copyWith(
      color: colors.onPrimaryContainer,
      fontSize: 15,
    ),
    code: base.code?.copyWith(
      color: colors.onSurfaceVariant,
      backgroundColor: colors.surfaceContainerLow,
      fontSize: 13.5,
    ),
    blockquote: base.blockquote?.copyWith(color: colors.onPrimaryContainer),
    codeblockDecoration: BoxDecoration(
      color: colors.onPrimaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    blockquoteDecoration: BoxDecoration(
      color: colors.onPrimaryContainer,
      borderRadius: BorderRadius.circular(12),
      border: Border(left: BorderSide(color: colors.outlineVariant, width: 4)),
    ),
  );
}

class _WelcomeCopy extends StatelessWidget {
  const _WelcomeCopy({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome, $firstName, to HavenBot.',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'How can we be of service to you today?\nAsk me anything about disaster relief or first aid.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PromptInput extends StatelessWidget {
  const _PromptInput({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isSending,
              style: textTheme.bodyLarge!.copyWith(
                color: colors.onSurfaceVariant,
              ),
              decoration: InputDecoration(
                hintText: 'Ask HavenBot...',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: isSending ? null : onSend,
            iconSize: 22,
            style: IconButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              minimumSize: const Size(44, 44),
            ),
            icon: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.arrow_upward_rounded),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Chat Screen')
Widget chatScreenPreview() {
  return _buildPreviewApp(const ChatScreen());
}

Widget _buildPreviewApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0277BD),
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(),
        elevatedButtonTheme: customElevatedBtnTheme,
      ),
      home: child,
    ),
  );
}
