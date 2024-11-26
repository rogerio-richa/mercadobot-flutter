import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:messaging_ui/core/core_service.dart';

class ChatService {
  final ChatManager chatManager = ChatManager();
  ChatManager get getChatManager => chatManager;

  Future<bool> sendMessage({
    required String message,
    String? base64Audio,
  }) async {
    WebSocket? webSocket = CoreService().webSocket;
    if (webSocket?.closeCode != null) {
      print('WebSocket is not connected');
      return false;
    }

    try {
      final chatUid = CoreService().webSocketId;
      final payload = base64Audio == null
          ? jsonEncode({'message': message, 'chat_uid': chatUid})
          : "$chatUid$base64Audio";

      webSocket?.add(payload);
      print('Sent message: $message');

      if (base64Audio == null) {
        final newChatEntry = ChatEntry(
          sender: 'user',
          timestamp: DateTime.now(),
          message: ChatMessage(text: message),
        );

        chatManager.addMessage(newChatEntry);
      }
      return true;
    } catch (e) {
      print('Failed to send message: $e');
      return false;
    }
  }
}

class ChatManager {
  final List<ChatEntry> _messages = []; // Stateful storage of messages
  final StreamController<List<ChatEntry>> _messageStreamController =
      StreamController.broadcast();

  Stream<List<ChatEntry>> get messages => _messageStreamController.stream;

  void addMessage(ChatEntry message) {
    _messages.add(message);
    _messageStreamController.add(List.unmodifiable(_messages));
  }

  void addMessages(List<ChatEntry> newMessages) {
    _messages.addAll(newMessages);
    _messageStreamController.add(List.unmodifiable(_messages));
  }

  void clearMessages() {
    _messages.clear();
    _messageStreamController.add(List.unmodifiable(_messages));
  }

  void getMessageHistory() {
    _messageStreamController.add(List.unmodifiable(_messages));
  }

  void dispose() {
    _messageStreamController.close();
  }
}

class ChatEntry {
  final String sender;
  final DateTime timestamp;
  final ChatMessage message;

  ChatEntry({
    required this.sender,
    required this.timestamp,
    required this.message,
  });

  factory ChatEntry.fromJson(Map<String, dynamic> json) {
    return ChatEntry(
      sender: json['sender'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: ChatMessage.fromJson(json['message'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to string
      'message': message.toJson(), // Convert message to JSON
    };
  }
}

class ChatMessage {
  final String text;
  final List<ProductResponse>? productList;
  final List<ProductResponse>? cartElements;
  final List<String>? listElements;

  ChatMessage({
    required this.text,
    this.productList,
    this.cartElements,
    this.listElements,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      productList: (json['productList'] as List<dynamic>?)
          ?.map((e) => ProductResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      cartElements: (json['cartElements'] as List<dynamic>?)
          ?.map((e) => ProductResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      listElements: (json['listElements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  // Convert the ChatMessage object to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'productList': productList?.map((e) => e.toJson()).toList(),
      'cartElements': cartElements?.map((e) => e.toJson()).toList(),
      'listElements': listElements,
    };
  }
}

class ProductResponse {
  final String category;
  final String image;
  final double price;
  final String name;
  final double unit;
  final String measure;
  final String brand;
  final String id;

  ProductResponse({
    required this.category,
    required this.image,
    required this.price,
    required this.name,
    required this.unit,
    required this.measure,
    required this.brand,
    required this.id,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      category: json['category'] as String,
      image: json['image'] as String,
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'] as double,
      name: json['name'] as String,
      unit: json['unit'] is int
          ? (json['unit'] as int).toDouble()
          : json['unit'] as double,
      measure: json['measure'] as String,
      brand: json['brand'] as String,
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'image': image,
      'price': price,
      'name': name,
      'unit': unit,
      'measure': measure,
      'brand': brand,
      'id': id,
    };
  }
}
