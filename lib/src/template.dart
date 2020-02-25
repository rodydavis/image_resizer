import 'dart:convert';

import 'package:meta/meta.dart';

/// Template for Icon
abstract class IconTemplate {
  const IconTemplate(this.size);
  final int size;
  String get filename;
}

/// web/icons/Icon-512.png
class WebIcon extends IconTemplate {
  const WebIcon({
    @required int size,
    this.prefix = 'Icon-',
    this.ext = 'png',
  }) : super(size);
  final String prefix;
  final String ext;

  WebIcon copyWith({
    int size,
    String prefix,
    String ext,
  }) {
    return WebIcon(
      prefix: prefix ?? this.prefix,
      size: size ?? this.size,
      ext: ext ?? this.ext,
    );
  }

  Map<String, dynamic> toJson([String folder = "icons"]) {
    return {
      "src": "$folder/$filename",
      "sizes": "$size" + "x" + "$size",
      "type": "image/$ext"
    };
  }

  @override
  String get filename => '$prefix$size.$ext';
}

/// web/icons/Icon-512.png
class WebFavicon extends IconTemplate {
  const WebFavicon({
    int size = 16,
    this.name = 'favicon',
    this.ext = 'png',
  }) : super(size);
  final String name;
  final String ext;

  WebFavicon copyWith({
    int size,
    String name,
    String ext,
  }) {
    return WebFavicon(
      size: size ?? this.size,
      ext: ext ?? this.ext,
      name: name ?? this.name,
    );
  }

  @override
  String get filename => '$name.$ext';
}

/// ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
class IosIcon extends IconTemplate {
  const IosIcon({
    @required int size,
    this.ext = 'png',
    this.prefix = 'Icon-App-',
    this.scale = 1,
    this.point5 = false,
  }) : super(size);
  final String prefix;
  final int scale;
  final String ext;
  final bool point5;

  IosIcon copyWith({
    int size,
    String prefix,
    int scale,
    String ext,
    bool point5,
  }) {
    return IosIcon(
      size: size ?? this.size,
      prefix: prefix ?? this.prefix,
      scale: scale ?? this.scale,
      ext: ext ?? this.ext,
      point5: point5 ?? this.point5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "size": "${size}x${size}",
      "idiom": "ios-marketing",
      "filename": filename,
      "scale": "${scale}x"
    };
  }

  @override
  String get filename => "$prefix${size}x${size}@${scale}x.$ext";
}

/// android/app/src/main/res/mipmap-hdpi/ic_launcher.png
class AndroidIcon extends IconTemplate {
  const AndroidIcon({
    @required int size,
    this.name = 'ic_launcher',
    this.ext = 'png',
    this.folderPrefix = 'mipmap-',
    this.folder = 'hdpi',
  }) : super(size);
  final String name;
  final String folder;
  final String folderPrefix;
  final String ext;

  AndroidIcon copyWith({
    String name,
    String folder,
    String folderPrefix,
    String ext,
    int size,
  }) {
    return AndroidIcon(
      name: name ?? this.name,
      size: size ?? this.size,
      folder: folder ?? this.folder,
      folderPrefix: folderPrefix ?? this.folderPrefix,
      ext: ext ?? this.ext,
    );
  }

  @override
  String get filename => "$name.$ext";
}

/// macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png
class MacOSIcon extends IconTemplate {
  const MacOSIcon({
    @required int size,
    this.prefix = 'app_icon_',
    this.ext = 'png',
    this.scale = 1,
    this.name = '16',
  }) : super(size);
  final String prefix;
  final int scale;
  final String ext;
  final String name;

  MacOSIcon copyWith({
    String name,
    int size,
    String prefix,
    int scale,
    String ext,
    bool point5,
  }) {
    return MacOSIcon(
      size: size ?? this.size,
      prefix: prefix ?? this.prefix,
      scale: scale ?? this.scale,
      ext: ext ?? this.ext,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "size": "$size" + "x" + "$size",
      "idiom": "mac",
      "filename": "$prefix$name.$ext",
      "scale": "${scale}x"
    };
  }

  @override
  String get filename => "$prefix$name.$ext";
}
