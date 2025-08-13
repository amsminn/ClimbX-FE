import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../utils/color_schemes.dart';

class MarkdownViewerPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const MarkdownViewerPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<MarkdownViewerPage> createState() => _MarkdownViewerPageState();
}

class _MarkdownViewerPageState extends State<MarkdownViewerPage> {
  String? _content;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await rootBundle.loadString(widget.assetPath);
      if (!mounted) return;
      setState(() {
        _content = text;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '문서를 불러오지 못했습니다.';
      });
    }
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
      body: _error != null
          ? Center(
              child: Text(
                _error!,
                style: const TextStyle(color: AppColorSchemes.textPrimary),
              ),
            )
          : (_content == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Markdown(
                    data: _content!,
                    selectable: true,
                    extensionSet: md.ExtensionSet.gitHubFlavored,
                    onTapLink: (text, href, title) async {
                      if (href == null) return;
                      final uri = Uri.tryParse(href);
                      if (uri == null) return;
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: const TextStyle(color: AppColorSchemes.textPrimary, height: 1.5),
                      strong: const TextStyle(
                        color: AppColorSchemes.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      em: const TextStyle(
                        color: AppColorSchemes.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                      h1: const TextStyle(
                        color: AppColorSchemes.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                      h2: const TextStyle(
                        color: AppColorSchemes.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      h3: const TextStyle(
                        color: AppColorSchemes.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      listBullet: const TextStyle(color: AppColorSchemes.textPrimary),
                      blockquote: const TextStyle(color: AppColorSchemes.textPrimary),
                      tableHead: const TextStyle(color: AppColorSchemes.textPrimary, fontWeight: FontWeight.w700),
                      tableBody: const TextStyle(color: AppColorSchemes.textPrimary),
                    ),
                  ),
                )),
    );
  }
}

