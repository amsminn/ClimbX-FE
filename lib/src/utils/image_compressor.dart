import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 이미지 압축 유틸리티
/// 5MB 이하로 압축하여 반환
const _maxBytes = 5 * 1024 * 1024; // 5 MB

/// 이미지를 5MB 이하로 압축
Future<File> compressUnder5MB(File original) async {
  final originSize = await original.length();
  if (originSize <= _maxBytes) return original;

  int quality = 90;
  int minSide = 2000; // 고해상도로 시작하여 점진적으로 축소
  List<int>? outBytes;

  while (quality >= 25) {
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
    quality -= 10;
    minSide = (minSide * 0.9).round();
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
