import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:image_resizer/image_resizer.dart';
import 'package:universal_html/html.dart' as html;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Icon Resizer',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        accentColor: Colors.red,
      ),
      darkTheme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<FileData>> _files;
  List<int> _imageData;
  bool _loading = false;
  @override
  void initState() {
    rootBundle.load("web/icons/Icon-512.png").then((bytes) async {
      _imageData = bytes.buffer.asUint8List();
      _refresh();
    });
    super.initState();
  }

  bool _isEditing = true;

  bool _exportIos = true;
  bool _exportWeb = true;
  bool _exportMacos = true;
  bool _exportAndroid = true;
  bool _exportFavicon = true;

  String _iosPath = "ios/Runner/Assets.xcassets/AppIcon.appiconset";
  String _webPath = "web/icons";
  String _macOSPath = "macos/Runner/Assets.xcassets/AppIcon.appiconset";
  String _androidPath = "example/android/app/src/main/res";

  List<IosIcon> _iosIcons = [
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

  List<WebIcon> _webIcons = [
    WebIcon(size: 192),
    WebIcon(size: 512),
  ];

  List<MacOSIcon> _macIcons = [
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

  List<AndroidIcon> _androidIcons = [
    AndroidIcon(size: 72, folderPrefix: "hdpi"),
    AndroidIcon(size: 48, folderPrefix: "mdpi"),
    AndroidIcon(size: 96, folderPrefix: "xhdpi"),
    AndroidIcon(size: 144, folderPrefix: "xxhdpi"),
    AndroidIcon(size: 192, folderPrefix: "xxxhdpi"),
  ];

  WebFavicon _webFavicon = WebFavicon();

  Future _refresh() async {
    _files = {};
    _setLoading(true);
    await _generateIcons(
      'iOS Icons',
      IosIconsFolder(
        icons: _iosIcons,
        path: _iosPath,
      ),
    );
    await _generateIcons(
      'Web Icons',
      WebIconsFolder(
        icons: _webIcons,
        favicion: _webFavicon,
        path: _webPath,
      ),
    );
    await _generateIcons(
      'MacOS Icons',
      MacOSIconsFolder(
        icons: _macIcons,
        path: _macOSPath,
      ),
    );
    await _generateIcons(
      'Android Icons',
      AndroidIconsFolder(
        icons: _androidIcons,
        path: _androidPath,
      ),
    );
    _isEditing = false;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    if (mounted)
      setState(() {
        _loading = value;
      });
  }

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
    print("Images: ${_images.length}");
    final _data = _gen.generateArchive(_images);
    await saveFile('images.zip', binaryData: _data);
  }

  Future<bool> saveFile(
    String fileName, {
    String initialDirectoryDesktop,
    List<int> binaryData,
    bool silentErrors = false,
  }) async {
    if (kIsWeb) {
      Uri dataUrl;
      try {
        if (binaryData != null) {
          dataUrl = Uri.dataFromBytes(binaryData);
        }
      } catch (e) {
        if (!silentErrors) {
          throw Exception("Error Creating File Data: $e");
        }
        return false;
      }
      final _element = html.AnchorElement()
        ..href = dataUrl.toString()
        ..setAttribute("download", fileName);
      _element.click();
      return true;
    }
    final _file = File(fileName)..createSync();
    _file.writeAsBytesSync(binaryData);
    return true;
  }

  Future _upload() async {
    _setLoading(true);
    final _upload = html.FileUploadInputElement();
    _upload.accept = 'image/*';
    _upload.click();
    final _file = await _upload.onChange.first;
    if (_file != null) {
      List<html.File> files = (_file.target as dynamic).files;
      final f = files.first;
      final reader = new html.FileReader();
      reader.readAsArrayBuffer(f);
      await reader.onLoadEnd.first;
      _imageData = reader.result as List<int>;
      _refresh();
    }
    _setLoading(false);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Resizer'),
        actions: <Widget>[
          if (kIsWeb) ...[
            IconButton(
              icon: Icon(Icons.file_upload),
              onPressed: _loading ? null : _upload,
            ),
          ],
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: _archive,
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              if (mounted)
                setState(() {
                  if (_isEditing) {
                    _isEditing = false;
                    _refresh();
                  } else {
                    _isEditing = true;
                  }
                });
            },
          ),
        ],
      ),
      body: _isEditing ? _buildEditingView() : _buildFilePreview(),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Generate Icons',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEditingView() {
    return Container();
  }

  Widget _buildFilePreview() {
    if (_files != null) {
      return Center(child: CircularProgressIndicator());
    }
    return ListView.separated(
      separatorBuilder: (context, index) => Container(
        height: 1.0,
        color: Colors.grey,
      ),
      itemCount: _files.keys.length,
      itemBuilder: (context, index) {
        final _key = _files.keys.toList()[index];
        final _folder = _files[_key];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                _key,
                style: Theme.of(context).textTheme.headline4,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: _folder.map((file) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            height: 200.0,
                            width: 200.0,
                            child: Card(
                              child: Image.memory(
                                Uint8List.fromList(file.data),
                              ),
                            ),
                          ),
                          Text(file.name),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
