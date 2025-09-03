enum LeaderboardType {
  rating('레이팅', 'rating'),
  streak('스트릭', 'current_streak'),
  longestStreak('최장 스트릭', 'longest_streak'),
  solvedProblems('푼 문제 수', 'solved_count');

  const LeaderboardType(this.label, this.criteria);
  
  final String label;
  final String criteria; // API 호출시 사용할 파라미터값
} 