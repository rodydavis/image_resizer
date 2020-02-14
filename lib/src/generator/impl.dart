import 'package:archive/archive.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as p;
import 'package:image_resizer/src/folders.dart';
import 'package:image_resizer/src/template.dart';

export 'package:image_resizer/src/folders.dart';
export 'package:image_resizer/src/template.dart';

abstract class IconGeneratorImpl {
  Future<FileData> generateIcon(Image image, IconTemplate icon,
      {String path = '', bool writeToDiskIO = true}) async {
    final Image resizedIcon = createResizedImage(icon, image);
    final filename = icon.filename;
    final data = encodeNamedImage(resizedIcon, filename);
    return FileData(data, data.length, filename);
  }

  Future<List<FileData>> generateIcons(Image image, ImageFolder folder,
      {String path = '', bool writeToDiskIO = true}) async {
    final List<FileData> _images = [];
    for (var template in folder.templates) {
      final _icon = await generateIcon(
        image,
        template,
        path: p.joinAll([if (path.isNotEmpty) path, folder.path]),
        writeToDiskIO: writeToDiskIO,
      );
      _images.add(_icon);
    }

    return _images;
  }

  List<int> generateArchive(List<FileData> images) {
    var encoder = ZipEncoder();
    final archive = Archive();

    for (var f in images) {
      final archiveFile = ArchiveFile(f.name, f.size, f.data);
      encoder.addFile(archiveFile);
    }
    return encoder.encode(archive);
  }
}

Image createResizedImage(IconTemplate template, Image image) {
  if (image.width >= template.size) {
    return copyResize(image,
        width: template.size,
        height: template.size,
        interpolation: Interpolation.average);
  } else {
    return copyResize(image,
        width: template.size,
        height: template.size,
        interpolation: Interpolation.linear);
  }
}

class FileData {
  final List<int> data;
  final int size;
  final String name;
  FileData(this.data, this.size, this.name);
}
