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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, List<FileData>> _files;

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  Future _refresh() async {
    _files = {};
    await _generateIcons('iOS Icons', IosIconsFolder());
    await _generateIcons('Web Icons', WebIconsFolder());
    await _generateIcons('MacOS Icons', MacOSIconsFolder());
    await _generateIcons('Android Icons', AndroidIconsFolder());
  }

  Future _generateIcons(String key, ImageFolder folder) async {
    rootBundle.load("web/icons/Icon-512.png").then((bytes) async {
      final _image = image.decodePng(bytes.buffer.asUint8List());
      final _gen = IconGenerator();
      final _archive =
          await _gen.generateIcons(_image, folder, writeToDiskIO: false);
      if (mounted)
        setState(() {
          _files[key] = _archive;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: () => _archive(),
          ),
        ],
      ),
      body: _files != null
          ? ListView.builder(
              itemCount: _files.keys.length,
              itemBuilder: (context, index) {
                final _key = _files.keys.toList()[index];
                final _folder = _files[_key];
                return Column(
                  children: <Widget>[
                    Text(_key),
                    Wrap(
                      children: _folder.map((file) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                height: 200.0,
                                width: 200.0,
                                child: Image.memory(
                                  Uint8List.fromList(file.data),
                                ),
                              ),
                              Text(file.name),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Generate Icons',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
