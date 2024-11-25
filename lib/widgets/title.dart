import 'package:flutter/material.dart';

Widget title() {
  return RichText(
    textAlign: TextAlign.center,
    text: const TextSpan(
        text: 'Mercado',
        style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.w700, color: Colors.black),
        children: [
          TextSpan(
            text: 'BOT',
            style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
          ),
        ]),
  );
}