import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ye Hongyu | robin.hye',
      themeMode: ThemeMode.system,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const PortfolioPage(),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: dark ? Colors.black : const Color(0xFFF5F5F7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0071E3),
        brightness: brightness,
        surface: dark ? const Color(0xFF1C1C1E) : Colors.white,
      ),
      fontFamily: 'NotoSansSC',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -2.2, height: 1.02),
        displayMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -1.6, height: 1.05),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.7),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.3),
        bodyLarge: TextStyle(height: 1.55),
        bodyMedium: TextStyle(height: 1.55),
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
  static const _compactGlassShape =
      LiquidRoundedSuperellipse(borderRadius: 14);
  static const _actionGlassShape =
      LiquidRoundedSuperellipse(borderRadius: 16);
  final _homeKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();
  bool _english = false;

  Map<String, String> get t => _english ? _en : _zh;

  Future<void> _scrollTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 620), curve: Curves.easeOutCubic, alignment: .06);
  }

  Future<void> _open(String value) => launchUrl(Uri.parse(value), mode: LaunchMode.platformDefault);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 760;
    final background = dark ? Colors.black : const Color(0xFFF5F5F7);
    return GlassScaffold(
      background: _AmbientBackground(dark: dark),
      backgroundColor: background,
      statusBarStyle: GlassStatusBarStyle.auto,
      edgeToEdge: true,
      edgeFade: true,
      settings: dark ? LiquidGlassSettings.ios27Dark : LiquidGlassSettings.ios27Light,
      appBar: GlassAppBar(
        toolbarHeight: compact ? 64 : 72,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 28),
        centerTitle: false,
        leading: Semantics(
          button: true,
          label: _english ? 'Back to top' : '返回首页',
          child: GestureDetector(
            onTap: () => _scrollTo(_homeKey),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(dark ? 'assets/hye-mark-white.png' : 'assets/hye-mark-black.png', width: 64, height: 36, fit: BoxFit.contain),
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
            width: 58, height: 44, stretch: .12, useOwnLayer: true,
            shape: _compactGlassShape,
            glowColor: const Color(0x330071E3),
            pressLightColor: const Color(0xFF0071E3),
            child: Text(_english ? '中' : 'EN', style: TextStyle(fontSize: 14, color: dark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _Hero(key: _homeKey, text: t, dark: dark, compact: compact, onProjects: () => _scrollTo(_projectsKey), onContact: () => _scrollTo(_contactKey)),
          _Section(key: _projectsKey, eyebrow: 'SELECTED WORK', title: t['projectsTitle']!, child: _ProjectGrid(text: t, compact: compact, dark: dark)),
          _Section(key: _aboutKey, eyebrow: 'ABOUT ME', title: t['aboutTitle']!, child: _About(text: t, compact: compact, dark: dark)),
          _Section(
            key: _contactKey, eyebrow: "LET'S CONNECT", title: t['contactTitle']!,
            child: _Contact(text: t, onEmail: () => _open('mailto:robin.hye@icloud.com'), onGithub: () => _open('https://github.com/HongyuYe12')),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 56), child: Text('© ${DateTime.now().year} Ye Hongyu · robin.hye', style: TextStyle(color: dark ? Colors.white54 : Colors.black54))),
        ]),
      ),
    );
  }
}

class _NavText extends StatelessWidget {
  const _NavText({required this.label, required this.onTap});
  final String label; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(22),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Text(label, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500))),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({super.key, required this.text, required this.dark, required this.compact, required this.onProjects, required this.onContact});
  final Map<String, String> text; final bool dark; final bool compact; final VoidCallback onProjects; final VoidCallback onContact;
  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const _Eyebrow("HELLO, I'M YE HONGYU"), const SizedBox(height: 18),
        Text(text['heroTitle']!, textAlign: compact ? TextAlign.center : TextAlign.left, style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: compact ? 48 : 78)),
        const SizedBox(height: 22),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Text(text['heroIntro']!, textAlign: compact ? TextAlign.center : TextAlign.left, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: compact ? 18 : 21, color: dark ? Colors.white70 : Colors.black54))),
        const SizedBox(height: 30),
        Wrap(alignment: compact ? WrapAlignment.center : WrapAlignment.start, spacing: 12, runSpacing: 12, children: [
          GlassButton.custom(label: text['viewProjects']!, onTap: onProjects, useOwnLayer: true, width: 132, height: 50, shape: _PortfolioPageState._actionGlassShape, glowColor: const Color(0x330071E3), pressLightColor: const Color(0xFF0071E3), style: GlassButtonStyle.prominent, child: Text(text['viewProjects']!, style: TextStyle(fontSize: 15, color: dark ? Colors.white : Colors.black, fontWeight: FontWeight.w600))),
          GlassButton.custom(label: text['contactMe']!, onTap: onContact, useOwnLayer: true, width: 112, height: 50, shape: _PortfolioPageState._actionGlassShape, glowColor: const Color(0x330071E3), pressLightColor: const Color(0xFF0071E3), style: GlassButtonStyle.filled, child: Text(text['contactMe']!, style: TextStyle(fontSize: 15, color: dark ? Colors.white : Colors.black, fontWeight: FontWeight.w600))),
        ]),
      ],
    );
    final portrait = Semantics(
      image: true, label: text['portraitLabel'],
      child: SizedBox(width: compact ? 270 : 390, height: compact ? 300 : 430, child: Stack(alignment: Alignment.center, children: [
        Container(width: compact ? 250 : 350, height: compact ? 250 : 350, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: dark ? [const Color(0xFF2D2D30), const Color(0xFF101012)] : [Colors.white, const Color(0xFFDCDCE1)]), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .35 : .12), blurRadius: 60, offset: const Offset(0, 24))])),
        Positioned(bottom: 8, child: Image.asset('assets/memoji-transparent.png', width: compact ? 245 : 345)),
      ])),
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 780),
      child: Padding(
        padding: EdgeInsets.fromLTRB(compact ? 24 : 56, compact ? 110 : 150, compact ? 24 : 56, 100),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: compact ? Column(children: [copy, const SizedBox(height: 42), portrait]) : Row(children: [Expanded(flex: 6, child: copy), const SizedBox(width: 42), Expanded(flex: 4, child: portrait)]))),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.eyebrow, required this.title, required this.child});
  final String eyebrow; final String title; final Widget child;
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 48, vertical: compact ? 72 : 112),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _Eyebrow(eyebrow), const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: compact ? 40 : 58)),
        const SizedBox(height: 42), child,
      ]))),
    );
  }
}

class _ProjectGrid extends StatelessWidget {
  const _ProjectGrid({required this.text, required this.compact, required this.dark});
  final Map<String, String> text; final bool compact; final bool dark;
  @override
  Widget build(BuildContext context) {
    final cards = List.generate(3, (i) => _ProjectCard(index: i + 1, type: text['projectType${i + 1}']!, title: text['projectTitle${i + 1}']!, description: text['projectDesc${i + 1}']!, status: text['comingSoon']!, dark: dark));
    if (compact) return Column(children: cards.map((card) => Padding(padding: const EdgeInsets.only(bottom: 16), child: card)).toList());
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: card))).toList());
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.index, required this.type, required this.title, required this.description, required this.status, required this.dark});
  final int index; final String type; final String title; final String description; final String status; final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 390), padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(color: dark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: dark ? Colors.white10 : Colors.black.withValues(alpha: .05))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(index.toString().padLeft(2, '0'), style: TextStyle(fontSize: 54, fontWeight: FontWeight.w700, color: dark ? Colors.white12 : Colors.black12)),
      const Spacer(), Text(type.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1)), const SizedBox(height: 10),
      Text(title, style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 12),
      Text(description, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: dark ? Colors.white60 : Colors.black54)), const SizedBox(height: 20),
      Text(status, style: const TextStyle(color: Color(0xFF0071E3), fontWeight: FontWeight.w600)),
    ]),
  );
}

class _About extends StatelessWidget {
  const _About({required this.text, required this.compact, required this.dark});
  final Map<String, String> text; final bool compact; final bool dark;
  @override
  Widget build(BuildContext context) {
    final lead = Text(text['aboutLead']!, style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: compact ? 28 : 38));
    final details = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(text['aboutDetail']!, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18, color: dark ? Colors.white70 : Colors.black54)), const SizedBox(height: 28),
      Wrap(spacing: 10, runSpacing: 10, children: List.generate(4, (i) => _SkillChip(text['skill${i + 1}']!, dark: dark))),
    ]);
    return compact ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [lead, const SizedBox(height: 28), details]) : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: lead), const SizedBox(width: 64), Expanded(child: details)]);
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip(this.label, {required this.dark});
  final String label; final bool dark;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: dark ? Colors.white10 : Colors.black.withValues(alpha: .055), borderRadius: BorderRadius.circular(12)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)));
}

class _Contact extends StatelessWidget {
  const _Contact({required this.text, required this.onEmail, required this.onGithub});
  final Map<String, String> text; final VoidCallback onEmail; final VoidCallback onGithub;
  @override
  Widget build(BuildContext context) => GlassContainer.card(
    useOwnLayer: true, quality: GlassQuality.standard, padding: const EdgeInsets.all(32), shape: const LiquidRoundedSuperellipse(borderRadius: 32),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(text['contactText']!, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18)), const SizedBox(height: 26),
      Wrap(spacing: 12, runSpacing: 12, children: [
        GlassButton.custom(label: 'Email robin.hye@icloud.com', onTap: onEmail, useOwnLayer: true, width: 238, height: 52, shape: _PortfolioPageState._actionGlassShape, glowColor: const Color(0x330071E3), pressLightColor: const Color(0xFF0071E3), child: Text('robin.hye@icloud.com ↗', style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600))),
        GlassButton.custom(label: 'GitHub HongyuYe12', onTap: onGithub, useOwnLayer: true, width: 120, height: 52, shape: _PortfolioPageState._actionGlassShape, glowColor: const Color(0x330071E3), pressLightColor: const Color(0xFF0071E3), style: GlassButtonStyle.filled, child: Text('GitHub ↗', style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600))),
      ]),
    ]),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text); final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Color(0xFF0071E3)));
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground({required this.dark}); final bool dark;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: dark ? Colors.black : const Color(0xFFF5F5F7), gradient: RadialGradient(center: const Alignment(.62, -.72), radius: 1.05, colors: dark ? [const Color(0xFF22242A), Colors.black] : [Colors.white, const Color(0xFFF5F5F7)], stops: const [0, .78])));
}

const _zh = <String, String>{
  'projects': '探索', 'about': '关于', 'contact': '联系',
  'heroTitle': '在学习中探索。\n在实践中成长。', 'heroIntro': '你好，我是 Ye Hongyu，一名学生。这里记录我的学习、经历与持续探索的事情。',
  'viewProjects': '查看探索', 'contactMe': '联系我', 'portraitLabel': 'Ye Hongyu 的拟我头像', 'projectsTitle': '学习与探索',
  'projectType1': '个人成长', 'projectTitle1': '学习记录', 'projectDesc1': '未来将在这里分享课程学习、读书笔记和实践成果。',
  'projectType2': '项目实践', 'projectTitle2': '未来项目', 'projectDesc2': '完成新的个人或团队项目后，我会在这里记录过程与收获。',
  'projectType3': '兴趣探索', 'projectTitle3': '想法与发现', 'projectDesc3': '这里将收录我感兴趣的主题、文章以及生活中的新发现。',
  'comingSoon': '持续更新中', 'aboutTitle': '关于我', 'aboutLead': '我是一名保持好奇、乐于学习和探索新事物的学生。',
  'aboutDetail': '目前我正在积累知识与实践经验。这个网站会持续记录我的成长、想法和未来完成的项目。',
  'skill1': '持续学习', 'skill2': '独立思考', 'skill3': '探索实践', 'skill4': '开放合作', 'contactTitle': '欢迎与我联系。',
  'contactText': '如果你想交流学习、兴趣或合作想法，可以通过邮件或 GitHub 找到我。',
};

const _en = <String, String>{
  'projects': 'Work', 'about': 'About', 'contact': 'Contact',
  'heroTitle': 'Explore through learning.\nGrow through practice.', 'heroIntro': 'Hi, I am Ye Hongyu, a student. This is where I share what I learn, build, and continue to explore.',
  'viewProjects': 'View work', 'contactMe': 'Contact me', 'portraitLabel': 'Memoji portrait of Ye Hongyu', 'projectsTitle': 'Learning & exploration',
  'projectType1': 'Personal growth', 'projectTitle1': 'Learning notes', 'projectDesc1': 'Coursework, reading notes, and practical outcomes will be shared here.',
  'projectType2': 'Projects', 'projectTitle2': 'Future projects', 'projectDesc2': 'I will document the process and lessons from future individual and team projects.',
  'projectType3': 'Curiosity', 'projectTitle3': 'Ideas & discoveries', 'projectDesc3': 'A collection of topics, writing, and discoveries that catch my attention.',
  'comingSoon': 'Continuously evolving', 'aboutTitle': 'About me', 'aboutLead': 'I am a curious student who enjoys learning and exploring new ideas.',
  'aboutDetail': 'I am currently building knowledge and practical experience. This site will continue to document my growth, ideas, and future work.',
  'skill1': 'Continuous learning', 'skill2': 'Independent thinking', 'skill3': 'Hands-on exploration', 'skill4': 'Open collaboration', 'contactTitle': 'Let’s connect.',
  'contactText': 'If you would like to talk about learning, shared interests, or collaboration, reach me by email or GitHub.',
};
