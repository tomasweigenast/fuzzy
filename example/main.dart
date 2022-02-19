import 'dart:convert';
import 'dart:io';

import 'package:fuzzysearch/fuzzysearch.dart';

Future<int> main() async {

  print("Please wait, loading 8mb and parsing 🥴");

  String mockFileContnet = File("mock_data.json").readAsStringSync();
  var persons = (jsonDecode(mockFileContnet) as Iterable).map((e) => Person.fromJson(e)).take(10000).toList();

  Stopwatch stopwatch = Stopwatch()..start();

  final fuse = Fuzzy.withIdentifiers(
    {for(var person in persons)person.name: person},
    tokens: persons.map((e) => [e.name, e.email]).toList(),
    options: FuzzyOptions(
      findAllMatches: true,
      tokenize: true,
      isCaseSensitive: false,
      threshold: 0.5,
      verbose: false,
      shouldSort: true,
    ),
  );

  final result = await fuse.search('henrry', 10);

  stopwatch.stop();

  print("Matches:");
  result.forEach((r) {
    print("${r.item} (${r.identifier}) - Score: ${r.score}");
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

  @override
  String toString() => "Person($id, $name, $email)";
}