import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // 프로필 페이지 이벤트
  static void visitMyStatSummary() {
    _analytics.logEvent(name: 'visit_my_stat_summary');
  }

  static void visitMyHistory(String period) {
    _analytics.logEvent(
      name: 'visit_my_history',
      parameters: {'period': period},
    );
  }

  static void visitMyStreak() {
    _analytics.logEvent(name: 'visit_my_streak');
  }

  static void visitMyVideo() {
    _analytics.logEvent(name: 'visit_my_video');
  }

  static void clickMyVideoRefresh() {
    _analytics.logEvent(name: 'click_my_video_refresh');
  }

  static void clickMyVideoUpload() {
    _analytics.logEvent(name: 'click_my_video_upload');
  }

  static void clickMyVideoFilming() {
    _analytics.logEvent(name: 'click_my_video_filming');
  }

  static void visitMySubmission() {
    _analytics.logEvent(name: 'visit_my_submission');
  }

  static void clickContribution(String problemId, String contextPage) {
    _analytics.logEvent(
      name: 'click_contribution',
      parameters: {
        'problem_id': problemId,
        'context_page': contextPage,
      },
    );
  }

  static void editProfile(String source, String value) {
    _analytics.logEvent(
      name: 'edit_profile',
      parameters: {
        'source': source,
        'value': value,
      },
    );
  }

  // 로그인 페이지 이벤트
  static void clickBack() {
    _analytics.logEvent(name: 'click_back');
  }

  static void clickLogin(String platform) {
    _analytics.logEvent(
      name: 'click_login',
      parameters: {'platform': platform},
    );
  }

  // 랭킹 페이지 이벤트
  static void visitRanking(String sortBy) {
    _analytics.logEvent(
      name: 'visit_ranking',
      parameters: {'sort_by': sortBy},
    );
  }

  static void clickUserView(String nickname, String viewerEmail) {
    _analytics.logEvent(
      name: 'click_user_view',
      parameters: {
        'nickname': nickname,
        'viewer_email': viewerEmail,
      },
    );
  }

  static void visitUserView(String nickname, String viewerEmail) {
    _analytics.logEvent(
      name: 'visit_user_view',
      parameters: {
        'nickname': nickname,
        'viewer_email': viewerEmail,
      },
    );
  }

  // 문제 검색 페이지 이벤트
  static void visitProblemSearchView() {
    _analytics.logEvent(name: 'visit_problem_search_view');
  }

  static void searchProblem({
    String? searchKeyword,
    int? gymId,
    int? areaId,
    String? levelColor,
    String? holdColor,
  }) {
    final Map<String, Object> parameters = {};
    if (searchKeyword != null) parameters['search_keyword'] = searchKeyword;
    if (gymId != null) parameters['gym_id'] = gymId;
    if (areaId != null) parameters['area_id'] = areaId;
    if (levelColor != null) parameters['level_color'] = levelColor;
    if (holdColor != null) parameters['hold_color'] = holdColor;

    _analytics.logEvent(
      name: 'search_problem',
      parameters: parameters,
    );
  }

  static void clickProblemDetail(String problemId) {
    _analytics.logEvent(
      name: 'click_problem_detail',
      parameters: {'problem_id': problemId},
    );
  }

  // 문제 등록 페이지 이벤트
  static void visitProblemRegisterView() {
    _analytics.logEvent(name: 'visit_problem_register_view');
  }

  static void submitProblemRegister({
    required int gymId,
    required int areaId,
    required String levelColor,
    required String holdColor,
  }) {
    _analytics.logEvent(
      name: 'submit_problem_register',
      parameters: {
        'gym_id': gymId,
        'area_id': areaId,
        'level_color': levelColor,
        'hold_color': holdColor,
      },
    );
  }

  // 문제 상세 페이지 이벤트
  static void visitProblemDetailView(String problemId) {
    _analytics.logEvent(
      name: 'visit_problem_detail_view',
      parameters: {'problem_id': problemId},
    );
  }

  static void clickSubmission(String problemId) {
    _analytics.logEvent(
      name: 'click_submission',
      parameters: {'problem_id': problemId},
    );
  }

  static void clickContributionFromProblemDetail(String problemId) {
    _analytics.logEvent(
      name: 'click_contribution',
      parameters: {'problem_id': problemId},
    );
  }

  // 문제 제출 페이지 이벤트
  static void visitProblemSubmissionView(String problemId) {
    _analytics.logEvent(
      name: 'visit_problem_submission_view',
      parameters: {'problem_id': problemId},
    );
  }

  static void submitProblem(String problemId, String videoId, String result) {
    _analytics.logEvent(
      name: 'submit_problem',
      parameters: {
        'problem_id': problemId,
        'video_id': videoId,
        'result': result,
      },
    );
  }

  // 난이도 기여 페이지 이벤트
  static void visitContributionView(String refScreen) {
    _analytics.logEvent(
      name: 'visit_contribution_view',
      parameters: {'ref_screen': refScreen},
    );
  }

  static void submitContribution(String tier, String detail) {
    _analytics.logEvent(
      name: 'submit_contribution',
      parameters: {
        'tier': tier,
        'detail': detail,
      },
    );
  }

  // 지도 페이지 이벤트
  static void visitMap() {
    _analytics.logEvent(name: 'visit_map');
  }

  static void clickMarker(int gymId) {
    _analytics.logEvent(
      name: 'click_marker',
      parameters: {'gym_id': gymId},
    );
  }

  static void clickProblemSearch(int gymId) {
    _analytics.logEvent(
      name: 'click_problem_search',
      parameters: {'gym_id': gymId},
    );
  }

  static void clickPhoneNumber(int gymId) {
    _analytics.logEvent(
      name: 'click_phone_number',
      parameters: {'gym_id': gymId},
    );
  }

  // 설정 페이지 이벤트
  static void viewSetting() {
    _analytics.logEvent(name: 'view_setting');
  }

  static void clickSettingEvent(String event) {
    _analytics.logEvent(
      name: 'click_setting_event',
      parameters: {'event': event},
    );
  }
}