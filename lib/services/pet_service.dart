import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PetService {
  // Select proper backend URL based on platform
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return Platform.isAndroid
          ? 'http://10.0.2.2:3000'
          : 'http://localhost:3000';
    }
  }

  Future<List<Map<String, dynamic>>> fetchPets({
    String? ownerId,
    String? petType,
    bool? isLost,
    bool? isFound,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (ownerId != null) params['ownerId'] = ownerId;
    if (petType != null) params['petType'] = petType;
    if (isLost != null) params['isLost'] = isLost.toString();
    if (isFound != null) params['isFound'] = isFound.toString();

    final uri =
        Uri.parse('$_backendUrl/api/pets').replace(queryParameters: params);
    final res =
        await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch pets: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['data'] as List).cast<Map<String, dynamic>>();
    return list;
  }

  Future<Map<String, dynamic>> createPet({
    required String petName,
    required String petType,
    required String breed,
    required String gender,
    required String color,
    required String homeLocation,
    required String ownerId,
    File? profileImageFile,
  }) async {
    // If no image, send JSON; if image, send multipart so backend can upload to Firebase Storage
    if (profileImageFile == null) {
      final res = await http.post(
        Uri.parse('$_backendUrl/api/pets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'petName': petName,
          'petType': petType,
          'breed': breed,
          'gender': gender,
          'color': color,
          'homeLocation': homeLocation,
          'ownerId': ownerId,
        }),
      );
      if (res.statusCode != 201) {
        throw Exception('Create pet failed: ${res.body}');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    final request =
        http.MultipartRequest('POST', Uri.parse('$_backendUrl/api/pets'))
          ..fields['petName'] = petName
          ..fields['petType'] = petType
          ..fields['breed'] = breed
          ..fields['gender'] = gender
          ..fields['color'] = color
          ..fields['homeLocation'] = homeLocation
          ..fields['ownerId'] = ownerId
          ..files.add(await http.MultipartFile.fromPath(
              'profileImage', profileImageFile.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 201) {
      throw Exception('Create pet failed: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePet({
    required String petId,
    required String petName,
    required String petType,
    required String breed,
    required String gender,
    required String color,
    required String homeLocation,
    required String ownerId,
    File? profileImageFile,
  }) async {
    if (profileImageFile == null) {
      final res = await http.put(
        Uri.parse('$_backendUrl/api/pets/$petId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'petName': petName,
          'petType': petType,
          'breed': breed,
          'gender': gender,
          'color': color,
          'homeLocation': homeLocation,
          'ownerId': ownerId,
        }),
      );
      if (res.statusCode != 200) {
        throw Exception('Update pet failed: ${res.body}');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    final request =
        http.MultipartRequest('PUT', Uri.parse('$_backendUrl/api/pets/$petId'))
          ..fields['petName'] = petName
          ..fields['petType'] = petType
          ..fields['breed'] = breed
          ..fields['gender'] = gender
          ..fields['color'] = color
          ..fields['homeLocation'] = homeLocation
          ..fields['ownerId'] = ownerId
          ..files.add(await http.MultipartFile.fromPath(
              'profileImage', profileImageFile.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception('Update pet failed: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> uploadAdditionalPhotos({
    required String petId,
    required List<File> files,
  }) async {
    if (files.isEmpty) return;
    final request = http.MultipartRequest(
        'POST', Uri.parse('$_backendUrl/api/pets/$petId/upload-photos'));
    for (final f in files) {
      request.files.add(await http.MultipartFile.fromPath('photos', f.path));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception('Upload photos failed: ${res.body}');
    }
  }

  Future<void> markLost(String petId) async {
    final res =
        await http.post(Uri.parse('$_backendUrl/api/pets/$petId/mark-lost'));
    if (res.statusCode != 200) {
      throw Exception('Mark lost failed: ${res.body}');
    }
  }

  Future<void> markFound(String petId) async {
    final res =
        await http.post(Uri.parse('$_backendUrl/api/pets/$petId/mark-found'));
    if (res.statusCode != 200) {
      throw Exception('Mark found failed: ${res.body}');
    }
  }
}
