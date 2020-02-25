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
    String filename = icon.filename;
    final data = encodeNamedImage(resizedIcon, filename);
    return FileData(
        data,
        data.length,
        filename,
        p.joinAll([
          path,
          if (icon is AndroidIcon) ...[
            icon.folder + '-' + icon.folderSuffix,
          ],
          filename
        ]));
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
    final _output = OutputStream();
    encoder.startEncode(_output);
    // final archive = Archive();
    for (var f in images) {
      final archiveFile = ArchiveFile(f.path, f.size, f.data);
      encoder.addFile(archiveFile);
    }
    encoder.endEncode();

    return _output.getBytes();
  }
}

Image createResizedImage(IconTemplate template, Image image) {
  Interpolation _interpolation;
  if (image.width >= template.size) {
    _interpolation = Interpolation.average;
  } else {
    _interpolation = Interpolation.linear;
  }
  if (template is IosIcon) {
    return copyResize(
      image,
      width: (template.adjustedSize * template.scale).round(),
      height: (template.adjustedSize * template.scale).round(),
      interpolation: _interpolation,
    );
  }
  if (template is MacOSIcon) {
    return copyResize(
      image,
      width: template.size * template.scale,
      height: template.size * template.scale,
      interpolation: _interpolation,
    );
  }
  return copyResize(
    image,
    width: template.size,
    height: template.size,
    interpolation: _interpolation,
  );
}

class FileData {
  final List<int> data;
  final int size;
  final String name;
  final String path;
  FileData(this.data, this.size, this.name, this.path);
}
