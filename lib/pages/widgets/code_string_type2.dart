import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/code_color/code_colors.dart';
import '../../config/theme_provider.dart';
import '../../implicit_structure/implicit_structure.dart';

class CodeStringType2 extends StatelessWidget {
  final GlobalKey<State<StatefulWidget>> richTextKey;
  final String? inputText;
  const CodeStringType2({
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

    // TTiTH => i
    String getIndexVariable(String text) {
      String variable = text.contains("VM")
          ? text.substring(text.indexOf("VM") + 2, text.indexOf("TH"))
          : text.substring(text.indexOf("TT") + 2, text.indexOf("TH"));
      return variable;
    }

    // 1..n => 1
    String getFromValue(String text) {
      return text.substring(0, text.indexOf(".."));
    }

    // 1..n => n
    String getToValue(String text) {
      return text.substring(text.indexOf("..") + 2, text.length);
    }

    //ex: return {VMiTH : 1..n-1, TTjTH : i+1..n, ..}
    Map<String, String> getIndexAndValueVariable() {
      return implicitStructure.getIndexAndValueVariableType2();
    }

    //getConditionOfPostType2
    List<TextSpan> getConditionOfPostSpanList() {
      var regexAlphabet = RegExp("[a-zA-Z0-9.]");
      var regexOperator = RegExp(r'%|!=|>=|<=|!|>|<|=');
      List<TextSpan> results = [];
      String conditionOfPostType = implicitStructure.getConditionOfPostType2();
      for (int i = 0; i < conditionOfPostType.length; i++) {
        if (regexAlphabet.hasMatch(conditionOfPostType[i])) {
          TextSpan tempSpan = TextSpan(
            text: conditionOfPostType[i],
            style: textStyleCode.apply(color: codeColor!.argumentColor),
          );
          results.add(tempSpan);
        } else if (regexOperator.hasMatch(conditionOfPostType[i])) {
          TextSpan tempSpan = TextSpan(
            text: conditionOfPostType[i],
            style: textStyleCode.apply(color: codeColor!.operatorColor),
          );
          results.add(tempSpan);
        } else {
          TextSpan tempSpan = TextSpan(
            text: conditionOfPostType[i],
            style: textStyleCode.apply(color: codeColor!.conditionColor),
          );
          results.add(tempSpan);
        }
      }
      return results;
    }

    return RichText(
      key: richTextKey,
      text: TextSpan(
        text: "",
        style: textStyleCode.apply(color: codeColor!.dataTypeColor),
        children: [
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
          //  body
          //
          for (int index = 0;
              index < getIndexAndValueVariable().length;
              index++) ...[
            const TextSpan(text: '\t\t\t\t\t'),
            TextSpan(
              text: 'for (',
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: 'let ',
              style: textStyleCode.apply(color: codeColor.dataTypeColor),
            ),
            TextSpan(
              text: getIndexVariable(
                  getIndexAndValueVariable().keys.elementAt(index)),
              style: textStyleCode.apply(color: codeColor.argumentColor),
            ),
            TextSpan(
              text: " = ",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            TextSpan(
              text:  getFromValue(
                  getIndexAndValueVariable().values.elementAt(index)).length == 1 ? (int.parse(getFromValue(
                  getIndexAndValueVariable().values.elementAt(index))) - 1).toString() : getFromValue(
                  getIndexAndValueVariable().values.elementAt(index)),
              style: textStyleCode.apply(color: codeColor.argumentColor),
            ),
            TextSpan(
              text: "; ",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            TextSpan(
              text: getIndexVariable(
                  getIndexAndValueVariable().keys.elementAt(index)),
              style: textStyleCode.apply(color: codeColor.argumentColor),
            ),
            TextSpan(
              text: " < ",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            TextSpan(
              text: getToValue(
                  getIndexAndValueVariable().values.elementAt(index)),
              style: textStyleCode.apply(color: codeColor.argumentColor),
            ),
            TextSpan(
              text: "; ",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            TextSpan(
              text: getIndexVariable(
                  getIndexAndValueVariable().keys.elementAt(index)),
              style: textStyleCode.apply(color: codeColor.argumentColor),
            ),
            TextSpan(
              text: "++",
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            TextSpan(
              text: ')',
              style: textStyleCode.apply(color: codeColor.conditionColor),
            ),
            TextSpan(
              text: ' {',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfConditionExpressionColor),
            ),
            const TextSpan(text: '\n'),
            if (index != getIndexAndValueVariable().length - 1) ...[
              const TextSpan(text: '\t\t\t\t\t'),
            ],
          ],
          //
          //condition body

          for (int index = 0;
              index < getIndexAndValueVariable().length;
              index++) ...[
            const TextSpan(text: '\t\t\t\t\t'),
          ],
          const TextSpan(text: '\t\t\t\t\t'),
          TextSpan(
            text: 'if (',
            style: textStyleCode.apply(color: codeColor.conditionColor),
          ),
          if (implicitStructure.getPostCondition()!.contains("TT")) ...[
            for (int i = 0; i < getConditionOfPostSpanList().length; i++) ...[
              getConditionOfPostSpanList()[i],
            ],
          ] else ...[
            TextSpan(
              text: '!',
              style: textStyleCode.apply(color: codeColor.operatorColor),
            ),
            TextSpan(
              text: '(',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfConditionExpressionColor),
            ),
            for (int i = 0; i < getConditionOfPostSpanList().length; i++) ...[
              getConditionOfPostSpanList()[i],
            ],
            TextSpan(
              text: ')',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfConditionExpressionColor),
            ),
          ],

          TextSpan(
            text: ')',
            style: textStyleCode.apply(color: codeColor.conditionColor),
          ),
          TextSpan(
            text: ' {',
            style: textStyleCode.apply(
                color: codeColor.parenthesisOfFunctionColor),
          ),
          const TextSpan(text: '\n'),
          //
          for (int index = 0;
              index < getIndexAndValueVariable().length;
              index++) ...[
            const TextSpan(text: '\t\t\t\t\t'),
          ],
          const TextSpan(text: '\t\t\t\t\t\t\t\t\t\t'),
          TextSpan(
            text: 'return ',
            style: textStyleCode.apply(color: codeColor.conditionColor),
          ),
          if (implicitStructure.getPostCondition()!.contains("TT")) ...[
            TextSpan(
              text: 'true',
              style: textStyleCode.apply(
                  color: codeColor.argumentOfConditionExpressionColor),
            ),
          ] else ...[
            TextSpan(
              text: 'false',
              style: textStyleCode.apply(
                  color: codeColor.argumentOfConditionExpressionColor),
            ),
          ],
          TextSpan(
            text: ';',
            style: textStyleCode.apply(color: codeColor.operatorColor),
          ),
          const TextSpan(text: '\n'),
          for (int index = 0;
              index < getIndexAndValueVariable().length;
              index++) ...[
            const TextSpan(text: '\t\t\t\t\t'),
          ],
          const TextSpan(text: '\t\t\t\t\t\t\t\t\t\t'),
          TextSpan(
            text: 'break',
            style: textStyleCode.apply(color: codeColor.conditionColor),
          ),
          TextSpan(
            text: ';',
            style: textStyleCode.apply(color: codeColor.operatorColor),
          ),
          //

          // đóng ngoặc
          const TextSpan(text: '\n'),
          for (int index = 0;
              index < getIndexAndValueVariable().length;
              index++) ...[
            const TextSpan(text: '\t\t\t\t\t'),
          ],
          const TextSpan(text: '\t\t\t\t\t'),
          TextSpan(
            text: '}',
            style: textStyleCode.apply(
                color: codeColor.parenthesisOfFunctionColor),
          ),
          //////----------///////////
          //

          const TextSpan(text: '\n'),
          //
          //
          //
          for (int index = getIndexAndValueVariable().length - 1;
              index >= 0;
              index--) ...[
            for (int i = 0; i <= index; i++) ...[
              const TextSpan(text: '\t\t\t\t\t'),
            ],
            TextSpan(
              text: '}',
              style: textStyleCode.apply(
                  color: codeColor.parenthesisOfConditionExpressionColor),
            ),
            const TextSpan(text: '\n'),
          ],
          const TextSpan(text: '\t\t\t\t\t'),
          TextSpan(
            text: 'return ',
            style: textStyleCode.apply(color: codeColor.conditionColor),
          ),
          TextSpan(
            text: implicitStructure.getPostCondition()!.contains("TT")
                ? 'false'
                : "true",
            style: textStyleCode.apply(
                color: codeColor.argumentOfConditionExpressionColor),
          ),
          TextSpan(
            text: ';',
            style: textStyleCode.apply(color: codeColor.operatorColor),
          ),
          const TextSpan(text: '\n'),
          /////////////
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
