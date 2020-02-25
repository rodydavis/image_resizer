import 'template.dart';

abstract class ImageFolder {
  final String path;
  final List<IconTemplate> templates;
  ImageFolder(this.path, this.templates);
}

class WebIconsFolder extends ImageFolder {
  WebIconsFolder({
    String path = 'web/icons',
    this.favicion,
    List<WebIcon> icons = _defaultIcons,
  }) : super(path, icons);

  static const _defaultIcons = [
    WebIcon(size: 192),
    WebIcon(size: 512),
  ];

  final WebFavicon favicion;
}

class IosIconsFolder extends ImageFolder {
  IosIconsFolder({
    String path = 'ios/Runner/Assets.xcassets/AppIcon.appiconset',
    List<IosIcon> icons = _defaultIcons,
  }) : super(path, icons);

  static const _defaultIcons = [
    IosIcon(size: 20, scale: 1),
    IosIcon(size: 20, scale: 2),
    IosIcon(size: 20, scale: 3),
    IosIcon(size: 29, scale: 1),
    IosIcon(size: 29, scale: 2),
    IosIcon(size: 29, scale: 3),
    IosIcon(size: 40, scale: 1),
    IosIcon(size: 40, scale: 2),
    IosIcon(size: 40, scale: 3),
    IosIcon(size: 60, scale: 2),
    IosIcon(size: 60, scale: 3),
    IosIcon(size: 76, scale: 1),
    IosIcon(size: 76, scale: 2),
    IosIcon(size: 83, scale: 2, point5: true),
    IosIcon(size: 1024, scale: 1),
  ];

  Map<String, dynamic> toJson({int version = 1, String author = 'xcode'}) {
    return {
      "images": [
        for (var icon in this.templates) ...{
          if (icon is IosIcon) ...{
            icon.toJson(),
          },
        }
      ],
      "info": {"version": version, "author": author}
    };
  }
}

class MacOSIconsFolder extends ImageFolder {
  MacOSIconsFolder({
    String path = 'macos/Runner/Assets.xcassets/AppIcon.appiconset',
    List<MacOSIcon> icons = _defaultIcons,
  }) : super(path, icons);

  static const _defaultIcons = [
    MacOSIcon(size: 16, scale: 1, name: '16'),
    MacOSIcon(size: 16, scale: 2, name: '32'),
    MacOSIcon(size: 32, scale: 1, name: '32'),
    MacOSIcon(size: 32, scale: 2, name: '64'),
    MacOSIcon(size: 128, scale: 1, name: '128'),
    MacOSIcon(size: 128, scale: 2, name: '256'),
    MacOSIcon(size: 256, scale: 1, name: '256'),
    MacOSIcon(size: 256, scale: 2, name: '512'),
    MacOSIcon(size: 512, scale: 1, name: '512'),
    MacOSIcon(size: 512, scale: 2, name: '1024'),
  ];

  Map<String, dynamic> toJson({int version = 1, String author = 'xcode'}) {
    return {
      "images": [
        for (var icon in this.templates) ...{
          if (icon is IosIcon) ...{
            icon.toJson(),
          },
        }
      ],
      "info": {"version": version, "author": author}
    };
  }
}

class AndroidIconsFolder extends ImageFolder {
  AndroidIconsFolder({
    String path = 'android/app/src/main/res',
    List<AndroidIcon> icons = _defaultIcons,
  }) : super(path, icons);

  static const _defaultIcons = [
    AndroidIcon(size: 72, folderSuffix: "hdpi"),
    AndroidIcon(size: 48, folderSuffix: "mdpi"),
    AndroidIcon(size: 96, folderSuffix: "xhdpi"),
    AndroidIcon(size: 144, folderSuffix: "xxhdpi"),
    AndroidIcon(size: 192, folderSuffix: "xxxhdpi"),
  ];
}
