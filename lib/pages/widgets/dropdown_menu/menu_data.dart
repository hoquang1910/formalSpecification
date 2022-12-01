import 'package:fomal_specification/pages/widgets/dropdown_menu/menu_model.dart';

class MenuItems {
  static const List<MenuModel> itemsFirst = [
    itemNewFile,
    itemOpenFile,
  ];

  static const List<MenuModel> itemsSecond = [
    itemSignOut,
  ];

  static const itemNewFile = MenuModel(
    text: "New File",
    imageUrl: "assets/ic_newfile.png",
  );

  static const itemOpenFile = MenuModel(
    text: "Open File",
    imageUrl: "assets/ic_openfile.png",
  );

  static const itemSignOut = MenuModel(
    text: "Exit",
    imageUrl: "assets/ic_exit.png",
  );
}
