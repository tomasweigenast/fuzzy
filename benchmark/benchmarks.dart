import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fuzzysearch/fuzzysearch.dart';
import 'base/benchmark_base.dart';

class BiggerSourceBenchmark extends AsyncBenchmarkBase {
  BiggerSourceBenchmark() : super("Bigger");

  late List<Person> _persons;

  @override
  FutureOr<void> setup() {
    String mockFileContnet = File("mock_data.json").readAsStringSync();
    _persons = (jsonDecode(mockFileContnet) as Iterable).map((e) => Person.fromJson(e)).toList();
  }

  @override
  FutureOr<void> teardown() {
    _persons.clear();
  }

  @override
  FutureOr<void> run() async {
    final fuse = Fuzzy(
      _persons.map((e) => e.name).toList(),
      tokens: _persons.map((e) => [e.name, e.email]).toList(),
      options: FuzzyOptions(
        findAllMatches: true,
        tokenize: true,
        isCaseSensitive: false,
        threshold: 0.5,
        verbose: false
      ),
    );

    await fuse.search('henrry', 10);
  }

  static Future<void> main() {
    return BiggerSourceBenchmark().report();
  }
}

class SmallerSourceBenchmark extends AsyncBenchmarkBase {
  SmallerSourceBenchmark() : super("Smaller");

  late List<Person> _persons;

  @override
  FutureOr<void> setup() {
    String mockFileContnet = File("mock_data.json").readAsStringSync();
    _persons = (jsonDecode(mockFileContnet) as Iterable).map((e) => Person.fromJson(e)).take(10000).toList();
  }

  @override
  FutureOr<void> teardown() {
    _persons.clear();
  }

  @override
  FutureOr<void> run() async {
    final fuse = Fuzzy(
      _persons.map((e) => e.name).toList(),
      tokens: _persons.map((e) => [e.name, e.email]).toList(),
      options: FuzzyOptions(
        findAllMatches: true,
        tokenize: true,
        isCaseSensitive: false,
        threshold: 0.5,
        verbose: false
      ),
    );

    await fuse.search('henrry', 10);
  }

  static Future<void> main() {
    return SmallerSourceBenchmark().report();
  }
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