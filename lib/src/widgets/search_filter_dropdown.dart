import 'package:flutter/material.dart';
import '../utils/color_schemes.dart';
import '../utils/color_codes.dart';

/// 드롭다운 전역 레지스트리: 오버레이 전환과 헤더 hit-test를 지원
class _DropdownRegistry {
  static final List<_DropdownHandle> _handles = [];
  static _DropdownHandle? _currentOpen;

  static void register(_DropdownHandle handle) {
    _handles.add(handle);
  }

  static void unregister(_DropdownHandle handle) {
    _handles.remove(handle);
    if (_currentOpen == handle) {
      _currentOpen = null;
    }
  }

  static void setCurrentOpen(_DropdownHandle handle) {
    _currentOpen = handle;
  }

  static void closeCurrent() {
    _currentOpen?.close();
    _currentOpen = null;
  }

  static _DropdownHandle? hitTest(Offset globalPosition) {
    for (final h in _handles) {
      final rect = h.getGlobalRect();
      if (rect != null && rect.contains(globalPosition)) {
        return h;
      }
    }
    return null;
  }
}

class _DropdownHandle {
  final Rect? Function() getGlobalRect;
  final VoidCallback open;
  final VoidCallback close;

  _DropdownHandle({
    required this.getGlobalRect,
    required this.open,
    required this.close,
  });
}

/// 드롭다운 형태의 필터 선택 위젯
class SearchFilterDropdown extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final Function(String?) onOptionSelected;

  const SearchFilterDropdown({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  State<SearchFilterDropdown> createState() => _SearchFilterDropdownState();
}

class _SearchFilterDropdownState extends State<SearchFilterDropdown> {
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _toggleKey = GlobalKey();
  late final _DropdownHandle _handle;

  @override
  void dispose() {
    _removeOverlay();
    _DropdownRegistry.unregister(_handle);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _handle = _DropdownHandle(
      getGlobalRect: _getToggleRect,
      open: _openOverlay,
      close: _closeOverlay,
    );
    _DropdownRegistry.register(_handle);
  }

  Rect? _getToggleRect() {
    final ctx = _toggleKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _openOverlay() {
    setState(() {
      _isExpanded = true;
    });
    _showOverlay();
  }

  void _closeOverlay() {
    setState(() {
      _isExpanded = false;
    });
    _removeOverlay();
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 투명 배리어: 바깥 클릭 시 닫힘
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final target = _DropdownRegistry.hitTest(details.globalPosition);
                // 현재 열린 드롭다운은 닫는다
                _DropdownRegistry.closeCurrent();
                // 다른 드롭다운을 눌렀다면, 그 드롭다운을 연다
                if (target != null && target != _handle) {
                  // 다음 프레임에 열도록 예약
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    target.open();
                  });
                }
              },
              child: const SizedBox.shrink(),
            ),
          ),
          // 드롭다운 본체
          Positioned(
            width: 100,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 40),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColorSchemes.backgroundPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColorSchemes.borderPrimary,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 전체 선택 옵션
                      _buildDropdownItem(null, '전체'),
                      const SizedBox(height: 4),
                      ...widget.options.map(
                        (option) => _buildDropdownItem(option, option),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _DropdownRegistry.setCurrentOpen(_handle);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_isExpanded) {
            _closeOverlay();
          } else {
            // 다른 드롭다운이 열려 있으면 먼저 닫고 이 드롭다운을 연다
            _DropdownRegistry.closeCurrent();
            _openOverlay();
          }
        },
        child: Container(
          key: _toggleKey,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          // 패딩 축소
          decoration: BoxDecoration(
            color: AppColorSchemes.backgroundPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColorSchemes.borderPrimary, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 11, // 폰트 크기 축소
                  fontWeight: FontWeight.w500,
                  color: AppColorSchemes.textPrimary,
                ),
              ),
              const SizedBox(width: 6), // 간격 축소
              // 선택된 색상 동그라미
              if (widget.selectedOption != null)
                Container(
                  width: 10, // 동그라미 크기 축소
                  height: 10,
                  decoration: BoxDecoration(
                    color: ColorCodes.toDisplayColorFromAny(widget.selectedOption!),
                    shape: BoxShape.circle,
                    border: ColorCodes.needsBorderForLabel(widget.selectedOption!) 
                        ? Border.all(color: Colors.grey, width: 0.5)
                        : null,
                  ),
                ),
              const SizedBox(width: 6), // 간격 축소
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 14, // 아이콘 크기 축소
                color: AppColorSchemes.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 드롭다운 아이템 위젯
  Widget _buildDropdownItem(String? option, String label) {
    final isSelected = widget.selectedOption == option;

    return GestureDetector(
      onTap: () {
        widget.onOptionSelected(option);
        setState(() {
          _isExpanded = false;
        });
        _removeOverlay();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        // 패딩 축소
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorSchemes.backgroundTertiary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (option != null) ...[
              Container(
                width: 10, // 동그라미 크기 축소
                height: 10,
                decoration: BoxDecoration(
                  color: ColorCodes.toDisplayColorFromAny(option),
                  shape: BoxShape.circle,
                  border: ColorCodes.needsBorderForLabel(option) 
                      ? Border.all(color: Colors.grey, width: 0.5)
                      : null,
                ),
              ),
              const SizedBox(width: 6), // 간격 축소
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11, // 폰트 크기 축소
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColorSchemes.textPrimary
                      : AppColorSchemes.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
