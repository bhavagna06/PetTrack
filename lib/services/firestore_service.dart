import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Management
  Future<void> createUserDocument(Map<String, dynamic> userData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(userData);
      }
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  Future<void> updateUserDocument(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user document: $e');
      rethrow;
    }
  }

  // Pet Management
  Future<String> createPetDocument(Map<String, dynamic> petData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docRef = await _firestore.collection('pets').add({
          ...petData,
          'ownerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return docRef.id;
      }
      throw Exception('User not authenticated');
    } catch (e) {
      print('Error creating pet document: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getPetDocument(String petId) async {
    try {
      final doc = await _firestore.collection('pets').doc(petId).get();
      return doc.data();
    } catch (e) {
      print('Error getting pet document: $e');
      return null;
    }
  }

  Future<void> updatePetDocument(
    String petId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating pet document: $e');
      rethrow;
    }
  }

  Future<void> deletePetDocument(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
    } catch (e) {
      print('Error deleting pet document: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUserPets(String userId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Report Management (Lost/Found)
  Future<String> createReportDocument(Map<String, dynamic> reportData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final docRef = await _firestore.collection('reports').add({
          ...reportData,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });
        return docRef.id;
      }
      throw Exception('User not authenticated');
    } catch (e) {
      print('Error creating report document: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getReportDocument(String reportId) async {
    try {
      final doc = await _firestore.collection('reports').doc(reportId).get();
      return doc.data();
    } catch (e) {
      print('Error getting report document: $e');
      return null;
    }
  }

  Future<void> updateReportDocument(
    String reportId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating report document: $e');
      rethrow;
    }
  }

  Future<void> deleteReportDocument(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
    } catch (e) {
      print('Error deleting report document: $e');
      rethrow;
    }
  }

  // Get all reports (for lost/found feed)
  Stream<QuerySnapshot> getAllReports() {
    return _firestore
        .collection('reports')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get reports by type (lost/found)
  Stream<QuerySnapshot> getReportsByType(String type) {
    return _firestore
        .collection('reports')
        .where('type', isEqualTo: type)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get user's reports
  Stream<QuerySnapshot> getUserReports(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Search reports by location
  Stream<QuerySnapshot> searchReportsByLocation(String location) {
    return _firestore
        .collection('reports')
        .where('location', isGreaterThanOrEqualTo: location)
        .where('location', isLessThan: location + '\uf8ff')
        .where('status', isEqualTo: 'active')
        .orderBy('location')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Search reports by pet type
  Stream<QuerySnapshot> searchReportsByPetType(String petType) {
    return _firestore
        .collection('reports')
        .where('petType', isEqualTo: petType)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mark report as resolved
  Future<void> markReportAsResolved(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': 'resolved',
        'resolvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking report as resolved: $e');
      rethrow;
    }
  }

  // Add comment to report
  Future<void> addCommentToReport(
    String reportId,
    Map<String, dynamic> comment,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('reports')
            .doc(reportId)
            .collection('comments')
            .add({
              ...comment,
              'userId': user.uid,
              'userName': user.displayName ?? 'Anonymous',
              'createdAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Get comments for a report
  Stream<QuerySnapshot> getReportComments(String reportId) {
    return _firestore
        .collection('reports')
        .doc(reportId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Update user preferences
  Future<void> updateUserPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user preferences: $e');
      rethrow;
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final petsSnapshot = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: userId)
          .get();

      final reportsSnapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .get();

      final resolvedReportsSnapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'resolved')
          .get();

      return {
        'totalPets': petsSnapshot.docs.length,
        'totalReports': reportsSnapshot.docs.length,
        'resolvedReports': resolvedReportsSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {'totalPets': 0, 'totalReports': 0, 'resolvedReports': 0};
    }
  }

  // Batch operations
  Future<void> batchUpdateDocuments(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();

      for (var update in updates) {
        final docRef = _firestore
            .collection(update['collection'])
            .doc(update['id']);
        batch.update(docRef, update['data']);
      }

      await batch.commit();
    } catch (e) {
      print('Error in batch update: $e');
      rethrow;
    }
  }

  // Real-time listeners
  Stream<DocumentSnapshot> watchDocument(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  Stream<QuerySnapshot> watchCollection(
    String collection, {
    List<Query Function(Query)>? queries,
  }) {
    Query query = _firestore.collection(collection);

    if (queries != null) {
      for (var queryFunction in queries) {
        query = queryFunction(query);
      }
    }

    return query.snapshots();
  }
}
