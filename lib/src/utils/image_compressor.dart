import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 이미지 압축 유틸리티
/// 5MB 이하로 압축하여 반환

// 압축 설정 상수
const _maxBytes = 5 * 1024 * 1024; // 5 MB
const _initialQuality = 90; // 초기 압축 품질
const _minQuality = 25; // 최소 압축 품질
const _qualityStep = 10; // 품질 감소 단위
const _initialMinSide = 2000; // 초기 최소 크기 (픽셀)
const _resizeFactor = 0.9; // 크기 감소 비율

/// 이미지를 5MB 이하로 압축
Future<File> compressUnder5MB(File original) async {
  final originSize = await original.length();
  if (originSize <= _maxBytes) return original;

  int quality = _initialQuality;
  int minSide = _initialMinSide; // 고해상도로 시작하여 점진적으로 축소
  List<int>? outBytes;

  while (quality >= _minQuality) {
    outBytes = await FlutterImageCompress.compressWithFile(
      original.path,
      quality: quality,
      minWidth: minSide,
      minHeight: minSide,
      format: CompressFormat.jpeg, // 모든 이미지를 JPEG로 통일
    );

    if (outBytes == null) break;
    if (outBytes.length <= _maxBytes) break;

    // 다음 반복을 위해 품질과 크기 감소
    quality -= _qualityStep;
    minSide = (minSide * _resizeFactor).round();
  }

  // 압축 실패 시 에러 발생
  if (outBytes == null || outBytes.length > _maxBytes) {
    throw Exception('이미지 파일이 너무 큽니다.');
  }

  // 압축된 파일 생성
  final tempDir = await getTemporaryDirectory();
  final fileName = 'comp_${DateTime.now().millisecondsSinceEpoch}.jpeg';
  final outPath = p.join(tempDir.path, fileName);
  return File(outPath)..writeAsBytesSync(outBytes, flush: true);
}
