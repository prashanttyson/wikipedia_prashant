import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:valuelabs_prashant/pages/content.dart';

class PagesHome extends StatefulWidget {
  const PagesHome({Key key}) : super(key: key);

  @override
  _PagesHomeState createState() => new _PagesHomeState();
}

class _PagesHomeState extends State<PagesHome> {
  final _searchFetcher = new _Fetcher();
  String _searchingQuery = '';
  List<_EntryWithReference> _fetchedSearchingEntries = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.grey[300],
        body: new CustomScrollView(slivers: <Widget>[
          new SliverAppBar(
              title: Text('Wiki Search Anything'),
              centerTitle: true,
              expandedHeight: 56.0,
              floating: true,
              snap: true,
              flexibleSpace: new FlexibleSpaceBar(
                  background: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Container(
                    child: new Center(child: new _AnimatedTitleText()),
                  )
                ],
              ))),
          new SliverList(delegate: new SliverChildListDelegate([_searchBar()])),
          _buildContent(context),
        ]));
  }

  Widget _buildContent(BuildContext context) {
    if (_fetchedSearchingEntries == null) {
      // NOTE which means loading
      return new SliverFillRemaining(
          child: new Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 50,
          ),
          Text('Hold on & Wait for the Result'),
        ],
      )));
    }

    return new SliverList(
        delegate: new SliverChildListDelegate(_buildEntriesList(context)));
  }

  Widget _searchBar() {
    return new Container(
        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
        child: new Card(
            child: new Container(
                padding: EdgeInsets.only(left: 20),
                child: new TextField(
                  onChanged: _handleSearchTextChanged,
                  decoration: const InputDecoration(
                      hintText: 'Type Something to search',
                      suffixIcon: (Icon(Icons.search_rounded))),
                ))));
  }

  void _handleSearchTextChanged(String str) {
    if (str == _searchingQuery) {
      return;
    }
    if (str == '') {
      return;
    }

    setState(() {
      _searchingQuery = str;
      _fetchedSearchingEntries = null;
    });

    _searchFetcher
        .search(str)
        .then((List<_EntryWithReference> fetchedSearchingEntries) {
      setState(() {
        _fetchedSearchingEntries = fetchedSearchingEntries;
      });
    });
  }

  List<Widget> _buildEntriesList(BuildContext context) {
    List<Widget> list = [];

    if (_fetchedSearchingEntries.isNotEmpty) {
      for (_EntryWithReference e in _fetchedSearchingEntries) {
        list
          ..add(
            Card(
              shadowColor: Colors.black,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(top: 20, left: 20, bottom: 10),
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Content(
                                  title: e.title,
                                  reference: '${e.reference}',
                                ),
                              ));
                        },
                        child: Text(
                          e.title,
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(left: 20, bottom: 5, top: 10),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Content(
                                  title: e.title,
                                  reference: '${e.reference}',
                                ),
                              ));
                        },
                        child: Text(
                          e.reference,
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        )),
                  ),
                ],
              ),
            ),
          )
          ..add(const SizedBox(
            height: 2,
          ));
      }

      list.removeLast(); // remove last divider
    }

    return [
      new Container(
        color: Colors.transparent,
        margin: EdgeInsets.all(8.0),
        child: new Column(children: list),
      )
    ];
  }
}

class _Fetcher {
  http.Client client = new http.Client();

  Future<List<_EntryWithReference>> search(String str) async {
    client.close();

    client = new http.Client();

    final String url =
        "https://en.wikipedia.org/w/api.php?action=opensearch&format=json&errorformat=bc&search=$str&namespace=0&limit=100&suggest=1&utf8=1&formatversion=2&prop=revisions&prop=content&section=0";

    final List fetched = json.decode(await client.read(url)) as List;

    client.close();

    List<_EntryWithReference> entries = [];
    for (var i = 0; i < (fetched[1] as List).length; i++) {
      entries.add(new _EntryWithReference(
          title: fetched[1][i], reference: fetched[3][i]));
    }

    return entries;
  }
}

class _EntryWithReference {
  final String title;
  final String reference;

  _EntryWithReference({this.title, this.reference});
}

class _AnimatedTitleText extends StatefulWidget {
  const _AnimatedTitleText({Key key}) : super(key: key);

  @override
  _AnimatedTitleTextState createState() => new _AnimatedTitleTextState();
}

class _AnimatedTitleTextState extends State<_AnimatedTitleText> {
  final String fullText = "WikiPedia";
  String _currentString = "";
  Timer _timer;

  @override
  void initState() {
    super.initState();

    new Timer(const Duration(milliseconds: 1024), _start);
  }

  @override
  Widget build(BuildContext context) {
    return new Text(
      _currentString,
    );
  }

  void _start() {
    _timer =
        new Timer.periodic(const Duration(milliseconds: 64), (Timer timer) {
      final newLength = _currentString.length + 1;
      if (newLength > fullText.length) {
        _stop();
      } else {
        setState(() {
          _currentString = fullText.substring(0, newLength);
        });
      }
    });
  }

  void _stop() {
    _timer.cancel();
  }
}
