import 'package:flutter/material.dart';
import 'package:fluttersocket/wave_widget.dart';

import 'chat_page.dart';
import 'utils/colors.dart';
import 'common/rounded_image_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoHeight = screenHeight * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Transform.translate(
            offset: Offset(screenWidth * 0.3, 0),
            child: Transform.rotate(
              angle: -0.3,
              child: Image.asset(
                "images/logo.png",
                height: logoHeight,
                color: logoTintColor,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Column(
              children: <Widget>[
                //Suggestions(),
                EditorArea(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
            child: Column(
              children: <Widget>[
                HeaderPanel(),
                Reply(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderPanel extends StatelessWidget {
  const HeaderPanel({
    Key key,
  }) : super(key: key);

  Widget _simplePopup() => PopupMenuButton<int>(
        icon: Icon(
          Icons.translate,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("English"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("हिंदी"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("मराठी"),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RoundedImageWidget(imagePath: "images/bot_icon.gif", isOnline: true),
        IconButton(
          icon: new Icon(Icons.keyboard_arrow_up, size: 40),
          onPressed: () {
            Navigator.push(context, SlideBottomRoute(page: ChatPage()));
          },
        ),
        _simplePopup(),
      ],
    );
  }
}

class Reply extends StatefulWidget {
  @override
  _ReplyState createState() => _ReplyState();
}

class _ReplyState extends State<Reply> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: Text(
        "Hey Priyank,\nwhat can I help you with today?",
        style: TextStyle(fontSize: 40),
      ),
    );
  }
}

class Suggestions extends StatelessWidget {
  Widget _suggestions(String btnText) {
    return OutlineButton(
      borderSide: BorderSide(color: Colors.blue),
      child: Text(
        btnText,
        style: TextStyle(fontSize: 16),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Wrap(
          spacing: 10,
          children: <Widget>[
            _suggestions("Bill Payments"),
            _suggestions("Raise Complaint"),
          ],
        ),
      ),
    );
  }
}

class EditorArea extends StatefulWidget {
  @override
  _EditorAreaState createState() => _EditorAreaState();
}

class _EditorAreaState extends State<EditorArea> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isComposingMessage = false;
  Container _messageEditor() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.blueAccent,
                ),
                onPressed: null //getImage,
                ),
          ),
          Flexible(
            child: TextField(
              controller: _textEditingController,
              onChanged: (String messageText) {
                setState(() {
                  _isComposingMessage = messageText.length > 0;
                });
              },
              onSubmitted: null,
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _getDefaultSendButton(),
          ),
        ],
      ),
    );
  }

  RaisedButton _getDefaultSendButton() {
    return RaisedButton(
      //disabledColor: YellowColor,
      //disabledElevation: 0,
      color: _isComposingMessage ? YellowColor : PrimaryAccentColor,
      shape: CircleBorder(),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : () {
              // if (_isAvailable && !_isListening)
              //   _speechRecognition.listen(locale: "en_US").then((result) {
              //     print('I am here: $resultText');
              //     _textEditingController.text = resultText;
              //     _isComposingMessage = true;
              //   });
            },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          _isComposingMessage ? Icons.send : Icons.mic,
          color: TextColorLight,
          size: 30.0,
        ),
      ),
    );
  }

  Future<Null> _textMessageSubmitted(String text) async {
    print(_textEditingController.text);
    // DateTime now = DateTime.now();
    // setState(() {
    //   bubbles.add(Bubble(Message(_textEditingController.text,
    //       DateFormat('kk:mm').format(now), true, true)));
    // });
    // getJoke().then((value) {
    //   //print(value["value"]["joke"]);
    //   setState(() {
    //     bubbles.add(Bubble(Message(value["value"]["joke"],
    //         DateFormat('kk:mm').format(now), true, false)));
    //   });
    //   _scrollController.animateTo(
    //         0.0,
    //         curve: Curves.easeOut,
    //         duration: const Duration(milliseconds: 300),
    //       );
    // }).catchError((error) {
    //   print(error);
    // });

    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:  MediaQuery.of(context).size.height / 8,
      width: MediaQuery.of(context).size.width,
      color: PrimaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: TextField(
                cursorColor: TextColorLight,
                style: TextStyle(color: Colors.white, fontSize: 20),
                controller: _textEditingController,
                onChanged: (String messageText) {
                  setState(() {
                    _isComposingMessage = messageText.length > 0;
                  });
                },
                onSubmitted: null,
                decoration:
                    InputDecoration.collapsed(
                      hintText: "Send a message", 
                      hintStyle: TextStyle(color: primaryTextColor, fontSize: 20)
                      ),
              ),
            ),
            Wrap(
              children: <Widget>[
                RawMaterialButton(
                  onPressed: () {},
                  child: new Icon(
                    Icons.mic,
                    color: Colors.blue,
                    size: 25.0,
                  ),
                  shape: new CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(15.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SlideBottomRoute extends PageRouteBuilder {
  final Widget page;
  SlideBottomRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
