


import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class Content extends StatefulWidget {
  final String title;
  final String reference;

  Content({Key key, @required this.title, @required this.reference}) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(toolbarHeight:150,title:Text('${widget.title}',style: TextStyle(fontSize: 40),),),
      body: Container(
        color: Colors.grey[600],
        child: WebView(initialUrl: widget.reference,
          javascriptMode: JavascriptMode.unrestricted,),
      ),
    );
  }
}
