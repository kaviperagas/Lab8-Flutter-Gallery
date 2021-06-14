import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gallery/screens/AddImage.dart';
import 'package:provider/provider.dart';


class DashboardScreen extends StatefulWidget {


  const DashboardScreen({
    Key key,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
);

ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
);

bool _light =true;

class _DashboardScreenState extends State<DashboardScreen> {
  final keyRefresh = GlobalKey<RefreshIndicatorState>();
  List<int> data = [];

  Widget makeImageGrid(){
    return GridView.builder(
        itemCount: 4,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context,index){
          return ImageGridItem(index);
        });
  }

  Future loadList() async{
    keyRefresh.currentState?.show();
    await Future.delayed(Duration(milliseconds: 4000));

    final random = Random();
    final data = List.generate(100, (_) => random.nextInt(100));

    setState(() => this.data = data);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme:_light? _lightTheme : _darkTheme,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Your Gallery'),
          actions: [
            Switch(value: _light,onChanged: (state){
              setState(() {
                _light = state;
              });
            },)

          ],
        ),
        body:RefreshIndicator(
          key: keyRefresh,
          onRefresh: loadList,
          child: Center(
            child: makeImageGrid(),
          ),

        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddImage()));
          },
        ),
      ),
    );
  }
}

class ImageGridItem extends StatefulWidget {
  int _index=0;

  ImageGridItem(int index){
    this._index = index;
  }

  @override
  _ImageGridItemState createState() => _ImageGridItemState();
}

class _ImageGridItemState extends State<ImageGridItem> {

  Uint8List imageFile;
  Reference photoref = FirebaseStorage.instance.ref().child('newfile');
  int i=1;

  getImage(){
    int MAX_SIZE = 7*1024*1024;

    photoref.child('image${widget._index}').getData(MAX_SIZE).then((data){
      i++;
      this.setState(() {
        imageFile= data;
      });

    }).catchError((error){

    });
  }

  Widget decideGrid(){
    if(imageFile==null){
      return Center(child: Text('No Images Added!'));
    }else{
      return Image.memory(imageFile,fit: BoxFit.cover,);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(child: decideGrid());
  }
}