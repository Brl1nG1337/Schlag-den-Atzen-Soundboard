import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/games/who_is_it/who_is_it_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WhoIsItRepository', () {
    test('loads the bundled people collection', () async {
      final people = await const WhoIsItRepository().loadPeople();

      expect(people, isNotEmpty);
      expect(
        people.map((person) => person.id).toSet(),
        hasLength(people.length),
      );
    });

    test('parses required and optional values', () async {
      final repository = WhoIsItRepository(
        assetBundle: _StringAssetBundle(
          jsonEncode([
            {
              'id': 'person_001',
              'name': 'Beispielperson',
              'imageAsset': 'assets/example.jpg',
              'hint': 'Ein Hinweis',
              'category': 'Film',
            },
            {
              'id': 'person_002',
              'name': 'Zweite Person',
              'imageAsset': 'assets/second.png',
            },
          ]),
        ),
      );

      final people = await repository.loadPeople();

      expect(people, hasLength(2));
      expect(people.first.name, 'Beispielperson');
      expect(people.first.hint, 'Ein Hinweis');
      expect(people.first.category, 'Film');
      expect(people.last.hint, isNull);
    });

    test('rejects missing required values', () {
      final repository = WhoIsItRepository(
        assetBundle: _StringAssetBundle(
          jsonEncode([
            {'id': 'invalid', 'name': '', 'imageAsset': 'assets/image.jpg'},
          ]),
        ),
      );

      expect(repository.loadPeople(), throwsA(isA<FormatException>()));
    });

    test('rejects malformed and empty collections', () async {
      final malformed = WhoIsItRepository(
        assetBundle: _StringAssetBundle('{"people": []}'),
      );
      final empty = WhoIsItRepository(assetBundle: _StringAssetBundle('[]'));

      await expectLater(
        malformed.loadPeople(),
        throwsA(isA<FormatException>()),
      );
      await expectLater(empty.loadPeople(), throwsA(isA<FormatException>()));
    });
  });
}

class _StringAssetBundle extends CachingAssetBundle {
  _StringAssetBundle(this.contents);

  final String contents;

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(contents));
    return ByteData.sublistView(bytes);
  }
}
