/// measure.dart 가 쓰는 통계 계산·서식 도우미.
/// 여기에는 게임 규칙이 없다. 숫자를 세고 줄로 만드는 일만 한다.
library;

/// 백분율 서식 (소수 첫째 자리)
String pct(num ratio) => (ratio * 100).toStringAsFixed(1);

/// 소수 서식
String fix(num v, [int digits = 2]) => v.toStringAsFixed(digits);

/// 표 칸 폭 맞추기 (한글은 두 칸으로 세어야 자리가 맞는다)
String pad(String s, int width) {
  var cells = 0;
  for (final code in s.runes) {
    cells += code > 0x2000 ? 2 : 1;
  }
  return s + ' ' * (width - cells).clamp(0, width);
}

double mean(Iterable<int> values) {
  if (values.isEmpty) return 0;
  return values.fold(0, (a, b) => a + b) / values.length;
}

int median(List<int> values) {
  if (values.isEmpty) return 0;
  final sorted = [...values]..sort();
  return sorted[sorted.length ~/ 2];
}

int maxOf(Iterable<int> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);

/// 구간 히스토그램. [edges] 는 각 구간의 「상한(포함)」이고
/// 마지막 구간은 상한 없이 그 위 전부를 담는다.
/// 예: edges [4, 8, 12] → "1~4" · "5~8" · "9~12" · "13~"
Map<String, int> histogram(List<int> values, List<int> edges) {
  final result = <String, int>{};
  var low = 1;
  for (final edge in edges) {
    result['$low~$edge'] = 0;
    low = edge + 1;
  }
  result['$low~'] = 0;
  for (final v in values) {
    var key = '$low~';
    var lo = 1;
    for (final edge in edges) {
      if (v <= edge) {
        key = '$lo~$edge';
        break;
      }
      lo = edge + 1;
    }
    result.update(key, (c) => c + 1);
  }
  return result;
}

/// 이항분포 Bin([n], [p]) 의 확률질량 목록 (k = 0..n)
List<double> binomialPmf(int n, double p) {
  final q = 1 - p;
  final pmf = List<double>.filled(n + 1, 0);
  var term = 1.0;
  for (var k = 0; k <= n; k++) {
    term = k == 0 ? _pow(q, n) : term * (n - k + 1) / k * (p / q);
    pmf[k] = term;
  }
  return pmf;
}

double _pow(double base, int exp) {
  var r = 1.0;
  for (var i = 0; i < exp; i++) {
    r *= base;
  }
  return r;
}

/// E[min(X, cap)] — X ~ Bin(n, p). 「적립 상한이 있는 각인」의 기대 적립이다.
/// E[min(X,c)] = Σ_{j=1..c} P(X ≥ j) 를 쓴다.
double expectedCapped(int n, double p, int cap) {
  if (n <= 0) return 0;
  final pmf = binomialPmf(n, p);
  var sum = 0.0;
  for (var j = 1; j <= cap; j++) {
    var tail = 0.0;
    for (var k = j; k <= n; k++) {
      tail += pmf[k];
    }
    sum += tail;
  }
  return sum;
}

/// 시행 수 n 이 전투마다 다를 때의 기대 적립.
/// [trialCounts] 는 「n → 그런 전투가 몇 번 있었나」이다.
double expectedCappedMixed(Map<int, int> trialCounts, double p, int cap) {
  var total = 0;
  var weighted = 0.0;
  trialCounts.forEach((n, count) {
    total += count;
    weighted += expectedCapped(n, p, cap) * count;
  });
  return total == 0 ? 0 : weighted / total;
}

/// 값 목록을 「값 → 개수」로 압축한다 (전투당 굴림 횟수 등).
Map<int, int> countByValue(List<int> values) {
  final counts = <int, int>{};
  for (final v in values) {
    counts.update(v, (c) => c + 1, ifAbsent: () => 1);
  }
  return counts;
}
