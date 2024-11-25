import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

String encodePassword(String password) {
  // Convert the password to bytes and hash it using SHA-256
  var bytes = utf8.encode(password); // Convert password to bytes
  var digest = sha512.convert(bytes); // Get the SHA-512 hash
  return digest.toString(); // Return the hash as a hex string
}

class NoAnimationPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

// Validate the response against the AdminSchema
bool validateAdminSchema(Map<String, dynamic> data) {
  final requiredFields = [
    'uid',
    'username',
    'first_name',
    'last_name',
    'status',
    'last_seen',
    'lang',
    'country',
    'timezone',
    'created_at',
  ];

  for (final field in requiredFields) {
    if (!data.containsKey(field)) {
      return false;
    }
  }
  return true;
}

Map<String, dynamic> decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Invalid JWT token format.');
  }

  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  return jsonDecode(payload) as Map<String, dynamic>;
}
