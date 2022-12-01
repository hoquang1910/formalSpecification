import 'package:stack/stack.dart';

class ImplicitStructure {
  String? _exerciseStructureText;

  // Contructure
  ImplicitStructure({
    required String? text,
  }) : _exerciseStructureText = text;

  // Creating the getter method
  String? get getExerciseStructureText {
    return _exerciseStructureText;
  }

  // Creating the setter method
  set setExerciseStructureText(String exerciseStructureText) {
    _exerciseStructureText = exerciseStructureText;
  }

  // Delete whitespace in text input
  String normalizeExpressionString(String input) {
    try {
      int indexPre = input.indexOf("pre");
      int indexPost = input.indexOf("post");
      String functionString = deleteWhitespace(input.substring(0, indexPre));
      String preConditionString =
          deleteWhitespace(input.substring(indexPre, indexPost));
      String postConditionString =
          deleteWhitespace(input.substring(indexPost, input.length))
              .replaceAll("\n", "");

      return "$functionString\n$preConditionString\n$postConditionString";
    } catch (e) {
      throw ("Invalid Data");
    }
  }

  // Get Function Name
  String? getFunctionName() {
    try {
      if (_exerciseStructureText == null) {
        // ignore: avoid_print
        print("Not Input Yet");
        return "";
      }
      int index = _exerciseStructureText!.indexOf("(");
      String functionName =
          deleteWhitespace(_exerciseStructureText!.substring(0, index));
      return functionName;
    } catch (e) {
      throw ("Invalid Data");
    }
  }

  // get map<argument, datatype>
  Map<String, String> getArgumentsAndDataType() {
    try {
      Map<String, String> result = {};

      // get line 1 => Function_name(argument1: Type1, argument2: Type2…) result: Type
      int indexPre = _exerciseStructureText!.indexOf("pre");
      String functionString =
          deleteWhitespace(_exerciseStructureText!.substring(0, indexPre));

      // get string arguments =>  argument1: Type1, argument2: Type2…
      int indexOpenParenthesis = functionString.indexOf("(");
      int indexCloseParenthesis = functionString.indexOf(")");
      String argumentsString = functionString.substring(
          indexOpenParenthesis + 1, indexCloseParenthesis);

      // get argument string list => {argument1: Type1, argument2: Type2…}
      var argumentStringList = argumentsString.split(",");

      if (indexCloseParenthesis - indexOpenParenthesis == 1) {
        // no arguments
        result = {};
      } else {
        for (int i = 0; i < argumentStringList.length; i++) {
          int indexColon = argumentStringList[i].indexOf(":");
          String argument = argumentStringList[i].substring(0, indexColon);
          String mathDataType = argumentStringList[i]
              .substring(indexColon + 1, argumentStringList[i].length);
          result[argument] = convertDataType(mathDataType);
        }
      }
      return result;
    } catch (e) {
      throw ("Invalid Data");
    }
  }

  // get result and datatype => result:type
  Map<String, String> getResultAndDataType() {
    try {
      Map<String, String> result = {};

      // get line 1 => Function_name(argument1: Type1, argument2: Type2…) result: Type
      int indexPre = _exerciseStructureText!.indexOf("pre");
      String functionString =
          deleteWhitespace(_exerciseStructureText!.substring(0, indexPre));

      int indexCloseParenthesis = functionString.indexOf(")");
      String resultString = deleteWhitespace(functionString.substring(
          indexCloseParenthesis + 1, functionString.length));

      int indexColon = resultString.indexOf(":");
      String argument = resultString.substring(0, indexColon);
      String mathDataType =
          resultString.substring(indexColon + 1, resultString.length);
      result[argument] = convertDataType(mathDataType);

      return result;
    } catch (e) {
      throw ("Invalid Data");
    }
  }

  // get pre condition => pre a != 0
  String? getPreCondition() {
    try {
      int indexPre = _exerciseStructureText!.indexOf("pre");
      int indexPost = _exerciseStructureText!.indexOf("post");
      String preConditionString = deleteWhitespace(
          _exerciseStructureText!.substring(indexPre + 3, indexPost));

      //check: (a > 0) or ((a > 0) && (b > 0))
      if (preConditionString == "") {
        return null;
      } else {
        if (preConditionString.contains("&&") ||
            preConditionString.contains("||")) {
          return normalizeMultipleExpressionString(preConditionString);
        } else {
          return normalizeSingleExpressionString(
              deleteParenthesisInSingleExpression(preConditionString));
        }
      }
    } catch (e) {
      throw ("Invalid Data");
    }
  }

  String? getPostCondition() {
    try {
      int indexPost = _exerciseStructureText!.indexOf("post");
      String postConditionString = deleteWhitespace(_exerciseStructureText!
              .substring(indexPost + 4, _exerciseStructureText!.length - 1))
          .replaceAll("\n", "");

      return postConditionString;
    } catch (e) {
      throw ("Invalid Data");
    }
  }

  //
  // Type 1:
  // ex: {a>0: a=true, a<0: a=false}
  //
  Map<String, String> getConditionAndResultOfPostCondition() {
    try {
      Map<String, String> results = {};
      var regex = RegExp("[a-zA-Z0-9]");

      // devide condition
      String datatypeResultVariable = getResultAndDataType().values.first;

      String? postConditionString = getPostCondition();
      var conditionList = postConditionString!.split("||");

      String resultVariable = getResultAndDataType().keys.first;

      //
      for (int i = 0; i < conditionList.length; i++) {
        String element = delete_1(conditionList[i]);
        List<String> elementList = element.split("&&");

        //determine which expression is the result
        for (int i = 0; i < elementList.length; i++) {
          if (elementList[i].contains(resultVariable)) {
            int indexResultVariable =
                elementList[i].indexOf("$resultVariable=");
            String preLetterResult = elementList[i][indexResultVariable - 1];
            if (!regex.hasMatch(preLetterResult) ||
                indexResultVariable - 1 < 0) {
              // ex: return c=a
              String resultExpresssion =
                  deleteParenthesisInSingleExpression(elementList[i]);
              int indexEqual = resultExpresssion.indexOf("=");
              // ex: c=a => a
              String resultReturn = "";
              String tempResultReturn = resultExpresssion.substring(
                  indexEqual + 1, resultExpresssion.length);
              if (datatypeResultVariable != "bool") {
                resultReturn = tempResultReturn;
              } else {
                resultReturn = tempResultReturn.toLowerCase();
              }
              if (elementList.length == 1) {
                results[""] = resultReturn;
              }
              if (elementList.length == 2) {
                elementList.removeAt(i);
                String conditionExpresssion = normalizeSingleExpressionString(
                    elementList[0].replaceAll("(", "").replaceAll(")", ""));
                int indexEqual = conditionExpresssion.indexOf("=");
                if (indexEqual > 0 &&
                    !regex.hasMatch(conditionExpresssion[indexEqual - 1])) {
                  results[conditionExpresssion] = resultReturn;
                } else {
                  results[conditionExpresssion.replaceAll("=", "==")] =
                      resultReturn;
                }
              }
              if (elementList.length > 2) {
                String conditions = "";
                elementList.removeAt(i);
                String a = " && ";
                for (var element in elementList) {
                  String ele = normalizeSingleExpressionString(element);
                  int indexEqual = ele.indexOf("=");

                  if (indexEqual > 0 && !regex.hasMatch(ele[indexEqual - 1])) {
                    conditions += ("$ele$a");
                  } else {
                    conditions += ("${ele.replaceAll("=", "==")}$a");
                  }
                }
                results[conditions.substring(0, conditions.length - a.length)] =
                    resultReturn;
              }
            }
          }
        }
      }
      return results;
    } catch (e) {
      throw ("Invalid Data");
    }
  }

  //
  // Type 2
  // ex: return {VMiTH : 1..n-1, TTjTH : i+1..n, ..}
  //
  Map<String, String> getIndexAndValueVariableType2() {
    try {
      var regex = RegExp(r'\{|\(|\)|\}');

      Map<String, String> results = {};
      String resultVariable = getResultAndDataType().keys.first;
      int numberOfLoops = '..'.allMatches(getPostCondition()!).length;
      String? postString = getPostCondition();
      for (int i = 0; i < numberOfLoops; i++) {
        int indexCloseBrace = postString!.indexOf("}.");
        //
        String subPostString = postString
            .substring(0, indexCloseBrace)
            .replaceAll('$resultVariable=', "");

        int indexOpenBrace = subPostString.indexOf("{");
        // eg: return: TTiTH
        String key =
            subPostString.substring(0, indexOpenBrace).replaceAll(regex, "");

        // eg: return: 1..n
        String value = subPostString
            .substring(indexOpenBrace, subPostString.length)
            .replaceAll(regex, "");

        postString =
            postString.substring(indexCloseBrace + 2, postString.length);
        results[key] = value;
      }
      return results;
    } catch (e) {
      throw ("Invalid Data");
    }
  }

  //eg: return a[i] <= a[j]
  String getConditionOfPostType2() {
    try {
      String result = "";
      int numberOfLoops = '..'.allMatches(getPostCondition()!).length;
      String? postString = getPostCondition();
      for (int i = 0; i < numberOfLoops; i++) {
        int indexCloseBrace = postString!.indexOf("}.");

        postString =
            postString.substring(indexCloseBrace + 2, postString.length);
        result = postString;
      }
      int numberOpenParenthesis = '('.allMatches(result).length;
      int numberCloseParenthesis = ')'.allMatches(result).length;

      // đếm số ngoặc thừa
      if (numberCloseParenthesis > numberOpenParenthesis) {
        int num = numberCloseParenthesis - numberOpenParenthesis;
        for (int i = 0; i < num; i++) {
          result = result.substring(0, result.length - 1);
        }
      }
      if (numberOpenParenthesis > numberCloseParenthesis) {
        int num = numberOpenParenthesis - numberCloseParenthesis;
        for (int i = 0; i < num; i++) {
          result = result.substring(1, result.length);
        }
      }
      String resultTempt = normalizeSingleExpressionString(result)
          .replaceAll("(", "[")
          .replaceAll(")", "]");
      return resultTempt;
    } catch (e) {
      throw ("Invalid Data");
    }
  }
}

// ex: (a>b) => (a > b)
String normalizeSingleExpressionString(String inputText) {
  try {
    var regexOperator = RegExp(r'%|!=|>=|<=|!|>|<|=');

    int indexOperatorFirst = inputText.indexOf(regexOperator);
    int indexOperatorLast = inputText.lastIndexOf(regexOperator);

    String operatorString =
        inputText.substring(indexOperatorFirst, indexOperatorLast + 1);

    String outputText =
        inputText.replaceAll(operatorString, " $operatorString ");
    return outputText;
  } catch (e) {
    throw ("Invalid Data");
  }
}

String normalizeMultipleExpressionString(String inputText) {
  try {
    String inputTempt = "";
    if (inputText.contains("&&")) {
      List<String> texts = inputText.split("&&");
      for (int i = 0; i < texts.length; i++) {
        if (i != texts.length - 1) {
          inputTempt += normalizeSingleExpressionString(texts[i]);
          inputTempt += " && ";
        } else {
          inputTempt += normalizeSingleExpressionString(texts[i]);
        }
      }
    }
    return inputTempt;
  } catch (e) {
    throw ("Invalid Data");
  }
}

//(xl="Kha") && (diem>=6.5) && (diem<8)

String convertDataType(String mathDataType) {
  switch (mathDataType) {
    case "R":
      return "double";
    case "Z":
      return "int";
    case "char*":
      return "String";
    case "B":
      return "bool";
    case "N":
      return "int";
    default:
      return "double";
  }
}

String deleteWhitespace(String text) {
  String newText = text.replaceAll(" ", "");
  return newText.trim();
}

String delete_1(String input) //delete string like (a)->a || ((a+b))->(a+b)
{
  Stack<String> s = Stack();
  Stack<int> index = Stack();

  List<String> operatorList = [
    "+",
    "-",
    "*",
    "/",
    "%",
    ">",
    "<",
    "=",
    "!=",
    ">=",
    "<=",
    "!"
  ];
  var dele = List.filled(300, 0);

  for (int i = 0; i < input.length; i++) {
    if (input[i] == ')') {
      int flag = 0;
      while (s.top() != '(') {
        String top = s.top();
        for (int i = 0; i < operatorList.length; i++) {
          if (top == operatorList[i]) {
            flag = 1;
            break;
          }
        }

        s.pop();
        index.pop();
      }
      if (flag == 0) {
        dele[index.top()] = 1;
        dele[i] = 1;
      }
      s.pop();
      index.pop();
    } else {
      s.push(input[i]);
      index.push(i);
    }
  }
  String rs = "";
  for (int i = 0; i < input.length; i++) {
    if (dele[i] == 0) rs += input[i];
  }
  return rs;
}

// (a+b) => a+b
String deleteParenthesisInSingleExpression(String textInput) {
  String text1 = textInput.replaceFirst("(", "");
  String text2 = text1.replaceFirst(")", "");
  return text2;
}
