/// Small deterministic RNG for replayable combat.
///
/// Xorshift32 is intentionally simple and self-contained. Combat replay stores
/// [state], so the same save seed + action sequence reproduces the same rolls.
class SeededRngV4 {
  SeededRngV4(int seed) : _state = seed == 0 ? 0x6D2B79F5 : seed & 0xFFFFFFFF;

  int _state;

  int get state => _state;

  void restore(int state) {
    _state = state == 0 ? 0x6D2B79F5 : state & 0xFFFFFFFF;
  }

  int nextUint32() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= (x >> 17);
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x & 0xFFFFFFFF;
    return _state;
  }

  int nextInt(int maxExclusive) {
    if (maxExclusive <= 0) {
      throw ArgumentError.value(maxExclusive, 'maxExclusive', 'must be > 0');
    }
    return nextUint32() % maxExclusive;
  }

  double nextDouble() => nextUint32() / 0x100000000;

  int d6() => nextInt(6) + 1;

  List<int> roll3d6() => [d6(), d6(), d6()];
}
