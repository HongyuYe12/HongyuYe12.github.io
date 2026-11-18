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

// 参考 Apple 官网建立统一字号层级，避免不同页面各自使用零散尺寸。
const _typeBody = 17.0;
const _typeBodyLarge = 19.0;
const _typeIntro = 21.0;
const _typeCardTitle = 32.0;
const _typeSectionMobile = 40.0;
const _typeSection = 48.0;
const _typeHeroMobile = 48.0;
const _typeHero = 64.0;
const _typeDisplayMobile = 48.0;
const _typeDisplay = 80.0;

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
    // 页面主体固定使用浅色主题；系统深浅色仅用于主页导航栏和展开菜单。
    themeMode: ThemeMode.light,
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
      // 标题优先 SF Pro Display，正文优先 SF Pro Text；未安装时自动回退。
      fontFamily: 'SF Pro Text',
      fontFamilyFallback: _appleFontFallback,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: _typeDisplay,
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -2.4,
          height: 1.05,
          decoration: TextDecoration.none,
        ),
        displayMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: _typeSection,
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.4,
          height: 1.08,
          decoration: TextDecoration.none,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: _typeCardTitle,
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -.7,
          height: 1.1,
          decoration: TextDecoration.none,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          color: foreground,
          fontWeight: FontWeight.w600,
          letterSpacing: -.4,
          decoration: TextDecoration.none,
        ),
        bodyLarge: TextStyle(
          fontSize: _typeBodyLarge,
          color: foreground,
          fontWeight: FontWeight.w400,
          letterSpacing: -.15,
          height: 1.5,
          decoration: TextDecoration.none,
        ),
        bodyMedium: TextStyle(
          fontSize: _typeBody,
          color: foreground,
          fontWeight: FontWeight.w400,
          letterSpacing: -.1,
          height: 1.5,
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

enum _MenuSection { main, computer, photography }

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
  _MenuSection _menuSection = _MenuSection.main;

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
      if (mounted) {
        setState(() {
          _menuVisible = false;
          _menuSection = _MenuSection.main;
        });
      }
      return;
    }
    setState(() {
      _menuVisible = true;
      _menuOpen = true;
      _menuSection = _MenuSection.main;
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

  // 点击菜单项目时，先播放菜单关闭动画，再执行跳转操作。
  Future<void> _closeMenuThen(VoidCallback action) async {
    if (_menuOpen) {
      setState(() => _menuOpen = false);
      await _menuAnimation.reverse();
    }
    if (!mounted) return;
    setState(() {
      _menuVisible = false;
      _menuSection = _MenuSection.main;
    });
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

  void _openProjectDetail(_ProjectInfo project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ProjectDetailPage(project: project, english: _english),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 页面内容始终为浅色；导航栏和展开菜单单独跟随系统深浅色。
    const pageDark = false;
    final navigationDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 760;
    return GlassScaffold(
      background: const ColoredBox(color: Color(0xFFF5F5F7)),
      backgroundColor: const Color(0xFFF5F5F7),
      statusBarStyle: GlassStatusBarStyle.auto,
      edgeToEdge: true,
      edgeFade: true,
      settings: navigationDark
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
                  dark: pageDark,
                  compact: compact,
                  onProjects: () => _scrollTo(_projectsKey),
                  onContact: () => _scrollTo(_contactKey),
                ),
                _Projects(
                  key: _projectsKey,
                  text: t,
                  dark: pageDark,
                  compact: compact,
                  onComputer: () => _openDetail(false),
                  onPhotography: () => _openDetail(true),
                ),
                _PageEnd(
                  key: _contactKey,
                  text: t,
                  dark: pageDark,
                  compact: compact,
                ),
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
                  dark: navigationDark,
                  english: _english,
                  section: _menuSection,
                  onComputer: () =>
                      setState(() => _menuSection = _MenuSection.computer),
                  onPhotography: () =>
                      setState(() => _menuSection = _MenuSection.photography),
                  onBack: () =>
                      setState(() => _menuSection = _MenuSection.main),
                  onExploreComputer: () => _openDetail(false),
                  onExplorePhotography: () => _openDetail(true),
                  onProject: _openProjectDetail,
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
              // 顶部状态贴合视口四周；开始滚动后再缩进为悬浮栏。
              final horizontalInset = (compact ? 12.0 : 28.0) * progress;
              final topInset = (compact ? 10.0 : 18.0) * progress;
              return Positioned(
                left: horizontalInset,
                right: horizontalInset,
                top: topInset,
                child: _AdaptiveNav(
                  dark: navigationDark,
                  compact: compact,
                  english: _english,
                  menuActive: _menuVisible,
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
    required this.menuActive,
    required this.progress,
    required this.menuAnimation,
    required this.onHome,
    required this.onMenu,
  });
  final bool dark;
  final bool compact;
  final bool english;
  final bool menuActive;
  final double progress;
  final Animation<double> menuAnimation;
  final VoidCallback onHome;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    // progress 为 0 时是普通状态，为 1 时是下滑后的悬浮玻璃状态。
    final eased = Curves.easeOutCubic.transform(progress);
    // 浅色模式始终使用纯白色作为导航背景，避免透明度插值时出现灰色闪变。
    final backgroundColor = menuActive
        ? Colors.transparent
        : dark
        ? Color.lerp(_darkPage, const Color(0xFF1A1A1A), eased)!
        : Colors.white;
    return Center(
      child: ConstrainedBox(
        // 与首屏文字和主题卡片使用相同的最大内容宽度。
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(menuActive ? 0 : 36 * eased),
            border: Border.all(
              color: menuActive
                  ? Colors.transparent
                  : Color.lerp(
                      Colors.transparent,
                      dark ? Colors.white12 : Colors.black12,
                      eased,
                    )!,
            ),
            boxShadow: menuActive
                ? const []
                : [
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
          // 固定内部留白、Logo 和按钮尺寸，仅动画视觉材质，不动画布局尺寸。
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                button: true,
                label: english ? 'Back to top' : '返回首页',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onHome,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Image.asset(
                      dark
                          ? 'assets/hye-mark-white.png'
                          : 'assets/hye-mark-black.png',
                      width: 50,
                      height: 26,
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
                size: 48,
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
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
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
    required this.section,
    required this.onComputer,
    required this.onPhotography,
    required this.onBack,
    required this.onExploreComputer,
    required this.onExplorePhotography,
    required this.onProject,
    required this.onContact,
    required this.onLanguage,
  });
  final Map<String, String> text;
  final bool dark;
  final bool english;
  final _MenuSection section;
  final VoidCallback onComputer;
  final VoidCallback onPhotography;
  final VoidCallback onBack;
  final VoidCallback onExploreComputer;
  final VoidCallback onExplorePhotography;
  final ValueChanged<_ProjectInfo> onProject;
  final VoidCallback onContact;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) {
    final color = dark ? _darkPrimary : const Color(0xFF1D1D1F);
    final secondary = dark ? _darkSecondary : const Color(0xFF6E6E73);
    return Material(
      color: dark ? _darkPage : const Color(0xFFF5F5F7),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: SingleChildScrollView(
              // 为无边框导航栏预留更充足的顶部距离，避免紧贴第一行。
              padding: const EdgeInsets.fromLTRB(28, 132, 28, 70),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(.025, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: section == _MenuSection.main
                    ? _MainMenuContent(
                        key: const ValueKey('main-menu'),
                        text: text,
                        english: english,
                        dark: dark,
                        color: color,
                        onComputer: onComputer,
                        onPhotography: onPhotography,
                        onContact: onContact,
                        onLanguage: onLanguage,
                      )
                    : _ProjectMenuContent(
                        key: ValueKey(section),
                        photography: section == _MenuSection.photography,
                        english: english,
                        dark: dark,
                        color: color,
                        secondary: secondary,
                        onBack: onBack,
                        onExplore: section == _MenuSection.photography
                            ? onExplorePhotography
                            : onExploreComputer,
                        onProject: onProject,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainMenuContent extends StatelessWidget {
  const _MainMenuContent({
    super.key,
    required this.text,
    required this.english,
    required this.dark,
    required this.color,
    required this.onComputer,
    required this.onPhotography,
    required this.onContact,
    required this.onLanguage,
  });

  final Map<String, String> text;
  final bool english;
  final bool dark;
  final Color color;
  final VoidCallback onComputer;
  final VoidCallback onPhotography;
  final VoidCallback onContact;
  final VoidCallback onLanguage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _MenuItem(text['computerProjects']!, onComputer, color),
      _MenuItem(text['photography']!, onPhotography, color),
      _MenuItem(text['contact']!, onContact, color),
      const SizedBox(height: 28),
      Divider(color: dark ? Colors.white12 : Colors.black12),
      const SizedBox(height: 24),
      _MenuItem(
        english ? '切换为中文' : 'Switch to English',
        onLanguage,
        color,
        small: true,
      ),
    ],
  );
}

class _ProjectMenuContent extends StatelessWidget {
  const _ProjectMenuContent({
    super.key,
    required this.photography,
    required this.english,
    required this.dark,
    required this.color,
    required this.secondary,
    required this.onBack,
    required this.onExplore,
    required this.onProject,
  });

  final bool photography;
  final bool english;
  final bool dark;
  final Color color;
  final Color secondary;
  final VoidCallback onBack;
  final VoidCallback onExplore;
  final ValueChanged<_ProjectInfo> onProject;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _MenuBackButton(
        label: english ? 'Back' : '返回',
        color: secondary,
        onTap: onBack,
      ),
      const SizedBox(height: 20),
      _MenuItem(
        photography
            ? (english ? 'Explore all photography' : '查看全部摄影作品')
            : (english ? 'Explore all projects' : '查看全部项目'),
        onExplore,
        color,
      ),
      const SizedBox(height: 12),
      if (photography)
        ..._photographySubjects.map(
          (theme) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Text(
              theme.title(english),
              style: TextStyle(
                color: secondary,
                fontSize: _typeBodyLarge,
                height: 1.35,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        )
      else
        ..._computerProjects.map(
          (project) => _MenuItem(project.name, () => onProject(project), color),
        ),
    ],
  );
}

class _MenuBackButton extends StatelessWidget {
  const _MenuBackButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: _typeBody,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
    hoverColor: Colors.transparent,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    focusColor: Colors.transparent,
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    child: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: small ? 14 : 18),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: small ? _typeBody : _typeCardTitle,
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
            fontSize: compact ? _typeHeroMobile : _typeHero,
            fontWeight: FontWeight.w600,
            letterSpacing: compact ? -1.4 : -2.2,
          ),
        ),
        SizedBox(height: compact ? 28 : 38),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            text['heroIntro']!,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: compact ? _typeBody : _typeIntro,
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
        compact ? 0 : 28,
        compact ? 70 : 82,
        compact ? 0 : 28,
        0,
      ),
      child: Center(
        child: ConstrainedBox(
          // 与导航栏和主题卡片保持统一的左右边界。
          constraints: const BoxConstraints(maxWidth: 1440),
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
                        padding: const EdgeInsets.only(bottom: 80),
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
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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
                fontSize: _typeBody,
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
      compact ? 16 : 28,
      compact ? 24 : 48,
      compact ? 16 : 28,
      compact ? 88 : 128,
    ),
    child: Center(
      child: ConstrainedBox(
        // 达到 1440px 后不再继续拉宽，超宽屏只增加两侧留白。
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
              SizedBox(height: compact ? 24 : 32),
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

// 单个主题卡片。宽屏左右排列，窄屏自动切换为文字在上、视觉在下。
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // 参考 Apple 支持页面：约 980px 起切换为横向大卡片。
      final horizontal = constraints.maxWidth >= 980;
      final foreground = dark || photography
          ? _darkPrimary
          : const Color(0xFF1D1D1F);
      final secondary = dark || photography
          ? _darkSecondary
          : const Color(0xFF6E6E73);

      final copy = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal ? 64 : 40,
          vertical: horizontal ? 72 : 52,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontSize: horizontal
                        ? _typeSection
                        : (compact ? _typeSectionMobile : _typeSection),
                    height: 1.08,
                    fontWeight: FontWeight.w600,
                    letterSpacing: horizontal ? -1.3 : -.8,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: secondary,
                    fontSize: horizontal ? _typeIntro : _typeBody,
                    height: 1.45,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 18),
                _BlueLink(label: button, onTap: onTap),
              ],
            ),
          ),
        ),
      );

      final visual = _ThemeVisual(
        photography: photography,
        dark: dark,
        horizontal: horizontal,
      );

      return SizedBox(
        height: horizontal ? 600 : (compact ? 680 : 720),
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: dark
                ? (photography
                      ? const Color(0xFF050505)
                      : const Color(0xFF111113))
                : (photography
                      ? const Color(0xFF050505)
                      : const Color(0xFFF5F5F7)),
            gradient: dark && !photography
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF20182E),
                      Color(0xFF111318),
                      Color(0xFF090909),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(32),
            border: dark
                ? Border.all(color: Colors.white10)
                : Border.all(color: const Color(0x12000000)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 32,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: horizontal
              ? Row(
                  children: [
                    Expanded(flex: 6, child: visual),
                    Expanded(flex: 5, child: copy),
                  ],
                )
              : Column(
                  children: [
                    copy,
                    Expanded(child: visual),
                  ],
                ),
        ),
      );
    },
  );
}

// 主题卡片的视觉区域。使用抽象设备构图替代单一大图标，使横竖排版都更接近参考图。
class _ThemeVisual extends StatelessWidget {
  const _ThemeVisual({
    required this.photography,
    required this.dark,
    required this.horizontal,
  });

  final bool photography;
  final bool dark;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final foreground = dark || photography
        ? Colors.white
        : const Color(0xFF1D1D1F);
    final accent = photography
        ? const Color(0xFF7B61FF)
        : const Color(0xFF2997FF);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: photography
              ? const [Color(0xFF17151D), Color(0xFF050505)]
              : dark
              ? const [Color(0xFF2A2040), Color(0xFF0A0A0C)]
              : const [Color(0xFFE9F3FF), Color(0xFFF5F5F7)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: horizontal ? -70 : -30,
            top: horizontal ? -50 : 20,
            child: _VisualTile(
              size: horizontal ? 250 : 160,
              icon: photography
                  ? Icons.photo_camera_back_rounded
                  : Icons.terminal_rounded,
              foreground: foreground,
              accent: accent,
            ),
          ),
          Positioned(
            right: horizontal ? 54 : 24,
            top: horizontal ? 58 : 34,
            child: _VisualTile(
              size: horizontal ? 150 : 112,
              icon: photography ? Icons.camera_rounded : Icons.memory_rounded,
              foreground: foreground,
              accent: accent,
            ),
          ),
          Positioned(
            left: horizontal ? 72 : 34,
            bottom: horizontal ? -64 : -42,
            child: _VisualTile(
              size: horizontal ? 210 : 142,
              icon: photography
                  ? Icons.filter_hdr_rounded
                  : Icons.data_object_rounded,
              foreground: foreground,
              accent: accent,
            ),
          ),
          Align(
            alignment: const Alignment(.35, .18),
            child: Container(
              width: horizontal ? 245 : 174,
              height: horizontal ? 330 : 220,
              decoration: BoxDecoration(
                color: dark || photography
                    ? const Color(0xFF202024)
                    : Colors.white,
                borderRadius: BorderRadius.circular(horizontal ? 38 : 28),
                border: Border.all(
                  color: dark || photography ? Colors.white12 : Colors.black12,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 30,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Icon(
                photography
                    ? Icons.camera_alt_rounded
                    : Icons.laptop_mac_rounded,
                size: horizontal ? 108 : 78,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualTile extends StatelessWidget {
  const _VisualTile({
    required this.size,
    required this.icon,
    required this.foreground,
    required this.accent,
  });

  final double size;
  final IconData icon;
  final Color foreground;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: foreground.withValues(alpha: .07),
      shape: BoxShape.circle,
      border: Border.all(color: foreground.withValues(alpha: .1)),
    ),
    child: Icon(icon, color: accent, size: size * .38),
  );
}

// 项目分类页。摄影页面展示主题画廊，计算机项目页面展示项目列表。
class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.photography, required this.english});
  final bool photography;
  final bool english;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 700;
    final title = photography
        ? (english ? 'Photography' : '摄影作品')
        : (english ? 'Computer Projects' : '计算机项目');
    final headline = photography
        ? (english ? 'A closer look at the world.' : '用影像，重新看见日常。')
        : (english ? 'Ideas, made useful.' : '把想法，做成真正可用的作品。');
    final intro = photography
        ? (english
              ? 'Photography shaped by light, place, movement, and the moments in between.'
              : '关于光线、空间、旅途与现场的摄影记录。')
        : (english
              ? 'Software, research, and experiments developed from first question to working result.'
              : '从问题出发，以代码、研究与设计完成的软件和实验。');
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 24 : 48,
                compact ? 64 : 94,
                compact ? 24 : 48,
                compact ? 74 : 112,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: compact ? 17 : 21,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0071E3),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      SizedBox(height: compact ? 18 : 24),
                      Text(
                        headline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge!
                            .copyWith(
                              fontSize: compact
                                  ? _typeDisplayMobile
                                  : _typeDisplay,
                              height: 1.04,
                              letterSpacing: compact ? -1.6 : -3,
                              decoration: TextDecoration.none,
                            ),
                      ),
                      SizedBox(height: compact ? 22 : 30),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Text(
                          intro,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                fontSize: compact ? _typeBodyLarge : _typeIntro,
                                height: 1.48,
                                color: dark
                                    ? _darkSecondary
                                    : const Color(0xFF6E6E73),
                                decoration: TextDecoration.none,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: dark ? const Color(0xFF111111) : const Color(0xFFF5F5F7),
              padding: EdgeInsets.fromLTRB(
                compact ? 18 : 40,
                compact ? 56 : 88,
                compact ? 18 : 40,
                compact ? 84 : 128,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: photography
                      ? _PhotographyThemeList(
                          dark: dark,
                          english: english,
                          compact: compact,
                          onTheme: (theme) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _PhotographyGalleryPage(
                                  theme: theme,
                                  english: english,
                                ),
                              ),
                            );
                          },
                        )
                      : _ComputerProjectList(
                          dark: dark,
                          english: english,
                          compact: compact,
                          onProject: (project) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _ProjectDetailPage(
                                  project: project,
                                  english: english,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            _PageEnd(text: english ? _en : _zh, dark: dark, compact: compact),
          ],
        ),
      ),
    );
  }
}

class _PhotoAsset {
  const _PhotoAsset(this.path, this.width, this.height);
  final String path;
  final int width;
  final int height;
  double get ratio => width / height;
}

class _PhotographyTheme {
  const _PhotographyTheme({
    required this.zhTitle,
    required this.enTitle,
    required this.zhSubtitle,
    required this.enSubtitle,
    required this.photos,
  });
  final String zhTitle;
  final String enTitle;
  final String zhSubtitle;
  final String enSubtitle;
  final List<_PhotoAsset> photos;
  String title(bool english) => english ? enTitle : zhTitle;
  String subtitle(bool english) => english ? enSubtitle : zhSubtitle;
}

const _aircraftPhotos = <_PhotoAsset>[
  _PhotoAsset('assets/photography/aircraft/01-dsc03486.webp', 2400, 1600),
  _PhotoAsset('assets/photography/aircraft/02-dsc03548.webp', 2400, 1196),
  _PhotoAsset('assets/photography/aircraft/03-dsc03552.webp', 2400, 1600),
  _PhotoAsset('assets/photography/aircraft/04-img_6521.webp', 2400, 1600),
];

const _architecturePhotos = <_PhotoAsset>[
  _PhotoAsset('assets/photography/architecture/01-dsc00120.webp', 2400, 1600),
  _PhotoAsset('assets/photography/architecture/02-dsc00485.webp', 1600, 2400),
  _PhotoAsset('assets/photography/architecture/03-img_6516.webp', 2400, 1600),
  _PhotoAsset('assets/photography/architecture/04-img_6525.webp', 2400, 1600),
];

const _naturePhotos = <_PhotoAsset>[
  _PhotoAsset('assets/photography/nature/01-dsc02009.webp', 2400, 1600),
  _PhotoAsset('assets/photography/nature/02-dsc04361.webp', 2157, 2400),
];

const _footballPhotos = <_PhotoAsset>[
  _PhotoAsset('assets/photography/juventus/01-dsc02391.webp', 2400, 1350),
  _PhotoAsset('assets/photography/juventus/02-dsc02814.webp', 2400, 1600),
  _PhotoAsset('assets/photography/juventus/03-dsc02846.webp', 2400, 1599),
  _PhotoAsset('assets/photography/juventus/04-dsc03025.webp', 2400, 1350),
  _PhotoAsset('assets/photography/juventus/05-dsc03087.webp', 2400, 2400),
];

const _taiwanPhotos = <_PhotoAsset>[
  _PhotoAsset('assets/photography/taiwan/01-dsc01446.webp', 2400, 1600),
  _PhotoAsset('assets/photography/taiwan/02-img_2291.webp', 1600, 2400),
  _PhotoAsset('assets/photography/taiwan/03-img_2292.webp', 1600, 2400),
  _PhotoAsset('assets/photography/taiwan/04-img_2293.webp', 1600, 2400),
  _PhotoAsset('assets/photography/taiwan/05-img_2294.webp', 2400, 1600),
  _PhotoAsset('assets/photography/taiwan/06-img_2296.webp', 2400, 1350),
  _PhotoAsset('assets/photography/taiwan/07-img_2297.webp', 2400, 1600),
  _PhotoAsset('assets/photography/taiwan/08-img_6528.webp', 1600, 2400),
];

// 第一层按摄影主题组织，同一作品可在活动专题中再次被引用。
const _photographySubjects = <_PhotographyTheme>[
  _PhotographyTheme(
    zhTitle: '体育摄影',
    enTitle: 'Sports Photography',
    zhSubtitle: '速度、对抗与看台之间，决定性瞬间只出现一次。',
    enSubtitle: 'Speed, tension, and decisive moments that happen only once.',
    photos: _footballPhotos,
  ),
  _PhotographyTheme(
    zhTitle: '自然风光',
    enTitle: 'Landscapes',
    zhSubtitle: '暮色、海岸、闪电，以及不断变化的天空。',
    enSubtitle: 'Twilight, coastlines, lightning, and an ever-changing sky.',
    photos: _naturePhotos,
  ),
  _PhotographyTheme(
    zhTitle: '建筑',
    enTitle: 'Architecture',
    zhSubtitle: '寻找光线、结构与空间之间清晰的秩序。',
    enSubtitle: 'Finding clarity between light, structure, and space.',
    photos: _architecturePhotos,
  ),
  _PhotographyTheme(
    zhTitle: '航空摄影',
    enTitle: 'Aviation Photography',
    zhSubtitle: '候机楼、进近航线，以及掠过天空的片刻。',
    enSubtitle: 'Terminals, final approaches, and fleeting moments overhead.',
    photos: _aircraftPhotos,
  ),
  _PhotographyTheme(
    zhTitle: '街头摄影',
    enTitle: 'Street Photography',
    zhSubtitle: '街道、列车、夜色与旅途中偶然相遇的画面。',
    enSubtitle:
        'Streets, trains, night light, and unplanned moments on the road.',
    photos: _taiwanPhotos,
  ),
];

// 第二层按一次旅行或一场比赛组织，形成更完整的活动叙事。
const _photographyEvents = <_PhotographyTheme>[
  _PhotographyTheme(
    zhTitle: '台湾',
    enTitle: 'Taiwan',
    zhSubtitle: '从海岸到城市，在列车、街道与夜色之间展开的一段旅程。',
    enSubtitle: 'A journey from coast to city, through trains, streets, and night light.',
    photos: _taiwanPhotos,
  ),
  _PhotographyTheme(
    zhTitle: '切尔西 · 尤文图斯',
    enTitle: 'Chelsea · Juventus',
    zhSubtitle: '从看台记录比赛的节奏、对抗与决定性瞬间。',
    enSubtitle: 'The rhythm, tension, and decisive moments of the match from the stands.',
    photos: _footballPhotos,
  ),
];

class _PhotographyThemeList extends StatelessWidget {
  const _PhotographyThemeList({
    required this.dark,
    required this.english,
    required this.compact,
    required this.onTheme,
  });
  final bool dark;
  final bool english;
  final bool compact;
  final ValueChanged<_PhotographyTheme> onTheme;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _PhotographySectionHeading(
        eyebrow: english ? 'BY SUBJECT' : '按主题浏览',
        title: english ? 'Find a different point of view.' : '从不同视角，重新发现画面。',
        description: english
            ? 'Five ways of seeing—from sport and aviation to streets, landscapes, and architecture.'
            : '从体育与航空，到街头、风光和建筑，以五种主题整理摄影作品。',
        compact: compact,
        dark: dark,
      ),
      SizedBox(height: compact ? 32 : 48),
      LayoutBuilder(
        builder: (context, constraints) {
          final gap = compact ? 16.0 : 24.0;
          final columns = compact ? 1 : (constraints.maxWidth >= 1040 ? 3 : 2);
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: _photographySubjects.indexed.map((entry) {
              final index = entry.$1;
              final theme = entry.$2;
              final featured = !compact && index == 0 && columns == 3;
              return SizedBox(
                width: featured ? width * 2 + gap : width,
                child: _PhotographySubjectCard(
                  theme: theme,
                  english: english,
                  dark: dark,
                  featured: featured,
                  onTap: () => onTheme(theme),
                ),
              );
            }).toList(),
          );
        },
      ),
      SizedBox(height: compact ? 88 : 144),
      _PhotographySectionHeading(
        eyebrow: english ? 'BY EVENT' : '按活动浏览',
        title: english
            ? 'Stories shaped by a place and time.'
            : '在特定时间与地点，展开完整故事。',
        description: english
            ? 'Travel and match-day collections bring related photographs together as one continuous experience.'
            : '以一次旅行或一场比赛为线索，将相关照片组织成连续的观看体验。',
        compact: compact,
        dark: dark,
      ),
      SizedBox(height: compact ? 32 : 48),
      ..._photographyEvents.indexed.map(
        (entry) => Padding(
          padding: EdgeInsets.only(bottom: compact ? 20 : 32),
          child: _PhotographyEventCard(
            theme: entry.$2,
            english: english,
            dark: dark,
            compact: compact,
            imageOnRight: entry.$1.isEven,
            onTap: () => onTheme(entry.$2),
          ),
        ),
      ),
    ],
  );
}

class _PhotographySectionHeading extends StatelessWidget {
  const _PhotographySectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.compact,
    required this.dark,
  });
  final String eyebrow;
  final String title;
  final String description;
  final bool compact;
  final bool dark;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 820),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFF0071E3),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.05,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
            fontSize: compact ? _typeSectionMobile : _typeHero,
            height: 1.04,
            letterSpacing: compact ? -1.4 : -2.2,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: compact ? _typeBody : _typeIntro,
            color: dark ? _darkSecondary : const Color(0xFF6E6E73),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
  );
}

class _PhotographySubjectCard extends StatelessWidget {
  const _PhotographySubjectCard({
    required this.theme,
    required this.english,
    required this.dark,
    required this.featured,
    required this.onTap,
  });
  final _PhotographyTheme theme;
  final bool english;
  final bool dark;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30);
    return Semantics(
      button: true,
      label: english ? 'Open ${theme.enTitle}' : '打开${theme.zhTitle}',
      child: Material(
        color: dark ? _darkCard : Colors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: featured ? 520 : 410,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  theme.photos.first.path,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x0D000000), Color(0xB8000000)],
                      stops: [.34, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.title(english),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: featured ? 40 : 30,
                          height: 1.06,
                          fontWeight: FontWeight.w600,
                          letterSpacing: featured ? -1.2 : -.7,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        theme.subtitle(english),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 17,
                          height: 1.4,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
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

class _PhotographyEventCard extends StatelessWidget {
  const _PhotographyEventCard({
    required this.theme,
    required this.english,
    required this.dark,
    required this.compact,
    required this.imageOnRight,
    required this.onTap,
  });
  final _PhotographyTheme theme;
  final bool english;
  final bool dark;
  final bool compact;
  final bool imageOnRight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 24 : 34),
      child: AspectRatio(
        aspectRatio: compact ? 4 / 3 : 16 / 11,
        child: Image.asset(
          theme.photos.first.path,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
    final copy = Padding(
      padding: EdgeInsets.all(compact ? 28 : 52),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            theme.title(english),
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              fontSize: compact ? _typeCardTitle : _typeHero,
              height: 1.06,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            theme.subtitle(english),
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: compact ? _typeBody : _typeBodyLarge,
              height: 1.5,
              color: dark ? _darkSecondary : const Color(0xFF6E6E73),
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            english ? 'Explore the story  ›' : '查看活动记录  ›',
            style: const TextStyle(
              color: Color(0xFF0071E3),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      label: english
          ? 'Open ${theme.enTitle} photography'
          : '打开${theme.zhTitle}摄影主题',
      child: Material(
        color: dark ? _darkCard : Colors.white,
        borderRadius: BorderRadius.circular(compact ? 28 : 40),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: compact
              ? Column(children: [image, copy])
              : Row(
                  children: imageOnRight
                      ? [Expanded(child: copy), Expanded(flex: 6, child: image)]
                      : [
                          Expanded(flex: 6, child: image),
                          Expanded(child: copy),
                        ],
                ),
        ),
      ),
    );
  }
}

class _PhotographyGalleryPage extends StatelessWidget {
  const _PhotographyGalleryPage({required this.theme, required this.english});
  final _PhotographyTheme theme;
  final bool english;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Scaffold(
      backgroundColor: dark ? _darkPage : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: english ? 'Back to photography' : '返回摄影作品',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 32,
          compact ? 48 : 76,
          compact ? 16 : 32,
          compact ? 88 : 128,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              children: [
                Text(
                  english ? 'PHOTOGRAPHY' : '摄影系列',
                  style: const TextStyle(
                    color: Color(0xFF0071E3),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  theme.title(english),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: compact ? _typeDisplayMobile : _typeDisplay,
                    height: 1.02,
                    letterSpacing: compact ? -1.8 : -3.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    theme.subtitle(english),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: compact ? _typeBody : _typeIntro,
                      height: 1.5,
                      color: dark ? _darkSecondary : const Color(0xFF6E6E73),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 54 : 82),
                _PhotographyGallery(
                  theme: theme,
                  compact: compact,
                  dark: dark,
                  english: english,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotographyGallery extends StatelessWidget {
  const _PhotographyGallery({
    required this.theme,
    required this.compact,
    required this.dark,
    required this.english,
  });
  final _PhotographyTheme theme;
  final bool compact;
  final bool dark;
  final bool english;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gap = compact ? 14.0 : 24.0;
      final columnWidth = (constraints.maxWidth - gap) / 2;
      final left = <Widget>[];
      final right = <Widget>[];
      double leftHeight = 0;
      double rightHeight = 0;
      for (var i = 0; i < theme.photos.length; i++) {
        final photo = theme.photos[i];
        final estimated = columnWidth / photo.ratio + gap;
        final tile = _PhotographyImageTile(
          photo: photo,
          dark: dark,
          label: english
              ? '${theme.enTitle} photograph ${i + 1}'
              : '${theme.zhTitle}摄影作品 ${i + 1}',
        );
        if (compact) {
          left.add(
            Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: tile,
            ),
          );
        } else if (leftHeight <= rightHeight) {
          left.add(
            Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: tile,
            ),
          );
          leftHeight += estimated;
        } else {
          right.add(
            Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: tile,
            ),
          );
          rightHeight += estimated;
        }
      }
      if (compact) return Column(children: left);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: left)),
          SizedBox(width: gap),
          Expanded(child: Column(children: right)),
        ],
      );
    },
  );
}

class _PhotographyImageTile extends StatelessWidget {
  const _PhotographyImageTile({
    required this.photo,
    required this.dark,
    required this.label,
  });
  final _PhotoAsset photo;
  final bool dark;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: label,
    child: Container(
      decoration: BoxDecoration(
        color: dark ? _darkCard : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: photo.ratio,
        child: Image.asset(
          photo.path,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          semanticLabel: label,
        ),
      ),
    ),
  );
}

// Apple Apps 风格的分区标题，强调“探索所有项目”的产品集合感。
class _ProjectCollectionHeader extends StatelessWidget {
  const _ProjectCollectionHeader({required this.dark, required this.english});
  final bool dark;
  final bool english;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            english ? 'Explore every project.' : '查看全部项目。',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              fontSize: _typeSection,
              height: 1.08,
              letterSpacing: -1.2,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        Icon(
          Icons.arrow_downward_rounded,
          size: 26,
          color: dark ? _darkSecondary : const Color(0xFF6E6E73),
        ),
      ],
    ),
  );
}

// 计算机项目数据。需要修改项目名称或简介时，可直接编辑此列表。
const _computerProjects = <_ProjectInfo>[
  _ProjectInfo(
    name: 'SpektraStudio',
    zhDescription: '以光谱计算重现胶片、相纸、颗粒与光晕的双语 Windows 影像工具。',
    enDescription: 'A bilingual Windows imaging tool that recreates film, paper, grain, and halation through spectral processing.',
    icon: Icons.auto_awesome_rounded,
    accent: Color(0xFF8E5CFF),
    githubUrl: 'https://github.com/HongyuYe12/SpektraStudio',
  ),
  _ProjectInfo(
    name: 'Monocular Depth Robustness',
    zhDescription: '评估单目深度估计在暗光、多深度与复杂场景中的稳定性，并探索深度引导自动对焦。',
    enDescription: 'Evaluating monocular-depth robustness in low-light and complex scenes, with experiments in depth-guided autofocus.',
    icon: Icons.blur_on_rounded,
    accent: Color(0xFF0071E3),
    githubUrl: 'https://github.com/HongyuYe12/monocular-depth-robustness',
  ),
  _ProjectInfo(
    name: 'Cabinet AI Assistant',
    zhDescription: '连接 DXF 图纸、AI 设计建议与本地视觉分析的橱柜设计和施工核验平台。',
    enDescription: 'A cabinet-planning and build-verification platform connecting DXF drawings, AI guidance, and local vision analysis.',
    icon: Icons.inventory_2_rounded,
    accent: Color(0xFF00A87E),
    githubUrl: 'https://github.com/HongyuYe12/cabinet-ai-assistant',
  ),
  _ProjectInfo(
    name: 'MinerU',
    zhDescription: '把 PDF 转换为可检索 Markdown，同时保留可靠、可追溯的原始页码映射。',
    enDescription: 'A local workflow that turns PDFs into searchable Markdown while preserving traceable source-page mappings.',
    icon: Icons.document_scanner_rounded,
    accent: Color(0xFFFF9F0A),
    githubUrl: 'https://github.com/HongyuYe12/mineru-book-page-map',
  ),
  _ProjectInfo(
    name: 'The Auctioneer',
    zhDescription: '一款 JavaFX 拍卖行经营游戏，在 30 天内通过探索、鉴定、库存与拍卖完成经营目标。',
    enDescription: 'A JavaFX auction-house management game built around exploration, appraisal, inventory, and live auctions over 30 days.',
    icon: Icons.gavel_rounded,
    accent: Color(0xFFFF375F),
    githubUrl: 'https://github.com/HongyuYe12/the-auctioneer',
  ),
];

class _ProjectInfo {
  const _ProjectInfo({
    required this.name,
    required this.zhDescription,
    required this.enDescription,
    required this.icon,
    required this.accent,
    required this.githubUrl,
  });

  final String name;
  final String zhDescription;
  final String enDescription;
  final IconData icon;
  final Color accent;
  final String githubUrl;
}

// 将项目排成宽幅编辑式卡片：第一项更突出，其余项目自适应排列。
class _ComputerProjectList extends StatelessWidget {
  const _ComputerProjectList({
    required this.dark,
    required this.english,
    required this.compact,
    required this.onProject,
  });

  final bool dark;
  final bool english;
  final bool compact;
  final ValueChanged<_ProjectInfo> onProject;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _ProjectCollectionHeader(dark: dark, english: english),
      LayoutBuilder(
        builder: (context, constraints) {
          final gap = compact ? 18.0 : 24.0;
          final cardWidth = compact
              ? constraints.maxWidth
              : (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: _computerProjects.indexed.map((entry) {
              final index = entry.$1;
              final project = entry.$2;
              return SizedBox(
                width: !compact && index == 0
                    ? constraints.maxWidth
                    : cardWidth,
                child: _ProjectCard(
                  project: project,
                  dark: dark,
                  english: english,
                  featured: index == 0,
                  onTap: () => onProject(project),
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}

// 单个项目卡片，保持与网站现有圆角、留白和深浅色风格一致。
class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.dark,
    required this.english,
    required this.featured,
    required this.onTap,
  });

  final _ProjectInfo project;
  final bool dark;
  final bool english;
  final bool featured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28);
    return Semantics(
      button: true,
      label: english
          ? 'Open ${project.name} project details'
          : '打开 ${project.name} 项目详情',
      child: Material(
        color: dark ? _darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: dark ? Colors.white10 : Colors.black12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          hoverColor: project.accent.withValues(alpha: dark ? .10 : .06),
          splashColor: project.accent.withValues(alpha: .10),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: featured ? 360 : 310),
            child: Padding(
              padding: EdgeInsets.all(featured ? 42 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: project.accent.withValues(
                            alpha: dark ? .22 : .12,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          project.icon,
                          color: project.accent,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: dark ? _darkSecondary : const Color(0xFF6E6E73),
                      ),
                    ],
                  ),
                  SizedBox(height: featured ? 76 : 42),
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: featured ? _typeSectionMobile : 28,
                      height: 1.08,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    english ? project.enDescription : project.zhDescription,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: featured ? _typeBodyLarge : _typeBody,
                      height: 1.45,
                      color: dark ? _darkSecondary : const Color(0xFF6E6E73),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    english ? 'Learn more  ›' : '进一步了解  ›',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: project.accent,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 第三级项目详情页。SpektraStudio 使用滚动与拖动联动的前后效果对比。
class _ProjectDetailPage extends StatefulWidget {
  const _ProjectDetailPage({required this.project, required this.english});

  final _ProjectInfo project;
  final bool english;

  @override
  State<_ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<_ProjectDetailPage> {
  final _scrollController = ScrollController();
  double _comparison = 0;
  bool _draggingComparison = false;

  bool get _isSpektra => widget.project.name == 'SpektraStudio';

  @override
  void initState() {
    super.initState();
    if (_isSpektra) _scrollController.addListener(_syncComparisonToScroll);
  }

  void _syncComparisonToScroll() {
    if (_draggingComparison || !_scrollController.hasClients) return;
    final next = ((_scrollController.offset - 220) / 720).clamp(0.0, 1.0);
    if ((next - _comparison).abs() > .002) {
      setState(() => _comparison = next);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncComparisonToScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 700;
    final secondary = dark ? _darkSecondary : const Color(0xFF6E6E73);
    final radius = BorderRadius.circular(compact ? 28 : 36);
    final english = widget.english;

    return Scaffold(
      backgroundColor: dark ? _darkPage : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: english ? 'Back to projects' : '返回项目列表',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: _isSpektra
            ? _buildSpektraPage(context, dark, compact, secondary)
            : _buildStandardPage(context, dark, compact, secondary, radius),
      ),
    );
  }

  Widget _buildSpektraPage(
    BuildContext context,
    bool dark,
    bool compact,
    Color secondary,
  ) => Column(
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 24 : 48,
          compact ? 48 : 82,
          compact ? 24 : 48,
          compact ? 62 : 92,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: compact ? 42 : 48,
                      height: compact ? 42 : 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFB06CFF), Color(0xFF5B35FF)],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'SpektraStudio',
                      style: TextStyle(
                        fontSize: compact ? 20 : 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.5,
                        color: dark ? _darkPrimary : const Color(0xFF1D1D1F),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 42 : 62),
                Text(
                  widget.english
                      ? 'Give every image\nits own character.'
                      : '让每一张影像，\n拥有自己的气质。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                    fontSize: compact ? _typeDisplayMobile : _typeDisplay,
                    height: 1.02,
                    letterSpacing: compact ? -2 : -4,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: compact ? 24 : 32),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    widget.english
                        ? 'A focused workspace for shaping color, texture, and atmosphere through an intuitive creative workflow.'
                        : '一个专注于色彩、质感与氛围的影像工作空间，让调整更直观，创作更专注。',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: compact ? _typeBodyLarge : _typeIntro,
                      height: 1.45,
                      color: secondary,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _ProjectGithubLink(
                  url: widget.project.githubUrl,
                  english: widget.english,
                  accent: widget.project.accent,
                ),
              ],
            ),
          ),
        ),
      ),
      Container(
        width: double.infinity,
        color: dark ? const Color(0xFF090909) : const Color(0xFFF5F5F7),
        padding: EdgeInsets.fromLTRB(
          compact ? 12 : 32,
          compact ? 62 : 100,
          compact ? 12 : 32,
          compact ? 78 : 120,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: _SpektraFilmComparison(
              value: _comparison,
              compact: compact,
              english: widget.english,
              onDragStart: () => setState(() => _draggingComparison = true),
              onChanged: (value) =>
                  setState(() => _comparison = value.clamp(0.0, 1.0)),
              onDragEnd: () => setState(() => _draggingComparison = false),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 24 : 48,
          compact ? 78 : 128,
          compact ? 24 : 48,
          compact ? 100 : 150,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              children: [
                Text(
                  widget.english
                      ? 'Creative control, without distraction.'
                      : '专注创作，不被复杂工具打断。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: compact ? _typeSectionMobile : _typeHero,
                    height: 1.06,
                    letterSpacing: compact ? -1.4 : -2.5,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: compact ? 48 : 72),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cards = [
                      (
                        Icons.palette_outlined,
                        widget.english ? 'Color with character' : '有性格的色彩',
                        widget.english
                            ? 'Shape film-inspired color and atmosphere while keeping the photograph itself at the center.'
                            : '塑造来自胶片的色彩与氛围，同时让照片本身始终处于创作中心。',
                      ),
                      (
                        Icons.tune_rounded,
                        widget.english ? 'Direct comparison' : '直观的前后对比',
                        widget.english
                            ? 'Scroll or drag to see every change in context and compare the result instantly.'
                            : '通过滚动或拖动，在同一画面中理解变化并立即比较结果。',
                      ),
                    ];
                    final width = compact
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 24) / 2;
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: cards
                          .map(
                            (card) => SizedBox(
                              width: width,
                              child: _SpektraFeatureCard(
                                icon: card.$1,
                                title: card.$2,
                                text: card.$3,
                                dark: dark,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      _PageEnd(text: widget.english ? _en : _zh, dark: dark, compact: compact),
    ],
  );

  Widget _buildStandardPage(
    BuildContext context,
    bool dark,
    bool compact,
    Color secondary,
    BorderRadius radius,
  ) {
    final project = widget.project;
    final content = _projectDetailContent(project.name, widget.english);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 24 : 48,
            compact ? 52 : 72,
            compact ? 24 : 48,
            120,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                children: [
                  Container(
                    width: compact ? 72 : 88,
                    height: compact ? 72 : 88,
                    decoration: BoxDecoration(
                      color: project.accent.withValues(alpha: dark ? .22 : .12),
                      borderRadius: BorderRadius.circular(compact ? 22 : 28),
                    ),
                    child: Icon(
                      project.icon,
                      color: project.accent,
                      size: compact ? 36 : 44,
                    ),
                  ),
                  SizedBox(height: compact ? 28 : 36),
                  Text(
                    project.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontSize: compact ? _typeSectionMobile : _typeHero,
                      height: 1.06,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: compact ? 20 : 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      widget.english
                          ? project.enDescription
                          : project.zhDescription,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: compact ? _typeBody : _typeIntro,
                        height: 1.55,
                        color: secondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 34 : 44),
                  _ProjectGithubLink(
                    url: project.githubUrl,
                    english: widget.english,
                    accent: project.accent,
                  ),
                  SizedBox(height: compact ? 70 : 96),
                  _ProjectNarrative(
                    content: content,
                    dark: dark,
                    compact: compact,
                    accent: project.accent,
                    radius: radius,
                  ),
                ],
              ),
            ),
          ),
        ),
        _PageEnd(
          text: widget.english ? _en : _zh,
          dark: dark,
          compact: compact,
        ),
      ],
    );
  }
}

class _ProjectDetailContent {
  const _ProjectDetailContent({
    required this.eyebrow,
    required this.headline,
    required this.intro,
    required this.sections,
  });
  final String eyebrow;
  final String headline;
  final String intro;
  final List<_ProjectDetailSection> sections;
}

class _ProjectDetailSection {
  const _ProjectDetailSection({
    required this.icon,
    required this.title,
    required this.body,
    required this.points,
    this.dark = false,
    this.wide = false,
  });
  final IconData icon;
  final String title;
  final String body;
  final List<String> points;
  final bool dark;
  final bool wide;
}

_ProjectDetailContent _projectDetailContent(String name, bool english) {
  if (name == 'Monocular Depth Robustness') {
    return _ProjectDetailContent(
      eyebrow: english ? 'COMPUTATIONAL PHOTOGRAPHY' : '计算摄影研究',
      headline: english ? 'Help autofocus understand depth.' : '让自动对焦，理解画面的深度。',
      intro: english
          ? 'A reproducible research pipeline evaluates monocular-depth stability, then turns relative depth into subject ranking, ambiguity detection, and a near/mid/far focus-search suggestion.'
          : '先以可复现实验评估单目深度在复杂环境中的稳定性，再把相对深度用于主体排序、歧义检测和近／中／远初始对焦范围预测。',
      sections: [
        _ProjectDetailSection(
          icon: Icons.center_focus_strong_rounded,
          title: english
              ? 'From a frame to a focus decision.'
              : '从一帧画面，到一次对焦决策。',
          body: english
              ? 'The prototype detects candidate subjects, estimates relative depth, compares each subject with its surroundings, and recommends a conservative focus region.'
              : '原型自动检测候选主体，估计相对深度，分析主体内部一致性和背景分离度，再给出保守的对焦区域建议。',
          points: english
              ? [
                  'AI subject candidates',
                  'Depth distribution analysis',
                  'Near / mid / far search range',
                  'Validation-frame sharpness refinement',
                ]
              : ['AI 候选主体检测', '主体深度分布与背景分离', '近／中／远搜索区域', '验证帧清晰度微调'],
          wide: true,
          dark: true,
        ),
        _ProjectDetailSection(
          icon: Icons.science_outlined,
          title: english
              ? 'Test robustness, not just appearance.'
              : '评估稳定性，而不只看深度图。',
          body: english
              ? 'Brightness, blur, noise, and resolution perturbations are deterministic, making comparisons repeatable across Depth Anything V2 and MiDaS/DPT.'
              : '通过确定性的亮度、模糊、噪声和分辨率扰动，在相同输入清单下公平比较 Depth Anything V2 与 MiDaS/DPT。',
          points: english
              ? [
                  'Spearman ranking',
                  'Order consistency',
                  'Affine NRMSE',
                  'Depth-edge F1',
                ]
              : ['Spearman 排序相关性', '像素对顺序一致率', '仿射对齐结构误差', '深度边缘 F1'],
        ),
        _ProjectDetailSection(
          icon: Icons.photo_camera_outlined,
          title: english
              ? 'Designed for real camera constraints.'
              : '面向真实相机约束。',
          body: english
              ? 'RAW previews are supported for low-light experiments, while uncertain or multi-depth subjects trigger a local focus sweep instead of an overconfident answer.'
              : '支持 RAW 临时帧用于暗光实验；当主体存在多深度歧义或置信度不足时，系统会触发局部焦点扫描，而不是给出过度自信的答案。',
          points: english
              ? [
                  'ARW / DNG / CR2 / NEF',
                  'Focus-sweep fallback',
                  'Ablation with and without depth',
                ]
              : ['支持 ARW／DNG／CR2／NEF', '焦点扫描回退机制', '有无深度特征的消融实验'],
        ),
      ],
    );
  }
  if (name == 'Cabinet AI Assistant') {
    return _ProjectDetailContent(
      eyebrow: english ? 'DESIGN + VISION WORKSPACE' : '设计与视觉工作空间',
      headline: english
          ? 'From floor plan to build verification.'
          : '从图纸理解，到施工核验。',
      intro: english
          ? 'A Java 21 and Spring Boot platform joins AI-assisted cabinet planning with practical CAD generation and three local visual-analysis modules.'
          : '一个由 Java 21 与 Spring Boot 构建的平台，将大模型橱柜规划、可下载的 CAD 生成和三个本地视觉分析模块连接起来。',
      sections: [
        _ProjectDetailSection(
          icon: Icons.architecture_rounded,
          title: english ? 'DXF in. A usable plan out.' : '上传 DXF，得到可执行的方案。',
          body: english
              ? 'The design workspace combines wall geometry, budget, style, and appliance dimensions. After confirmation, it writes cabinet placements back into a downloadable DXF.'
              : '设计工作区综合墙体几何、预算、风格与电器尺寸；确认 AI 建议后，将柜体和电器布置写回可下载的 DXF 文件。',
          points: english
              ? [
                  'Budget and style constraints',
                  'Appliance dimension planning',
                  'AI recommendations',
                  'Generated designed-kitchen.dxf',
                ]
              : ['预算与风格约束', '电器尺寸规划', 'AI 设计建议', '生成 designed-kitchen.dxf'],
          wide: true,
          dark: true,
        ),
        _ProjectDetailSection(
          icon: Icons.grid_view_rounded,
          title: english ? 'Three vision modules.' : '三个可运行的视觉模块。',
          body: english
              ? 'The visual lab analyzes floor-plan regions, parses ASCII DXF structure, and compares design renders with construction photos after translation alignment.'
              : '视觉实验室可分析户型图区域、解析 ASCII DXF 的图层和图元，并在平移对齐后比较效果图与施工结果。',
          points: english
              ? [
                  'Wall and room candidates',
                  'Layer and entity statistics',
                  'Similarity and changed-area metrics',
                  'Difference heatmap',
                ]
              : ['墙体与房间候选区域', '图层与图元统计', '相似度与变化面积', '差异热力图'],
        ),
        _ProjectDetailSection(
          icon: Icons.cloud_done_outlined,
          title: english ? 'A complete deployable prototype.' : '可部署的完整原型。',
          body: english
              ? 'The static interface publishes through GitHub Pages, while a Dockerized Spring Boot backend runs on Render. API keys remain server-side.'
              : '静态界面通过 GitHub Pages 发布，Docker 化的 Spring Boot 后端部署在 Render；API Key 只保存在服务端环境变量中。',
          points: english
              ? [
                  'GitHub Pages frontend',
                  'Render backend',
                  'Docker deployment',
                  'Server-side secrets',
                ]
              : ['GitHub Pages 前端', 'Render 后端', 'Docker 部署', '服务端密钥管理'],
        ),
      ],
    );
  }
  if (name == 'MinerU') {
    return _ProjectDetailContent(
      eyebrow: english ? 'TRACEABLE DOCUMENT PIPELINE' : '可追溯文档管线',
      headline: english
          ? 'Search Markdown. Return to the exact PDF page.'
          : '在 Markdown 中检索，回到准确的 PDF 页。',
      intro: english
          ? 'A local MinerU workflow converts long PDFs into searchable Markdown while preserving auditable physical-page mappings for later retrieval and document Q&A.'
          : '调用本地 MinerU 将长 PDF 转换为可检索 Markdown，同时保留可审计的物理页码映射，为检索和文档问答提供可靠引用。',
      sections: [
        _ProjectDetailSection(
          icon: Icons.account_tree_outlined,
          title: english
              ? 'One source. Five traceable outputs.'
              : '一份 PDF，生成五类可追溯产物。',
          body: english
              ? 'The pipeline keeps the cleaned Markdown, human-readable map, machine-readable JSON index, referenced images, and original MinerU output together.'
              : '流程同时保留最终 Markdown、人类可读页码表、程序可读 JSON 索引、引用图片和 MinerU 原始输出。',
          points: english
              ? [
                  'book.md page anchors',
                  'book.page-map.md',
                  'book.page-map.json',
                  'images and mineru_raw',
                ]
              : [
                  'book.md 隐形页码锚点',
                  'book.page-map.md 对照表',
                  'book.page-map.json 索引',
                  'images 与 mineru_raw',
                ],
          wide: true,
          dark: true,
        ),
        _ProjectDetailSection(
          icon: Icons.verified_outlined,
          title: english ? 'Verification before trust.' : '先验证，再使用。',
          body: english
              ? 'After conversion, the tool checks page-anchor order and local image references. Uncertain matches remain unknown instead of receiving fabricated page numbers.'
              : '转换完成后自动检查页码标记的完整性、顺序和本地图片引用；无法确认的页码保持 unknown，不伪造映射。',
          points: english
              ? [
                  'Ordered page anchors',
                  'Broken-image detection',
                  'Unknown-page fallback',
                  'Rebuild without rerunning MinerU',
                ]
              : ['页码锚点顺序检查', '损坏图片检测', '未知页码回退', '无需重跑 MinerU 的 rebuild'],
        ),
        _ProjectDetailSection(
          icon: Icons.search_rounded,
          title: english ? 'Ready for retrieval systems.' : '为检索系统而设计。',
          body: english
              ? 'Search results report both Markdown line and physical PDF page, creating a practical foundation for cited book or paper question answering.'
              : '搜索结果同时返回 Markdown 行号和 PDF 物理页码，可直接作为带页码引用的书籍、论文问答基础。',
          points: english
              ? [
                  'Keyword search',
                  'Page lookup',
                  'Physical-page citations',
                  'NLP / multimodal extension path',
                ]
              : ['关键词搜索', '按页查询', '物理页码引用', 'NLP／多模态扩展路径'],
        ),
      ],
    );
  }
  return _ProjectDetailContent(
    eyebrow: english ? 'JAVA DESKTOP GAME' : 'Java 桌面经营游戏',
    headline: english
        ? 'Build an auction house in 30 days.'
        : '用 30 天，经营一家拍卖行。',
    intro: english
        ? 'A JavaFX management game with a complete loop of exploration, appraisal, inventory, shopping, and live auctions.'
        : '一款拥有完整经营循环的 JavaFX 拍卖行游戏：探索、鉴定、库存、商店和现场拍卖相互连接。',
    sections: [
      _ProjectDetailSection(
        icon: Icons.explore_outlined,
        title: english ? 'Explore. Appraise. Decide.' : '探索、鉴定，再做决定。',
        body: english
            ? 'Players spend energy exploring increasingly rare locations, then determine whether artifacts are genuine before committing inventory space and resources.'
            : '玩家消耗精力探索旧地窖、黑市货船与亚特兰蒂斯遗迹，鉴定文物真伪，再决定库存和资源如何分配。',
        points: english
            ? [
                'Multiple exploration areas',
                'Rarity and authenticity',
                'Energy economy',
                'Unlockable advanced region',
              ]
            : ['多个探索区域', '稀有度与真伪系统', '精力经济', '高级区域解锁'],
        wide: true,
        dark: true,
      ),
      _ProjectDetailSection(
        icon: Icons.gavel_rounded,
        title: english
            ? 'A weekly auction changes the strategy.'
            : '每七天一次拍卖，改变经营节奏。',
        body: english
            ? 'Every seven days, selected artifacts enter the auction. Timing, inventory choices, and appraisal risk determine whether the house reaches ten million coins.'
            : '每七天选择藏品参加拍卖；出售时机、库存选择和鉴定风险共同决定能否在期限内赚到一千万金币。',
        points: english
            ? [
                '30-day deadline',
                'Weekly auction events',
                'Ten-million target',
                'Win and loss settlement',
              ]
            : ['30 天期限', '每周拍卖事件', '一千万经营目标', '完整胜负结算'],
      ),
      _ProjectDetailSection(
        icon: Icons.layers_outlined,
        title: english
            ? 'A structured JavaFX application.'
            : '结构完整的 JavaFX 应用。',
        body: english
            ? 'FXML views, CSS styling, controller-driven flows, and model utilities are packaged with Maven and classpath-safe resources.'
            : 'FXML 页面、CSS 样式、控制器流程和数据模型通过 Maven 管理，并完成 classpath 资源加载适配。',
        points: english
            ? ['Java 21', 'JavaFX 21', 'FXML + CSS', 'Maven build']
            : ['Java 21', 'JavaFX 21', 'FXML + CSS', 'Maven 构建'],
      ),
    ],
  );
}

class _ProjectGithubLink extends StatelessWidget {
  const _ProjectGithubLink({
    required this.url,
    required this.english,
    required this.accent,
  });
  final String url;
  final bool english;
  final Color accent;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () =>
        launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault),
    icon: const Icon(Icons.code_rounded, size: 20),
    label: Text(english ? 'View source on GitHub' : '在 GitHub 查看源码'),
    style: TextButton.styleFrom(
      foregroundColor: accent,
      textStyle: const TextStyle(
        fontSize: _typeBody,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
  );
}

class _ProjectNarrative extends StatelessWidget {
  const _ProjectNarrative({
    required this.content,
    required this.dark,
    required this.compact,
    required this.accent,
    required this.radius,
  });
  final _ProjectDetailContent content;
  final bool dark;
  final bool compact;
  final Color accent;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        content.eyebrow,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: compact ? 14 : 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: accent,
          decoration: TextDecoration.none,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        content.headline,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontSize: compact ? _typeSectionMobile : _typeHero,
          height: 1.06,
          letterSpacing: compact ? -1.4 : -2.4,
          decoration: TextDecoration.none,
        ),
      ),
      const SizedBox(height: 24),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Text(
          content.intro,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: compact ? _typeBody : _typeIntro,
            height: 1.55,
            color: dark ? _darkSecondary : const Color(0xFF6E6E73),
            decoration: TextDecoration.none,
          ),
        ),
      ),
      SizedBox(height: compact ? 54 : 76),
      LayoutBuilder(
        builder: (context, constraints) {
          final gap = compact ? 18.0 : 24.0;
          final half = compact
              ? constraints.maxWidth
              : (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: content.sections
                .map(
                  (section) => SizedBox(
                    width: compact || section.wide
                        ? constraints.maxWidth
                        : half,
                    child: _ProjectNarrativeCard(
                      section: section,
                      darkMode: dark,
                      compact: compact,
                      accent: accent,
                      radius: radius,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    ],
  );
}

class _ProjectNarrativeCard extends StatelessWidget {
  const _ProjectNarrativeCard({
    required this.section,
    required this.darkMode,
    required this.compact,
    required this.accent,
    required this.radius,
  });
  final _ProjectDetailSection section;
  final bool darkMode;
  final bool compact;
  final Color accent;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final useDark = section.dark;
    final foreground = useDark
        ? Colors.white
        : (darkMode ? _darkPrimary : const Color(0xFF1D1D1F));
    final secondary = useDark
        ? Colors.white70
        : (darkMode ? _darkSecondary : const Color(0xFF6E6E73));
    return Container(
      constraints: BoxConstraints(minHeight: section.wide ? 380 : 390),
      padding: EdgeInsets.all(compact ? 30 : 42),
      decoration: BoxDecoration(
        color: useDark
            ? const Color(0xFF101010)
            : (darkMode ? _darkCard : const Color(0xFFF5F5F7)),
        borderRadius: radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(section.icon, size: 40, color: accent),
          SizedBox(height: section.wide ? 88 : 60),
          Text(
            section.title,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: section.wide
                  ? (compact ? _typeCardTitle : _typeSection)
                  : 28,
              height: 1.1,
              color: foreground,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            section.body,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: _typeBody,
              height: 1.55,
              color: secondary,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 24),
          ...section.points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: useDark ? Colors.white : foreground,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpektraFeatureCard extends StatelessWidget {
  const _SpektraFeatureCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.dark,
  });
  final IconData icon;
  final String title;
  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 300),
    padding: const EdgeInsets.all(36),
    decoration: BoxDecoration(
      color: dark ? _darkCard : const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 38, color: const Color(0xFF8E5CFF)),
        const SizedBox(height: 96),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: _typeCardTitle,
            height: 1.12,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: _typeBody,
            height: 1.55,
            color: dark ? _darkSecondary : const Color(0xFF6E6E73),
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
  );
}

class _SpektraFilmComparison extends StatelessWidget {
  const _SpektraFilmComparison({
    required this.value,
    required this.compact,
    required this.english,
    required this.onDragStart,
    required this.onChanged,
    required this.onDragEnd,
  });

  final double value;
  final bool compact;
  final bool english;
  final VoidCallback onDragStart;
  final ValueChanged<double> onChanged;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        english ? 'From digital to film.' : '从原图，到胶片。',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayMedium!.copyWith(
          fontSize: compact ? _typeSectionMobile : _typeSection,
          decoration: TextDecoration.none,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        english
            ? 'Scroll to reveal the film rendering, or drag the divider for a direct comparison.'
            : '向下滚动逐渐呈现胶片效果，也可以拖动分隔条直接比较。',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: compact ? _typeBody : _typeBodyLarge,
          color: Theme.of(context).brightness == Brightness.dark
              ? _darkSecondary
              : const Color(0xFF6E6E73),
          decoration: TextDecoration.none,
        ),
      ),
      SizedBox(height: compact ? 28 : 38),
      LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxWidth * 2208 / 2400;
          final dividerX = constraints.maxWidth * value;
          void update(double localX) =>
              onChanged((localX / constraints.maxWidth).clamp(0.0, 1.0));

          return Semantics(
            slider: true,
            label: english ? 'Original and film comparison' : '原图与胶片效果对比',
            value: '${(value * 100).round()}%',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) {
                onDragStart();
                update(details.localPosition.dx);
              },
              onHorizontalDragUpdate: (details) =>
                  update(details.localPosition.dx),
              onHorizontalDragEnd: (_) => onDragEnd(),
              onTapDown: (details) => update(details.localPosition.dx),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(compact ? 20 : 28),
                child: SizedBox(
                  width: double.infinity,
                  height: height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/spektrastudio/temple-original-aligned.webp',
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                      ClipRect(
                        clipper: _HorizontalRevealClipper(value),
                        child: Image.asset(
                          'assets/spektrastudio/temple-film.webp',
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Positioned(
                        left: dividerX - 1,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 2,
                          color: Colors.white.withValues(alpha: .96),
                        ),
                      ),
                      Positioned(
                        left: dividerX - 24,
                        top: height / 2 - 30,
                        child: SizedBox(
                          width: 48,
                          height: 60,
                          child: Center(
                            child: Container(
                              width: 24,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .94),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 14,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 3,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6E6E73),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}

class _HorizontalRevealClipper extends CustomClipper<Rect> {
  const _HorizontalRevealClipper(this.value);
  final double value;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * value, size.height);

  @override
  bool shouldReclip(covariant _HorizontalRevealClipper oldClipper) =>
      oldClipper.value != value;
}

// 所有普通页面共用的结尾区域。全屏展开菜单是覆盖层，不插入这里。
class _PageEnd extends StatelessWidget {
  const _PageEnd({
    super.key,
    required this.text,
    required this.dark,
    required this.compact,
  });

  final Map<String, String> text;
  final bool dark;
  final bool compact;

  Future<void> _open(String value) =>
      launchUrl(Uri.parse(value), mode: LaunchMode.platformDefault);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Contact(
        text: text,
        dark: dark,
        compact: compact,
        onEmail: () => _open('mailto:robin.hye@icloud.com'),
        onGithub: () => _open('https://github.com/HongyuYe12'),
      ),
      _Footer(dark: dark, text: text),
    ],
  );
}

// 联系方式区域：提供公开邮箱和 GitHub 主页链接。
class _Contact extends StatelessWidget {
  const _Contact({
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
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontSize: compact ? _typeSectionMobile : _typeSection,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                text['contactText']!,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: compact ? _typeBody : _typeBodyLarge,
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
  const _Footer({required this.dark, required this.text});
  final bool dark;
  final Map<String, String> text;
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
            '${text['copyright']} © ${DateTime.now().year} Ye Hongyu.',
            style: TextStyle(
              fontSize: 12.5,
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
  'projects': '作品',
  'contact': '联系',
  'heroName': 'Ye Hongyu',
  'heroRole': '',
  'heroIntro': '我关注影像、计算机视觉与实用软件。这里收录我的项目、实验与摄影作品，也记录每一次从想法到实现的过程。',
  'viewProjects': '查看作品',
  'contactMe': '与我联系',
  'portraitLabel': 'Ye Hongyu 的拟我头像',
  'contactTitle': '保持联系。',
  'contactText': '如果你想讨论项目、摄影或合作想法，欢迎通过邮件或 GitHub 与我联系。',
  'computerProjects': '计算机项目',
  'photography': '摄影作品',
  'computerSubtitle': '用代码、研究与设计，把想法做成可用的工具。',
  'photoSubtitle': '关于光线、空间、旅途与现场的影像记录。',
  'learnMore': '进一步了解',
  'copyright': '版权所有',
};

// 英文文案表。字段名称需与中文文案表保持一致。
const _en = <String, String>{
  'projects': 'Work',
  'contact': 'Contact',
  'heroName': 'Ye Hongyu',
  'heroRole': '',
  'heroIntro': 'I work across imaging, computer vision, and practical software. This site brings together my projects, experiments, and photography—from first idea to finished result.',
  'viewProjects': 'Explore the work',
  'contactMe': 'Get in touch',
  'portraitLabel': 'Memoji portrait of Ye Hongyu',
  'computerProjects': 'Computer Projects',
  'photography': 'Photography',
  'computerSubtitle': 'Code, research, and design shaped into useful tools.',
  'photoSubtitle': 'Photographs of light, place, travel, and the moment.',
  'learnMore': 'Learn more',
  'contactTitle': 'Stay in touch.',
  'contactText': 'For conversations about projects, photography, or collaboration, reach me by email or GitHub.',
  'copyright': 'Copyright',
};
