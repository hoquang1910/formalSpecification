import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_js/javascript_runtime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class Calculate extends StatefulWidget {
  const Calculate({Key? key}) : super(key: key);

  @override
  State<Calculate> createState() => _CalculateState();
}

class _CalculateState extends State<Calculate> {
  List<TextEditingController>? _controllers = [];
  String _jsResult = '';
  String a = "";
  String function = "";
  int valueLength = 0;
  List valueList = [];

  final JavascriptRuntime javascriptRuntime = getJavascriptRuntime();
  String? text;
  String? _quickjsVersion;
  Process? _process;
  bool _processInitialized = false;
  Future<String> evalJS(List valueList) async {
    String jsResult = javascriptRuntime
        .evaluate(text! +
            """$function(${countValue(valueList)})
            """)
        .stringResult;

    return jsResult;
  }

  String countValue(List valueList) {
    String valueInput = "";
    for (int i = 0; i < valueLength; i++) {
      if (i < valueLength - 1) {
        valueInput = valueInput + "${valueList[i]},";
      } else {
        valueInput = valueInput + "${valueList[i]}";
      }
    }
    return valueInput;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom, allowedExtensions: ['txt', 'doc']);
              if (result == null) return;

              //open single file
              final file = result.files.first;
              final newFile = await saveFilePermanently(file);
              await readFile(newFile).then((value) {
                if (value != "") {
                  text = value;
                }
              });
              if (text != null) {
                final subText = text!.split('{');
                final subText2 = subText[0].split('function ');
                final subText3 = subText2[1].split(' ');
                final subText4 = subText3[0].split('(');
                function = subText4[0].toString();

                final subText5 = subText4[1].split(')');
                final subText6 = subText5[0].split(',');
                valueLength = subText6.length;
              }
              setState(() {});
            },
            icon: Icon(Icons.file_copy)),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          text != null
              ? Container(
                  child: Text('$text'),
                )
              : Container(),
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: valueLength,
              itemBuilder: (context, index) {
                _controllers!.add(TextEditingController());
                return TextFormField(
                  controller: _controllers![index],
                );
              },
            ),
          ),
          SizedBox(
            height: 30,
          ),
          text != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Text(
                        '$a',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                        onPressed: () async {
                          valueList = [];
                          for (int i = 0; i < _controllers!.length; i++) {
                            valueList.add(_controllers![i].text);
                          }
                          try {
                            final result = await evalJS(valueList);
                            a = result;
                          } on PlatformException catch (e) {
                            debugPrint(e.details);
                          }
                          setState(() {});
                        },
                        icon: Icon(Icons.change_circle))
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    final directory = await getApplicationDocumentsDirectory();
    final newFile = File('${directory.path}/${file.name}');
    return File(file.path!).copy(newFile.path);
  }

  Future<String> readFile(File file) async {
    try {
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "";
    }
  }
}
