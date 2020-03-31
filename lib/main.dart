import 'dart:async';
import 'dart:convert' as convert;
import 'package:flag/flag.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ncovid/Constant.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:ncovid/model/International.dart';
import 'package:ncovid/model/Vietnam.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider
      (
        create: (context)=>Vietnam(),
        child: MyHomePage(title: 'Flutter Demo Home Page')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool isLoading = true;
  Timer timer;
  final hr = Divider();
  Vietnam vietnam = new Vietnam();
   International international = new International();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
    String _currentChoice = "Số ca";
  void _onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    await _makeGetRequest();
    _refreshController.refreshCompleted();
    
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    await _makeGetRequest();
    if(mounted)
    setState(() {

    });
    _refreshController.loadComplete();
  }

  
  Future<void> _makeGetRequest() async {
  var url = 'https://code.junookyo.xyz/api/ncov-moh/data.json';

  // Await the http get response, then decode the json-formatted response.
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    vietnam = Vietnam.fromJson(jsonResponse);

    setState(() {
      isLoading=false;
       vietnam = Vietnam.fromJson(jsonResponse);
    });

  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}
 Future<void>  _makeWHOGetRequest() async {
  var url = 'https://corona-api.com/countries';

  // Await the http get response, then decode the json-formatted response.
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse = convert.jsonDecode(response.body);
    
    setState(() {
       international = International.fromJson(jsonResponse);
       choiceAction(_currentChoice);
       //international.data.sort((b, a) => a.latestData.confirmed.compareTo(b.latestData.confirmed));
    });

  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}
//

  
  @override
  void initState() {
    
    super.initState();
     timer = Timer.periodic(Duration(seconds: 5), (Timer t) { 
    _makeGetRequest();
    _makeWHOGetRequest();});
    //  _makeGetRequest();
    // _makeWHOGetRequest();

  }
  void choiceAction(String choice){
    _currentChoice = choice;
   if(choice ==Constant.sum){
      setState(() {
        international.data.sort((b, a) => a.latestData.confirmed.compareTo(b.latestData.confirmed));
      });
   }
   else if(choice ==Constant.death){
      setState(() {
        international.data.sort((b, a) => a.latestData.deaths.compareTo(b.latestData.deaths));
      });
   }
   else if(choice ==Constant.recovery){
      setState(() {
        international.data.sort((b, a) => a.latestData.recovered.compareTo(b.latestData.recovered));
      });
   }else if(choice ==Constant.critical){
      setState(() {
        international.data.sort((b, a) => a.latestData.critical.compareTo(b.latestData.critical));
      });
   }else if(choice ==Constant.recoverRatio){
      setState(() {
        international.data.sort((b, a) => international.calculateRatio(a.latestData.recovered, a.latestData.confirmed).compareTo(international.calculateRatio(b.latestData.recovered, b.latestData.confirmed)));
      });
   }
   else if(choice ==Constant.deathRatio){
      setState(() {
        international.data.sort((b, a) => international.calculateRatio(a.latestData.deaths, a.latestData.confirmed).compareTo(international.calculateRatio(b.latestData.deaths, b.latestData.confirmed)));
      });
   }
   if(choice ==Constant.alphabet){
      setState(() {
        international.data.sort((a, b) => a.name.compareTo(b.name));
      });
   }
  }
@override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    Vietnam vietname = Provider.of<Vietnam>(context);

    return Scaffold(
      appBar: AppBar(
       
        title: Text("nCovid Tracker"),
        actions: <Widget>[
          
            PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext context){
                return Constant.option.map((String choice){
                return PopupMenuItem(value: choice,
                child: Text(choice),
                );
                }).toList();
              },
            )
        ],
      ),
      body: isLoading
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                child: SpinKitWave(
                     color: Colors.blueAccent,
                     size: 30,
                ),
              ),
                Padding(
                  padding: EdgeInsets.only(top: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Đang lấy dữ liệu , vui lòng chờ ",
                    style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 20
                  ),
                ),
                SpinKitThreeBounce(
                  color: Colors.grey,
                  size: 13,
                )
                  ],
                ),
              ],
            )
            ://else
            SmartRefresher(
              controller: _refreshController,
        onRefresh: _onRefresh,
        //onLoading: _onLoading,
        enablePullDown: true,
        //enablePullUp: true,
        header: WaterDropHeader(),
                          child: SingleChildScrollView(
                                                      child: Container(
        
          child: Column(children: <Widget>[
            vietnamCard(),
            Text("Nguồn : Bộ Y Tế"),
            globalCard(),
            Text("Nguồn : Bộ Y Tế"),

            hightline("Thống kê các quốc gia khác",Colors.redAccent),
            hightline(_currentChoice,Colors.blueAccent),
            for(int i =0;i<international.data.length;i++) international.data[i].latestData.confirmed<1?Container(): detailCard(i),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          ),
                                          hr,
          ],),
        
      ),
                          ),
            ),
    );
  }
  Widget card(String title, String content) {
    return Row(
      children: <Widget>[
        
        Padding(
          padding: const EdgeInsets.only(left:10  ),
          child: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left:5),
              child: Text(content,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
            )),
      ],
    );
  }
  Widget vietnamCard(){
    return Column(children: <Widget>[
      Column(
                                            children: <Widget>[
                                               new Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: new BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: new DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: new NetworkImage(
                                                                        "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Flag_of_Vietnam.svg/2000px-Flag_of_Vietnam.svg.png")))),
                                            ],
                                          ),
                                          hr,
      Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          ),
                                          card("Tổng số trường hợp: ",
                                              vietnam.data.vietnam.cases),
                                          hr,
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          ),
                                          card("Tổng số ca đã hồi phục: ",
                                              vietnam.data.vietnam.recovered),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Tỷ lệ hồi phục: ",
                                                international.calculateRatio(int.parse(vietnam.data.vietnam.recovered), int.parse(vietnam.data.vietnam.cases)).toStringAsFixed(1)+"%"
                                                )
                                          ,
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),

                                           card("Tổng số ca tử vong: ",
                                              vietnam.data.vietnam.deaths),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          
                                          card("Tỷ lệ tử vong: ",
                                                international.calculateRatio(int.parse(vietnam.data.vietnam.deaths), int.parse(vietnam.data.vietnam.cases)).toStringAsFixed(1)+"%"
                                                )
                                          ,
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
    ],);
  }
  Widget detailCard(int i){
    return Column(children: <Widget>[
      
                                          hr,
                                           Flags.getMiniFlag(international.data[i].code, 50, null),
      Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          ),
                                          Text((rank+1).toString()),
                                          card("Quốc gia: ",
                                              international.data[i].name),
                                          hr,
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          ),
                                          card("Tổng số ca : ",
                                              international.data[i].latestData.confirmed.toString()),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Tổng số ca đã hồi phục: ",
                                              international.data[i].latestData.recovered.toString()),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Tỉ lệ hồi phục: ",
                                             international.calculateRatio(international.data[i].latestData.recovered, international.data[i].latestData.confirmed).toStringAsFixed(1)+"%"),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Số ca đang nguy kịch ",
                                             international.data[i].latestData.critical.toString()),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Tống số ca tử vong: ",
                                             international.data[i].latestData.deaths.toString()),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Tỉ lệ tử vong: ",
                                             international.calculateRatio(international.data[i].latestData.deaths, international.data[i].latestData.confirmed).toStringAsFixed(1)+"%"),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Ca nhiễm mới nhất: ",
                                             international.data[i].today.confirmed.toString()),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Ca tử vong mới nhất: ",
                                             international.data[i].today.deaths.toString()),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          )
                                          
    ],);
  }
  Widget globalCard(){
    return Column(children: <Widget>[
      Column(
                                            children: <Widget>[
                                               new Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration: new BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: new DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: new NetworkImage(
                                                                        "https://www.fairobserver.com/wp-content/uploads/2019/10/Earth.jpg")))),
                                            ],
                                          ),
                                          hr,
      Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          ),
                                          card("Tổng số trường hợp: ",
                                              vietnam.data.global.cases),
                                          hr,
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          ),
                                          card("Tổng số ca đã hồi phục: ",
                                              vietnam.data.global.recovered),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Tỷ lệ hồi phục trung bình: ",
                                                international.calculateRatio(int.parse(vietnam.data.global.recovered), int.parse(vietnam.data.global.cases)).toStringAsFixed(1)+"%"
                                                )
                                          ,Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          
                                          card("Tổng số ca tử vong: ",
                                              vietnam.data.global.deaths),
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
                                          card("Tỷ lệ tử vong trung bình: ",
                                                international.calculateRatio(int.parse(vietnam.data.global.deaths), int.parse(vietnam.data.global.cases)).toStringAsFixed(1)+"%"
                                                )
                                          ,
                                          Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(0, 0, 0, 20),
                                          ),
    ],);
  }
  Widget hightline(String title,Color colors) {
    return Padding(
                                padding: EdgeInsets.only(
                                  top: 50,
                                    right: 0,
                                    left: 0,
                                    bottom: 0),
                                child: Material(
                                  elevation: 10.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                  shadowColor: Colors.white,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        ),
                                        Wrap(
                                          children: <Widget>[
                                            Icon(Icons.sort,
                                            color: Colors.blueAccent,
                                            ),
                                            Text(
                                              title,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: colors,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 0, 0, 0),
                                            )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  ),
                                ),
                              );
  }
}
