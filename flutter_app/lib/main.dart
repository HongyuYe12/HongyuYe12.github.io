// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

// 深色模式使用的基础颜色。集中放在这里，方便统一调整暗色主题。
const _darkPage = Color(0xFF000000);
const _darkCard = Color(0xFF1C1C1E);
const _darkPrimary = Color(0xFFF5F5F7);
const _darkSecondary = Color(0xFFA1A1A6);
const _darkLink = Color(0xFF2997FF);

// 苹果官网使用系统字体优先策略：Apple 设备优先 SF Pro / 苹方，
// Windows 和其他平台再回退到 Segoe UI、Noto Sans SC 等字体。
const _appleFontFallback = <String>[
  'SF Pro Display',
  'SF Pro Text',
  'PingFang SC',
  'Helvetica Neue',
  'Segoe UI',
  'NotoSansSC',
  'Arial',
];

// 应用入口：先初始化 Flutter 和 Liquid Glass，再启动网站。
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

// 网站根组件：设置网站标题、自动深浅色模式和全局主题。
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

  // 根据系统亮度生成对应主题。字体、颜色和文字样式都可在这里统一修改。
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
      // 不强制绑定单一字体，让浏览器优先选择当前系统的苹果风格字体。
      fontFamilyFallback: _appleFontFallback,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.6,
          height: 1.08,
          decoration: TextDecoration.none,
        ),
        displayMedium: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.2,
          height: 1.1,
          decoration: TextDecoration.none,
        ),
        headlineMedium: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -.45,
          height: 1.16,
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
          fontWeight: FontWeight.w400,
          letterSpacing: -.12,
          height: 1.47,
          decoration: TextDecoration.none,
        ),
        bodyMedium: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w400,
          letterSpacing: -.08,
          height: 1.47,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

// 网站主页。使用 StatefulWidget 是因为菜单、语言和导航栏动画会动态变化。
class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});
  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage>
    with TickerProviderStateMixin {
  // 各页面区域的定位锚点，用于点击按钮后平滑滚动到对应位置。
  final _homeKey = GlobalKey();
  final _projectsKey = GlobalKey();
  final _contactKey = GlobalKey();
  final _scrollController = ScrollController();

  // 菜单展开动画与顶部导航栏悬浮动画。
  late final AnimationController _menuAnimation;
  late final AnimationController _navAnimation;

  // 页面当前状态：语言、菜单显示状态、导航栏是否进入悬浮状态。
  bool _english = false;
  bool _menuOpen = false;
  bool _menuVisible = false;
  bool _navFloating = false;

  // 根据当前语言，从文件末尾的 _zh 或 _en 文案表中读取文字。
  Map<String, String> get t => _english ? _en : _zh;

  @override
  void initState() {
    super.initState();
    // 控制全屏展开菜单的出现、缩放与关闭动画。
    _menuAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      reverseDuration: const Duration(milliseconds: 300),
    );
    // 控制导航栏从普通状态切换为悬浮玻璃状态。
    _navAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      reverseDuration: const Duration(milliseconds: 380),
    );
    _scrollController.addListener(_handleScroll);
  }

  // 用户稍微向下滚动后自动播放悬浮栏动画；回到顶部时恢复普通导航栏。
  void _handleScroll() {
    final offset = _scrollController.offset;
    if (!_navFloating && offset > 28) {
      _navFloating = true;
      _navAnimation.forward();
    } else if (_navFloating && offset < 8) {
      _navFloating = false;
      _navAnimation.reverse();
    }
  }

  // 打开或关闭全屏菜单，并等待动画结束后再隐藏组件。
  Future<void> _toggleMenu() async {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
      await _menuAnimation.reverse();
      if (mounted) setState(() => _menuVisible = false);
      return;
    }
    setState(() {
      _menuVisible = true;
      _menuOpen = true;
    });
    await _menuAnimation.forward();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _menuAnimation.dispose();
    _navAnimation.dispose();
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

  // 用系统默认应用打开网页或邮件链接。
  Future<void> _open(String value) =>
      launchUrl(Uri.parse(value), mode: LaunchMode.platformDefault);

  // 点击菜单项目时，先播放菜单关闭动画，再执行跳转操作。
  Future<void> _closeMenuThen(VoidCallback action) async {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
      await _menuAnimation.reverse();
    }
    if (!mounted) return;
    setState(() => _menuVisible = false);
    action();
  }

  // 打开计算机项目或摄影作品的详情页。
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
    // dark 跟随系统深浅色模式；compact 用于判断是否采用窄屏布局。
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
          // 主页面内容，从上到下依次为首屏、项目、联系方式和页脚。
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
          // 展开的全屏菜单。通过透明度和缩放组合出更自然的出现效果。
          if (_menuVisible)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _menuAnimation,
                builder: (context, child) {
                  final progress = Curves.easeOutCubic.transform(
                    _menuAnimation.value,
                  );
                  return Opacity(
                    opacity: progress,
                    child: Transform.scale(
                      alignment: Alignment.topRight,
                      scale: .88 + .12 * progress,
                      child: child,
                    ),
                  );
                },
                child: _MenuPanel(
                  text: t,
                  dark: dark,
                  english: _english,
                  onComputer: () => _closeMenuThen(() => _openDetail(false)),
                  onPhotography: () => _closeMenuThen(() => _openDetail(true)),
                  onContact: () => _closeMenuThen(() => _scrollTo(_contactKey)),
                  onLanguage: () => setState(() => _english = !_english),
                ),
              ),
            ),
          // 顶部导航栏始终覆盖在页面内容上方，并根据滚动状态改变形态。
          AnimatedBuilder(
            animation: _navAnimation,
            builder: (context, _) {
              final progress = Curves.easeOutCubic.transform(
                _navAnimation.value,
              );
              return Positioned(
                left: compact ? 12 : 28,
                right: compact ? 12 : 28,
                top: 8 + (compact ? 2 : 10) * progress,
                child: _AdaptiveNav(
                  dark: dark,
                  compact: compact,
                  english: _english,
                  progress: progress,
                  menuAnimation: _menuAnimation,
                  onHome: () => _scrollTo(_homeKey),
                  onMenu: _toggleMenu,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 自适应顶部导航栏：左侧为 HYe 标志，右侧为菜单按钮。
class _AdaptiveNav extends StatelessWidget {
  const _AdaptiveNav({
    required this.dark,
    required this.compact,
    required this.english,
    required this.progress,
    required this.menuAnimation,
    required this.onHome,
    required this.onMenu,
  });
  final bool dark;
  final bool compact;
  final bool english;
  final double progress;
  final Animation<double> menuAnimation;
  final VoidCallback onHome;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    // progress 为 0 时是普通状态，为 1 时是下滑后的悬浮玻璃状态。
    final eased = Curves.easeOutCubic.transform(progress);
    final horizontal = 4 + (compact ? 10 : 18) * eased;
    final vertical = 2 + 7 * eased;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1440 - (compact ? 0 : 320) * eased,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.transparent,
              dark ? const Color(0xF21A1A1A) : const Color(0xF2FFFFFF),
              eased,
            ),
            borderRadius: BorderRadius.circular(16 + 22 * eased),
            border: Border.all(
              color: Color.lerp(
                Colors.transparent,
                dark ? Colors.white12 : Colors.black12,
                eased,
              )!,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(
                  Colors.transparent,
                  const Color(0x26000000),
                  eased,
                )!,
                blurRadius: 32 * eased,
                offset: Offset(0, 12 * eased),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: vertical,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                button: true,
                label: english ? 'Back to top' : '返回首页',
                child: InkWell(
                  onTap: onHome,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Image.asset(
                      dark
                          ? 'assets/hye-mark-white.png'
                          : 'assets/hye-mark-black.png',
                      width: 54 - 5 * eased,
                      height: 28 - 2 * eased,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              _MenuButton(
                dark: dark,
                english: english,
                animation: menuAnimation,
                onTap: onMenu,
                emphasized: eased > .5,
                size: 48 - 2 * eased,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 圆形菜单按钮。按钮本身没有额外边框，点击区域仍保持足够大。
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.dark,
    required this.english,
    required this.animation,
    required this.onTap,
    required this.emphasized,
    required this.size,
  });
  final bool dark;
  final bool english;
  final Animation<double> animation;
  final bool emphasized;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: english ? 'Open or close menu' : '打开或关闭菜单',
    child: Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: size / 2,
        highlightShape: BoxShape.circle,
        child: SizedBox.square(
          dimension: size,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => CustomPaint(
              painter: _MenuMorphPainter(
                progress: Curves.easeInOutCubic.transform(animation.value),
                color: dark ? Colors.white : const Color(0xFF1D1D1F),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// 自定义绘制两条横线，并在菜单打开时将它们旋转为关闭图标。
class _MenuMorphPainter extends CustomPainter {
  const _MenuMorphPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final center = size.center(Offset.zero);
    final half = 9.0;
    final spacing = 5.5 * (1 - progress);
    final shrink = 1 - .16 * progress;

    // 绘制第一条横线，并随动画顺时针旋转。
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(.785398 * progress);
    canvas.drawLine(
      Offset(-half * shrink, -spacing),
      Offset(half * shrink, -spacing),
      paint,
    );
    canvas.restore();

    // 绘制第二条横线，并随动画逆时针旋转。
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-.785398 * progress);
    canvas.drawLine(
      Offset(-half * shrink, spacing),
      Offset(half * shrink, spacing),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MenuMorphPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// 全屏菜单面板：包含两个主题入口、联系方式和中英文切换。
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

// 菜单中的单行文字按钮。small 用于语言切换项的小字号样式。
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
            fontSize: small ? 17 : 32,
            height: 1.1,
            fontWeight: FontWeight.w600,
            letterSpacing: small ? -.2 : -.7,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    ),
  );
}

// 首页首屏区域：展示姓名、个人介绍、操作链接和透明背景头像。
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
            fontSize: compact ? 40 : 56,
            fontWeight: FontWeight.w600,
            letterSpacing: compact ? -1.1 : -1.8,
          ),
        ),
        SizedBox(height: compact ? 28 : 38),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            text['heroIntro']!,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: compact ? 17 : 19,
              color: secondary,
              height: 1.47,
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
        alignment: compact ? Alignment.bottomCenter : Alignment.topCenter,
        child: Image.asset(
          'assets/memoji-portrait-transparent.png',
          width: compact ? 270 : 380,
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
                    SizedBox(height: 325, child: portrait),
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
                      child: Transform.translate(
                        offset: const Offset(0, -24),
                        child: SizedBox(height: 470, child: portrait),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// 苹果官网风格的蓝色文字链接，右侧带箭头图标。
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
                fontWeight: FontWeight.w400,
                letterSpacing: -.2,
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

// 主题展示区域：依次放置计算机项目和摄影作品两个独立窗口。
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
      compact ? 8 : 14,
      compact ? 22 : 36,
      compact ? 8 : 14,
      compact ? 88 : 136,
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1600),
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

// 单个主题卡片。photography 决定显示摄影还是计算机项目的视觉样式。
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
    width: double.infinity,
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
                  fontSize: compact ? 36 : 48,
                  fontWeight: FontWeight.w600,
                  letterSpacing: compact ? -.8 : -1.3,
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
                  fontSize: compact ? 17 : 21,
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

// 项目详情页。摄影页面保留作品占位，计算机项目页面展示项目列表。
class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.photography, required this.english});
  final bool photography;
  final bool english;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 700;
    // 根据入口类型和当前语言生成详情页标题与简介。
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
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: compact ? 40 : 56,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  intro,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: compact ? 17 : 19,
                    color: dark ? _darkSecondary : const Color(0xFF6E6E73),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 64),
                if (photography)
                  _ComingSoonCard(dark: dark, english: english)
                else
                  _ComputerProjectList(
                    dark: dark,
                    english: english,
                    compact: compact,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 计算机项目数据。需要修改项目名称或简介时，可直接编辑此列表。
const _computerProjects = <_ProjectInfo>[
  _ProjectInfo(
    name: 'SpektraStudio',
    zhDescription: '面向视觉与创意工作的实验性工作室项目，探索更直观的数字内容创作体验。',
    enDescription: 'An experimental studio project exploring a more intuitive experience for visual and creative digital work.',
    icon: Icons.auto_awesome_rounded,
    accent: Color(0xFF8E5CFF),
  ),
  _ProjectInfo(
    name: 'Monocular Depth Robustness',
    zhDescription: '研究单目深度估计在多深度、低照度和复杂场景中的稳定性，并探索深度引导的自动对焦。',
    enDescription: 'Researching monocular depth stability in multi-depth, low-light, and complex scenes, with depth-guided autofocus experiments.',
    icon: Icons.blur_on_rounded,
    accent: Color(0xFF0071E3),
  ),
  _ProjectInfo(
    name: 'Cabinet AI Assistant',
    zhDescription: '围绕资料整理、信息检索与日常工作流设计的个人 AI 助手项目。',
    enDescription: 'A personal AI assistant project designed around document organization, information retrieval, and everyday workflows.',
    icon: Icons.inventory_2_rounded,
    accent: Color(0xFF00A87E),
  ),
  _ProjectInfo(
    name: 'MinerU',
    zhDescription: '将 PDF 解析为可检索 Markdown，并维护原始 PDF 页码与内容之间的可靠映射。',
    enDescription: 'A local workflow that converts PDFs into searchable Markdown while preserving reliable source-page mappings.',
    icon: Icons.document_scanner_rounded,
    accent: Color(0xFFFF9F0A),
  ),
  _ProjectInfo(
    name: 'The Auctioneer',
    zhDescription: '围绕拍卖流程、出价互动与信息展示构建的应用项目。',
    enDescription: 'An application project built around auction workflows, bidding interactions, and clear information presentation.',
    icon: Icons.gavel_rounded,
    accent: Color(0xFFFF375F),
  ),
];

class _ProjectInfo {
  const _ProjectInfo({
    required this.name,
    required this.zhDescription,
    required this.enDescription,
    required this.icon,
    required this.accent,
  });

  final String name;
  final String zhDescription;
  final String enDescription;
  final IconData icon;
  final Color accent;
}

// 将五个项目排成自适应卡片：宽屏两列，窄屏单列。
class _ComputerProjectList extends StatelessWidget {
  const _ComputerProjectList({
    required this.dark,
    required this.english,
    required this.compact,
  });

  final bool dark;
  final bool english;
  final bool compact;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = compact ? 1 : 2;
      final gap = compact ? 18.0 : 24.0;
      final cardWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: _computerProjects
            .map(
              (project) => SizedBox(
                width: cardWidth,
                child: _ProjectCard(
                  project: project,
                  dark: dark,
                  english: english,
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

// 单个项目卡片，保持与网站现有圆角、留白和深浅色风格一致。
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.dark,
    required this.english,
  });

  final _ProjectInfo project;
  final bool dark;
  final bool english;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 260),
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: dark ? _darkCard : const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: dark ? Colors.white10 : Colors.black12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: project.accent.withValues(alpha: dark ? .22 : .12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(project.icon, color: project.accent, size: 28),
        ),
        const SizedBox(height: 30),
        Text(
          project.name,
          style: Theme.of(context).textTheme.headlineMedium!
              .copyWith(fontSize: 24, decoration: TextDecoration.none),
        ),
        const SizedBox(height: 14),
        Text(
          english ? project.enDescription : project.zhDescription,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 16,
            color: dark ? _darkSecondary : const Color(0xFF6E6E73),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
  );
}

// 摄影作品尚未加入时显示的占位卡片。
class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.dark, required this.english});
  final bool dark;
  final bool english;

  @override
  Widget build(BuildContext context) => Container(
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
      style: const TextStyle(fontSize: 17, decoration: TextDecoration.none),
    ),
  );
}

// 联系方式区域：提供公开邮箱和 GitHub 主页链接。
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
                  .copyWith(fontSize: compact ? 36 : 48),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                text['contactText']!,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: compact ? 17 : 19,
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

// 网站页脚：显示分隔线和自动更新年份的版权信息。
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
              height: 1.33,
              color: dark ? Colors.white54 : Colors.black54,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    ),
  );
}

// 中文文案表。修改网站中文内容时，优先在这里调整对应字段。
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

// 英文文案表。字段名称需与中文文案表保持一致。
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
