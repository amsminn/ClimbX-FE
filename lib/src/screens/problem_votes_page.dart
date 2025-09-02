import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fquery/fquery.dart';
import '../api/vote.dart';
import '../models/problem_vote.dart';
import '../utils/color_schemes.dart';
import '../widgets/problem_vote_compose.dart';
import '../widgets/problem_vote_list_item.dart';

class ProblemVotesPage extends HookWidget {
  final String problemId;

  const ProblemVotesPage({super.key, required this.problemId});

  @override
  Widget build(BuildContext context) {
    final queryClient = useQueryClient();
    final page = useState(0);
    const size = 20;
    final votes = useState<List<ProblemVote>>([]);
    final hasMore = useState(true);
    final isLoadingMore = useState(false);

    final initialQuery = useQuery<List<ProblemVote>, Exception>(
      ['problem_votes', problemId],
      () => ProblemVoteApi.getVotes(problemId: problemId, page: 0, size: size),
    );

    useEffect(() {
      if (initialQuery.data != null) {
        votes.value = initialQuery.data!;
        hasMore.value = initialQuery.data!.length == size;
        page.value = 0;
      }
      return null;
    }, [initialQuery.data]);

    Future<void> loadMore() async {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
      try {
        final nextPage = page.value + 1;
        final next = await ProblemVoteApi.getVotes(problemId: problemId, page: nextPage, size: size);
        votes.value = [...votes.value, ...next];
        page.value = nextPage;
        hasMore.value = next.length == size;
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('불러오기 실패: $e')),
        );
      } finally {
        isLoadingMore.value = false;
      }
    }

    void refreshAfterSubmit() {
      queryClient.invalidateQueries(['problem_votes', problemId]);
    }

    return Scaffold(
      backgroundColor: AppColorSchemes.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppColorSchemes.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColorSchemes.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '난이도 기여',
          style: TextStyle(color: AppColorSchemes.textPrimary),
        ),
      ),
      body: initialQuery.isLoading
          ? const Center(child: CircularProgressIndicator())
          : initialQuery.isError
              ? _buildError(context, initialQuery.error.toString())
              : _buildContent(context, votes.value, hasMore.value, isLoadingMore.value, loadMore, refreshAfterSubmit),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColorSchemes.accentRed, size: 48),
          const SizedBox(height: 12),
          Text('불러오기 실패: $message', style: const TextStyle(color: AppColorSchemes.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<ProblemVote> list,
    bool hasMore,
    bool isLoadingMore,
    Future<void> Function() loadMore,
    VoidCallback refreshAfterSubmit,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
          loadMore();
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProblemVoteCompose(problemId: problemId, onSubmitted: refreshAfterSubmit),
          const SizedBox(height: 16),
          if (list.isEmpty)
            _buildEmpty()
          else ...[
            ...list.map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProblemVoteListItem(vote: v),
              ),
            ),
            if (isLoadingMore) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            if (!isLoadingMore && hasMore)
              Center(
                child: TextButton(
                  onPressed: loadMore,
                  child: const Text('더 보기'),
                ),
              ),
          ]
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColorSchemes.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorSchemes.borderPrimary),
      ),
      child: const Text(
        '아직 등록된 의견이 없어요. 첫 의견을 남겨보세요!',
        style: TextStyle(color: AppColorSchemes.textSecondary),
      ),
    );
  }
}


