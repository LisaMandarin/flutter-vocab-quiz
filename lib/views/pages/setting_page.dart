import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/styles.dart';
import 'package:vocab_quiz/services/auth_services.dart';
import 'package:vocab_quiz/services/firestore_services.dart';
import 'package:vocab_quiz/views/components/appbar_widget.dart';
import 'package:vocab_quiz/views/components/usercard_widget.dart';
import 'package:vocab_quiz/views/components/vocabList_widget.dart';
import 'package:vocab_quiz/views/pages/home_page.dart';
import 'package:vocab_quiz/main.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

// RouteAware allows the widget to listen for navigation event
// WidgetBindingObserver lets the widget listen to app lifecycle events
class _SettingPageState extends State<SettingPage> with RouteAware, WidgetsBindingObserver {
  
  String errorMessage = '';

  //to hold the future returned by Firestore's getUserDoc()
  // used by FutureBuilder
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userDataFuture = firestore.value.getUserDoc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // subscribe this page to the global RouteObserver
    MyApp.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MyApp.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // refresh page when user comes back from other page
    refreshPage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // refresh user data when the app comes back from background
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes back to foreground
      refreshPage();
    }
  }

  //re-fetch user data and rebuild the page after updating username or coming back from other routes
  void refreshPage() {
    setState(() {
      _userDataFuture = firestore.value.getUserDoc();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(title: "Setting"),
      body: FutureBuilder(
        future: _userDataFuture,
        builder: (context, snapshot) {
          // show loading animation when fetching user data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // build widget when user data is fetched
          if (snapshot.hasData) {
            final userData = snapshot.data;
            final email = userData?['email'] ?? "";
            final username = (userData)?['username'];

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // greeting message
                  Text(
                    username != null ? "Hello, $username" : "Hello",
                    style: titleStyle,
                  ),

                  // cards: user and word lists
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          UsercardWidget(
                            email: email,
                            username: username ?? "",
                            errorMessage: errorMessage,
                            refresh: refreshPage,
                          ),
                          SizedBox(height: 10),
                          VocablistWidget(),
                        ],
                      ),
                    ),
                  ),

                  // log out button
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await authService.value.signOut();
                      if (!mounted) return;
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => HomePage(title: "Vocab Quiz"),
                        ),
                        (route) => false,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Sign Out"),
                        SizedBox(width: 10),
                        Icon(Icons.logout),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Always return a widget if no data or error
          return Center(child: Text('No user data found.'));
        },
      ),
    );
  }
}
