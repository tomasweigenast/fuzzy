// import 'package:fuzzysearch/fuzzysearch.dart';
// import 'package:test/test.dart';

// final defaultList = ['Apple', 'Orange', 'Banana'];
// final defaultOptions = FuzzyOptions(
//   location: 0,
//   distance: 100,
//   threshold: 0.6,
//   maxPatternLength: 32,
//   isCaseSensitive: false,
//   tokenSeparator: RegExp(r' +'),
//   minTokenCharLength: 1,
//   findAllMatches: false,
//   minMatchCharLength: 1,
//   shouldSort: true,
//   sortFn: (a, b) => a.score.compareTo(b.score),
//   tokenize: false,
//   matchAllTokens: false,
//   verbose: false,
// );

// Fuzzy setup({List<String>? itemList, FuzzyOptions? options}) {
//   return Fuzzy(
//     itemList ?? defaultList,
//     options: options ?? defaultOptions,
//   );
// }

// void main() {
//   group('Empty list of strings', () {
//     late Fuzzy fuse;
//     setUp(() {
//       fuse = setup(itemList: <String>[]);
//     });
//     test('empty result is returned', () async {
//       final result = await fuse.search('Bla');
//       expect(result.isEmpty, true);
//     });
//   });

//   group('Flat list of strings: ["Apple", "Orange", "Banana"]', () {
//     late Fuzzy fuse;
//     setUp(() {
//       fuse = setup();
//     });

//     test('When searching for the term "Apple"', () async {
//       final result = await fuse.search('Apple');

//       expect(result.length, 1, reason: 'we get a list of exactly 1 item');
//       expect(result[0].item, equals('Apple'),
//           reason: 'whose value is the index 0, representing ["Apple"]');
//     });
//   });

//   group('Flat list of strings: ["Apple", "Orange", "Banana"]', () {
//     late Fuzzy fuse;
//     setUp(() {
//       fuse = setup();
//     });

//     test('When performing a fuzzy search for the term "ran"', () async {
//       final result = await fuse.search('ran');

//       expect(result.length, 2, reason: 'we get a list of containing 2 items');
//       expect(result[0].item, equals('Orange'),
//           reason: 'whose values represent the indices of ["Orange", "Banana"]');
//       expect(result[1].item, equals('Banana'),
//           reason: 'whose values represent the indices of ["Orange", "Banana"]');
//     });

//     test(
//         'When performing a fuzzy search for the term "nan" with a limit of 1 result',
//         () async {
//       final result = await fuse.search('nan', 1);

//       expect(result.length, 1,
//           reason: 'we get a list of containing 1 item: [2]');
//       expect(result[0].item, equals('Banana'),
//           reason: 'whose value is the index 2, representing ["Banana"]');
//     });
//   });

//   group('Include score in result list: ["Apple", "Orange", "Banana"]', () {
//     late Fuzzy fuse;
//     setUp(() {
//       fuse = setup();
//     });

//     test('When searching for the term "Apple"', () async {
//       final result = await fuse.search('Apple');

//       expect(result.length, equals(1),
//           reason: 'we get a list of exactly 1 item');
//       expect(result[0].item, equals('Apple'),
//           reason: 'whose value is the index 0, representing ["Apple"]');
//       expect(result[0].score, equals(0),
//           reason: 'and the score is a perfect match');
//     });

//     test('When performing a fuzzy search for the term "ran"', () async {
//       final result = await fuse.search('ran');

//       expect(result.length, 2, reason: 'we get a list of containing 2 items');

//       expect(result[0].item, equals('Orange'));
//       expect(result[0].score, isNot(0), reason: 'score is not zero');

//       expect(result[1].item, equals('Banana'));
//       expect(result[1].score, isNot(0), reason: 'score is not zero');
//     });
//   });

//   group('Include arrayIndex in result list', () {
//     final fuse = setup();

//     test('When performing a fuzzy search for the term "ran"', ()  async{
//       final result = await fuse.search('ran');

//       expect(result.length, 2, reason: 'we get a list of containing 2 items');

//       expect(result[0].item, equals('Orange'));
//       expect(result[0].matches.single.arrayIndex, 1);

//       expect(result[1].item, equals('Banana'));
//       expect(result[1].matches.single.arrayIndex, 2);
//     });
//   });

//   group(
//       'Search with match all tokens in a list of strings with leading and trailing whitespace',
//       () {
//     late Fuzzy fuse;
//     setUp(() {
//       final customList = [' Apple', 'Orange ', ' Banana '];
//       fuse = setup(
//         itemList: customList,
//         options: defaultOptions.copyWith(tokenize: true),
//       );
//     });

//     test('When searching for the term "Banana"', () async {
//       final result = await fuse.search('Banana');

//       expect(result.length, 1, reason: 'we get a list of exactly 1 item');
//       expect(result[0].item, equals(' Banana '),
//           reason:
//               'whose value is the same, disconsidering leading and trailing whitespace');
//     });
//   });

//   group(
//       'Search with tokenize where the search pattern starts or ends with the tokenSeparator',
//       () {
//     group('With the default tokenSeparator, which is white space', () {
//       final fuse = setup(options: FuzzyOptions(tokenize: true));

//       test('When the search pattern starts with white space', () async {
//         final result = await fuse.search(' Apple');

//         expect(result.length, 1, reason: 'we get a list of exactly 1 item');
//         expect(result[0].item, equals('Apple'));
//       });

//       test('When the search pattern ends with white space', () async {
//         final result = await fuse.search('Apple ');

//         expect(result.length, 1, reason: 'we get a list of exactly 1 item');
//         expect(result[0].item, equals('Apple'));
//       });

//       test('When the search pattern contains white space in the middle', () async {
//         final result = await fuse.search('Apple Orange');

//         expect(result.length, 2, reason: 'we get a list of exactly 2 itens');
//         expect(result[0].item, equals('Orange'));
//         expect(result[1].item, equals('Apple'));
//       });
//     });

//     group('With a custom tokenSeparator', () {
//       final fuse = setup(
//           options: FuzzyOptions(tokenize: true, tokenSeparator: RegExp(';')));

//       test('When the search pattern ends with a tokenSeparator match', () async {
//         final result = await fuse.search('Apple;Orange;');

//         expect(result.length, 2, reason: 'we get a list of exactly 2 itens');
//         expect(result[0].item, equals('Orange'));
//         expect(result[1].item, equals('Apple'));
//       });
//     });
//   });

//   group('Search with match all tokens', () {
//     late Fuzzy fuse;
//     setUp(() {
//       final customList = [
//         'AustralianSuper - Corporate Division',
//         'Aon Master Trust - Corporate Super',
//         'Promina Corporate Superannuation Fund',
//         'Workforce Superannuation Corporate',
//         'IGT (Australia) Pty Ltd Superannuation Fund',
//       ];
//       fuse = setup(
//         itemList: customList,
//         options: defaultOptions.copyWith(tokenize: true),
//       );
//     });

//     test('When searching for the term "Australia"', () async {
//       final result = await fuse.search('Australia');

//       expect(result.length, equals(2),
//           reason: 'We get a list containing exactly 2 items');
//       expect(result[0].item, equals('AustralianSuper - Corporate Division'));
//       expect(result[1].item,
//           equals('IGT (Australia) Pty Ltd Superannuation Fund'));
//     });

//     test('When searching for the term "corporate"', () async {
//       final result = await fuse.search('corporate');

//       expect(result.length, equals(4),
//           reason: 'We get a list containing exactly 2 items');

//       expect(result[0].item, equals('Promina Corporate Superannuation Fund'));
//       expect(result[1].item, equals('AustralianSuper - Corporate Division'));
//       expect(result[2].item, equals('Aon Master Trust - Corporate Super'));
//       expect(result[3].item, equals('Workforce Superannuation Corporate'));
//     });
//   });

//   group('Search with tokenize includes token average on result score', () {
//     final customList = ['Apple and Orange Juice'];
//     final fuse = setup(
//       itemList: customList,
//       options: FuzzyOptions(
//         threshold: 0.1,
//         tokenize: true,
//         location: 0,
//         distance: 100,
//         maxPatternLength: 32,
//         isCaseSensitive: false,
//         tokenSeparator: RegExp(r' +'),
//         minTokenCharLength: 1,
//         findAllMatches: false,
//         minMatchCharLength: 1,
//         shouldSort: true,
//         sortFn: (a, b) => a.score.compareTo(b.score),
//         matchAllTokens: false,
//         verbose: false,
//       ),
//     );

//     test('When searching for the term "Apple Juice"', () async {
//       final result = await fuse.search('Apple Juice');

//       // By using a lower threshold, we guarantee that the full text score
//       // ("apple juice" on "Apple and Orange Juice") returns a score of 1.0,
//       // while the token searches return 0.0 (perfect matches) for "Apple" and
//       // "Juice". Thus, the token score average is 0.0, and the result score
//       // should be (1.0 + 0.0) / 2 = 0.5
//       expect(result.length, 1);
//       expect(result[0].score, 0.5);
//     });
//   });

//   group('Searching with default options', () {
//     late Fuzzy fuse;
//     setUp(() {
//       final customList = ['t te tes test tes te t'];
//       fuse = setup(itemList: customList);
//     });

//     test('When searching for the term "test"', () async {
//       final result = await fuse.search('test');

//       expect(result[0].matches[0].matchedIndices.length, equals(4),
//           reason: 'We get a match containing 4 indices');

//       expect(result[0].matches[0].matchedIndices[0].start, equals(0),
//           reason: 'and the first index is a single character');
//       expect(result[0].matches[0].matchedIndices[0].end, equals(0),
//           reason: 'and the first index is a single character');
//     });
//   });

//   group('Searching with findAllMatches', () {
//     late Fuzzy fuse;
//     setUp(() {
//       final customList = ['t te tes test tes te t'];
//       fuse = setup(
//         itemList: customList,
//         options: defaultOptions.copyWith(
//           findAllMatches: true,
//         ),
//       );
//     });

//     test('When searching for the term "test"', () async {
//       final result = await fuse.search('test');

//       expect(result[0].matches[0].matchedIndices.length, equals(7),
//           reason: 'We get a match containing 7 indices');

//       expect(result[0].matches[0].matchedIndices[0].start, equals(0),
//           reason: 'and the first index is a single character');
//       expect(result[0].matches[0].matchedIndices[0].end, equals(0),
//           reason: 'and the first index is a single character');
//     });
//   });

//   group('Searching with minCharLength', () {
//     late Fuzzy fuse;
//     setUp(() {
//       final customList = ['t te tes test tes te t'];
//       fuse = setup(
//         itemList: customList,
//         options: defaultOptions.copyWith(
//           minMatchCharLength: 2,
//         ),
//       );
//     });

//     test('When searching for the term "test"', () async {
//       final result = await fuse.search('test');

//       expect(result[0].matches[0].matchedIndices.length, equals(3),
//           reason: 'We get a match containing 3 indices');

//       expect(result[0].matches[0].matchedIndices[0].start, equals(2),
//           reason: 'and the first index is a 2 character word');
//       expect(result[0].matches[0].matchedIndices[0].end, equals(3),
//           reason: 'and the first index is a 2 character word');
//     });

//     test('When searching for a string shorter than minMatchCharLength', () async {
//       final result = await fuse.search('t');

//       expect(result.length, equals(1),
//           reason: 'We get a result with no matches');
//       expect(result[0].matches[0].matchedIndices.length, equals(0),
//           reason: 'We get a result with no matches');
//     });
//   });

//   group('Searching using string large strings', () {
//     late Fuzzy fuse;
//     setUp(() {
//       final customList = [
//         'pizza',
//         'feast',
//         'super+large+much+unique+36+very+wow+',
//       ];
//       fuse = setup(
//         itemList: customList,
//         options: defaultOptions.copyWith(
//           threshold: 0.5,
//           location: 0,
//           distance: 0,
//           maxPatternLength: 50,
//           minMatchCharLength: 4,
//           shouldSort: true,
//         ),
//       );
//     });

//     test('finds delicious pizza', () async {
//       final result = await fuse.search('pizza');
//       expect(result[0].matches[0].value, equals('pizza'));
//     });

//     test('finds pizza when clumbsy', () async {
//       final result = await fuse.search('pizze');
//       expect(result[0].matches[0].value, equals('pizza'));
//     });

//     test('finds no matches when string is exactly 31 characters', () async {
//       final result = await fuse.search('this-string-is-exactly-31-chars');
//       expect(result.isEmpty, isTrue);
//     });

//     test('finds no matches when string is exactly 32 characters', () async {
//       final result = await fuse.search('this-string-is-exactly-32-chars-');
//       expect(result.isEmpty, isTrue);
//     });

//     test('finds no matches when string is larger than 32 characters', () async {
//       final result = await fuse.search('this-string-is-more-than-32-chars');
//       expect(result.isEmpty, isTrue);
//     });

//     test('should find one match that is larger than 32 characters', () async {
//       final result = await fuse.search('super+large+much+unique+36+very+wow+');
//       expect(result[0].matches[0].value,
//           equals('super+large+much+unique+36+very+wow+'));
//     });
//   });

//   group('On string normalization', () {
//     final diacriticList = ['Ápplé', 'Öřângè', 'Bánànã'];
//     late Fuzzy fuse;
//     setUp(() {
//       fuse = setup(
//         itemList: diacriticList,
//         options: defaultOptions.copyWith(shouldNormalize: true),
//       );
//     });

//     test('When searching for the term "rän"', () async {
//       final result = await fuse.search('rän');

//       expect(result.length, equals(2),
//           reason: 'we get a list of containing 2 items');
//       expect(result[0].item, equals('Öřângè'));
//       expect(result[1].item, equals('Bánànã'));
//     });
//   });

//   group('Without string normalization', () {
//     final diacriticList = ['Ápplé', 'Öřângè', 'Bánànã'];
//     late Fuzzy fuse;
//     setUp(() {
//       fuse = setup(itemList: diacriticList);
//     });

//     test('Nothing is found without normalization', () async {
//       final result = await fuse.search('ran');

//       expect(result.length, equals(0));
//     });
//   });
// }
