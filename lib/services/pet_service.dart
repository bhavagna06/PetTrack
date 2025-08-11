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
    String? registrationType,
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
    if (registrationType != null) params['registrationType'] = registrationType;

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
    String registrationType = 'registered', // Default to registered
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
          'registrationType': registrationType,
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
          ..fields['registrationType'] = registrationType
          ..files.add(await http.MultipartFile.fromPath(
              'profileImage', profileImageFile.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 201) {
      throw Exception('Create pet failed: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // Get a single pet by ID
  Future<Map<String, dynamic>> getPetById(String petId) async {
    final res = await http.get(
      Uri.parse('$_backendUrl/api/pets/$petId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch pet: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePet({
    required String petId,
    String? petName,
    String? petType,
    String? breed,
    String? gender,
    String? color,
    String? homeLocation,
    String? ownerId,
    File? profileImageFile,
  }) async {
    // If no image, send JSON; if image, send multipart so backend can upload to Firebase Storage
    if (profileImageFile == null) {
      final updateData = <String, dynamic>{};
      if (petName != null) updateData['petName'] = petName;
      if (petType != null) updateData['petType'] = petType;
      if (breed != null) updateData['breed'] = breed;
      if (gender != null) updateData['gender'] = gender;
      if (color != null) updateData['color'] = color;
      if (homeLocation != null) updateData['homeLocation'] = homeLocation;
      if (ownerId != null) updateData['ownerId'] = ownerId;

      final res = await http.put(
        Uri.parse('$_backendUrl/api/pets/$petId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );
      if (res.statusCode != 200) {
        throw Exception('Update pet failed: ${res.body}');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    final request =
        http.MultipartRequest('PUT', Uri.parse('$_backendUrl/api/pets/$petId'))
          ..files.add(await http.MultipartFile.fromPath(
              'profileImage', profileImageFile.path));

    if (petName != null) request.fields['petName'] = petName;
    if (petType != null) request.fields['petType'] = petType;
    if (breed != null) request.fields['breed'] = breed;
    if (gender != null) request.fields['gender'] = gender;
    if (color != null) request.fields['color'] = color;
    if (homeLocation != null) request.fields['homeLocation'] = homeLocation;
    if (ownerId != null) request.fields['ownerId'] = ownerId;

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception('Update pet failed: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // Mark pet as lost
  Future<Map<String, dynamic>> markPetAsLost(String petId) async {
    final res = await http.post(
      Uri.parse('$_backendUrl/api/pets/$petId/mark-lost'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to mark pet as lost: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // Mark pet as found
  Future<Map<String, dynamic>> markPetAsFound(String petId) async {
    final res = await http.post(
      Uri.parse('$_backendUrl/api/pets/$petId/mark-found'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to mark pet as found: ${res.body}');
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
}
