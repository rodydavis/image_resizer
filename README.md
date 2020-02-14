[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/rodydavis)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WSH3GVC49GNNJ)
[![pub package](https://img.shields.io/badge/pub-1.1.0-blueviolet.svg)](https://pub.dev/packages/image_resizer)

# image_resizer

Dart image resizer library for flutter. 

It can write to the correct folder locations, create an archive and work across web and io.

Online Demo: https://rodydavis.github.io/image_resizer/

#### Included Folders:

- IosIconsFolder
- WebIconsFolder
- MacOSIconsFolder
- AndroidIconsFolder

This package is also mean to resize images at runtime too, or used for CLI purposes.

## Getting Started

```dart
await _generateIcons('iOS Icons', IosIconsFolder());
await _generateIcons('Web Icons', WebIconsFolder());
await _generateIcons('MacOS Icons', MacOSIconsFolder());
await _generateIcons('Android Icons', AndroidIconsFolder());

Future _generateIcons(String key, ImageFolder folder) async {
    final _image = image.decodePng(_imageData);
    final _gen = IconGenerator();
    final _archive =
        await _gen.generateIcons(_image, folder, writeToDiskIO: false);
    if (mounted)
        setState(() {
        _files[key] = _archive;
        });
}

Future _archive() async {
    final _gen = IconGenerator();
    List<FileData> _images = [];
    for (var key in _files.keys) {
        final _folder = _files[key];
        _images.addAll(_folder.toList());
    }
    final _data = _gen.generateArchive(_images);
    await saveFile('images.zip', binaryData: _data);
}
```
