import 'package:flutter/material.dart';
import '../utils/color_schemes.dart';

/// 드롭다운 형태의 필터 선택 위젯
class SearchFilterDropdown extends StatefulWidget {
  final String title;
  final String identifier; // 드롭다운 식별자
  final List<String> options;
  final String? selectedOption;
  final Function(String?) onOptionSelected;
  final Function(String?)? onDropdownStateChanged; // 드롭다운 상태 변경 콜백
  final bool forceClose; // 강제로 드롭다운 닫기

  const SearchFilterDropdown({
    super.key,
    required this.title,
    required this.identifier,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
    this.onDropdownStateChanged,
    this.forceClose = false,
  });

  @override
  State<SearchFilterDropdown> createState() => _SearchFilterDropdownState();
}

class _SearchFilterDropdownState extends State<SearchFilterDropdown> {
  bool _isExpanded = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchFilterDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부에서 강제로 닫기 요청이 오면 드롭다운 닫기
    if (widget.forceClose && !oldWidget.forceClose && _isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeDropdown();
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _closeDropdown() {
    setState(() {
      _isExpanded = false;
    });
    _removeOverlay();
    // 빌드 과정 중이 아닐 때만 콜백 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDropdownStateChanged?.call(null);
    });
  }

  void _showOverlay() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 100, // 크기 축소
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
                  // 모든 옵션 선택
                  _buildDropdownItem(null, '모두'),
                  const SizedBox(height: 4),
                  ...widget.options.map((option) => _buildDropdownItem(option, option)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          
          if (_isExpanded) {
            // 다른 드롭다운들에게 닫기 신호 전송
            widget.onDropdownStateChanged?.call(widget.identifier);
            _showOverlay();
          } else {
            _removeOverlay();
            widget.onDropdownStateChanged?.call(null);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // 패딩 축소
          decoration: BoxDecoration(
            color: AppColorSchemes.backgroundPrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColorSchemes.borderPrimary,
              width: 1,
            ),
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
              // 선택된 색상 표시 또는 "모두" 아이콘
              widget.selectedOption == null 
                ? Icon(
                    Icons.select_all,
                    size: 10,
                    color: AppColorSchemes.textSecondary,
                  )
                : Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _getColorForOption(widget.selectedOption!),
                      shape: BoxShape.circle,
                    ),
                  ),
              const SizedBox(width: 6), // 간격 축소
              Icon(
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
        // 상태 변경을 안전하게 처리
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onDropdownStateChanged?.call(null);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // 패딩 축소
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColorSchemes.backgroundTertiary
            : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // 모든 옵션 아이콘 또는 색상 동그라미
            option == null 
              ? Icon(
                  Icons.select_all,
                  size: 10,
                  color: AppColorSchemes.textSecondary,
                )
              : Container(
                  width: 10, // 동그라미 크기 축소
                  height: 10,
                  decoration: BoxDecoration(
                    color: _getColorForOption(option),
                    shape: BoxShape.circle,
                  ),
                ),
            const SizedBox(width: 6), // 간격 축소
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

  /// 옵션에 따른 색상 반환
  Color _getColorForOption(String option) {
    switch (option) {
      case '빨강':
        return const Color(0xFFEF4444);
      case '파랑':
        return const Color(0xFF3B82F6);
      case '초록':
        return const Color(0xFF10B981);
      case '노랑':
        return const Color(0xFFF59E0B);
      case '보라':
        return const Color(0xFF8B5CF6);
      default:
        return AppColorSchemes.accentBlue;
    }
  }
} 