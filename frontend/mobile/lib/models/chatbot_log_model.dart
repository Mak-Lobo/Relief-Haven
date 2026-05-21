class ChatbotLogModel {
  final String chatId;
  final String userId;
  final String prompt;
  final String response;
  final DateTime createdAt;

  ChatbotLogModel({
    required this.chatId,
    required this.userId,
    required this.prompt,
    required this.response,
    required this.createdAt,
  });

  factory ChatbotLogModel.fromJson(Map<String, dynamic> json) {
    return ChatbotLogModel(
      chatId: json['chat_id'] as String,
      userId: json['user_id'] as String,
      prompt: json['prompt'] as String,
      response: json['response'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'chat_id': chatId,
  //     'user_id': userId,
  //     'prompt': prompt,
  //     'response': response,
  //     'created_at': createdAt.toIso8601String(),
  //   };
  // }

  ChatbotLogModel copyWith({
    String? chatId,
    String? userId,
    String? prompt,
    String? response,
    DateTime? createdAt,
  }) {
    return ChatbotLogModel(
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      prompt: prompt ?? this.prompt,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Request payload for chatbot interaction.
/// User input from mobile is only the prompt; user/date metadata is backend-derived.
class ChatPromptRequest {
  final String userId;
  final String prompt;

  const ChatPromptRequest({required this.prompt, required this.userId});

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'prompt': prompt};
  }
}
