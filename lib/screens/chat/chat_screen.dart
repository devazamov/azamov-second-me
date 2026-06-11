/// ═══════════════════════════════════════════════════════════════
/// Chat Screen - AZAMOV Second Me
/// Future Self AI Chat - Core Feature
/// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/chat_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  // Voice Input
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    // Start a new chat session if none exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatId = ref.read(currentChatIdProvider);
      if (chatId == null) {
        ref.read(chatNotifierProvider.notifier).startNewChat();
      }
      _initSpeech();
    });
  }
  
  Future<void> _initSpeech() async {
    final available = await _speech.initialize();
    if (mounted) setState(() => _speechAvailable = available);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _messageController.clear();

    // Scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
  
  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    } else {
      final result = await _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
          // Auto-send when user stops speaking
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _speech.stop();
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'uz_UZ',
      );
      if (mounted) {
        setState(() => _isListening = result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final messages = ref.watch(chatMessagesProvider);
    final user = ref.watch(currentUserProvider);

    // Show error snackbar
    ref.listen<ChatState>(chatNotifierProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(chatNotifierProvider.notifier).state =
            next.copyWith(clearError: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelajakdagi O\'zing',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user.valueOrNull?.isPremium ?? false
                      ? 'Premium'
                      : '${user.valueOrNull?.dailyChatsUsed ?? 0}/${5} chat',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 24),
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).startNewChat();
              ref.invalidate(chatMessagesProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Messages List ───
          Expanded(
            child: messages.when(
              data: (messageList) {
                if (messageList.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final message = messageList[index];
                    return _MessageBubble(
                      message: message,
                      isLast: index == messageList.length - 1,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Xatolik: $e')),
            ),
          ),

          // ─── Typing Indicator ───
          if (chatState.isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.silverLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Kelajakdagingiz javob yozmoqda',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ─── Message Input ───
          _MessageInput(
            controller: _messageController,
            focusNode: _focusNode,
            onSend: _sendMessage,
            canSend: !chatState.isTyping && !chatState.isSending,
            isListening: _isListening,
            speechAvailable: _speechAvailable,
            onVoiceToggle: _toggleListening,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kelajakdagi o\'zing bilan gaplashishni boshlang',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI sizning kelajak versiyangiz sifatida maslahat beradi va maqsadlaringizga erishishda yordam beradi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  text: 'German tilini o\'rganyapman',
                  onTap: (text) {
                    _messageController.text = text;
                    _sendMessage();
                  },
                ),
                _SuggestionChip(
                  text: 'Bugun sport bilan shug\'ullandim',
                  onTap: (text) {
                    _messageController.text = text;
                    _sendMessage();
                  },
                ),
                _SuggestionChip(
                  text: 'Yangi biznes g\'oya bor',
                  onTap: (text) {
                    _messageController.text = text;
                    _sendMessage();
                  },
                ),
              ],
            ),

            // ─── Voice Input Button ───
            if (_speechAvailable) ...[const SizedBox(height: 24),
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ovozli xabar yuborish',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ─── Message Bubble ───
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLast;

  const _MessageBubble({
    required this.message,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppColors.silverLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUser
                  ? Text(
                      message.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        strong: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        em: TextStyle(
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// ─── Message Input ───
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool canSend;
  final bool isListening;
  final bool speechAvailable;
  final VoidCallback onVoiceToggle;

  const _MessageInput({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.canSend,
    this.isListening = false,
    this.speechAvailable = false,
    required this.onVoiceToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.silverLight, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ─── Voice Button ───
            if (speechAvailable) ...[                GestureDetector(
                onTap: onVoiceToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isListening ? AppColors.premiumGradient : null,
                    color: isListening ? null : AppColors.background,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isListening ? Colors.transparent : AppColors.silverLight,
                    ),
                    boxShadow: isListening
                        ? [BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 0),
                          )]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: isListening ? Colors.white : AppColors.textMuted,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isListening ? AppColors.errorLight : AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isListening ? AppColors.error : AppColors.silverLight,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: isListening ? 'Gapiryapsiz...' : 'Kelajakdagingizga yozing...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: canSend ? onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: canSend ? AppColors.primaryGradient : null,
                  color: canSend ? null : AppColors.silverLight,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: canSend
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: const Center(
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Suggestion Chip ───
class _SuggestionChip extends StatelessWidget {
  final String text;
  final Function(String) onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.silverLight),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
