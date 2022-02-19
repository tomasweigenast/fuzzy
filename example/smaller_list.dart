import 'dart:convert';
import 'dart:io';

import 'package:fuzzy/fuzzy.dart';

Future<int> main() async {

  print("Please wait, loading 8mb and parsing 🥴");

  String mockFileContnet = File("MOCKDATA.json").readAsStringSync();
  var persons = (jsonDecode(mockFileContnet) as Iterable).map((e) => Person.fromJson(e)).take(10000).toList();

  Stopwatch stopwatch = Stopwatch()..start();

  final fuse = Fuzzy(
    persons.map((e) => e.name).toList(),
    tokens: persons.map((e) => [e.name, e.email]).toList(),
    options: FuzzyOptions(
      findAllMatches: true,
      tokenize: true,
      isCaseSensitive: false,
      threshold: 0.5,
      verbose: false
    ),
  );

  final result = await fuse.search('henrry', 10);

  stopwatch.stop();

  print('A score of 0 indicates a perfect match, while a score of 1 indicates a complete mismatch.');

  result.forEach((r) {
    print('\nScore: ${r.score}\nTitle: ${r.item}');
  });

  print("It matched ${result.length} in ${stopwatch.elapsedMilliseconds} ms.");
  return 0;
}

class Person {
  final String id;
  final String name;
  final String email;

  Person({required this.id, required this.name, required this.email});

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json["id"],
      email: json["email"],
      name: json["name"],
    );
  }
}