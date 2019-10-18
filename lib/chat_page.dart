import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:speech_recognition/speech_recognition.dart';

import './utils/colors.dart';

enum MessageFormats { Text, Image, Link, Suggestions }

class Message {
  String message;
  String time;
  bool delivered;
  bool isMe;
  MessageFormats format;

  Message(this.message, this.time, this.delivered, this.isMe,
      [this.format = MessageFormats.Text]);
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  File _image;


  Future getImage() async {
        try {
        var image = await ImagePicker.pickImage(source: ImageSource.camera);
        setState(() {
      _image = image;
      print("Image Selected.");
    });
      } catch (e) {
        print(e);
      }

    
  }
  ScrollController _scrollController = new ScrollController();

  final TextEditingController _textEditingController = TextEditingController();
  bool _isComposingMessage = false;
  List<Widget> bubbles = [];
  List<Message> msgs = [
    Message("Hey there.", "11:00", true, true),
    Message("Hi. How may I help?", "11:01", true, false,
        MessageFormats.Suggestions),
    Message("Can you tell me about Yellow Messenger?", "11:01", true, true),
    Message("Sure thing.", "11:02", true, false),
    Message("images/mission.jpg", "11:02", true, false, MessageFormats.Image),
    Message(
        "Yellow Messenger is a leading omnichannel conversational AI tool that helps more than 100 top brands to offer personalised customer service at scale and drive growth.",
        "11:02",
        true,
        false),
    Message("Thanks.", "11:03", false, true),
  ];

  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => _textEditingController.text = speech),
      // (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
      () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: PrimaryDarkColor,
          elevation: 0.0,
          title: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
            child: Image.asset("images/Logo_footer.png"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            )
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Flexible(
                child: Container(
                  child: _chatBubbles(),
                ),
              ),
              Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _messageEditor(),
              ),
              // Container(width: 0.0, height: 0.0),
            ],
          ),
        ));
  }

  Widget _chatBubbles() {
    //Creating chat bubbles
    setState(() {
      if (bubbles.length < 1)
        for (Message msg in msgs) {
          bubbles.add(Bubble(msg));
        }
    });

    return ListView(
        controller: _scrollController,
        reverse: true,
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: bubbles,
          ),
        ]);
  }

  Container _messageEditor() {

    return Container(
      height: MediaQuery.of(context).size.height / 6,
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

    // return Container(
    //   margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    //   child: Row(
    //     children: <Widget>[
    //       Container(
    //         margin: EdgeInsets.symmetric(horizontal: 4.0),
    //         child: IconButton(
    //             icon: Icon(
    //               Icons.attach_file,
    //               color: Colors.blueAccent,
    //             ),
    //             onPressed: getImage,
    //             ),
    //       ),
    //       Flexible(
    //         child: TextField(
    //           controller: _textEditingController,
    //           onChanged: (String messageText) {
    //             setState(() {
    //               _isComposingMessage = messageText.length > 0;
    //             });
    //           },
    //           onSubmitted: null,
    //           decoration: InputDecoration.collapsed(hintText: "Send a message"),
    //         ),
    //       ),
    //       Container(
    //         margin: const EdgeInsets.symmetric(horizontal: 4.0),
    //         child: _getDefaultSendButton(),
    //       ),
    //     ],
    //   ),
    // );
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

                if (_isAvailable && !_isListening)
                _speechRecognition.listen(locale: "en_US").then((result) {
                  print('I am here: $resultText');
                  _textEditingController.text = resultText;
                  _isComposingMessage = true;
                });
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
    //print(_textEditingController.text);
    DateTime now = DateTime.now();
    setState(() {
      bubbles.add(Bubble(Message(_textEditingController.text,
          DateFormat('kk:mm').format(now), true, true)));
    });
    getJoke().then((value) {
      //print(value["value"]["joke"]);
      setState(() {
        bubbles.add(Bubble(Message(value["value"]["joke"],
            DateFormat('kk:mm').format(now), true, false)));
      });
      _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
    }).catchError((error) {
      print(error);
    });

    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });
  }
}

class Bubble extends StatelessWidget {
  Bubble(this.msg);

  final Message msg;
  Widget _messageBody() {
    Widget childElement;
    switch (msg.format) {
      case MessageFormats.Text:
        childElement = Text(msg.message);
        break;
      case MessageFormats.Link:
        childElement = Text(msg.message);
        break; //todo
      case MessageFormats.Suggestions:
        childElement = Column(
          children: <Widget>[
            Text(msg.message),
            OutlineButton(
                child: new Text("Suggestion 1"),
                onPressed: () {},
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0))),
            OutlineButton(
                child: new Text("Suggestion 2"),
                onPressed: () {},
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0))),
            OutlineButton(
                child: new Text("Suggestion 3"),
                onPressed: () {},
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0))),
          ],
        );
        break; //todo
      case MessageFormats.Image:
        childElement = Image.asset(
          msg.message,
          height: 300,
        );
        break;
      default:
        childElement = Container();
    }
    return childElement;
  }

  @override
  Widget build(BuildContext context) {
    //print(msg.format);
    final bg = msg.isMe ? Colors.yellowAccent.shade100 : Colors.white;
    final align = msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final icon = msg.delivered ? Icons.done_all : Icons.done;
    final radius = msg.isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );

    final messageBody = _messageBody();

    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: .5,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.12))
            ],
            color: bg,
            borderRadius: radius,
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 48.0),
                child: messageBody,
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                  children: <Widget>[
                    Text(msg.time,
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 10.0,
                        )),
                    SizedBox(width: 3.0),
                    Icon(
                      icon,
                      size: 12.0,
                      color: Colors.black38,
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}



Future<dynamic> getJoke() async {
  final baseUrl = "http://api.icndb.com/jokes/random";
  http.Response response = await http.get(Uri.parse(baseUrl));
  var data = json.decode(response.body);
  return data;
}
