import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/color_schemes.dart';

class EmailComposePage extends StatefulWidget {
  final String title;
  final String toEmail;
  final String defaultSubject;
  final String? hint;
  final String? contentId; // 신고 시 프리필할 수 있는 식별자

  const EmailComposePage({
    super.key,
    required this.title,
    required this.toEmail,
    required this.defaultSubject,
    this.hint,
    this.contentId,
  });

  @override
  State<EmailComposePage> createState() => _EmailComposePageState();
}

class _EmailComposePageState extends State<EmailComposePage> {
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.defaultSubject);
    final buffer = StringBuffer();
    if (widget.contentId != null && widget.contentId!.isNotEmpty) {
      buffer.writeln('콘텐츠 ID/링크: ${widget.contentId}');
      buffer.writeln('');
    }
    buffer.writeln('내용:');
    buffer.writeln('');
    _bodyController = TextEditingController(text: buffer.toString());
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorSchemes.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppColorSchemes.backgroundPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColorSchemes.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColorSchemes.backgroundPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '받는 사람',
                    style: TextStyle(
                      color: AppColorSchemes.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, color: AppColorSchemes.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          widget.toEmail,
                          style: const TextStyle(
                            color: AppColorSchemes.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: '메일 주소 복사',
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await Clipboard.setData(ClipboardData(text: widget.toEmail));
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(content: Text('메일 주소를 복사했습니다.')),
                          );
                        },
                        icon: const Icon(Icons.copy, color: AppColorSchemes.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: '내용',
                  hintText: widget.hint ?? '상세 내용을 입력해 주세요',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColorSchemes.accentBlue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _openMailApp,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('메일 앱으로 보내기'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: '내용 복사',
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(ClipboardData(
                      text: _composeFullBodyForCopyOnly(),
                    ));
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('내용을 클립보드에 복사했습니다')),
                    );
                  },
                  icon: const Icon(Icons.copy, color: AppColorSchemes.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMailApp() async {
    final pkg = await PackageInfo.fromPlatform();
    final footer = [
      '',
      '---',
      '앱 버전: ${pkg.version}+${pkg.buildNumber}',
      '플랫폼/OS: ',
      '닉네임: ',
    ].join('\n');

    final uri = Uri(
      scheme: 'mailto',
      path: widget.toEmail,
      queryParameters: {
        'subject': _subjectController.text.trim(),
        'body': '${_bodyController.text.trim()}\n$footer',
      },
    );

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      await Clipboard.setData(ClipboardData(
        text: 'To: ${widget.toEmail}\n${_composeFullBodyForCopyOnly()}\n$footer',
      ));
      messenger.showSnackBar(
        const SnackBar(content: Text('메일 앱을 열 수 없습니다. 내용을 복사했습니다. 메일 앱에서 붙여넣기 해 주세요.')),
      );
    }
  }

  String _composeFullBodyForCopyOnly() {
    return 'Subject: ${_subjectController.text.trim()}\n\n${_bodyController.text.trim()}';
  }
}

