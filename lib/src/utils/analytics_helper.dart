import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsHelper {
  static FirebaseAnalytics? _analyticsInstance;
  static bool _isAnalyticsInitialized = false;

  /// Firebase Analytics 인스턴스를 lazy하게 가져옴
  /// Firebase 초기화가 실패한 경우 null 반환
  static FirebaseAnalytics? get _analytics {
    if (!_isAnalyticsInitialized) {
      _isAnalyticsInitialized = true;
      try {
        _analyticsInstance = FirebaseAnalytics.instance;
      } catch (e) {
        debugPrint('Firebase Analytics 초기화 실패: $e');
        _analyticsInstance = null;
      }
    }
    return _analyticsInstance;
  }

  /// 안전한 이벤트 로깅
  static void _logEventSafely(String eventName, [Map<String, Object>? parameters]) {
    try {
      final analytics = _analytics;
      if (analytics == null) {
        debugPrint('GA 사용 불가 - Firebase 미초기화 ($eventName)');
        return;
      }
      analytics.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      debugPrint('GA 이벤트 로깅 실패 ($eventName): $e');
    }
  }

  // 프로필 페이지 이벤트
  static void visitMyStatSummary() {
    _logEventSafely('visit_my_stat_summary');
  }

  static void visitMyHistory(String period) {
    _logEventSafely('visit_my_history', {'period': period});
  }

  static void visitMyStreak() {
    _logEventSafely('visit_my_streak');
  }

  static void visitMyVideo() {
    _logEventSafely('visit_my_video');
  }

  static void clickMyVideoRefresh() {
    _logEventSafely('click_my_video_refresh');
  }

  static void clickMyVideoUpload() {
    _logEventSafely('click_my_video_upload');
  }

  static void clickMyVideoFilming() {
    _logEventSafely('click_my_video_filming');
  }

  static void visitMySubmission() {
    _logEventSafely('visit_my_submission');
  }

  static void clickContribution(String problemId, String contextPage) {
    _logEventSafely('click_contribution', {
      'problem_id': problemId,
      'context_page': contextPage,
    });
  }

  static void editProfile(String source, String value) {
    _logEventSafely('edit_profile', {
      'source': source,
      'value': value,
    });
  }

  // 로그인 페이지 이벤트
  static void clickBack() {
    _logEventSafely('click_back');
  }

  static void clickLogin(String platform) {
    _logEventSafely('click_login', {'platform': platform});
  }

  // 랭킹 페이지 이벤트
  static void visitRanking(String sortBy) {
    _logEventSafely('visit_ranking', {'sort_by': sortBy});
  }

  static void clickUserView(String nickname, String viewerId) {
    _logEventSafely('click_user_view', {
      'nickname': nickname,
      'viewer_id': viewerId,
    });
  }

  static void visitUserView(String nickname, String viewerId) {
    _logEventSafely('visit_user_view', {
      'nickname': nickname,
      'viewer_id': viewerId,
    });
  }

  // 문제 검색 페이지 이벤트
  static void visitProblemSearchView() {
    _logEventSafely('visit_problem_search_view');
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

    _logEventSafely('search_problem', parameters);
  }

  static void clickProblemDetail(String problemId) {
    _logEventSafely('click_problem_detail', {'problem_id': problemId});
  }

  // 문제 등록 페이지 이벤트
  static void visitProblemRegisterView() {
    _logEventSafely('visit_problem_register_view');
  }

  static void submitProblemRegister({
    required int gymId,
    required int areaId,
    required String levelColor,
    required String holdColor,
  }) {
    _logEventSafely('submit_problem_register', {
      'gym_id': gymId,
      'area_id': areaId,
      'level_color': levelColor,
      'hold_color': holdColor,
    });
  }

  // 문제 상세 페이지 이벤트
  static void visitProblemDetailView(String problemId) {
    _logEventSafely('visit_problem_detail_view', {'problem_id': problemId});
  }

  static void clickSubmission(String problemId) {
    _logEventSafely('click_submission', {'problem_id': problemId});
  }


  // 문제 제출 페이지 이벤트
  static void visitProblemSubmissionView(String problemId) {
    _logEventSafely('visit_problem_submission_view', {'problem_id': problemId});
  }

  static void submitProblem(String problemId, String videoId, String result) {
    _logEventSafely('submit_problem', {
      'problem_id': problemId,
      'video_id': videoId,
      'result': result,
    });
  }

  // 난이도 기여 페이지 이벤트
  static void visitContributionView(String refScreen) {
    _logEventSafely('visit_contribution_view', {'ref_screen': refScreen});
  }

  static void submitContribution(String tier, String detail) {
    _logEventSafely('submit_contribution', {
      'tier': tier,
      'detail': detail,
    });
  }

  // 지도 페이지 이벤트
  static void visitMap() {
    _logEventSafely('visit_map');
  }

  static void clickMarker(int gymId) {
    _logEventSafely('click_marker', {'gym_id': gymId});
  }

  static void clickProblemSearch(int gymId) {
    _logEventSafely('click_problem_search', {'gym_id': gymId});
  }

  static void clickPhoneNumber(int gymId) {
    _logEventSafely('click_phone_number', {'gym_id': gymId});
  }

  // 설정 페이지 이벤트
  static void viewSetting() {
    _logEventSafely('view_setting');
  }

  static void clickSettingEvent(String event) {
    _logEventSafely('click_setting_event', {'event': event});
  }
}