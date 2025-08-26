import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/views/pages/setting_page.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key, required this.title});

  final String title;

  @override
  State<AppbarWidget> createState() => _AppbarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppbarWidgetState extends State<AppbarWidget> {
  @override
  Widget build(BuildContext context) {
    final bool isSettingPage =
        widget.title == "Setting" ||
        widget.title == "Login" ||
        widget.title == "Register";

    return AppBar(
      title: Text(
        widget.title,
        style: appBarFont,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        if (!isSettingPage)
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.settings_outlined),
          ),
      ],
      flexibleSpace: Image.asset(
        "assets/images/background1.png",
        fit: BoxFit.cover,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.white),
    );
  }
}
