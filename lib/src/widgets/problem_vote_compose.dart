import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import '../api/vote.dart';
import '../utils/color_schemes.dart';
import '../utils/tier_colors.dart';
import '../utils/problem_tier.dart';

class ProblemVoteCompose extends HookWidget {
  final String problemId;
  final VoidCallback? onSubmitted;

  const ProblemVoteCompose({super.key, required this.problemId, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final isSubmitting = useState(false);
    // 서버 스펙: B/S/G/P 각 3단계, M 1단계
    const tiers = [
      'B3','B2','B1',
      'S3','S2','S1',
      'G3','G2','G1',
      'P3','P2','P1',
      'D3','D2','D1',
      'M',
    ];
    final selectedTier = useState<String?>(null);

    final queryClient = useQueryClient();
    final mutation = useMutation(
      (Map<String, dynamic> vars) => ProblemVoteApi.createVote(
        problemId: problemId,
        tier: vars['tier'] as String,
        comment: vars['comment'] as String?,
      ),
      onSuccess: (_, __, ___) {
        controller.clear();
        selectedTier.value = null;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('의견이 등록되었습니다.')),
          );
        }
        onSubmitted?.call();
        queryClient.invalidateQueries(['problem_votes', problemId]);
        isSubmitting.value = false;
      },
      onError: (error, __, ___) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('등록 실패: $error')),
          );
        }
        isSubmitting.value = false;
      },
    );

    void handleSubmit() {
      final text = controller.text.trim();
      if (selectedTier.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('난이도 티어를 선택해주세요.')),
        );
        return;
      }
      if (isSubmitting.value) return;
      isSubmitting.value = true;
      final vars = <String, dynamic>{
        'tier': selectedTier.value!,
        if (text.isNotEmpty) 'comment': text,
      };
      mutation.mutate(vars);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorSchemes.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColorSchemes.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '난이도 의견 작성',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColorSchemes.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // 티어 선택 (드롭다운)
          DropdownButtonFormField<String>(
            value: selectedTier.value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColorSchemes.textSecondary),
            dropdownColor: AppColorSchemes.backgroundPrimary,
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 360,
            items: tiers.map((code) {
              return DropdownMenuItem<String>(
                value: code,
                child: _TierSmallBadge(code: code, compact: false),
              );
            }).toList(),
            selectedItemBuilder: (context) => tiers.map((code) => Align(
                  alignment: Alignment.centerLeft,
                  child: _TierSmallBadge(code: code, compact: true),
                )).toList(),
            onChanged: (v) => selectedTier.value = v,
            decoration: InputDecoration(
              labelText: '난이도 티어 선택',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColorSchemes.borderPrimary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColorSchemes.accentBlue),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '문제 난이도에 대한 의견을 남겨주세요 (태그 없이 의견만)',
              hintStyle: const TextStyle(color: AppColorSchemes.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColorSchemes.borderPrimary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColorSchemes.accentBlue),
              ),
            ),
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: isSubmitting.value ? null : handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorSchemes.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(isSubmitting.value ? '등록 중...' : '의견 등록'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TierSmallBadge extends StatelessWidget {
  final String code;
  final bool compact;
  const _TierSmallBadge({required this.code, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final mapped = ProblemTierHelper.getDisplayAndTypeFromCode(code);
    final scheme = TierColors.getColorScheme(mapped.type);
    final double vPad = compact ? 3 : 6;
    final double hPad = compact ? 8 : 10;
    final double fSize = compact ? 11 : 12;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        gradient: scheme.gradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        mapped.display,
        style: TextStyle(
          fontSize: fSize,
          fontWeight: FontWeight.w800,
          color: AppColorSchemes.backgroundPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}


