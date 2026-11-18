# Ye Hongyu — Personal Website

[![Website](https://img.shields.io/badge/Website-hongyuye12.github.io-0071E3?style=flat-square)](https://hongyuye12.github.io)
[![Built with Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=flat-square&logo=flutter)](https://flutter.dev)

Ye Hongyu 的双语个人网站，用于展示计算机项目、摄影作品与联系方式。整体设计参考 Apple 的简洁排版与系统级深浅色体验，并使用 Flutter Web 构建。

## 网站功能

- 中文 / English 双语切换
- 跟随系统自动切换浅色与深色模式
- 计算机项目与摄影作品独立详情页
- 响应式桌面、平板与手机布局
- Apple 风格悬浮导航与克制的 Liquid Glass 视觉效果
- GitHub Pages 公开访问

## 计算机项目

- **SpektraStudio** — 探索视觉与创意数字内容创作体验的实验性工作室项目
- **Monocular Depth Robustness** — 单目深度估计鲁棒性与深度引导自动对焦研究
- **Cabinet AI Assistant** — 面向资料整理、信息检索与日常工作流的个人 AI 助手
- **MinerU** — 将 PDF 转换为可检索 Markdown，并维护可靠的原始页码映射
- **The Auctioneer** — 围绕拍卖流程、出价互动与信息展示构建的应用项目

## 技术栈

- Flutter Web
- Dart
- `liquid_glass_widgets`
- GitHub Pages

## 本地运行

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

## 构建与发布

```bash
cd flutter_app
flutter build web --release
```

构建结果位于 `flutter_app/build/web`。本仓库根目录保存 GitHub Pages 使用的发布文件。

## 联系方式

- Website: [hongyuye12.github.io](https://hongyuye12.github.io)
- GitHub: [HongyuYe12](https://github.com/HongyuYe12)
- Email: [robin.hye@icloud.com](mailto:robin.hye@icloud.com)
- WeChat: `HYe_12Dec`
- Phone: [+86 136 0690 3960](tel:+8613606903960)

## License

网站内容与个人视觉资产 © Ye Hongyu。第三方依赖与 Liquid Glass 相关资源遵循各自许可证。
