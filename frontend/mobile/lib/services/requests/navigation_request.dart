import 'package:dio/dio.dart';
// import 'package:logger/logger.dart';

import '../../models/navigation_model.dart';
import 'base.dart';


class NavigationRequest extends Base {
  Future<List<NearestShelterRouteModel>> fetchNearestShelters({
    required double latitude,
    required double longitude,
    int limit = 4,
    int candidateLimit = 50,
    String profile = 'driving',
  }) async {
    try {
      final response = await dio.get(
        '/navigate/nearest',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'limit': limit,
          'candidate_limit': candidateLimit,
          'profile': profile,
        },
      );

      return _extractShelterList(response.data);
    } on DioException catch (error) {
      throw mapDioException(
        error,
        fallbackMessage: 'Unable to load nearby shelters right now.',
      );
    }
  }

  Future<NavigationRouteModel> fetchRouteToShelter({
    required String shelterId,
    required double latitude,
    required double longitude,
    String profile = 'driving',
  }) async {
    try {
      final response = await dio.get(
        '/navigate/route/$shelterId',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'profile': profile,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return NavigationRouteModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw const RequestException('The route response was not valid.');
    } on DioException catch (error) {
      throw mapDioException(
        error,
        fallbackMessage: 'Unable to load the route right now.',
      );
    }
  }

  List<NearestShelterRouteModel> _extractShelterList(dynamic data) {
    if (data == null || data is String && data.trim().isEmpty) {
      return [];
    }

    if (data is List) {
      return _toShelterModels(data);
    }

    if (data is Map<String, dynamic>) {
      for (final key in ['shelters', 'results', 'data']) {
        final candidate = data[key];
        if (candidate is List) {
          return _toShelterModels(candidate);
        }
      }

      if (data.containsKey('shelter_id')) {
        return [NearestShelterRouteModel.fromJson(data)];
      }
    }

    return [];
  }

  List<NearestShelterRouteModel> _toShelterModels(List items) {
    return items
        .whereType<Map>()
        .map(
          (item) => NearestShelterRouteModel.fromJson(
            item.cast<String, dynamic>(),
          ),
        )
        .toList();
  }
}
