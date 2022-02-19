import 'dart:async';

class BenchmarkBase {
  final String name;
  final ScoreEmitter emitter;

  // Empty constructor.
  const BenchmarkBase(this.name, {this.emitter = const PrintEmitter()});

  // The benchmark code.
  // This function is not used, if both [warmup] and [exercise] are overwritten.
  void run() {}

  // Runs a short version of the benchmark. By default invokes [run] once.
  void warmup() {
    run();
  }

  // Exercises the benchmark. By default invokes [run] 10 times.
  void exercise() {
    for (var i = 0; i < 10; i++) {
      run();
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {}

  // Not measures teardown code executed after the benchmark runs.
  void teardown() {}

  // Measures the score for this benchmark by executing it repeatedly until
  // time minimum has been reached.
  static double measureFor(void Function() f, int minimumMillis) {
    var iter = 0;
    var watch = Stopwatch();
    watch.start();
    var elapsed = 0;
    while (elapsed < minimumMillis) {
      print("Running: $iter");
      f();
      elapsed += watch.elapsedMilliseconds;
      iter++;
    }
    return elapsed / iter;
  }

  // Measures the score for the benchmark and returns it.
  double measure() {
    setup();
    // Warmup for at least 100ms. Discard result.
    measureFor(warmup, 100);
    // Run the benchmark for at least 2000ms.
    var result = measureFor(exercise, 2000);
    teardown();
    return result;
  }

  void report() {
    emitter.emit(name, measure());
  }
}

class AsyncBenchmarkBase {
  final String name;
  final ScoreEmitter emitter;

  // Empty constructor.
  const AsyncBenchmarkBase(this.name, {this.emitter = const PrintEmitter()});

  // The benchmark code.
  // This function is not used, if both [warmup] and [exercise] are overwritten.
  FutureOr<void> run() {}

  // Runs a short version of the benchmark. By default invokes [run] once.
  FutureOr<void> warmup() {
    return run();
  }

  // Exercises the benchmark. By default invokes [run] 10 times.
  Future<void> exercise() async {
    for (var i = 0; i < 10; i++) {
      await run();
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  FutureOr<void> setup() {}

  // Not measures teardown code executed after the benchmark runs.
  FutureOr<void> teardown() {}

  // Measures the score for this benchmark by executing it repeatedly until
  // time minimum has been reached.
  static Future<double> measureFor(FutureOr<void> Function() f, int minimumMillis) async {
    var iter = 0;
    var watch = Stopwatch();
    watch.start();
    var elapsed = 0;
    while (elapsed < minimumMillis) {
      print("Running: $iter");
      await f();
      elapsed = watch.elapsedMilliseconds;
      iter++;
    }
    return elapsed / iter;
  }

  // Measures the score for the benchmark and returns it.
  Future<double> measure() async {
    await setup();

    // Warmup for at least 100ms. Discard result.
    await measureFor(warmup, 100);
    
    // Run the benchmark for at least 2000ms.
    var result = await measureFor(exercise, 2000);
    await teardown();
    return result;
  }

  Future<void> report() async {
    emitter.emit(name, await measure());
  }
}

abstract class ScoreEmitter {
  void emit(String testName, double value);
}

class PrintEmitter implements ScoreEmitter {
  const PrintEmitter();

  @override
  void emit(String testName, double value) {
    print('$testName(RunTime): $value ms.');
  }
}