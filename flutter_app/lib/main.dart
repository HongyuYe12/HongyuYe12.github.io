// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize(warmUpMode: GlassWarmUpMode.auto);
  runApp(LiquidGlassWidgets.wrap(
    theme: const GlassThemeData.ios27(),
    child: const HyeApp(),
  ));
}

class HyeApp extends StatelessWidget {
  const HyeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ye Hongyu | robin.hye',
        themeMode: ThemeMode.system,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const PortfolioPage(),
      );

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final foreground = dark ? const Color(0xFFF5F5F7) : const Color(0xFF1D1D1F);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: dark ? Colors.black : Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0071E3), brightness: brightness, surface: dark ? const Color(0xFF1D1D1F) : Colors.white),
      fontFamily: 'NotoSansSC',
      textTheme: TextTheme(
        displayLarge: TextStyle(color: foreground, fontWeight: FontWeight.w700, letterSpacing: -2.6, height: 1.06),
        displayMedium: TextStyle(color: foreground, fontWeight: FontWeight.w700, letterSpacing: -1.8, height: 1.08),
        headlineMedium: TextStyle(color: foreground, fontWeight: FontWeight.w600, letterSpacing: -.8, height: 1.14),
        titleLarge: TextStyle(color: foreground, fontWeight: FontWeight.w600, letterSpacing: -.4),
        bodyLarge: TextStyle(color: foreground, height: 1.52),
        bodyMedium: TextStyle(color: foreground, height: 1.52),
      ),
    );
  }
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  static const _languageShape = LiquidOval();
  static const _glassShape = LiquidRoundedSuperellipse(borderRadius: 28);
  final _homeKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();
  bool _english = false;
  Map<String, String> get t => _english ? _en : _zh;

  Future<void> _scrollTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic, alignment: .04);
  }

  Future<void> _open(String value) => launchUrl(Uri.parse(value), mode: LaunchMode.platformDefault);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 760;
    return GlassScaffold(
      background: ColoredBox(color: dark ? Colors.black : const Color(0xFFF5F5F7)),
      backgroundColor: dark ? Colors.black : const Color(0xFFF5F5F7),
      statusBarStyle: GlassStatusBarStyle.auto,
      edgeToEdge: true,
      edgeFade: true,
      settings: dark ? LiquidGlassSettings.ios27Dark : LiquidGlassSettings.ios27Light,
      appBar: GlassAppBar(
        toolbarHeight: 52,
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 28),
        centerTitle: false,
        leading: Semantics(
          button: true,
          label: _english ? 'Back to top' : '返回首页',
          child: GestureDetector(
            onTap: () => _scrollTo(_homeKey),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Image.asset(dark ? 'assets/hye-mark-white.png' : 'assets/hye-mark-black.png', width: 54, height: 28, fit: BoxFit.contain),
            ),
          ),
        ),
        actions: [
          if (!compact) ...[
            _NavText(label: t['projects']!, onTap: () => _scrollTo(_projectsKey)),
            _NavText(label: t['about']!, onTap: () => _scrollTo(_aboutKey)),
            _NavText(label: t['contact']!, onTap: () => _scrollTo(_contactKey)),
            const SizedBox(width: 8),
          ],
          GlassButton.custom(
            label: _english ? '切换为中文' : 'Switch to English',
            onTap: () => setState(() => _english = !_english),
            width: 40, height: 40, stretch: .06, useOwnLayer: true, shape: _languageShape,
            glowColor: const Color(0x330071E3), pressLightColor: const Color(0xFF0071E3),
            child: Text(_english ? '中' : 'EN', style: TextStyle(fontSize: 12, color: dark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _Hero(key: _homeKey, text: t, dark: dark, compact: compact, onProjects: () => _scrollTo(_projectsKey), onContact: () => _scrollTo(_contactKey)),
          _Projects(key: _projectsKey, text: t, dark: dark, compact: compact),
          _About(key: _aboutKey, text: t, dark: dark, compact: compact),
          _Contact(key: _contactKey, text: t, dark: dark, compact: compact, onEmail: () => _open('mailto:robin.hye@icloud.com'), onGithub: () => _open('https://github.com/HongyuYe12')),
          _Footer(dark: dark),
        ]),
      ),
    );
  }
}

class _NavText extends StatelessWidget {
  const _NavText({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w400)),
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({super.key, required this.text, required this.dark, required this.compact, required this.onProjects, required this.onContact});
  final Map<String, String> text;
  final bool dark;
  final bool compact;
  final VoidCallback onProjects;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final secondary = dark ? const Color(0xFFB7B7BD) : const Color(0xFF6E6E73);
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 760 : 840),
      color: dark ? Colors.black : Colors.white,
      padding: EdgeInsets.fromLTRB(24, compact ? 94 : 112, 24, compact ? 30 : 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(text['heroEyebrow']!, textAlign: TextAlign.center, style: TextStyle(color: secondary, fontSize: compact ? 17 : 21, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(text['heroTitle']!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: compact ? 46 : 76, letterSpacing: compact ? -1.8 : -3.2)),
            const SizedBox(height: 20),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Text(text['heroIntro']!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: compact ? 18 : 22, color: secondary, height: 1.42))),
            const SizedBox(height: 18),
            Wrap(alignment: WrapAlignment.center, spacing: 22, runSpacing: 4, children: [
              _BlueLink(label: text['viewProjects']!, onTap: onProjects),
              _BlueLink(label: text['contactMe']!, onTap: onContact),
            ]),
            SizedBox(height: compact ? 38 : 46),
            Semantics(
              image: true, label: text['portraitLabel'],
              child: SizedBox(
                width: compact ? 310 : 430, height: compact ? 300 : 390,
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    width: compact ? 270 : 360, height: compact ? 270 : 360,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: dark ? [const Color(0xFF252528), const Color(0xFF101012)] : [const Color(0xFFF5F5F7), const Color(0xFFD9D9DE)])),
                  ),
                  Positioned(bottom: 0, child: Image.asset('assets/memoji-transparent.png', width: compact ? 285 : 390)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BlueLink extends StatelessWidget {
  const _BlueLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: const TextStyle(color: Color(0xFF0071E3), fontSize: 17, fontWeight: FontWeight.w500)),
          const SizedBox(width: 3),
          const Icon(Icons.chevron_right_rounded, size: 17, color: Color(0xFF0071E3)),
        ]),
      ),
    ),
  );
}

class _Projects extends StatelessWidget {
  const _Projects({super.key, required this.text, required this.dark, required this.compact});
  final Map<String, String> text;
  final bool dark;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    color: dark ? const Color(0xFF101010) : const Color(0xFFF5F5F7),
    padding: EdgeInsets.fromLTRB(compact ? 12 : 20, compact ? 12 : 20, compact ? 12 : 20, compact ? 72 : 112),
    child: Column(children: [
      _ShowcaseCard(
        minHeight: compact ? 560 : 680,
        eyebrow: text['projectType1']!, title: text['projectTitle1']!, description: text['projectDesc1']!, status: text['comingSoon']!,
        art: _LearningArt(compact: compact),
      ),
      SizedBox(height: compact ? 12 : 20),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: compact
            ? Column(children: [
                _ProjectTile(light: true, eyebrow: text['projectType2']!, title: text['projectTitle2']!, description: text['projectDesc2']!, status: text['comingSoon']!, number: '02'),
                const SizedBox(height: 12),
                _ProjectTile(light: false, eyebrow: text['projectType3']!, title: text['projectTitle3']!, description: text['projectDesc3']!, status: text['comingSoon']!, number: '03'),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _ProjectTile(light: true, eyebrow: text['projectType2']!, title: text['projectTitle2']!, description: text['projectDesc2']!, status: text['comingSoon']!, number: '02')),
                const SizedBox(width: 20),
                Expanded(child: _ProjectTile(light: false, eyebrow: text['projectType3']!, title: text['projectTitle3']!, description: text['projectDesc3']!, status: text['comingSoon']!, number: '03')),
              ]),
      ),
    ]),
  );
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({required this.minHeight, required this.eyebrow, required this.title, required this.description, required this.status, required this.art});
  final double minHeight;
  final String eyebrow;
  final String title;
  final String description;
  final String status;
  final Widget art;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: 1440, minHeight: minHeight),
    child: Container(
      width: double.infinity, clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF050505), Color(0xFF252329)]), borderRadius: BorderRadius.circular(28)),
      child: Stack(children: [
        Positioned.fill(child: art),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 58, 24, 36),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(eyebrow, style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 48, height: 1.06, letterSpacing: -1.7, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.45)),
                const SizedBox(height: 12),
                Text(status, style: const TextStyle(color: Color(0xFF2997FF), fontSize: 16, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ),
      ]),
    ),
  );
}

class _LearningArt extends StatelessWidget {
  const _LearningArt({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) => Stack(alignment: Alignment.bottomCenter, children: [
    Positioned(
      bottom: compact ? -150 : -220,
      child: Container(
        width: compact ? 510 : 900, height: compact ? 510 : 900,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF6D5DFB).withValues(alpha: .9), const Color(0xFF1677FF).withValues(alpha: .42), Colors.transparent], stops: const [0, .42, .72])),
      ),
    ),
    Positioned(bottom: compact ? 32 : 36, child: Image.asset('assets/hye-mark-white.png', width: compact ? 210 : 300, fit: BoxFit.contain)),
  ]);
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.light, required this.eyebrow, required this.title, required this.description, required this.status, required this.number});
  final bool light;
  final String eyebrow;
  final String title;
  final String description;
  final String status;
  final String number;
  @override
  Widget build(BuildContext context) {
    final foreground = light ? const Color(0xFF1D1D1F) : Colors.white;
    return Container(
      constraints: const BoxConstraints(minHeight: 580),
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 38),
      decoration: BoxDecoration(color: light ? Colors.white : Colors.black, borderRadius: BorderRadius.circular(28)),
      child: Column(children: [
        Text(eyebrow, style: TextStyle(color: foreground.withValues(alpha: .62), fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center, style: TextStyle(color: foreground, fontSize: 40, height: 1.08, letterSpacing: -1.2, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Text(description, textAlign: TextAlign.center, style: TextStyle(color: foreground.withValues(alpha: .62), fontSize: 17, height: 1.45))),
        const SizedBox(height: 12),
        Text(status, style: const TextStyle(color: Color(0xFF0071E3), fontSize: 16, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(number, style: TextStyle(color: foreground.withValues(alpha: .08), fontSize: 170, height: .86, letterSpacing: -9, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _About extends StatelessWidget {
  const _About({super.key, required this.text, required this.dark, required this.compact});
  final Map<String, String> text;
  final bool dark;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final secondary = dark ? const Color(0xFFB7B7BD) : const Color(0xFF6E6E73);
    return Container(
      color: dark ? Colors.black : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: compact ? 96 : 150),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(children: [
            Text(text['aboutTitle']!, style: TextStyle(color: secondary, fontSize: 19, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Text(text['aboutLead']!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: compact ? 40 : 62)),
            const SizedBox(height: 28),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Text(text['aboutDetail']!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: compact ? 18 : 21, color: secondary))),
            const SizedBox(height: 40),
            Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: List.generate(4, (i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(color: dark ? const Color(0xFF1D1D1F) : const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(14)),
              child: Text(
                text['skill${i + 1}']!,
                style: TextStyle(
                  color: dark ? const Color(0xFFF5F5F7) : const Color(0xFF1D1D1F),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))),
          ]),
        ),
      ),
    );
  }
}

class _Contact extends StatelessWidget {
  const _Contact({super.key, required this.text, required this.dark, required this.compact, required this.onEmail, required this.onGithub});
  final Map<String, String> text;
  final bool dark;
  final bool compact;
  final VoidCallback onEmail;
  final VoidCallback onGithub;
  @override
  Widget build(BuildContext context) => Container(
    color: dark ? const Color(0xFF101010) : const Color(0xFFF5F5F7),
    padding: EdgeInsets.fromLTRB(compact ? 16 : 24, compact ? 72 : 110, compact ? 16 : 24, compact ? 72 : 110),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: GlassContainer.card(
          useOwnLayer: true, quality: GlassQuality.standard, padding: EdgeInsets.symmetric(horizontal: compact ? 24 : 64, vertical: compact ? 56 : 78), shape: _PortfolioPageState._glassShape,
          child: Column(children: [
            Text(text['contactTitle']!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: compact ? 42 : 62)),
            const SizedBox(height: 18),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: Text(text['contactText']!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: compact ? 17 : 20, color: dark ? const Color(0xFFB7B7BD) : const Color(0xFF6E6E73)))),
            const SizedBox(height: 20),
            Wrap(alignment: WrapAlignment.center, spacing: 22, runSpacing: 4, children: [
              _BlueLink(label: 'robin.hye@icloud.com', onTap: onEmail),
              _BlueLink(label: 'GitHub', onTap: onGithub),
            ]),
          ]),
        ),
      ),
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer({required this.dark});
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, color: dark ? const Color(0xFF101010) : const Color(0xFFF5F5F7), padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Container(
          padding: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: dark ? Colors.white12 : Colors.black12))),
          child: Text('Copyright © ${DateTime.now().year} Ye Hongyu. All rights reserved.', style: TextStyle(fontSize: 12, color: dark ? Colors.white54 : Colors.black54)),
        ),
      ),
    ),
  );
}

const _zh = <String, String>{
  'projects': '探索', 'about': '关于', 'contact': '联系',
  'heroEyebrow': 'Ye Hongyu · Student', 'heroTitle': '学习。创造。持续探索。',
  'heroIntro': '你好，我是 Ye Hongyu。这里记录我的学习、实践，以及每一次从好奇心出发的探索。',
  'viewProjects': '了解探索', 'contactMe': '联系我', 'portraitLabel': 'Ye Hongyu 的拟我头像',
  'projectType1': '个人成长', 'projectTitle1': '让每一次学习，都留下作品。', 'projectDesc1': '课程、阅读与实践，不只是完成任务，也是在建立自己的思考方式。',
  'projectType2': '项目实践', 'projectTitle2': '从想法到实现。', 'projectDesc2': '未来完成的个人与团队项目，会在这里记录过程、选择与收获。',
  'projectType3': '兴趣探索', 'projectTitle3': '保持好奇。', 'projectDesc3': '收集值得继续研究的主题、文章、灵感，以及生活中的新发现。',
  'comingSoon': '持续更新中', 'aboutTitle': '关于我', 'aboutLead': '好奇心，是我理解世界的方式。',
  'aboutDetail': '我是一名学生，正在积累知识与实践经验。这个网站会持续记录我的成长、思考，以及未来完成的项目。',
  'skill1': '持续学习', 'skill2': '独立思考', 'skill3': '探索实践', 'skill4': '开放合作',
  'contactTitle': '一起聊聊。', 'contactText': '如果你想交流学习、共同兴趣或合作想法，可以通过邮件或 GitHub 找到我。',
};

const _en = <String, String>{
  'projects': 'Explore', 'about': 'About', 'contact': 'Contact',
  'heroEyebrow': 'Ye Hongyu · Student', 'heroTitle': 'Learn. Create. Keep exploring.',
  'heroIntro': 'Hi, I am Ye Hongyu. This is where I document what I learn, what I make, and every exploration that begins with curiosity.',
  'viewProjects': 'Explore my work', 'contactMe': 'Contact me', 'portraitLabel': 'Memoji portrait of Ye Hongyu',
  'projectType1': 'Personal growth', 'projectTitle1': 'Turn every lesson into something made.', 'projectDesc1': 'Coursework, reading, and practice help me build not only knowledge, but my own way of thinking.',
  'projectType2': 'Projects', 'projectTitle2': 'From an idea to reality.', 'projectDesc2': 'Future individual and team projects will document the process, decisions, and lessons along the way.',
  'projectType3': 'Curiosity', 'projectTitle3': 'Stay curious.', 'projectDesc3': 'A growing collection of topics, writing, inspiration, and discoveries worth exploring further.',
  'comingSoon': 'Continuously evolving', 'aboutTitle': 'About me', 'aboutLead': 'Curiosity is how I understand the world.',
  'aboutDetail': 'I am a student building knowledge and practical experience. This site will continue to document my growth, ideas, and future work.',
  'skill1': 'Continuous learning', 'skill2': 'Independent thinking', 'skill3': 'Hands-on exploration', 'skill4': 'Open collaboration',
  'contactTitle': 'Let’s talk.', 'contactText': 'If you would like to talk about learning, shared interests, or collaboration, reach me by email or GitHub.',
};
