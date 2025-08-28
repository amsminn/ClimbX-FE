import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter_svg/flutter_svg.dart';
import '../models/gym.dart';
import '../utils/color_schemes.dart';

/// 지도 PNG 위에 영역 SVG를 오버레이하여 path 단위로 클릭 가능한 위젯
class GymAreaMapOverlay extends StatefulWidget {
  const GymAreaMapOverlay({
    super.key,
    required this.mapImageUrl,
    required this.areas,
    required this.selectedAreaId,
    required this.onSelected,
    this.selectedOpacity = 0.35,
  });

  final String mapImageUrl;
  final List<GymArea> areas;
  final int? selectedAreaId;
  final ValueChanged<int?> onSelected; // null이면 전체
  final double selectedOpacity; // 0.0 ~ 1.0

  @override
  State<GymAreaMapOverlay> createState() => _GymAreaMapOverlayState();
}

class _GymAreaMapOverlayState extends State<GymAreaMapOverlay> {
  /// areaId -> Raw SVG path 집합 및 viewBox
  final Map<int, _SvgAreaGeometry> _rawGeometries = {};
  Future<void>? _loading;
  Size? _baseSize; // 렌더 기준 크기 (SVG viewBox 기반)
  double? _pngAspect; // PNG 가로/세로 비율

  @override
  void initState() {
    super.initState();
    _loading = _loadAllSvgGeometries();
    _resolvePngAspect();
  }

  @override
  void didUpdateWidget(covariant GymAreaMapOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.areas != widget.areas) {
      _loading = _loadAllSvgGeometries();
    }
    if (oldWidget.mapImageUrl != widget.mapImageUrl) {
      _resolvePngAspect();
    }
  }

  void _resolvePngAspect() {
    try {
      final provider = NetworkImage(widget.mapImageUrl);
      final stream = provider.resolve(const ImageConfiguration());
      late final ImageStreamListener listener;
      listener = ImageStreamListener((info, _) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (!mounted) return;
        setState(() {
          _pngAspect = h == 0 ? null : (w / h);
        });
        stream.removeListener(listener);
      }, onError: (error, stackTrace) {
        // ignore
      });
      stream.addListener(listener);
    } catch (_) {}
  }

  Future<void> _loadAllSvgGeometries() async {
    _rawGeometries.clear();
    _baseSize = null;
    for (final area in widget.areas) {
      try {
        final resp = await http.get(Uri.parse(area.areaImageCdnUrl));
        if (resp.statusCode != 200) continue;
        final doc = xml.XmlDocument.parse(resp.body);

        // viewBox 파싱
        final svgEl = doc.findAllElements('svg').firstOrNull;
        if (svgEl == null) continue;
        final viewBoxAttr = svgEl.getAttribute('viewBox') ?? '0 0 100 100';
        final parts = viewBoxAttr.split(RegExp(r'[ ,]+')).map((e) => double.tryParse(e) ?? 0).toList();
        final Rect viewBox = parts.length >= 4
            ? Rect.fromLTWH(parts[0], parts[1], parts[2], parts[3])
            : const Rect.fromLTWH(0, 0, 100, 100);

        // path 요소 수집 (기본 구현: <path d="..."> 만 처리)
        final paths = <Path>[];
        for (final pathEl in doc.findAllElements('path')) {
          final d = pathEl.getAttribute('d');
          if (d == null || d.isEmpty) continue;
          try {
            final p = parseSvgPathData(d);
            paths.add(p);
          } catch (_) {
            // ignore path parse error
          }
        }

        // 일부 SVG는 polygon/polyline로 전달될 수 있음 → 최소 처리
        for (final poly in doc.findAllElements('polygon')) {
          final points = poly.getAttribute('points');
          if (points == null) continue;
          final p = Path();
          final coords = points.trim().split(RegExp(r'[\s,]+')).where((e) => e.isNotEmpty).toList();
          if (coords.length >= 2) {
            for (int i = 0; i + 1 < coords.length; i += 2) {
              final x = double.tryParse(coords[i]) ?? 0;
              final y = double.tryParse(coords[i + 1]) ?? 0;
              if (i == 0) {
                p.moveTo(x, y);
              } else {
                p.lineTo(x, y);
              }
            }
            p.close();
            paths.add(p);
          }
        }

        if (paths.isEmpty) continue;
        final union = Path();
        for (final p in paths) {
          union.addPath(p, Offset.zero);
        }
        _rawGeometries[area.areaId] = _SvgAreaGeometry(
          viewBox: viewBox,
          rawPath: union,
          rawSvg: resp.body,
        );
        _baseSize ??= Size(viewBox.width, viewBox.height);
      } catch (_) {
        // skip
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 초기부터 PNG 비율을 사용해 베이스 비율 고정
    final Size baseSize = _baseSize ?? (_pngAspect != null
        ? Size(1000, 1000 / _pngAspect!)
        : const Size(1000, 700));
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: baseSize.width,
              height: baseSize.height,
              child: Stack(
                children: [
                  // 선택된 영역 SVG 표시 - png뒤에
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _buildSelectedSvgLayer(),
                    ),
                  ),
                  // 영역 오버레이 + 클릭 판정 (기준 크기 좌표계)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (details) {
                        final pos = details.localPosition;
                        int? tappedAreaId;
                        _rawGeometries.forEach((areaId, geom) {
                          final scaled = geom.scaledPath(baseSize);
                          if (scaled.contains(pos)) {
                            tappedAreaId = areaId;
                          }
                        });
                        if (tappedAreaId != null) {
                          widget.onSelected(tappedAreaId);
                        }
                      },
                      child: const SizedBox.expand(),
                    ),
                  ),
                  // 배경 PNG - 맨 위
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Image.network(
                        widget.mapImageUrl,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SvgAreaGeometry {
  _SvgAreaGeometry({required this.viewBox, required this.rawPath, required this.rawSvg});
  final Rect viewBox;
  final Path rawPath; // SVG 좌표계 경로
  final String rawSvg; // 원본 SVG 문자열 (색상 포함 렌더용)

  Path scaledPath(Size toSize) {
    final double sx = toSize.width / viewBox.width;
    final double sy = toSize.height / viewBox.height;
    final Matrix4 m = Matrix4.identity()
      ..translate(-viewBox.left, -viewBox.top)
      ..scale(sx, sy);
    return rawPath.transform(m.storage);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}


extension _SelectedSvg on _GymAreaMapOverlayState {
    Widget _buildSelectedSvgLayer() {
    final int? id = widget.selectedAreaId;
    if (_rawGeometries.isEmpty) return const SizedBox.shrink();

    // 전체(null)면 모든 영역 표시
    if (id == null) {
      return Stack(
        children: _rawGeometries.entries.map((e) {
          return Positioned.fill(
            child: SvgPicture.string(
              e.value.rawSvg,
              fit: BoxFit.fill,
              allowDrawingOutsideViewBox: true,
            ),
          );
        }).toList(),
      );
    }

    // 단일 선택이면 해당 영역만 표시
    final geom = _rawGeometries[id];
    if (geom == null) return const SizedBox.shrink();
    return SvgPicture.string(
      geom.rawSvg,
      fit: BoxFit.fill,
      allowDrawingOutsideViewBox: true,
    );
  }
}

