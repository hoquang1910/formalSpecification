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
  List<TextEditingController>? _nControllers = [];
  String _jsResult = '';
  String a = "";
  String function = "";
  int valueLength = 0;
  List valueList = [];
  List valueVariableFormal = [];
  List kindValueVariableFormal = [];
  bool? temp;
  String error = "0";
  String? catchError;
  int? type;
  String? vari;
  bool codeJsVisibility = false;

  final JavascriptRuntime javascriptRuntime = getJavascriptRuntime();
  String textJs = "function ";
  String? kind;
  String? text;
  String? textFormal;
  String? _quickjsVersion;
  Process? _process;
  bool _processInitialized = false;
  //function help debug js code
  Future<String> evalJS(List valueList) async {
    final jsResult;
    if (type != 2) {
      jsResult = temp!
          ? await javascriptRuntime
              .evaluate(textJs +
                  """$function(${countValue(valueList)})
            """)
              .stringResult
          : await javascriptRuntime
              .evaluate(textJs +
                  """$function(${countValue(valueList)})
            """)
              .stringResult;
      debugPrint(textJs +
          """$function(${countValue(valueList)})
            """);
    } else {
      jsResult = temp!
          ? await javascriptRuntime
              .evaluate(textJs +
                  """${countVar(vari, valueList)}""" +
                  """$function(${countValue(valueList)})
            """)
              .stringResult
          : await javascriptRuntime
              .evaluate(textJs +
                  """${countVar(vari, valueList)}""" +
                  """$function(${countValue(valueList)})
            """)
              .stringResult;
      debugPrint(textJs +
          "\n" +
          """${countVar(vari, valueList)}""" +
          "\n" +
          """$function(${countValue(valueList)})
            """);
    }

    return jsResult;
  }

  //input array in type 2
  String countVar(String? value, List valueList) {
    value = value! + " = [";
    for (int i = 0; i < int.parse(_nControllers![0].text.toString()); i++) {
      if (i < int.parse(_nControllers![0].text.toString()) - 1) {
        value = value! + "${valueList[i]},";
      } else {
        value = value! + "${valueList[i]}];";
      }
    }
    return value!;
  }

  //input value in function
  String countValue(List valueList) {
    String valueInput = "";
    if (type != 2) {
      for (int i = 0; i < valueLength; i++) {
        if (i < valueLength - 1) {
          valueInput = valueInput + "${valueList[i]},";
        } else {
          valueInput = valueInput + "${valueList[i]}";
        }
      }
    } else {
      valueInput = valueInput + vari! + "," + _nControllers![0].text.toString();
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
    _nControllers!.add(TextEditingController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              textJs = "function ";
              kind = null;
              text = null;
              textFormal = null;
              _controllers = [];
              _nControllers = [];
              _jsResult = '';
              a = "";
              function = "";
              valueLength = 0;
              valueList = [];
              valueVariableFormal = [];
              kindValueVariableFormal = [];
              temp = null;
              final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom, allowedExtensions: ['txt', 'doc']);
              if (result == null) return;

              //open single file
              final file = result.files.first;
              final formalFile = await saveFilePermanently(file);
              await readFile(formalFile).then((value) {
                if (value != "") {
                  textFormal = value;
                }
              });
              //divide into 3 part
              if (textFormal != null) {
                final subText = textFormal!.split('\n');
                if (subText.length > 3) {
                  for (int i = 3; i < subText.length; i++) {
                    subText[i] = subText[i].replaceAll(" ", "");
                    subText[i] = subText[i].replaceAll("\r", "");
                    subText[i] = subText[i].replaceAll("\t", "");
                    subText[2] = subText[2] + subText[i];
                  }
                }
                //Make Funtion
                final functionText = subText[0].split('(');
                //function name = function text [0]
                final variablesText = functionText[1].split(')');
                final resultText = variablesText[1].split(":");
                //kind of result resultText[1]
                String tempExText = resultText[1].replaceAll(" ", "");
                tempExText = tempExText.replaceAll("\n", "");
                tempExText = tempExText.replaceAll("\r", "");
                tempExText = tempExText.replaceAll("\t", "");
                if (tempExText == "B") {
                  temp = false;
                } else {
                  temp = true;
                }
                //variable of result is resultText[0]
                final variableText = variablesText[0].split(",");
                //variableText.lenghth is total variable
                for (int i = 0; i < variableText.length; i++) {
                  final valueVariable = variableText[i].split(':');
                  //valueVariable[0] is variable
                  valueVariableFormal.add(valueVariable[0]);
                  //valueVariable[1] is kind
                  kindValueVariableFormal.add(valueVariable[1]);
                }

                final tempText = functionText[0] + '(';
                textJs = textJs + tempText.replaceAll(" ", "");
                vari = valueVariableFormal[0];
                for (int i = 0; i < valueVariableFormal.length; i++) {
                  if (i < valueVariableFormal.length - 1) {
                    final tempText1 = "${valueVariableFormal[i]},";
                    textJs = textJs + tempText1.replaceAll(" ", "");
                  } else {
                    final tempText1 = "${valueVariableFormal[i]}";
                    textJs = textJs + tempText1.replaceAll(" ", "");
                  }
                }
                textJs = textJs + ') {\n';
                //
                //Pre condition
                subText[1] = subText[1].substring(4);
                subText[1] = subText[1].replaceAll("\n", "");
                subText[1] = subText[1].replaceAll("\r", "");
                subText[1] = subText[1].replaceAll("\t", "");
                subText[1] = subText[1].replaceAll("(", "");
                subText[1] = subText[1].replaceAll(")", "");
                catchError = subText[1];
                if (subText[1].length > 0) {
                  type = 1;
                  textJs = textJs + "if(${subText[1]}){\n";
                  //Post value
                  subText[2] = subText[2].substring(5);
                  subText[2] = subText[2].replaceAll("\n", "");
                  subText[2] = subText[2].replaceAll(" ", "");
                  subText[2] = subText[2].replaceAll("\t", "");
                  subText[2] = subText[2].replaceAll("\r", "");
                  //calculate function have many cases
                  if (subText[2].contains("||")) {
                    final ifElseValue = subText[2].split('||');
                    for (int i = 0; i < ifElseValue.length; i++) {
                      if (i != ifElseValue.length - 1) {
                        //Make main function in post
                        textJs = textJs + "if(";
                        if (ifElseValue[i].contains("&&")) {
                          textJs = textJs +
                              ifElseValue[i]
                                  .substring(ifElseValue[i].indexOf("&&") + 2,
                                      ifElseValue[i].length - 1)
                                  .replaceAll("=", "==")
                                  .replaceAll("!==", "!=")
                                  .replaceAll(">==", ">=")
                                  .replaceAll("==<", "=<");
                        }
                        //calculate the result
                        final value = ifElseValue[i].substring(
                            ifElseValue[i].indexOf("=") + 1,
                            ifElseValue[i].indexOf(")"));
                        textJs = textJs +
                            "){\n\t\treturn ${value.toLowerCase()};\n}\n";
                      } else {
                        //Make main function in post
                        textJs = textJs + "if(";
                        if (ifElseValue[i].contains("&&")) {
                          textJs = textJs +
                              ifElseValue[i]
                                  .substring(ifElseValue[i].indexOf("&&") + 2,
                                      ifElseValue[i].length - 1)
                                  .replaceAll("=", "==")
                                  .replaceAll("!==", "!=");
                        }
                        //calculate the result
                        final value = ifElseValue[i].substring(
                            ifElseValue[i].indexOf("=") + 1,
                            ifElseValue[i].indexOf(")"));
                        textJs = textJs +
                            "){\n\t\treturn ${value.toLowerCase()};\n}\n}";
                      }
                    }
                  }
                  //calculate the result which only have one case
                  else {
                    final value = subText[2].substring(
                        subText[2].indexOf("=") + 1, subText[2].indexOf(")"));
                    textJs = textJs + "return ${value.toLowerCase()};\n}";
                  }
                  textJs = textJs + "\nelse{\n return $error;\n}\n}";
                }
                //calculate which not have pre condition
                else {
                  subText[2] = subText[2].substring(5);
                  subText[2] = subText[2].replaceAll("\n", "");
                  subText[2] = subText[2].replaceAll(" ", "");
                  subText[2] = subText[2].replaceAll("\t", "");
                  subText[2] = subText[2].replaceAll("\r", "");
                  debugPrint(subText[2]);
                  //check the type of it
                  //type 2
                  if (subText[2].contains("VM") || subText[2].contains("TT")) {
                    type = 2;
                    int count = 1;
                    String tempCount =
                        subText[2].substring(subText[2].indexOf("}."));
                    //count the number of case
                    if (tempCount.contains("VM") || tempCount.contains("TT")) {
                      count++;
                      tempCount = tempCount.substring(tempCount.indexOf("}."));
                    }
                    tempCount = subText[2];
                    //make loop for each case
                    for (int i = 1; i <= count; i++) {
                      String variable = tempCount.contains("VM")
                          ? tempCount.substring(tempCount.indexOf("VM") + 2,
                              tempCount.indexOf("VM") + 3)
                          : tempCount.substring(tempCount.indexOf("TT") + 2,
                              tempCount.indexOf("TT") + 3);
                      String iValue = tempCount.substring(
                          tempCount.indexOf("{") + 1, tempCount.indexOf(".."));
                      if (i == 1) {
                        iValue = (int.parse(iValue) - 1).toString();
                      }
                      String nValue = tempCount.substring(
                          tempCount.indexOf("..") + 2, tempCount.indexOf("}"));
                      textJs = textJs +
                          "\tfor(let $variable = $iValue; $variable < $nValue ; $variable++){\n";
                      tempCount =
                          tempCount.substring(tempCount.indexOf("}.") + 2);
                    }
                    //return result
                    tempCount = tempCount.substring(0, tempCount.length - 1);
                    tempCount = tempCount.replaceAll("(", "[");
                    tempCount = tempCount.replaceAll(")", "]");
                    //calculate result for TT case
                    if (subText[2].contains("TT")) {
                      textJs = textJs +
                          "if(($tempCount)){\n\t\t\treturn true;\n\t\t\tbreak;\n}\n";
                      for (int i = 1; i <= count; i++) {
                        textJs = textJs + "}\n";
                      }
                      textJs = textJs + "\t\t\treturn false;\n}";
                    }
                    //calculate result for TT case
                    else {
                      textJs = textJs +
                          "if(!($tempCount)){\n\t\treturn false;\n\t\tbreak;\n}\n";
                      for (int i = 1; i <= count; i++) {
                        textJs = textJs + "}\n";
                      }
                      textJs = textJs + "\treturn true;\n};";
                    }
                  }
                  //type 1
                  else {
                    type = 1;
                    //calculate function have many cases
                    if (subText[2].contains("||")) {
                      final ifElseValue = subText[2].split('||');
                      for (int i = 0; i < ifElseValue.length; i++) {
                        if (i != ifElseValue.length - 1) {
                          //make main function
                          textJs = textJs + "if(";
                          if (ifElseValue[i].contains("&&")) {
                            textJs = textJs +
                                ifElseValue[i]
                                    .substring(ifElseValue[i].indexOf("&&") + 2,
                                        ifElseValue[i].length - 1)
                                    .replaceAll("=", "==")
                                    .replaceAll("!==", "!=")
                                    .replaceAll(">==", ">=")
                                    .replaceAll("==<", "=<");
                          }
                          //calculate result
                          final value = ifElseValue[i].substring(
                              ifElseValue[i].indexOf("=") + 1,
                              ifElseValue[i].indexOf(")"));
                          textJs = textJs +
                              "){\n\t\treturn ${value.toLowerCase()};\n}\n";
                        } else {
                          textJs = textJs + "if(";
                          if (ifElseValue[i].contains("&&")) {
                            textJs = textJs +
                                ifElseValue[i]
                                    .substring(ifElseValue[i].indexOf("&&") + 2,
                                        ifElseValue[i].length - 1)
                                    .replaceAll("=", "==")
                                    .replaceAll("!==", "!=");
                          }
                          final value = ifElseValue[i].substring(
                              ifElseValue[i].indexOf("=") + 1,
                              ifElseValue[i].indexOf(")"));
                          textJs = textJs +
                              "){\n\t\treturn ${value.toLowerCase()};\n}\n}";
                        }
                      }
                    }
                    //calculate function have only one case
                    else {
                      final value = subText[2].substring(
                          subText[2].indexOf("=") + 1, subText[2].indexOf(")"));
                      textJs = textJs + "return ${value.toLowerCase()};\n}";
                    }
                  }
                }
              }
              //Make right funtion
              if (textJs != null) {
                final subText = textJs.split('{');
                final subText2 = subText[0].replaceAll('function ', "");
                final subText3 = subText2.replaceAll(' ', "");
                final subText4 = subText3.split('(');
                function = subText4[0].toString();
                subText4[1] = subText4[1].replaceAll('(', "");
                final subText5 = subText4[1].replaceAll(')', "");
                final subText6 = subText5.split(',');
                valueLength = subText6.length;
              }
              setState(() {});
            },
            icon: Icon(Icons.file_copy)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              children: [
                //show the input test case
                textFormal != null
                    ? Container(
                        child:
                            Text('$textFormal', style: TextStyle(fontSize: 20)),
                      )
                    : Container(),
                SizedBox(
                  height: 30,
                ),
                //generate code
                textFormal != null
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            codeJsVisibility = !codeJsVisibility;
                          });
                        },
                        icon: Icon(Icons.arrow_downward))
                    : Container(),
                //show js code
                Visibility(
                  visible: codeJsVisibility,
                  child: Container(
                    child: Text(
                      '$textJs',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Visibility(
                  visible: codeJsVisibility,
                  child: Expanded(
                    child: type != 2
                        //type 1 input
                        ? ListView.builder(
                            itemCount: valueLength,
                            itemBuilder: (context, index) {
                              _controllers!.add(TextEditingController());
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 100,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: TextFormField(
                                  controller: _controllers![index],
                                  decoration: InputDecoration(
                                      hintText: valueVariableFormal[index]),
                                ),
                              );
                            },
                          )
                        //type 2 input
                        : Column(
                            children: [
                              //show input number of element
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, top: 8, bottom: 8),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          hintText: valueVariableFormal[1]),
                                      controller: _nControllers![0],
                                      onChanged: (value) {
                                        setState(() {
                                          debugPrint(_nControllers![0]
                                              .text
                                              .toString());
                                          _controllers = [];
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              //show array input field
                              _nControllers![0].text != ""
                                  ? Expanded(
                                      child: ListView.builder(
                                        itemCount: int.parse(
                                            _nControllers![0].text.toString()),
                                        itemBuilder: (context, index) {
                                          _controllers!
                                              .add(TextEditingController());
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              margin: EdgeInsets.all(8),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15,
                                                    top: 8,
                                                    bottom: 8),
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          valueVariableFormal[
                                                                  0] +
                                                              "$index"),
                                                  controller:
                                                      _controllers![index],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                //show the result
                textJs != null
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
                          //call function to calculate the result
                          _nControllers![0].text != ""
                              ? IconButton(
                                  onPressed: () async {
                                    valueList = [];
                                    for (int i = 0;
                                        i < _controllers!.length;
                                        i++) {
                                      valueList.add(_controllers![i].text);
                                    }
                                    try {
                                      final result = await evalJS(valueList);
                                      if (result == error) {
                                        _controllers = [];
                                        valueList = [];
                                        notifiDialog();
                                      } else {
                                        a = result;
                                      }
                                    } on PlatformException catch (e) {
                                      debugPrint(e.details);
                                    }
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.change_circle))
                              : Container()
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
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

  Future<File> writeFile(File file, String textValue) async {
    return file.writeAsString(textValue);
  }

  Future notifiDialog() => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: Text("Please input again"),
            content: Text("The value must be $catchError"),
          )));
}
