import 'package:flutter/material.dart';
import 'package:fomal_specification/config/code_color/code_colors.dart';
import 'package:fomal_specification/implicit_structure/implicit_structure.dart';
import 'package:provider/provider.dart';

import '../../config/theme_provider.dart';

class CodeStringType1 extends StatelessWidget {
  final GlobalKey<State<StatefulWidget>> richTextKey;
  final String? inputText;
  const CodeStringType1({
    Key? key,
    required this.richTextKey,
    this.inputText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImplicitStructure implicitStructure = ImplicitStructure(text: inputText);
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    TextStyle textStyleCode = themeProvider.getTheme.textTheme.bodyText1!;

    final CodeColor? codeColor = themeProvider.getTheme.extension<CodeColor>();
    List<TextSpan> getArguments() {
      List<TextSpan> result = [];
      Map<String, String> arguments =
          implicitStructure.getArgumentsAndDataType();
      arguments.forEach((key, value) {
        TextSpan keySpan = TextSpan(
          text: key,
          style: textStyleCode.apply(color: codeColor!.argumentColor),
        );
        result.add(keySpan);
      });
      return result;
    }

    //
    Map<List<TextSpan>, List<TextSpan>> getConditionAndResults() {
      var regexAlphabet = RegExp("[a-zA-Z0-9.]");
      var regexParenthesis = RegExp(r'\)|\(');

      // result map
      Map<List<TextSpan>, List<TextSpan>> results = {};

      Map<String, String> resultStrings =
          implicitStructure.getConditionAndResultOfPostCondition();

      // duyệt {a>b:c=a, b>a:c=b}
      resultStrings.forEach((key, value) {
        //
        List<TextSpan> conditionSpanList = [];
        List<TextSpan> resultSpanList = [];

        //tách từng ký tự trong value
        if (key != "") {
          for (int i = 0; i < key.length; i++) {
            TextSpan conditionSpanCharacter;
            if (regexParenthesis.hasMatch(key[i])) {
              conditionSpanCharacter = TextSpan(
                text: key[i],
                style: textStyleCode.apply(
                    color: codeColor!.parenthesisOfConditionExpressionColor),
              );
              conditionSpanList.add(conditionSpanCharacter);
            } else if (!regexAlphabet.hasMatch(key[i]) &&
                !regexParenthesis.hasMatch(key[i])) {
              conditionSpanCharacter = TextSpan(
                text: key[i],
                style: textStyleCode.apply(color: codeColor!.operatorColor),
              );
              conditionSpanList.add(conditionSpanCharacter);
            } else {
              conditionSpanCharacter = TextSpan(
                text: key[i],
                style: textStyleCode.apply(
                    color: codeColor!.argumentOfConditionExpressionColor),
              );
              conditionSpanList.add(conditionSpanCharacter);
            }
          }
        }

        for (int i = 0; i < value.length; i++) {
          TextSpan resultSpanCharacter;
          if (regexParenthesis.hasMatch(value[i])) {
            resultSpanCharacter = TextSpan(
              text: value[i],
              style: textStyleCode.apply(
                  color: codeColor!.parenthesisOfConditionExpressionColor),
            );
            resultSpanList.add(resultSpanCharacter);
          } else if (!regexAlphabet.hasMatch(value[i]) &&
              !regexParenthesis.hasMatch(value[i])) {
            resultSpanCharacter = TextSpan(
              text: value[i],
              style: textStyleCode.apply(color: codeColor!.operatorColor),
            );
            resultSpanList.add(resultSpanCharacter);
          } else {
            resultSpanCharacter = TextSpan(
              text: value[i],
              style: textStyleCode.apply(
                  color: codeColor!.argumentOfConditionExpressionColor),
            );
            resultSpanList.add(resultSpanCharacter);
          }
        }

        results[conditionSpanList] = resultSpanList;
      });
      return results;
    }

    List<TextSpan> getPreCondition() {
      var regexAlphabet = RegExp("[a-zA-Z0-9.]");
      var regexParenthesis = RegExp(r'\)|\(');
      List<TextSpan> conditionSpanList = [];
      String? preConditionString = implicitStructure.getPreCondition();
      if (preConditionString != null) {
        for (int i = 0; i < preConditionString.length; i++) {
          TextSpan conditionSpanCharacter;
          if (regexParenthesis.hasMatch(preConditionString[i])) {
            conditionSpanCharacter = TextSpan(
              text: preConditionString[i],
              style: textStyleCode.apply(
                  color: codeColor!.parenthesisOfConditionExpressionColor),
            );
            conditionSpanList.add(conditionSpanCharacter);
          } else if (!regexAlphabet.hasMatch(preConditionString[i]) &&
              !regexParenthesis.hasMatch(preConditionString[i])) {
            conditionSpanCharacter = TextSpan(
              text: preConditionString[i],
              style: textStyleCode.apply(color: codeColor!.operatorColor),
            );
            conditionSpanList.add(conditionSpanCharacter);
          } else {
            conditionSpanCharacter = TextSpan(
              text: preConditionString[i],
              style: textStyleCode.apply(
                  color: codeColor!.argumentOfConditionExpressionColor),
            );
            conditionSpanList.add(conditionSpanCharacter);
          }
        }
      }
      return conditionSpanList;
    }

    return RichText(
      key: richTextKey,
      text: TextSpan(
        text: "",
        style: textStyleCode.apply(color: codeColor!.dataTypeColor),
        children: [
          // check condition
          if (getPreCondition().isNotEmpty) ...[
            TextSpan(
              text: "function",
              style: textStyleCode.apply(color: codeColor.dataTypeColor),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: "checkCondition",
              style: textStyleCode.apply(color: codeColor.functionNameColor),
            ),
            TextSpan(
              text: '(',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfFunctionColor),
            ),
            for (int i = 0; i < getArguments().length; i++) ...[
              getArguments().elementAt(i),
              if ((i % 2 == 0) && (i != getArguments().length - 1)) ...[
                TextSpan(
                  text: ",",
                  style: textStyleCode.apply(color: codeColor.operatorColor),
                ),
              ],
              if (i != getArguments().length - 1) ...[
                const TextSpan(text: " "),
              ],
            ],
            TextSpan(
              text: ')',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfFunctionColor),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: '{\n',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfFunctionColor),
            ),
            const TextSpan(text: "\t\t\t\t\t"),
            TextSpan(
              text: "if (",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            for (int i = 0; i < getPreCondition().length; i++) ...[
              getPreCondition()[i],
            ],
            TextSpan(
              text: ")",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: " {",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            const TextSpan(text: "\n"),
            const TextSpan(text: "\t\t\t\t\t\t\t\t\t\t"),
            TextSpan(
              text: "return ",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: "true",
              style: textStyleCode.apply(
                  color: codeColor.trueFalseExpressionColor),
            ),
            TextSpan(
              text: ";",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            const TextSpan(text: "\n"),
            const TextSpan(text: "\t\t\t\t"),
            TextSpan(
              text: " }",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            const TextSpan(text: "\n"),
            const TextSpan(text: "\t\t\t\t\t"),
            TextSpan(
              text: "return ",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: "false",
              style: textStyleCode.apply(
                  color: codeColor.trueFalseExpressionColor),
            ),
            TextSpan(
              text: ";",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            const TextSpan(text: "\n"),
            TextSpan(
              text: '}',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfFunctionColor),
            ),
          ],

          if (getPreCondition().isNotEmpty) ...[
            const TextSpan(text: '\n\n'),
          ],

          // execute function
          TextSpan(
            text: "function",
            style: textStyleCode.apply(color: codeColor.dataTypeColor),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: implicitStructure.getFunctionName(),
            style: textStyleCode.apply(color: codeColor.functionNameColor),
          ),
          TextSpan(
            text: '(',
            style: textStyleCode.apply(
                color: codeColor.parenthesisOfFunctionColor),
          ),

          // arguments => double a, double b
          for (int i = 0; i < getArguments().length; i++) ...[
            getArguments().elementAt(i),
            if ((i % 2 == 0) && (i != getArguments().length - 1)) ...[
              TextSpan(
                text: ",",
                style: textStyleCode.apply(color: codeColor.operatorColor),
              ),
            ],
            if (i != getArguments().length - 1) ...[
              const TextSpan(text: " "),
            ],
          ],

          TextSpan(
            text: ')',
            style: textStyleCode.apply(
                color: codeColor.parenthesisOfFunctionColor),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: '{\n',
            style: textStyleCode.apply(
                color: codeColor.parenthesisOfFunctionColor),
          ),

          //

          if (getPreCondition().isNotEmpty) ...[
            const TextSpan(text: "\t\t\t\t\t"),
            TextSpan(
              text: "if (",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: "checkCondition",
              style: textStyleCode.apply(color: codeColor.functionNameColor),
            ),
            TextSpan(
              text: '(',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfFunctionColor),
            ),
            for (int i = 0; i < getArguments().length; i++) ...[
              getArguments().elementAt(i),
              if ((i % 2 == 0) && (i != getArguments().length - 1)) ...[
                TextSpan(
                  text: ",",
                  style: textStyleCode.apply(color: codeColor.operatorColor),
                ),
              ],
              if (i != getArguments().length - 1) ...[
                const TextSpan(text: " "),
              ],
            ],
            TextSpan(
              text: ')',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfFunctionColor),
            ),
            TextSpan(
              text: ')',
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: " {",
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfConditionExpressionColor),
            ),
            const TextSpan(text: "\n"),
          ],
          //
          for (int i = 0; i < getConditionAndResults().length; i++) ...[
            if (getConditionAndResults().length != 1) ...[
              if (getPreCondition().isNotEmpty) ...[
                const TextSpan(text: "\t\t\t\t\t\t\t\t\t\t"),
              ] else ...[
                const TextSpan(text: "\t\t\t\t\t"),
              ],
              TextSpan(
                text: "if (",
                style: textStyleCode.apply(color: codeColor.conditionColor),
              ),
              for (int j = 0;
                  j < getConditionAndResults().keys.elementAt(i).length;
                  j++) ...[
                getConditionAndResults().keys.elementAt(i)[j],
              ],

              // đóng ngoặc biểu thức điều kiện ex: (a>b)<==
              TextSpan(
                text: ")",
                style: textStyleCode.apply(color: codeColor.conditionColor),
              ),

              TextSpan(
                text: " {",
                style: textStyleCode.apply(color: codeColor.conditionColor),
              ),
              const TextSpan(text: "\n"),
            ],
            if (getConditionAndResults().length != 1) ...[
              if (getPreCondition().isNotEmpty) ...[
                const TextSpan(text: "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t"),
              ] else ...[
                const TextSpan(text: "\t\t\t\t\t\t\t\t\t\t"),
              ],
            ] else ...[
              if (getPreCondition().isNotEmpty) ...[
                const TextSpan(text: "\t\t\t\t\t\t\t\t\t\t"),
              ] else ...[
                const TextSpan(text: "\t\t\t\t\t"),
              ],
            ],
            TextSpan(
              text: "return ",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            for (int j = 0;
                j < getConditionAndResults().values.elementAt(i).length;
                j++) ...[
              getConditionAndResults().values.elementAt(i)[j],
            ],
            TextSpan(
              text: ";",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            // đóng ngoặc if
            if (getConditionAndResults().length != 1) ...[
              const TextSpan(text: "\n"),
              if (getPreCondition().isNotEmpty) ...[
                const TextSpan(text: "\t\t\t\t\t\t\t\t\t\t"),
              ] else ...[
                const TextSpan(text: "\t\t\t\t\t"),
              ],
              TextSpan(
                text: "}",
                style: textStyleCode.apply(color: codeColor.conditionColor),
              ),
            ],
            const TextSpan(text: "\n"),
          ],

          //
          if (getPreCondition().isNotEmpty) ...[
            const TextSpan(text: "\t\t\t\t\t"),
            TextSpan(
              text: "}",
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfConditionExpressionColor),
            ),
            const TextSpan(text: "\n"),
            const TextSpan(text: "\t\t\t\t\t"),
            TextSpan(
              text: "else ",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: "{",
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfConditionExpressionColor),
            ),
            const TextSpan(text: "\n"),
            const TextSpan(text: "\t\t\t\t\t\t\t\t\t\t"),
            TextSpan(
              text: "return ",
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: "\"null\"",
              style: textStyleCode.apply(
                  color: codeColor.argumentOfConditionExpressionColor),
            ),
            TextSpan(
              text: ";",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            const TextSpan(text: "\n"),
            const TextSpan(text: "\t\t\t\t\t"),
            TextSpan(
              text: "}",
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfConditionExpressionColor),
            ),
            const TextSpan(text: "\n"),
          ],
          //
          TextSpan(
            text: '}',
            style: textStyleCode.apply(
                color: codeColor.parenthesisOfFunctionColor),
          ),
        ],
      ),
    );
  }
}
