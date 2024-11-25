import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/theme/configuration.dart';
import 'package:messaging_ui/utils/utils.dart';

class APIService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<double> get scaleFactor async {
    final scaleString = await storage.read(key: 'textScale');
    return scaleString != null ? double.tryParse(scaleString) ?? 1.0 : 1.0;
  }

  Future<void> setScaleFactor(double newScale) async {
    await storage.write(key: 'textScale', value: newScale.toString());
  }

  Future<String?> get firstName => storage.read(key: 'first_name');
  Future<String?> get lastName => storage.read(key: 'last_name');

  Future<void> updateProfile(String firstName, String lastName) async {
    final jwtToken = await storage.read(key: 'jwtToken');
    if (jwtToken == null) {
      print('JWT token not found');
      return;
    }

    final uid = await storage.read(key: 'uid');

    if (uid == null) {
      print('UID not found');
      return;
    }

    final uri = Uri.parse('https://$baseUrl/v2/admin');
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $jwtToken',
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final body = jsonEncode({
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
    });

    try {
      final response = await http.put(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        await storage.write(key: 'first_name', value: firstName);
        await storage.write(key: 'last_name', value: lastName);
        print('Profile updated successfully');
      } else {
        print('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<dynamic> signIn(String username, String hashedPassword) async {
    try {
      final response = await http.post(
        Uri.parse('https://$baseUrl/v2/public/auth'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username.trim().toLowerCase(),
          'password': hashedPassword,
          'browser': 'flutter',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jwtToken = data['token'];
        if (jwtToken != null) {
          await saveAuthData(jwtToken);
          await CoreService().initWebSocket();
        } else {
          return {};
        }
      } else {
        return {'code': response.statusCode};
      }
    } catch (e) {
          return {};
    }
    return null;
  }

  Future<dynamic> signUp(String firstName, String lastName, String username) async {
    try {
      final response = await http.post(
        Uri.parse('https://$baseUrl/v2/public/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': 'Test',
          'username': username.trim().toLowerCase(),
          'last_name': lastName,
          'first_name': firstName,
        }),
      );

      if (response.statusCode == 200) {
          return true;
      } else {
        return {'code': response.statusCode};
      }
    } catch (e) {
        return {};
    }
  }

  Future<bool> forgotPword(String username) async {
    try {
      final response = await http.post(
        Uri.parse('https://$baseUrl/v2/public/reset'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username.trim().toLowerCase(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveAuthData(String jwtToken) async {
    await storage.write(key: 'jwtToken', value: jwtToken);
    final Map<String, dynamic> payload = decodeJwt(jwtToken);
    await storage.write(key: 'uid', value: payload['uid']);
    await fetchAndStoreAdminData();
  }

  Future<void> signOut() async {
    await storage.deleteAll();
    CoreService().themeService.resetToLight();
    await CoreService().closeWebSocket();
  }

  Future<void> fetchAndStoreAdminData() async {
    try {
      final jwtToken = await storage.read(key: 'jwtToken');
      final uid = await storage.read(key: 'uid');

      if (uid == null) {
        print('UID not found');
        return;
      }

      // Query the admin endpoint
      final response = await http.get(
        Uri.parse('https://$baseUrl/v2/admin'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        final List<dynamic> dataList = jsonDecode(response.body);

        if (dataList.isNotEmpty && validateAdminSchema(dataList[0])) {
          final data =
              dataList[0]; // Access the first element if the list isn't empty

          // Store first_name and last_name in secure storage
          await storage.write(key: 'first_name', value: data['first_name']);
          await storage.write(key: 'last_name', value: data['last_name']);
          print('Admin data successfully stored.');
        } else {
          print('Invalid admin data schema or empty response.');
        }
      } else {
        print('Failed to fetch admin data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching admin data: $e');
    }
  }

  Future<bool> deleteChatHistoryItem(String chatId) async {
    try {
      final jwtToken = await storage.read(key: 'jwtToken'); // Get the JWT token
      if (jwtToken == null) {
        throw Exception('JWT Token not found');
      }

      final url = Uri.parse('https://$baseUrl/v2/admin/chat?uid=$chatId');
      final response = await http.delete(
        url,
        headers: {
          'Authorization':
              'Bearer $jwtToken', // Use the JWT token for authentication
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error fetching descriptions: $e');
    }
  }

  Future<List<String>> fetchProductDescriptions() async {
    try {
      final jwtToken = await storage.read(key: 'jwtToken'); // Get the JWT token
      if (jwtToken == null) {
        throw Exception('JWT Token not found');
      }

      final url = Uri.parse('https://$baseUrl/v2/admin/shopping');
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer $jwtToken', // Use the JWT token for authentication
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<String> descriptions = List<String>.from(data);
        return descriptions;
      } else {
        throw Exception('Failed to load descriptions');
      }
    } catch (e) {
      throw Exception('Error fetching descriptions: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCartItems() async {
    try {
      final jwtToken = await storage.read(key: 'jwtToken'); // Get the JWT token
      if (jwtToken == null) {
        throw Exception('JWT Token not found');
      }

      final url = Uri.parse('https://$baseUrl/v2/admin/cart');
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Bearer $jwtToken', // Use the JWT token for authentication
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> cartItems = [];
        for (var item in data) {
          cartItems.add({
            'category': item['category'],
            'image': item['image'],
            'price': item['price'],
            'name': item['name'],
            'unit': item['unit'],
            'measure': item['measure'],
            'brand': item['brand'],
            'id': item['id'],
          });
        }
        return cartItems;
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      throw Exception('Error fetching cart items: $e');
    }
  }

  // Function to fetch chat history from the server
  Future<List<Map<String, dynamic>>> fetchChatHistory() async {
    try {
      final jwtToken = await storage.read(key: 'jwtToken');
      final uid = await storage.read(key: 'uid');

      if (uid == null) {
        print('UID not found');
      }

      final response = await http
          .get(Uri.parse('https://$baseUrl/v2/admin/chat/list'), headers: {
        HttpHeaders.authorizationHeader: 'Bearer $jwtToken',
        HttpHeaders.contentTypeHeader: 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> chatHistory = [];
        for (var chat in data) {
          chatHistory.add({
            'chat_id': chat['chat_id'],
            'last_message_timestamp': chat['last_message_timestamp'],
          });
        }
        return chatHistory;
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (e) {
      throw Exception('Failed to fetch chat history: $e');
    }
  }
}
