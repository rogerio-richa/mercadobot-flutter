import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:messaging_ui/core/api_service.dart';
import 'package:messaging_ui/core/chat_service.dart';
import 'package:messaging_ui/core/theme_service.dart';
import 'package:messaging_ui/theme/configuration.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ConnectivityStatus {
  connecting,
  connected,
  offline,
}

class CoreService {
  static final CoreService _instance = CoreService._internal();

  factory CoreService() {
    return _instance;
  }

  CoreService._internal();

  late String documentPath;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    documentPath = "${(await getApplicationDocumentsDirectory()).path}/";
    print(documentPath);

    _monitorConnectivity();
  }

  final DateTime _appStartTime = DateTime.now();

  DateTime get getAppStartTime {
    return _appStartTime;
  }

  final APIService apiService = APIService();
  final ThemeService themeService = ThemeService();
  final ChatService chatManager = ChatService();

  final ValueNotifier<ConnectivityStatus> connectivityStatus =
      ValueNotifier(ConnectivityStatus.offline);
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  WebSocket? _webSocket;
  WebSocket? get webSocket => _webSocket;
  String webSocketId = '';

  Future<void> _monitorConnectivity() async {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) async {
      if (result[0] == ConnectivityResult.none) {
        _handleOffline();
      } else {
        if (await isUserAuthenticated) {
          connectivityStatus.value = ConnectivityStatus.connecting;
          _handleReconnect();
        }
      }
    });
  }

  void _handleOffline() {
    connectivityStatus.value = ConnectivityStatus.offline;
    closeWebSocket();
  }

  Future<bool> get isUserAuthenticated async {
    return await storage.read(key: 'jwtToken') != null;
  }

  Future<void> reconnect(
      String? chatId, AppLocalizations? localizations) async {
    chatManager.chatManager.clearMessages(localizations);
    webSocketId = chatId ?? '';
    initWebSocket();
  }

  Future<void> initWebSocket() async {
    if (await isUserAuthenticated) {
      if (_webSocket != null) {
        await closeWebSocket();
      }
      await connectWebSocket();
    }
  }

  int reconnectAttempts = 0;

  Future<void> connectWebSocket() async {
    final jwtToken = await storage.read(key: 'jwtToken');
    if (jwtToken == null) return;
    if (_webSocket != null && _webSocket?.closeCode == null) {
      print('WebSocket is already connected');
      connectivityStatus.value = ConnectivityStatus.connected;

      return;
    }

    connectivityStatus.value = ConnectivityStatus.connecting;

    try {
      print(webSocketId);
      final uri = Uri.parse(
        webSocketId.isEmpty
            ? 'wss://$baseUrl/v2/admin/chat'
            : 'wss://$baseUrl/v2/admin/chat?uid=$webSocketId',
      );

      _webSocket = await WebSocket.connect(uri.toString(),
          headers: {HttpHeaders.authorizationHeader: 'Bearer $jwtToken'});

      final stream = _webSocket!.asBroadcastStream();

      connectivityStatus.value = ConnectivityStatus.connected;
      reconnectAttempts = 0;

      _webSocket!.add('Bearer $jwtToken');
      stream.listen(
        (data) {
          print('Received data: $data');
          bool notJson = true;

          try {
            final parsedData = jsonDecode(data);
            notJson = false;
            if (parsedData is List) {
              final messages = parsedData
                  .map((message) => ChatEntry.fromJson(message))
                  .toList();
              chatManager.chatManager.addMessages(messages);
            } else {
              final chatEntry = ChatEntry.fromJson(parsedData);
              chatManager.chatManager.addMessage(chatEntry);
            }
          } catch (e) {
            if (notJson) {
              webSocketId = data;
              print('WebSocket ID received: $webSocketId');
            } else {
              print("problems");
            }
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleReconnect();
        },
        onDone: () {
          connectivityStatus.value = ConnectivityStatus.offline;
          print('WebSocket closed.');
          _handleReconnect();
        },
      );
    } catch (e) {
      print('Failed to connect WebSocket: $e');
    }
  }

  void _handleReconnect() {
    final delay = Duration(seconds: reconnectAttempts * 3);
    print('Reconnecting in ${delay.inSeconds} seconds...');

    Future.delayed(delay, connectWebSocket);
    reconnectAttempts++;
  }

  Future<void> closeWebSocket() async {
    await _webSocket?.close();
    _webSocket = null;
    print('WebSocket closed');
  }

  void dispose() {
    _connectivitySubscription.cancel();
    closeWebSocket();
  }
}
