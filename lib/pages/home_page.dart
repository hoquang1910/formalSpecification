import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fomal_specification/implicit_structure/implicit_structure.dart';
import 'package:fomal_specification/pages/widgets/alert_dialog.dart';
import 'package:fomal_specification/pages/widgets/code_string_type1.dart';
import 'package:fomal_specification/pages/widgets/code_string_type2.dart';
import 'package:fomal_specification/pages/widgets/dropdown_menu/menu_data.dart';
import 'package:fomal_specification/pages/widgets/dropdown_menu/menu_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../config/theme_constants.dart';
import '../config/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? inputText;
  var inputTextController = TextEditingController();
  final richTextKey = GlobalKey();
  bool isGenerateCode = false;
  int? numberOfLines;
  String? s;
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    ImplicitStructure implicitStructure =
        ImplicitStructure(text: inputTextController.text);
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: themeProvider.getTheme.scaffoldBackgroundColor,
      floatingActionButton: isGenerateCode && inputTextController.text != ""
          ? FloatingActionButton(
              backgroundColor: themeProvider
                  .getTheme.floatingActionButtonTheme.backgroundColor,
              child: Icon(
                Icons.play_arrow,
                color: themeProvider.getTheme.colorScheme.secondary,
              ),
              onPressed: () {
                print(implicitStructure.getIndexAndValueVariableType2());

                if (isGenerateCode) {
                  final RichText? richText =
                      richTextKey.currentWidget as RichText;
                  s = "${richText?.text.toPlainText()}";
                  // debugPrint(s);
                }
              },
            )
          : null,
      appBar: AppBar(
        iconTheme: themeProvider.getTheme.iconTheme,
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Image(
            image: AssetImage("assets/uit_logo.png"),
          ),
        ),
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            "FomalSpecification",
            style: TextStyle(color: themeProvider.getTheme.primaryColor),
          ),
        ),
        centerTitle: true,
        actions: [
          FlutterSwitch(
            value: themeProvider.getTheme == darkTheme,
            activeToggleColor: const Color(0xFF6E40C9),
            inactiveToggleColor: const Color(0xFF2F363D),
            activeSwitchBorder: Border.all(
              color: const Color(0xFF3C1E70),
              width: 1.0,
            ),
            inactiveSwitchBorder: Border.all(
              color: const Color(0xFFD1D5DA),
              width: 1.0,
            ),
            activeColor: const Color(0xFF271052),
            inactiveColor: Colors.white,
            activeIcon: const Icon(
              Icons.nightlight_round,
              color: Color(0xFFF8E3A1),
            ),
            inactiveIcon: const Icon(
              Icons.wb_sunny,
              color: Color(0xFFFFDF5D),
            ),
            onToggle: (val) {
              setState(() {
                themeProvider.changeTheme();
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<MenuModel>(
              onSelected: (item) => onSelected(context, item),
              itemBuilder: (context) => [
                ...MenuItems.itemsFirst.map(buildItem).toList(),
                const PopupMenuDivider(),
                ...MenuItems.itemsSecond.map(buildItem).toList(),
              ],
            ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        backgroundColor: Colors.transparent, // Colors.white.withOpacity(0.1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    maxLines: numberOfLines,
                    controller: inputTextController,
                    style: TextStyle(
                      color: themeProvider.getTheme.primaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.0,
                        ),
                      ),
                      hintStyle: themeProvider.getTheme.textTheme.bodyText1,
                      hintText: "Exercise Input",
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    //width: 200.0,
                    height: 25.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const ui.Color.fromARGB(255, 19, 176, 187),
                        //border width and color
                        elevation: 3, //elevation of button
                        shape: RoundedRectangleBorder(
                          //to set border radius to button
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Generate Code',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isGenerateCode = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: themeProvider.getTheme.colorScheme.background,
                    borderRadius: const BorderRadius.all(Radius.circular(15))),
                // height: 300,
                child: isGenerateCode && inputTextController.text != ""
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: inputTextController.text.contains("VM") ||
                                inputTextController.text.contains("TT")
                            ? CodeStringType2(
                                richTextKey: richTextKey,
                                inputText: inputTextController.text,
                              )
                            : CodeStringType1(
                                richTextKey: richTextKey,
                                inputText: inputTextController.text,
                              ),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<MenuModel> buildItem(MenuModel item) {
    return PopupMenuItem<MenuModel>(
      value: item,
      child: Row(
        children: [
          Image.asset(
            item.imageUrl,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 12),
          Text(item.text),
        ],
      ),
    );
  }

  Future<void> onSelected(BuildContext context, MenuModel item) async {
    switch (item) {
      case MenuItems.itemOpenFile:
        ImplicitStructure implicitStructure =
            ImplicitStructure(text: inputTextController.text);
        final result = await FilePicker.platform.pickFiles(
            type: FileType.custom, allowedExtensions: ['txt', 'doc']);

        if (result == null) return;

        //open single file
        final file = result.files.first;
        final newFile = await saveFilePermanently(file);
        await readFile(newFile).then((value) {
          if (value != "") {
            inputTextController.text =
                implicitStructure.normalizeExpressionString(value);
            numberOfLines = '\n'.allMatches(value).length;
          }
        });
        setState(() {
          isGenerateCode = false;
        });
        break;
      case MenuItems.itemNewFile:
        inputTextController.clear();
        setState(() {
          numberOfLines = 1;
          isGenerateCode = false;
        });
        break;
      case MenuItems.itemSignOut:
        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'Warning !!!',
              subTitle: 'Do you want to exit the app?',
              action: () {
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
              },
            );
          },
        );
        break;
    }
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
