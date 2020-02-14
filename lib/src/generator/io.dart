import 'dart:convert';

import 'package:image/image.dart';

import 'impl.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class IconGenerator extends IconGeneratorImpl {
  @override
  Future<List<FileData>> generateIcons(Image image, ImageFolder folder,
      {String path = '', bool writeToDiskIO = true}) async {
    final List<FileData> _images = [];
    final _folderPath = p.joinAll([if (path.isNotEmpty) path, folder.path]);
    for (var template in folder.templates) {
      final _icon = await generateIcon(
        image,
        template,
        path: _folderPath,
        writeToDiskIO: writeToDiskIO,
      );
      _images.add(_icon);
    }
    if (writeToDiskIO) {
      if (folder is IosIconsFolder) {
        final _file = File(p.join(_folderPath, 'Contents.json'));
        if (!_file.existsSync()) {
          await _file.create(recursive: true);
        }
        await _file.writeAsString(json.encode(folder.toJson()));
      }
      if (folder is MacOSIconsFolder) {
        final _file = File(p.join(_folderPath, 'Contents.json'));
        if (!_file.existsSync()) {
          await _file.create(recursive: true);
        }
        await _file.writeAsString(json.encode(folder.toJson()));
      }
    }
    return _images;
  }

  @override
  Future<FileData> generateIcon(Image image, IconTemplate icon,
      {String path = '', bool writeToDiskIO = true}) async {
    if (path == '') {
      path = Directory.current.path;
    }
    final _file = File(p.join(path, icon.filename));
    if (writeToDiskIO && !_file.existsSync()) {
      await _file.createSync(recursive: true);
    }
    final Image resizedIcon = createResizedImage(icon, image);
    final filename = icon.filename;
    final data = encodeNamedImage(resizedIcon, filename);
    if (writeToDiskIO) {
      await _file.writeAsBytes(data);
    }
    return FileData(data, data.length, filename);
  }
}
