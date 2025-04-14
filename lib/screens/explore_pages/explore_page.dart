import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  ListTile _currentTile = ListTile();
  int length =
      6; // this will be changed to  some sort of lenght function when SELECT functions are made

  void changeView(ListTile tile) {
    setState(() {
      _currentTile = tile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                  onPressed: () => changeView(exploreTile),
                  child: Text(
                    'Explore',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )),
              MaterialButton(
                  onPressed: () => changeView(friendTile),
                  child: Text('Friends',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
            ],
          ),
        ),
        body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: MediaQuery.of(context).size.height / 2,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: length,
                  itemBuilder: (BuildContext context, int position) {
                    return _currentTile;
                  }), //Pulls from database for either friends items or ideas that you
              //can do)
            )));
  }

  ListTile exploreTile = ListTile(
      title: MaterialButton(
          //Made in to a button to allow for links to page of the trip if needed, if not change back to sizedBox and remove onPressed: null,
          onPressed: null,
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 192, 202, 202),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Person')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Text('Trip Title'), Text('Trip Date Range')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Text('Location'), Text('Rating')],
                ),
                Text('Description of the trip and stuff they said')
              ],
            ),
          ))); //Tiles that will pull from API calls to show suggestions

  ListTile friendTile = ListTile(
    title: Column(),
  ); //Tiles that will check friends profiles for trips shared and then show them in chronological order
}
