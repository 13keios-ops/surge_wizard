/// 효과음 합성기: 저작권 걱정 없는 효과음을 코드로 직접 만들어
/// assets/sfx/*.wav 로 저장한다. 실행: dart run tool/gen_sfx.dart
///
/// 외부 음원 다운로드는 CLAUDE.md 절대 규칙 6(외부 에셋 금지)에 걸리므로
/// 사인파·노이즈 합성으로 대신한다. 나중에 진짜 음원으로 교체 가능.
// ignore_for_file: avoid_print — 콘솔 출력용 CLI 도구라 print가 맞다
library;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const int kSampleRate = 22050;

void main() {
  final dir = Directory('assets/sfx')..createSync(recursive: true);

  // 딸깍: 아주 짧은 고음 틱 (주사위 잠금)
  _write('${dir.path}/click.wav', _click());
  // 주사위 굴림: 틱이 점점 느려지며 잦아드는 소리 (감속 손맛)
  _write('${dir.path}/dice.wav', _diceRoll());
  // 타격: 짧고 낮은 퉁 소리
  _write('${dir.path}/hit.wav', _thump(140, 0.12));
  // 대성공: 밝게 올라가는 3음 아르페지오
  _write('${dir.path}/crit.wav', _arpeggio([523, 659, 784], 0.09));
  // 폭주: 아래로 미끄러지는 불안한 소리
  _write('${dir.path}/surge.wav', _slideDown());
  print('효과음 5종 생성 완료 → assets/sfx/');
}

/// 16비트 모노 WAV 파일로 저장
void _write(String path, List<double> samples) {
  final data = ByteData(44 + samples.length * 2);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little); // PCM 청크 크기
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // 모노
  data.setUint32(24, kSampleRate, Endian.little);
  data.setUint32(28, kSampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(
        44 + i * 2, (samples[i].clamp(-1.0, 1.0) * 32767).round(),
        Endian.little);
  }
  File(path).writeAsBytesSync(data.buffer.asUint8List());
  print('$path (${samples.length / kSampleRate}s)');
}

List<double> _click() {
  final n = (kSampleRate * 0.03).round();
  final rnd = Random(1);
  return List.generate(n, (i) {
    final env = exp(-i / (kSampleRate * 0.004));
    return (sin(2 * pi * 2400 * i / kSampleRate) * 0.7 +
            (rnd.nextDouble() * 2 - 1) * 0.3) *
        env *
        0.6;
  });
}

List<double> _diceRoll() {
  // 틱 간격이 점점 벌어지는(감속) 소리 0.7초
  final n = (kSampleRate * 0.7).round();
  final out = List.filled(n, 0.0);
  final rnd = Random(2);
  var t = 0.0;
  var gap = 0.035;
  while (t < 0.62) {
    final start = (t * kSampleRate).round();
    final freq = 900 + rnd.nextInt(700);
    for (var i = 0; i < (kSampleRate * 0.02).round(); i++) {
      final idx = start + i;
      if (idx >= n) break;
      final env = exp(-i / (kSampleRate * 0.003));
      out[idx] += sin(2 * pi * freq * i / kSampleRate) * env * 0.5;
    }
    t += gap;
    gap *= 1.28; // ease-out: 점점 느려진다
  }
  return out;
}

List<double> _thump(double freq, double seconds) {
  final n = (kSampleRate * seconds).round();
  return List.generate(n, (i) {
    final env = exp(-i / (kSampleRate * 0.03));
    final f = freq * (1 - i / n * 0.4); // 살짝 내려가는 피치
    return sin(2 * pi * f * i / kSampleRate) * env * 0.8;
  });
}

List<double> _arpeggio(List<double> freqs, double noteLen) {
  final noteN = (kSampleRate * noteLen).round();
  final out = <double>[];
  for (final f in freqs) {
    for (var i = 0; i < noteN; i++) {
      final env = exp(-i / (kSampleRate * 0.05));
      out.add((sin(2 * pi * f * i / kSampleRate) +
              0.4 * sin(2 * pi * f * 2 * i / kSampleRate)) *
          env *
          0.45);
    }
  }
  return out;
}

List<double> _slideDown() {
  final n = (kSampleRate * 0.4).round();
  return List.generate(n, (i) {
    final progress = i / n;
    final f = 600 - 380 * progress; // 600Hz → 220Hz 하강
    final wobble = sin(2 * pi * 9 * i / kSampleRate) * 24; // 흔들리는 느낌
    final env = 1 - progress * 0.7;
    return sin(2 * pi * (f + wobble) * i / kSampleRate) * env * 0.5;
  });
}
