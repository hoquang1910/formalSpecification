import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:fomal_specification/pages/widgets/input_field.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../config/theme_provider.dart';
import '../implicit_structure/implicit_structure.dart';

class OutputScreen extends StatefulWidget {
  final int type;
  final bool codeJsVisibility;
  final String? inputText;
  const OutputScreen({
    Key? key,
    required this.type,
    required this.codeJsVisibility,
    this.inputText,
  }) : super(key: key);

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  List<TextEditingController>? _controllers = [];
  final List<TextEditingController> _nControllers = [];
  String vari = "";
  String function = "";
  List valueList = [];
  String error = "null";
  String? catchError;
  String a = "";
  String textJs = "function ";
  final JavascriptRuntime javascriptRuntime = getJavascriptRuntime();

  //run js function
  Future<String> evalJS(List valueList) async {
    function = "";
    functionJS();
    int index = 0;
    ImplicitStructure implicitStructure =
        ImplicitStructure(text: widget.inputText);
    Map<String, String> resultStrings =
        implicitStructure.getArgumentsAndDataType();
    function = function + implicitStructure.getFunctionName().toString();
    resultStrings.forEach((key, value) {
      debugPrint(key);
      if (index == 0) {
        vari = key;
      }
      index++;
    });
    final String jsResult;
    if (widget.type != 2) {
      jsResult = javascriptRuntime.evaluate(
          """$textJs$function(${countValue(valueList)})""").stringResult;
    } else {
      jsResult = javascriptRuntime.evaluate(
          """$textJs${countVar(vari, valueList)}$function(${countValue(valueList)})""").stringResult;
    }
    return jsResult;
  }

  //input array in type 2
  String countVar(String? value, List valueList) {
    value = "${value!} = [";
    for (int i = 0; i < int.parse(_nControllers[0].text.toString()); i++) {
      if (i < int.parse(_nControllers[0].text.toString()) - 1) {
        value = "${value!}${valueList[i]},";
      } else {
        value = "${value!}${valueList[i]}];";
      }
    }
    debugPrint(value);
    return value!;
  }

  //input value in function
  String countValue(List valueList) {
    ImplicitStructure implicitStructure =
        ImplicitStructure(text: widget.inputText);
    Map<String, String> resultStrings =
        implicitStructure.getArgumentsAndDataType();
    String valueInput = "";
    if (widget.type != 2) {
      for (int i = 0; i < resultStrings.length; i++) {
        if (i < resultStrings.length - 1) {
          valueInput = "$valueInput${valueList[i]},";
        } else {
          valueInput = "$valueInput${valueList[i]}";
        }
      }
    } else {
      valueInput = "$valueInput$vari,${_nControllers[0].text}";
    }
    return valueInput;
  }

  //calculate result
  Future calculateResult() async {
    valueList = [];
    for (int i = 0; i < _controllers!.length; i++) {
      valueList.add(_controllers![i].text);
    }
    try {
      final result = await evalJS(valueList);
      if (result == error) {
        _controllers = [];
        valueList = [];
        notifiErrorDialog();
      } else {
        a = result;
        notifiDialog();
      }
    } on PlatformException catch (e) {
      debugPrint(e.details);
    }
    setState(() {});
  }

  //change formal to js
  String functionJS() {
    String? textFormal = widget.inputText;
    textJs = "function ";
    a = "";
    function = "";
    valueList = [];
    List valueVariableFormal = [];
    List kindValueVariableFormal = [];
    if (textFormal != null) {
      final subText = textFormal.split('\n');
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

      final tempText = '${functionText[0]}(';
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
      textJs = '$textJs) {\n';
      //
      //Pre condition
      subText[1] = subText[1].substring(3);
      subText[1] = subText[1].replaceAll("\n", "");
      subText[1] = subText[1].replaceAll("\r", "");
      subText[1] = subText[1].replaceAll("\t", "");
      subText[1] = subText[1].replaceAll("(", "");
      subText[1] = subText[1].replaceAll(")", "");
      catchError = subText[1];
      if (subText[1].isNotEmpty) {
        textJs = "${textJs}if(${subText[1]}){\n";
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
              textJs = "${textJs}if(";
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
                  ifElseValue[i].indexOf("=") + 1, ifElseValue[i].indexOf(")"));
              textJs = "$textJs){\n\t\treturn ${value.toLowerCase()};\n}\n";
            } else {
              //Make main function in post
              textJs = "${textJs}if(";
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
                  ifElseValue[i].indexOf("=") + 1, ifElseValue[i].indexOf(")"));
              textJs = "$textJs){\n\t\treturn ${value.toLowerCase()};\n}\n}";
            }
          }
        }
        //calculate the result which only have one case
        else {
          final value = subText[2]
              .substring(subText[2].indexOf("=") + 1, subText[2].indexOf(")"));
          textJs = "${textJs}return ${value.toLowerCase()};\n}";
        }
        textJs = "$textJs\nelse{\n return $error;\n}\n}";
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
          int count = 1;
          String tempCount = subText[2].substring(subText[2].indexOf("}."));
          //count the number of case
          if (tempCount.contains("VM") || tempCount.contains("TT")) {
            count++;
            tempCount = tempCount.substring(tempCount.indexOf("}."));
          }
          tempCount = subText[2];
          //make loop for each case
          for (int i = 1; i <= count; i++) {
            String variable = tempCount.contains("VM")
                ? tempCount.substring(
                    tempCount.indexOf("VM") + 2, tempCount.indexOf("VM") + 3)
                : tempCount.substring(
                    tempCount.indexOf("TT") + 2, tempCount.indexOf("TT") + 3);
            String iValue = tempCount.substring(
                tempCount.indexOf("{") + 1, tempCount.indexOf(".."));
            if (i == 1) {
              iValue = (int.parse(iValue) - 1).toString();
            }
            String nValue = tempCount.substring(
                tempCount.indexOf("..") + 2, tempCount.indexOf("}"));
            textJs =
                "$textJs\tfor(let $variable = $iValue; $variable < $nValue ; $variable++){\n";
            tempCount = tempCount.substring(tempCount.indexOf("}.") + 2);
          }
          //return result
          tempCount = tempCount.substring(0, tempCount.length - 1);
          tempCount = tempCount.replaceAll("(", "[");
          tempCount = tempCount.replaceAll(")", "]");

          //calculate result for TT case
          if (subText[2].contains("TT")) {
            textJs =
                "${textJs}if(($tempCount)){\n\t\t\treturn true;\n\t\t\tbreak;\n}\n";
            for (int i = 1; i <= count; i++) {
              textJs = "$textJs}\n";
            }
            textJs = "$textJs\t\t\treturn false;\n}";
          }
          //calculate result for TT case
          else {
            textJs =
                "${textJs}if(!($tempCount)){\n\t\treturn false;\n\t\tbreak;\n}\n";
            for (int i = 1; i <= count; i++) {
              textJs = "$textJs}\n";
            }
            textJs = "$textJs\treturn true;\n};";
          }
        }
        //type 1
        else {
          //calculate function have many cases
          if (subText[2].contains("||")) {
            final ifElseValue = subText[2].split('||');
            for (int i = 0; i < ifElseValue.length; i++) {
              if (i != ifElseValue.length - 1) {
                //make main function
                textJs = "${textJs}if(";
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
                textJs = "$textJs){\n\t\treturn ${value.toLowerCase()};\n}\n";
              } else {
                textJs = "${textJs}if(";
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
                textJs = "$textJs){\n\t\treturn ${value.toLowerCase()};\n}\n}";
              }
            }
          }
          //calculate function have only one case
          else {
            final value = subText[2].substring(
                subText[2].indexOf("=") + 1, subText[2].indexOf(")"));
            textJs = "${textJs}return ${value.toLowerCase()};\n}";
          }
        }
      }
    }
    return textJs;
  }

  @override
  Widget build(BuildContext context) {
    _nControllers.add(TextEditingController());
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    ImplicitStructure implicitStructure =
        ImplicitStructure(text: widget.inputText);
    Map<String, String> resultStrings =
        implicitStructure.getArgumentsAndDataType();
    List<String> hintText = [];
    resultStrings.forEach((key, value) {
      hintText.add(key);
    });
    catchError = implicitStructure.getPreCondition();
    return Scaffold(
      backgroundColor: themeProvider.getTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(implicitStructure.getFunctionName()!),
      ),
      body: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              // minHeight: 100,
              // minWidth: double.infinity,
              maxHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  150,
            ),
            // height: 200,
            child: widget.type != 2
                //type 1 input
                ? ListView.builder(
                    itemCount: resultStrings.length,
                    itemBuilder: (context, index) {
                      _controllers!.add(TextEditingController());
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InputField(
                          hint: hintText[index],
                          title: 'Enter ${hintText[index]}',
                          controller: _controllers![index],
                        ),
                      );
                    },
                  )
                //type 2 input
                : Container(
                    constraints: BoxConstraints(
                      // minHeight: 100,
                      // minWidth: double.infinity,
                      maxHeight: MediaQuery.of(context).size.height -
                          AppBar().preferredSize.height -
                          150,
                    ),
                    child: Column(
                      children: [
                        //show input number of element
                        Container(
                          decoration: const BoxDecoration(
                              // color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, top: 8, bottom: 8),
                            child: InputField(
                              hint: hintText[1],
                              title: 'Enter the number of elements',
                              controller: _nControllers[0],
                              onChanged: (value) {
                                setState(() {
                                  debugPrint(_nControllers[0].text.toString());
                                  _controllers = [];
                                });
                              },
                            ),
                          ),
                        ),
                        //show array input field in type 2
                        _nControllers[0].text != ""
                            ? Container(
                                constraints: BoxConstraints(
                                  // minHeight: 100,
                                  // minWidth: double.infinity,
                                  maxHeight:
                                      MediaQuery.of(context).size.height -
                                          AppBar().preferredSize.height -
                                          300,
                                ),
                                child: ListView.builder(
                                  itemCount: int.parse(
                                      _nControllers[0].text.toString()),
                                  itemBuilder: (context, index) {
                                    _controllers!.add(TextEditingController());
                                    return Container(
                                      decoration: const BoxDecoration(
                                          // color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, top: 8, bottom: 8),
                                        child: InputField(
                                          hint: "${hintText[0]}$index",
                                          title: 'Enter the ${index}st element',
                                          controller: _controllers![index],
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
            width: 200.0,
            height: 45.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: const ui.Color.fromARGB(255, 19, 176, 187),
                elevation: 3, //elevation of button
                shape: RoundedRectangleBorder(
                  //to set border radius to button
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Show Result',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              onPressed: () {
                setState(() {
                  //show result
                  calculateResult();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future notifiErrorDialog() => showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text("Please input again"),
              content: Text("The value must be $catchError"),
            )),
      );

  Future notifiDialog() => showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text("Result"),
              content: SizedBox(
                height: 50,
                child: Center(
                  child: Text(
                    a,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
            )),
      );
}
