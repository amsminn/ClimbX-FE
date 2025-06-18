import 'package:flutter/material.dart';
import '../widgets/profile_header.dart';
import '../widgets/tier_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('ClimbX', style: TextStyle(color: Colors.black)),
        actions: const [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: null,
          ),
        ],
      ),
      body: DefaultTabController(
        length: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeader(),
            // 탭바
            Container(
              color: Colors.white,
              child: const TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 4, color: Colors.blue),
                ),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: '개요'),
                  Tab(text: '히스토리'),
                  Tab(text: '스트릭'),
                  Tab(text: '분야별 티어'),
                  Tab(text: '내 영상'),
                ],
              ),
            ),

            // 탭 내용
            // 탭 내용
            Expanded(
              child: TabBarView(
                children: [
                  Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [TierWidget()],
                    ),
                  ),

                  Container(
                    color: Colors.white,
                    child: Center(child: Text('히스토리 콘텐츠')),
                  ),
                  Container(
                    color: Colors.white,
                    child: Center(child: Text('스트릭 콘텐츠')),
                  ),
                  Container(
                    color: Colors.white,
                    child: Center(child: Text('분야별 티어 콘텐츠')),
                  ),

                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Text('내 영상 콘텐츠'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFEDEDED),
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '리더보드'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '분석'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
        onTap: (idx) {
          // 페이지 전환 로직 추가
        },
      ),
    );
  }
}
