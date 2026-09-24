import 'dart:convert';

import 'package:flutter/services.dart';

import 'who_is_it_entry.dart';

class WhoIsItRepository {
  const WhoIsItRepository({this.assetBundle});

  static const assetPath = 'assets/games/who_is_it/people.json';
  final AssetBundle? assetBundle;

  Future<List<WhoIsItEntry>> loadPeople() async {
    final source = await (assetBundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! List<Object?>) {
      throw const FormatException(
        'Die Personendatei muss eine Liste enthalten.',
      );
    }

    final people = decoded
        .map((entry) {
          if (entry is! Map<String, Object?>) {
            throw const FormatException('Jede Person muss ein Objekt sein.');
          }
          return WhoIsItEntry.fromJson(entry);
        })
        .toList(growable: false);

    if (people.isEmpty) {
      throw const FormatException('Die Personendatei ist leer.');
    }
    return people;
  }
}
