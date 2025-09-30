import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import '../api/vote.dart';
import '../utils/color_schemes.dart';
import '../utils/tier_colors.dart';
import '../models/problem_tier_code.dart';
import '../utils/analytics_helper.dart';

class ProblemVoteCompose extends HookWidget {
  final String problemId;
  final VoidCallback? onSubmitted;

  const ProblemVoteCompose({super.key, required this.problemId, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedTier = useState<ProblemTierCode?>(null);

    final queryClient = useQueryClient();
    final mutation = useMutation(
      (Map<String, dynamic> vars) => ProblemVoteApi.createVote(
        problemId: problemId,
        tier: vars['tier'] as String,
        comment: vars['comment'] as String?,
      ),
      onSuccess: (_, __, ___) {
        // GA 이벤트 로깅
        AnalyticsHelper.submitContribution(
          selectedTier.value!.code,
          controller.text.trim(),
        );
        
        controller.clear();
        selectedTier.value = null;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('의견이 등록되었어요')),
          );
          onSubmitted?.call();
          queryClient.invalidateQueries(['problem_votes', problemId]);
        }
        isSubmitting.value = false;
      },
      onError: (error, __, ___) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('의견을 등록할 수 없어요')),
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
        'tier': selectedTier.value!.code,
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
          // 티어 선택 (드롭다운) - FormField 직접 사용해 버전 호환/디프리케이션 회피
          InputDecorator(
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ProblemTierCode>(
                value: selectedTier.value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColorSchemes.textSecondary),
                items: ProblemTierCode.all.map((tierCode) {
                  return DropdownMenuItem<ProblemTierCode>(
                    value: tierCode,
                    child: _TierSmallBadge(tierCode: tierCode, compact: true),
                  );
                }).toList(),
                onChanged: (v) => selectedTier.value = v,
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
  final ProblemTierCode tierCode;
  final bool compact;
  const _TierSmallBadge({required this.tierCode, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final scheme = TierColors.getColorScheme(tierCode.tierType);
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
        tierCode.display,
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


