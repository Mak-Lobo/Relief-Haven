import 'package:dio/dio.dart';
import '../../models/chatbot_log_model.dart';
import 'base.dart';

class ChatRequests extends Base {
  Future<ChatbotLogModel> generateNewChat(ChatPromptRequest request) async {
    return _withMappedErrors(
      () async {
        final response = await dio.post('/chat/new', data: request.toJson());
        return ChatbotLogModel.fromJson(response.data);
      },
      fallbackMessage: 'Failed to generate chat response.',
    );
  }

  Future<List<ChatbotLogModel>> getChatHistory(String userId) async {
    try {
      final response = await dio.get('/chat/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => ChatbotLogModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // If the FastAPI backend returns 404 for no history, we might want to return an empty list
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw mapDioException(
        e,
        fallbackMessage: 'Failed to fetch chat history.',
      );
    }
  }

  Future<void> deleteChat(String chatId) {
    return _withMappedErrors<void>(
      () async {
        await dio.delete('/chat/$chatId');
      },
      fallbackMessage: 'Failed to delete chat entry.',
    );
  }

  Future<T> _withMappedErrors<T>(
    Future<T> Function() request, {
    required String fallbackMessage,
  }) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw mapDioException(e, fallbackMessage: fallbackMessage);
    }
  }
}
