library fuzzy;

import 'dart:async';
import 'dart:math';

import 'package:async_task/async_task.dart';

import 'bitap/bitap.dart';
import 'data/fuzzy_options.dart';
import 'data/result.dart';

export 'data/fuzzy_options.dart';

/// Fuzzy search in Dart.
///
/// Import this library as follows:
///
/// ```
/// import 'package:fuzzy/fuzzy.dart';
/// ```
class Fuzzy<T extends Object> {
  /// Instantiates it given a list of strings to look into, and options
  Fuzzy(this.source, {this.tokens, FuzzyOptions? options}) 
      : options = options ?? FuzzyOptions(),
        _identifiers = null;

  /// Creates a new Fuzzy index with identifiers.
  Fuzzy.withIdentifiers(Map<String, T> source, {this.tokens, FuzzyOptions? options}) 
    : options = options ?? FuzzyOptions(),
      source = source.keys.toList(),
      _identifiers = source;

  /// The original list of string
  final List<String> source;

  final Map<String, T>? _identifiers;

  /// An optional list of predefined tokens for each element in [source].
  final List<List<String>>? tokens;

  /// Fuzz search Options
  final FuzzyOptions options;

  /// Search for a given [pattern] on the [list], optionally [limit]ing the result length
  Future<List<Result<T>>> search(String pattern, [int limit = -1]) async {
    if (source.isEmpty) {
      return <Result<T>>[];
    }

    // Return original list as [List<Result>] if pattern is empty
    if (pattern.isEmpty) {
      return source
          .map((item) => Result<T>(
                identifier: _identifierFor(item),
                item: item,
                matches: const [],
                score: 0,
              ))
          .toList();
    }

    final searchers = _prepareSearchers(pattern);
    final resultsAndWeights = await _search(searchers.tokenSearchers, searchers.fullSearcher);
    
    _computeScore(resultsAndWeights.weights, resultsAndWeights.results);

    if (options.shouldSort) {
      _sort(resultsAndWeights.results);
    }

    if (limit > 0) {
      return resultsAndWeights.results.take(limit).toList();
    }

    return resultsAndWeights.results;
  }

  Searchers _prepareSearchers(String pattern) {
    final tokenSearchers = <Bitap>[];

    if (options.tokenize) {
      // Tokenize on the separator
      final tokens = pattern.split(options.tokenSeparator)
        ..removeWhere((token) => token.isEmpty)
        ..removeWhere((token) => token.length < options.minTokenCharLength);
      for (var i = 0, len = tokens.length; i < len; i += 1) {
        tokenSearchers.add(Bitap(tokens[i], options: options));
      }
    }

    final fullSearcher = Bitap(pattern, options: options);

    return Searchers(
      tokenSearchers: tokenSearchers,
      fullSearcher: fullSearcher,
    );
  }

  Future<ResultsAndWeights<T>> _search(List<Bitap> tokenSearchers, Bitap fullSearcher) async {
    final results = <Result<T>>[];
    // final resultMap = <int, Result>{};

    if(source.length > 10000) {
      var chunks = _chunkList(source, 10000);
      var tasks = chunks.map((e) => _FuzzySearchTask(_FuzzySearchTaskArgs(
        identifiers: _identifiers,
        tokenSearchers: tokenSearchers, 
        fullSearcher: fullSearcher, 
        tokens: tokens ?? e.map((e) => e.split(' ')).toList(), 
        words: e, 
        options: options
      ))).toList();

      var executor = AsyncExecutor(
        sequential: false,
        parallelism: 10,
        taskTypeRegister: _taskTypeRegister,
      );

      var executions = executor.executeAll(tasks);
      await Future.wait(executions);

      for(var task in tasks) {
        var taskResult = task.result!;
        results.addAll(taskResult);
      }

      await executor.close();

    } else {
      // Iterate over every item
      for (var i = 0, len = source.length; i < len; i += 1) {
        var record = source[i];
        results.addAll(_analyze<T>(
          key: '',
          value: record.toString().trim(),
          record: record,
          identifier: _identifierFor(record),
          index: i,
          tokenSearchers: tokenSearchers,
          fullSearcher: fullSearcher,
          options: options,
          tokens: tokens
        ));
      }
    }

    return ResultsAndWeights<T>(results: results, weights: {});
  }

  static List<Result<T>> _analyze<T extends Object>({
    String key = '',
    required String value,
    required String record,
    required T? identifier,
    required int index,
    required List<Bitap> tokenSearchers,
    required Bitap fullSearcher,
    required FuzzyOptions options,
    List<List<String>>? tokens
  }) {
    // Check if the texvaluet can be searched
    if (value.isEmpty) {
      return [];
    }

    var resultMap = <int, Result<T>>{};
    var results = <Result<T>>[];

    var exists = false;
    var averageScore = -1.0;
    var numTextMatches = 0;

    // final mainSearchResult = fullSearcher.search(value);
    // dev.log('Full text: "$value", score: ${mainSearchResult.score}');

    if (options.tokenize) {
      final words = tokens == null ? value.split(options.tokenSeparator) : tokens[index];
      final scores = <double>[];

      for (var i = 0; i < tokenSearchers.length; i++) {
        final tokenSearcher = tokenSearchers[i];

        var hasMatchInText = false;

        for (var j = 0; j < words.length; j++) {
          final word = words[j];
          final tokenSearchResult = tokenSearcher.search(word);
          if (tokenSearchResult.isMatch) {
            exists = true;
            hasMatchInText = true;
            scores.add(tokenSearchResult.score);
          } else {
            if (options.matchAllTokens) {
              scores.add(1);
            }
          }
        }

        if (hasMatchInText) {
          numTextMatches += 1;
        }
      }

      averageScore = scores.fold<double>(0, (memo, score) => memo + score) / scores.length;
    }

    double finalScore = 0;
    if (averageScore > -1) {
      finalScore = (finalScore + averageScore) / 2;
    }

    final checkTextMatches = (options.tokenize && options.matchAllTokens)
        ? numTextMatches >= tokenSearchers.length
        : true;

    // If a match is found, add the item to <rawResults>, including its score
    if (exists && checkTextMatches) {
      // Check if the item already exists in our results
      final existingResult = resultMap[index];
      if (existingResult != null) {
        // Use the lowest score
        // existingResult.score, bitapResult.score
        existingResult.matches.add(ResultDetails(
          key: key,
          arrayIndex: index,
          value: value,
          score: finalScore,
          matchedIndices: [],
        ));
      } else {
        // Add it to the raw result list
        final res = Result<T>(
          item: record,
          identifier: identifier,
          matches: [
            ResultDetails(
              key: key,
              arrayIndex: index,
              value: value,
              score: finalScore,
              matchedIndices: [],
            ),
          ],
        );

        resultMap.update(
          index,
          (_) => res,
          ifAbsent: () => res,
        );

        results.add(res);
      }
    }

    return results;
  }

  void _computeScore(Map<String, double> weights, List<Result> results) {
    if (weights.length <= 1) {
      _computeScoreNoWeights(results);
    } else {
      _computeScoreWithWeights(weights, results);
    }
  }

  void _computeScoreNoWeights(List<Result> results) {
    for (var i = 0, len = results.length; i < len; i += 1) {
      final matches = results[i].matches;
      var bestScore = matches.map((m) => m.score).fold<double>(
          1.0, (previousValue, element) => min(previousValue, element));
      results[i].score = bestScore;
    }
  }

  void _computeScoreWithWeights(Map<String, double> weights, List<Result> results) {
    for (var i = 0, len = results.length; i < len; i += 1) {
      var currScore = 1.0;

      for (var match in results[i].matches) {
        var weight = weights[match.key];
        assert(weight != null);

        // We don't use 0 so that the weight differences don't get zeroed out
        final score = match.score == 0.0 ? 0.001 : match.score;
        final nScore = score * (weight ?? 1.0);

        match.nScore = nScore;
        currScore *= nScore;
      }

      results[i].score = currScore;
    }
  }

  void _sort(List<Result> results) {
    results.sort(options.sortFn);
  }

  static List<List<String>> _chunkList(List<String> input, int chunkSize) {
    var chunks = <List<String>>[];
    for (var i = 0; i < input.length; i += chunkSize) {
      chunks.add(input.sublist(i, i+chunkSize > input.length ? input.length : i + chunkSize)); 
    }

    return chunks;
  }

  T? _identifierFor(String record) {
    if(_identifiers == null) {
      return null;
    }

    return _identifiers![record];
  }
}

// ignore: strict_raw_type
List<AsyncTask> _taskTypeRegister() => [
  _FuzzySearchTask(_FuzzySearchTaskArgs(tokenSearchers: const [], fullSearcher: Bitap.empty(), identifiers: null, tokens: [], words: [], options: FuzzyOptions()))
];

class _FuzzySearchTask<T extends Object> extends AsyncTask<_FuzzySearchTaskArgs<T>, List<Result<T>>> {

  final _FuzzySearchTaskArgs<T> args;

  _FuzzySearchTask(this.args);

  @override
  // ignore: strict_raw_type
  AsyncTask<_FuzzySearchTaskArgs<T>, List<Result<T>>> instantiate(_FuzzySearchTaskArgs<T> parameters, [Map<String, SharedData>? sharedData]) {
    return _FuzzySearchTask<T>(parameters);
  }

  @override
  _FuzzySearchTaskArgs<T> parameters() {
    return args;
  }

  @override
  FutureOr<List<Result<T>>> run() {
    List<Result<T>> results = [];
    for (var i = 0, len = args.words.length; i < len; i += 1) {
      var record = args.words[1];
      results.addAll(Fuzzy._analyze<T>(
        key: '',
        value: record.toString().trim(),
        record: record,
        identifier: args.identifiers?[record],
        index: i,
        tokenSearchers: args.tokenSearchers,
        fullSearcher: args.fullSearcher,
        options: args.options,
        tokens: args.tokens 
      ));
    }

    return results;
  }

}

class _FuzzySearchTaskArgs<T extends Object> {
  final List<List<String>> tokens;
  final List<Bitap> tokenSearchers;
  final Bitap fullSearcher;
  final List<String> words;
  final FuzzyOptions options;
  final Map<String, T>? identifiers;

  _FuzzySearchTaskArgs({required this.tokenSearchers, required this.fullSearcher, required this.tokens, required this.words, required this.options, required this.identifiers});
}