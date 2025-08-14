import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http_parser/http_parser.dart';
import 'auth_service.dart';
import 'session_service.dart';
import 'user_service.dart';

class PetService {
  // Select proper backend URL based on platform
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://${AuthService.getPhysicalDeviceIP()}:3000';
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
    // Only get ownerId from session if we're fetching user-specific pets
    // Lost and found pets should be visible to everyone
    String? finalOwnerId = ownerId;

    // Only try to get ownerId from session if we're not fetching lost/found pets for public view
    if (finalOwnerId == null && (isLost == null && isFound == null)) {
      // First check if we have a valid backend session
      final userService = UserService();
      final hasValidSession = await userService.hasValidBackendSession();

      if (hasValidSession) {
        finalOwnerId = await SessionService().getBackendUserId();
        print('PetService: Using ownerId from valid session: $finalOwnerId');
      } else {
        print('PetService: No valid backend session found');
      }
    }

    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    // Only add ownerId if it's a valid MongoDB ObjectId (24 hex characters)
    if (finalOwnerId != null &&
        finalOwnerId.length == 24 &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(finalOwnerId)) {
      params['ownerId'] = finalOwnerId;
    } else if (finalOwnerId != null) {
      print('PetService: Invalid ownerId format, skipping: $finalOwnerId');
    }
    if (petType != null) params['petType'] = petType;
    if (isLost != null) params['isLost'] = isLost.toString();
    if (isFound != null) params['isFound'] = isFound.toString();
    if (registrationType != null) params['registrationType'] = registrationType;

    print('PetService: Fetching pets with params: $params');
    if (isLost != null || isFound != null) {
      print(
          'PetService: Fetching public lost/found pets - no authentication required');
    }

    final uri =
        Uri.parse('$_backendUrl/api/pets').replace(queryParameters: params);
    final res =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    print('PetService: Response status: ${res.statusCode}');
    print('PetService: Response body: ${res.body}');

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
    String? ownerId,
    String registrationType = 'registered', // Default to registered
    File? profileImageFile,
  }) async {
    // If ownerId is not provided, try to get it from session
    String? finalOwnerId = ownerId;
    if (finalOwnerId == null) {
      // First check if we have a valid backend session
      final userService = UserService();
      final hasValidSession = await userService.hasValidBackendSession();

      if (hasValidSession) {
        finalOwnerId = await SessionService().getBackendUserId();
        print(
            'PetService: Using ownerId from valid session for createPet: $finalOwnerId');
      } else {
        print('PetService: No valid backend session found for createPet');
      }
    }

    if (finalOwnerId == null) {
      throw Exception('Owner ID is required. Please log in again.');
    }
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
          'ownerId': finalOwnerId,
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
          ..fields['ownerId'] = finalOwnerId
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
    Function(int, double)? onProgress,
  }) async {
    if (files.isEmpty) return;

    print(
        'PetService: Starting parallel upload of ${files.length} photos for pet $petId');
    print('PetService: Backend URL: $_backendUrl');

    // Test backend connectivity first
    try {
      final testResponse = await http.get(
        Uri.parse('$_backendUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      print(
          'PetService: Backend health check status: ${testResponse.statusCode}');
      if (testResponse.statusCode != 200) {
        throw Exception(
            'Backend is not responding properly. Status: ${testResponse.statusCode}');
      }
    } catch (e) {
      print('PetService: Backend connectivity test failed: $e');
      throw Exception(
          'Cannot connect to backend server. Please check your network connection and ensure the backend is running.');
    }

    // Upload photos in parallel using multiple requests
    final List<Future<void>> uploadFutures =
        files.asMap().entries.map((entry) async {
      final int index = entry.key;
      final File file = entry.value;

      try {
        print(
            'PetService: Starting upload for photo ${index + 1}: ${file.path}');
        print('PetService: File exists: ${await file.exists()}');
        print('PetService: File size: ${await file.length()} bytes');

        final request = http.MultipartRequest(
            'POST', Uri.parse('$_backendUrl/api/pets/$petId/upload-photos'));

        // Get file extension to determine MIME type
        final String extension = file.path.split('.').last.toLowerCase();
        String mimeType = 'image/jpeg'; // default

        switch (extension) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          case 'jpg':
          case 'jpeg':
          default:
            mimeType = 'image/jpeg';
            break;
        }

        print('PetService: Using MIME type: $mimeType for file: ${file.path}');

        request.files.add(await http.MultipartFile.fromPath(
          'photos',
          file.path,
          contentType: MediaType.parse(mimeType),
        ));

        final streamed =
            await request.send().timeout(const Duration(seconds: 30));
        final res = await http.Response.fromStream(streamed);

        print('PetService: Upload response status: ${res.statusCode}');
        print('PetService: Upload response body: ${res.body}');

        if (res.statusCode != 200) {
          throw Exception('Upload photo failed: ${res.body}');
        }

        print(
            'PetService: Successfully uploaded photo ${index + 1}/${files.length}');
        if (onProgress != null) {
          onProgress(index, 1.0); // 100% progress for this photo
        }
      } catch (e) {
        print('PetService: Error uploading photo ${index + 1}: $e');
        print('PetService: Error details: ${e.toString()}');
        rethrow;
      }
    }).toList();

    // Wait for all uploads to complete in parallel
    await Future.wait(uploadFutures);
    print('PetService: All photos uploaded successfully for pet $petId');
  }

  // Recover session for Google users
  Future<bool> _recoverSession() async {
    try {
      print('PetService: Attempting to recover session...');

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('PetService: No Firebase user found');
        return false;
      }

      print('PetService: Firebase user found: ${firebaseUser.uid}');
      print('PetService: Firebase user email: ${firebaseUser.email}');

      final userService = UserService();
      final success = await userService.forceRefreshBackendSession();

      if (success) {
        print('PetService: Session recovered successfully');
        // Verify the session was actually saved
        final userId = await SessionService().getBackendUserId();
        print('PetService: Verified session recovery, user ID: $userId');
        return userId != null;
      } else {
        print('PetService: Failed to recover session');
        return false;
      }
    } catch (e) {
      print('PetService: Error recovering session: $e');
      return false;
    }
  }
}
