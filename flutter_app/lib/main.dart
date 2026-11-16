// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

const _darkPage = Color(0xFF000000);
const _darkCard = Color(0xFF1C1C1E);
const _darkPrimary = Color(0xFFF5F5F7);
const _darkSecondary = Color(0xFFA1A1A6);
const _darkLink = Color(0xFF2997FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize(warmUpMode: GlassWarmUpMode.auto);
  runApp(
    LiquidGlassWidgets.wrap(
      theme: const GlassThemeData.ios27(),
      child: const HyeApp(),
    ),
  );
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
    final foreground = dark ? _darkPrimary : const Color(0xFF1D1D1F);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: dark ? _darkPage : Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dark ? _darkLink : const Color(0xFF0071E3),
        brightness: brightness,
        surface: dark ? _darkCard : Colors.white,
      ),
      fontFamily: 'NotoSansSC',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: -2.6,
          height: 1.06,
          decoration: TextDecoration.none,
        ),
        displayMedium: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.8,
          height: 1.08,
          decoration: TextDecoration.none,
        ),
        headlineMedium: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -.8,
          height: 1.14,
          decoration: TextDecoration.none,
        ),
        titleLarge: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -.4,
          decoration: TextDecoration.none,
        ),
        bodyLarge: TextStyle(
          color: foreground,
          height: 1.52,
          decoration: TextDecoration.none,
        ),
        bodyMedium: TextStyle(
          color: foreground,
          height: 1.52,
          decoration: TextDecoration.none,
        ),
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
  final _homeKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _contactKey = GlobalKey();
  final _scrollController = ScrollController();
  bool _english = false;
  bool _menuOpen = false;
  bool _scrolled = false;
  Map<String, String> get t => _english ? _en : _zh;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final next = _scrollController.offset > 96;
    if (next != _scrolled && mounted) setState(() => _scrolled = next);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: .04,
    );
  }

  Future<void> _open(String value) =>
      launchUrl(Uri.parse(value), mode: LaunchMode.platformDefault);

  void _menuScroll(GlobalKey key) {
    setState(() => _menuOpen = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(key));
  }

  void _openDetail(bool photography) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _DetailPage(photography: photography, english: _english),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 760;
    return GlassScaffold(
      background: ColoredBox(color: dark ? _darkPage : const Color(0xFFF5F5F7)),
      backgroundColor: dark ? _darkPage : const Color(0xFFF5F5F7),
      statusBarStyle: GlassStatusBarStyle.auto,
      edgeToEdge: true,
      edgeFade: true,
      settings: dark
          ? LiquidGlassSettings.ios27Dark
          : LiquidGlassSettings.ios27Light,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _Hero(
                  key: _homeKey,
                  text: t,
                  dark: dark,
                  compact: compact,
                  onProjects: () => _scrollTo(_projectsKey),
                  onContact: () => _scrollTo(_contactKey),
                ),
                _Projects(
                  key: _projectsKey,
                  text: t,
                  dark: dark,
                  compact: compact,
                  onComputer: () => _openDetail(false),
                  onPhotography: () => _openDetail(true),
                ),
                _Contact(
                  key: _contactKey,
                  text: t,
                  dark: dark,
                  compact: compact,
                  onEmail: () => _open('mailto:robin.hye@icloud.com'),
                  onGithub: () => _open('https://github.com/HongyuYe12'),
                ),
                _Footer(dark: dark),
              ],
            ),
          ),
          if (_menuOpen)
            Positioned.fill(
              child: _MenuPanel(
                text: t,
                dark: dark,
                english: _english,
                onComputer: () => _menuScroll(_projectsKey),
                onPhotography: () => _menuScroll(_projectsKey),
                onContact: () => _menuScroll(_contactKey),
                onLanguage: () => setState(() => _english = !_english),
              ),
            ),
          if (!_scrolled)
            Positioned(
              left: compact ? 16 : 28,
              right: compact ? 14 : 26,
              top: 8,
              child: _TopBar(
                dark: dark,
                menuOpen: _menuOpen,
                english: _english,
                onHome: () => _scrollTo(_homeKey),
                onMenu: () => setState(() => _menuOpen = !_menuOpen),
              ),
            ),
          if (_scrolled)
            Positioned(
              left: compact ? 12 : 28,
              right: compact ? 12 : 28,
              top: compact ? 10 : 18,
              child: _FloatingNav(
                dark: dark,
                compact: compact,
                english: _english,
                menuOpen: _menuOpen,
                onHome: () => _scrollTo(_homeKey),
                onExplore: () => _scrollTo(_projectsKey),
                onMenu: () => setState(() => _menuOpen = !_menuOpen),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.dark,
    required this.menuOpen,
    required this.english,
    required this.onHome,
    required this.onMenu,
  });
  final bool dark;
  final bool menuOpen;
  final bool english;
  final VoidCallback onHome;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Semantics(
        button: true,
        label: english ? 'Back to top' : '返回首页',
        child: InkWell(
          onTap: onHome,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Image.asset(
              dark ? 'assets/hye-mark-white.png' : 'assets/hye-mark-black.png',
              width: 54,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      _MenuButton(
        dark: dark,
        menuOpen: menuOpen,
        english: english,
        onTap: onMenu,
      ),
    ],
  );
}

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.dark,
    required this.compact,
    required this.english,
    required this.menuOpen,
    required this.onHome,
    required this.onExplore,
    required this.onMenu,
  });
  final bool dark;
  final bool compact;
  final bool english;
  final bool menuOpen;
  final VoidCallback onHome;
  final VoidCallback onExplore;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1120),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? const Color(0xF21A1A1A) : const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(compact ? 28 : 36),
          border: Border.all(color: dark ? Colors.white12 : Colors.black12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(compact ? 18 : 28, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onHome,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Ye Hongyu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dark ? _darkPrimary : const Color(0xFF1D1D1F),
                        fontSize: compact ? 20 : 27,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.7,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
              if (!compact)
                OutlinedButton(
                  onPressed: onExplore,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: dark
                        ? _darkPrimary
                        : const Color(0xFF1D1D1F),
                    side: BorderSide(
                      color: dark ? Colors.white38 : Colors.black26,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(english ? 'Explore' : '探索'),
                ),
              if (!compact) const SizedBox(width: 10),
              _MenuButton(
                dark: dark,
                menuOpen: menuOpen,
                english: english,
                onTap: onMenu,
                filled: true,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.dark,
    required this.menuOpen,
    required this.english,
    required this.onTap,
    this.filled = false,
  });
  final bool dark;
  final bool menuOpen;
  final bool english;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: menuOpen
        ? (english ? 'Close menu' : '关闭菜单')
        : (english ? 'Open menu' : '打开菜单'),
    child: Material(
      color: filled
          ? const Color(0xFF0071E3)
          : (dark ? const Color(0xB3222224) : const Color(0xCCF5F5F7)),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 48,
          child: Icon(
            menuOpen ? Icons.close_rounded : Icons.menu_rounded,
            size: 25,
            color: filled || dark ? Colors.white : const Color(0xFF1D1D1F),
          ),
        ),
      ),
    ),
  );
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.text,
    required this.dark,
    required this.english,
    required this.onComputer,
    required this.onPhotography,
    required this.onContact,
    required this.onLanguage,
  });
  final Map<String, String> text;
  final bool dark;
  final bool english;
  final VoidCallback onComputer;
  final VoidCallback onPhotography;
  final VoidCallback onContact;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    final color = dark ? _darkPrimary : const Color(0xFF1D1D1F);
    return Material(
      color: dark ? _darkPage : const Color(0xFFF5F5F7),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(34, 76, 34, 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuItem(text['computerProjects']!, onComputer, color),
              _MenuItem(text['photography']!, onPhotography, color),
              _MenuItem(text['contact']!, onContact, color),
              const SizedBox(height: 22),
              Divider(color: dark ? Colors.white12 : Colors.black12),
              const SizedBox(height: 18),
              _MenuItem(
                english ? '切换为中文' : 'Switch to English',
                onLanguage,
                color,
                small: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(this.label, this.onTap, this.color, {this.small = false});
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool small;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: small ? 14 : 18),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: small ? 22 : 38,
            height: 1.05,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.1,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({
    super.key,
    required this.text,
    required this.dark,
    required this.compact,
    required this.onProjects,
    required this.onContact,
  });
  final Map<String, String> text;
  final bool dark;
  final bool compact;
  final VoidCallback onProjects;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final secondary = dark ? _darkSecondary : const Color(0xFF6E6E73);
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text['heroName']!,
          style: Theme.of(context).textTheme.displayLarge!.copyWith(
            fontSize: compact ? 46 : 68,
            fontWeight: FontWeight.w500,
            letterSpacing: compact ? -1.8 : -2.8,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          text['heroRole']!,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
            fontSize: compact ? 28 : 44,
            color: secondary,
            fontWeight: FontWeight.w400,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: compact ? 28 : 38),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            text['heroIntro']!,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: compact ? 18 : 21,
              color: secondary,
              height: 1.52,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 22,
          runSpacing: 2,
          children: [
            _BlueLink(label: text['viewProjects']!, onTap: onProjects),
            _BlueLink(label: text['contactMe']!, onTap: onContact),
          ],
        ),
      ],
    );
    final portrait = Semantics(
      image: true,
      label: text['portraitLabel'],
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image.asset(
          'assets/memoji-portrait-transparent.png',
          width: compact ? 330 : 480,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 760 : 680),
      decoration: BoxDecoration(
        color: dark ? _darkPage : Colors.white,
        gradient: dark
            ? const RadialGradient(
                center: Alignment(0.72, -0.38),
                radius: 1.05,
                colors: [Color(0xFF171126), Color(0xFF07070A), _darkPage],
                stops: [0, .48, 1],
              )
            : null,
      ),
      padding: EdgeInsets.fromLTRB(
        compact ? 0 : 48,
        compact ? 70 : 82,
        compact ? 0 : 48,
        0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 390, child: portrait),
                    Container(
                      color: dark ? const Color(0xE6000000) : Colors.white,
                      padding: const EdgeInsets.fromLTRB(28, 54, 28, 72),
                      child: copy,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18, bottom: 80),
                        child: copy,
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      flex: 6,
                      child: SizedBox(height: 560, child: portrait),
                    ),
                  ],
                ),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? _darkLink
                    : const Color(0xFF0071E3),
                fontSize: 17,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: Theme.of(context).brightness == Brightness.dark
                  ? _darkLink
                  : const Color(0xFF0071E3),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Projects extends StatelessWidget {
  const _Projects({
    super.key,
    required this.text,
    required this.dark,
    required this.compact,
    required this.onComputer,
    required this.onPhotography,
  });
  final Map<String, String> text;
  final bool dark;
  final bool compact;
  final VoidCallback onComputer;
  final VoidCallback onPhotography;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: dark ? _darkPage : Colors.white,
    padding: EdgeInsets.fromLTRB(
      compact ? 16 : 32,
      compact ? 32 : 56,
      compact ? 16 : 32,
      compact ? 88 : 136,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              _ThemeCard(
                photography: false,
                dark: dark,
                compact: compact,
                title: text['computerProjects']!,
                subtitle: text['computerSubtitle']!,
                button: text['learnMore']!,
                onTap: onComputer,
              ),
              SizedBox(height: compact ? 28 : 44),
              _ThemeCard(
                photography: true,
                dark: dark,
                compact: compact,
                title: text['photography']!,
                subtitle: text['photoSubtitle']!,
                button: text['learnMore']!,
                onTap: onPhotography,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.photography,
    required this.dark,
    required this.compact,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onTap,
  });
  final bool photography;
  final bool dark;
  final bool compact;
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: compact ? 570 : 680),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: dark
          ? (photography ? const Color(0xFF050505) : const Color(0xFF111113))
          : (photography ? const Color(0xFF050505) : const Color(0xFFF5F5F7)),
      gradient: dark && !photography
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF20182E), Color(0xFF111318), Color(0xFF090909)],
            )
          : null,
      borderRadius: BorderRadius.circular(28),
      border: dark
          ? Border.all(color: Colors.white10)
          : Border.all(color: const Color(0x12000000)),
      boxShadow: dark
          ? const [
              BoxShadow(
                color: Color(0x52000000),
                blurRadius: 36,
                offset: Offset(0, 18),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 32,
                offset: Offset(0, 14),
              ),
            ],
    ),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24, compact ? 50 : 68, 24, 0),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark || photography
                      ? _darkPrimary
                      : const Color(0xFF1D1D1F),
                  fontSize: compact ? 40 : 54,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.8,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark || photography
                      ? _darkSecondary
                      : const Color(0xFF6E6E73),
                  fontSize: compact ? 18 : 22,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0071E3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: Text(button),
              ),
            ],
          ),
        ),
        const Spacer(),
        Icon(
          photography ? Icons.camera_alt_rounded : Icons.laptop_mac_rounded,
          color: dark || photography ? _darkPrimary : const Color(0xFF1D1D1F),
          size: compact ? 210 : 310,
        ),
        SizedBox(height: compact ? 38 : 48),
      ],
    ),
  );
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.photography, required this.english});
  final bool photography;
  final bool english;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final title = photography
        ? (english ? 'Photography' : '摄影作品')
        : (english ? 'Computer Projects' : '计算机项目');
    final intro = photography
        ? (english
              ? 'A place for photographs, visual stories, and observations from daily life.'
              : '这里将收录摄影作品、视觉故事，以及日常生活中的观察。')
        : (english
              ? 'A place for software experiments, learning projects, and future products.'
              : '这里将收录软件实验、学习项目，以及未来完成的产品。');
    return Scaffold(
      backgroundColor: dark ? _darkPage : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 70, 24, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              children: [
                Icon(
                  photography
                      ? Icons.camera_alt_rounded
                      : Icons.laptop_mac_rounded,
                  size: 88,
                  color: const Color(0xFF0071E3),
                ),
                const SizedBox(height: 28),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge!
                      .copyWith(fontSize: 64, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 24),
                Text(
                  intro,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 21,
                    color: dark ? _darkSecondary : const Color(0xFF6E6E73),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 64),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: dark ? _darkCard : const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(28),
                    border: dark ? Border.all(color: Colors.white10) : null,
                  ),
                  child: Text(
                    english ? 'More work is coming soon.' : '更多作品正在整理中。',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Contact extends StatelessWidget {
  const _Contact({
    super.key,
    required this.text,
    required this.dark,
    required this.compact,
    required this.onEmail,
    required this.onGithub,
  });
  final Map<String, String> text;
  final bool dark;
  final bool compact;
  final VoidCallback onEmail;
  final VoidCallback onGithub;
  @override
  Widget build(BuildContext context) => Container(
    color: dark ? _darkPage : const Color(0xFFF5F5F7),
    padding: EdgeInsets.fromLTRB(
      compact ? 24 : 48,
      compact ? 84 : 124,
      compact ? 24 : 48,
      compact ? 64 : 86,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text['contactTitle']!,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.displayMedium!
                  .copyWith(fontSize: compact ? 42 : 58),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                text['contactText']!,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: compact ? 17 : 20,
                  color: dark ? _darkSecondary : const Color(0xFF6E6E73),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(height: compact ? 24 : 30),
            Wrap(
              spacing: compact ? 16 : 30,
              runSpacing: 8,
              children: [
                _BlueLink(label: 'robin.hye@icloud.com', onTap: onEmail),
                _BlueLink(label: 'GitHub', onTap: onGithub),
              ],
            ),
          ],
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
    width: double.infinity,
    color: dark ? _darkPage : const Color(0xFFF5F5F7),
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: dark ? Colors.white12 : Colors.black12),
            ),
          ),
          child: Text(
            'Copyright © ${DateTime.now().year} Ye Hongyu. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: dark ? Colors.white54 : Colors.black54,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    ),
  );
}

const _zh = <String, String>{
  'projects': '探索',
  'contact': '联系',
  'heroName': 'Ye Hongyu',
  'heroRole': '学生',
  'heroIntro': '我是一名保持好奇、乐于学习和探索新事物的学生。这里记录我的成长、思考，以及未来完成的项目。',
  'viewProjects': '了解探索',
  'contactMe': '联系我',
  'portraitLabel': 'Ye Hongyu 的拟我头像',
  'projectType1': '个人成长',
  'projectTitle1': '让每一次学习，都留下作品。',
  'projectDesc1': '课程、阅读与实践，不只是完成任务，也是在建立自己的思考方式。',
  'projectType2': '项目实践',
  'projectTitle2': '从想法到实现。',
  'projectDesc2': '未来完成的个人与团队项目，会在这里记录过程、选择与收获。',
  'projectType3': '兴趣探索',
  'projectTitle3': '保持好奇。',
  'projectDesc3': '收集值得继续研究的主题、文章、灵感，以及生活中的新发现。',
  'comingSoon': '持续更新中',
  'contactTitle': '一起聊聊。',
  'contactText': '如果你想交流学习、共同兴趣或合作想法，可以通过邮件或 GitHub 找到我。',
  'computerProjects': '计算机项目',
  'photography': '摄影作品',
  'computerSubtitle': '代码、实验与产品想法。',
  'photoSubtitle': '用影像记录观察与故事。',
  'learnMore': '进一步了解',
};

const _en = <String, String>{
  'projects': 'Explore',
  'contact': 'Contact',
  'heroName': 'Ye Hongyu',
  'heroRole': 'Student',
  'heroIntro': 'I am a curious student who enjoys learning and exploring new ideas. This site documents my growth, thinking, and future work.',
  'viewProjects': 'Explore my work',
  'contactMe': 'Contact me',
  'portraitLabel': 'Memoji portrait of Ye Hongyu',
  'projectType1': 'Personal growth',
  'projectTitle1': 'Turn every lesson into something made.',
  'projectDesc1': 'Coursework, reading, and practice help me build not only knowledge, but my own way of thinking.',
  'projectType2': 'Projects',
  'projectTitle2': 'From an idea to reality.',
  'projectDesc2': 'Future individual and team projects will document the process, decisions, and lessons along the way.',
  'projectType3': 'Curiosity',
  'projectTitle3': 'Stay curious.',
  'projectDesc3': 'A growing collection of topics, writing, inspiration, and discoveries worth exploring further.',
  'comingSoon': 'Continuously evolving',
  'computerProjects': 'Computer Projects',
  'photography': 'Photography',
  'computerSubtitle': 'Code, experiments, and product ideas.',
  'photoSubtitle': 'Observations and stories through images.',
  'learnMore': 'Learn more',
  'contactTitle': 'Let’s talk.',
  'contactText': 'If you would like to talk about learning, shared interests, or collaboration, reach me by email or GitHub.',
};
