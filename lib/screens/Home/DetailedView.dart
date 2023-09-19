import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../Model/Product_Model.dart';
import '../../utilities/AppManagement.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import 'CarouselDisplay.dart';
import 'HomeScreen.dart';
import 'NavigationItemBar.dart';
import 'ProductList.dart';
import 'package:http/http.dart' as http;
import 'Search.dart';


class DetailedView extends StatefulWidget {
   const DetailedView({Key? key, required this.name, required this.id, required this.state,}) : super(key: key);
    final String name;
    final String id;
    final int state;
  @override
  _DetailedViewState createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  String available = '';
  final GlobalKey<ScaffoldState> _scaffoldkey =  GlobalKey<ScaffoldState>();
  final Controller c = Get.put(Controller());
  List<ProductItemModel> prodList=[];
  List relatedData=[];
  List carousel = [];
  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getData();
  }
  getData()async{
    prodList=[];relatedData=[];
    String userid = await Util.getStringValuesSF('userid');
    available = await Util.getStringValuesSF('availability');
    try{
      final productList = http.MultipartRequest('POST',Uri.parse('${Util.baseurl}listbyid.php'));
      productList.fields['userid']=userid;
      productList.fields['client']=Util.clientName;
      productList.fields['id']=widget.id;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if(response.statusCode==200){
        var dec = jsonDecode(response.body);
        print('detailview:$dec');
        if (dec['success']) {
          for (int i = 0; i < dec['data'].length; i++) {
            carousel.add(dec['data'][i]['image']);
          }
        }     
        prodList.add(ProductItemModel(name: dec['data'][0]['name'], image: dec['data'][0]['image'][0], uuid: dec['data'][0]['uuid'], count: dec['data'][0]['count'],
              price: dec['data'][0]['price'], rating: dec['data'][0]['rating'],description:dec['data'][0]['description'],stock:dec['data'][0]['stock'],weight : dec['data'][0]['weight'],
              actualprice: dec['data'][0]['actualprice'].toString(),discount:dec['data'][0]['discount'].toString()));
        relatedData.addAll(dec['relateddata']);
      }
    }catch(e){Util.logDebug(e);}
    if(mounted) {
      setState(() {
    });
    }
  }
  nav(){
    if(widget.state==2){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
      c.nav.value=0;
    }
    else if(widget.state==3){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>const Search(share: {'state':0},)));
      c.nav.value=2;
    }
    else{
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductList(state: widget.state, name: widget.name,)));
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        nav();
        return true;
      },
      child: Container(
        color: Palette.white,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, Platform.isAndroid?0:20),
          child: Scaffold(
            key: _scaffoldkey,
            backgroundColor: Palette.background,
            extendBodyBehindAppBar:true,
            body: SafeArea(
                child: checkConnection()),
            bottomSheet: Container(
              color: Palette.white,
              height: 50,
              child: const NavigationItemBar(state: 5,),
            ),
          ),
        ),
      ),
    );
  }
  Widget checkConnection() {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        return model.isOnline
            ? page()
            : NoInternet();
      },
    );
  }

  page() {
    return ListView(
      children: [
        productDetail(),
        const SizedBox(height: 20.0,),
        relatedProducts(),
        const SizedBox(height: 50.0,)
      ],
    );
  }
 Widget productDetail(){
    return prodList.isNotEmpty?Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: nav,
              icon: Icon(Platform.isAndroid?Icons.arrow_back:Icons.arrow_back_ios,color: Palette.black,),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(prodList[0].name,style: Util.txt(Palette.black, 16, FontWeight.w500),softWrap: true),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 2, 10, 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 30.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RatingBarIndicator(
                        // initialRating: catItmL[i]['priority']!='' && catItmL[i]['priority']!=null?double.parse(catItmL[i]['priority'])>5.0?5.0:double.parse(catItmL[i]['priority']):1,
                        rating: double.parse(prodList[0].rating),
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: 20.0,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        carousel[0].isNotEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.width < 600 ? 220.0 : 500.0,
                  child: CarouselDisplay(
                    image: carousel[0],
                  ))
              : CarouselDisplay(image: [prodList[0].image]),
        //CarouselDisplay(image:[prodList[0].image]),
        Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
          child: Column(
            children: [
              if(prodList[0].weight!='')
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                child: Row(
                  children: [
                    Text(prodList[0].weight,style: Util.txt(Palette.black, 16, FontWeight.w500),),
                  ],
                ),
              ),
              if(prodList[0].discount!='' && prodList[0].discount!='0')
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                  child: Row(
                    children: <Widget>[
                      Text('\u20B9 ${prodList[0].actualprice}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20,color: Palette.gray,decoration: TextDecoration.lineThrough,decorationColor: Colors.red),),
                      Text('   ${prodList[0].discount} %',style: Util.txt(Colors.red, 20, FontWeight.w500),)
                    ],
                  ),
                ),
              Row(
                children: <Widget>[
                  Text('\u20B9 ',style: Util.txt(Colors.red, 20, FontWeight.w500),),
                  Text(prodList[0].price,style: Util.txt(Palette.black, 28, FontWeight.w600),),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            prodList[0].stock!='not available'?Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Visibility(
                        visible: prodList[0].count==0?true:false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 60,height: 30,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(20.0),
                                // ),
                                child: OutlinedButton(onPressed: () async {
                                  String userid = await Util.getStringValuesSF('userid');
                                  available = await Util.getStringValuesSF('availability');
                                  print('status is : $available');
                                  if(available.toString() == '1') {
                                    onlineCart(prodList[0].uuid, 0, 1);
                                  }else{if(userid==''||userid.toString()=='null'){Util.showLoginPop(_scaffoldkey.currentContext!,'Please Login to continue...',{'nav':0,'name':widget.name,'state':widget.state});return;};Util.customDialog('sorry, we are not accepting orders at this moment','',context);}
                                },
                                  style: ButtonStyle(
                                      side: MaterialStateProperty.all(BorderSide(color: Palette.black,width: 1.2)),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))))
                                  ), child: Text('ADD',style: Util.txt(Palette.black, 16, FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: prodList[0].count==0?false:true,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 30,height: 30,
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(10.0),
                              //   border: Border.all(color: Palette.black,width: 2.0),
                              // ),
                              child: OutlinedButton(onPressed: (){
                                setState(() {
                                  int sky = prodList[0].count-1;
                                  if(sky>=1){
                                    onlineCart(prodList[0].uuid, 0, sky);
                                  }
                                  if(sky==0){
                                    onlineCart(prodList[0].uuid, 0, 0);
                                  }
                                });
                              },//
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 0.0)),
                                    side: MaterialStateProperty.all(BorderSide(color: Palette.black,width: 1.2)),
                                    shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))))
                                ),
                                child:prodList[0].count==1?Icon(Icons.delete_outline,color: Palette.black):Icon(Icons.remove,color: Palette.black,),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                height: 30,width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color:  Palette.black,width: 1.2),
                                ),
                                child:Center(child: Text(prodList[0].count.toString(),textAlign: TextAlign.center,)),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              height: 30,
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(10.0),
                              //   border: Border.all(color: Colors.teal,width: 2.0),
                              // ),
                              child: OutlinedButton(onPressed: (){
                                int sky=prodList[0].count+1;
                                onlineCart(prodList[0].uuid, 0, sky);
                              },
                                style: ButtonStyle(
                                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 0.0)),
                                    side: MaterialStateProperty.all(BorderSide(color: Palette.black,width: 1.2)),
                                    shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))))
                                ),
                                child: Icon(Icons.add,color: Palette.black,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ):
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 0, 2),
              child: Text('Out of Stock',style: Util.txt(Colors.orange, 18, FontWeight.w500),softWrap: true,textAlign: TextAlign.justify,),
            ),
          ],
        ),
        if(prodList[0].description != '')
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text('Description',style: Util.txt(Palette.black, 18, FontWeight.w600),softWrap: true,textAlign: TextAlign.justify,),
            ),
          ],
        ),
        // Row(
        //   children: [
        //     Flexible(
        //       child: Padding(
        //         padding: const EdgeInsets.all(5.0),
        //         child: Text(prodList[0].description,style: Util.txt(Palette.black, 16, FontWeight.w400),softWrap: true,textAlign: TextAlign.justify,),
        //       ),
        //     ),
        //   ],
        // ),
        if(prodList[0].description != '')
        Row(
          children: [
           // Html(data: prodList[0].description,)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
                child:Text(prodList[0].description,style: Util.txt(Palette.black, 14, FontWeight.w500),),
              ),
            ), 
         ],
        ),
      ]
    ):const Center(child: CupertinoActivityIndicator(),);
 }
 Widget relatedProducts(){
    return relatedData.isNotEmpty?Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 12, 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Related Products',style: Util.txt(Palette.black, 16, FontWeight.w500),maxLines: 1,)),
            ],
          ),
        ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(height: 220,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                children: [
                  for(int j=0;j<relatedData.length;j++)
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailedView(name: '', id: relatedData[j]['uuid'], state: 2)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Stack(
                          children: [
                            Column(
                              children: <Widget>[
                                Card(elevation:0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  child: Container(
                                    height: 160.0,width: 120.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image:NetworkImage(relatedData[j]['image']),//
                                        fit: BoxFit.fill,
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 120.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Text(relatedData[j]['name'],style: Util.txt(Palette.black, 14, FontWeight.w300),textAlign: TextAlign.center,softWrap: true,overflow: TextOverflow.clip,maxLines: 2,),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if(relatedData[j]['discount']!='' && relatedData[j]['discount']!='0')
                              Positioned(
                                top: 2,right: 2,
                                child: Card(
                                  color: Palette.green,
                                  clipBehavior: Clip.none,elevation: 0,margin: EdgeInsets.zero,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                                    child: Text(relatedData[j]['discount']+'%  OFF',style: Util.txt(Palette.white, 12, FontWeight.normal),),
                                  ),
                                ),

                              )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    ):Container();
 }
  //---------
  onlineCart(String itemcode,int index,int count)async{
    String userid = await Util.getStringValuesSF('userid');
    if(userid==''||userid.toString()=='null'){
      Util.showLoginPop(_scaffoldkey.currentContext!,'Please Login to continue...',{'nav':2,'id':widget.id,'name':widget.name,'state':widget.state});
    }
    else{
      Map<String,String>map={'userid':userid,'itemcode':itemcode,'count':count.toString(),'client':Util.clientName};
      var response = await http.post(Uri.parse('${Util.baseurl}carttemp.php'),body: jsonEncode(map));
      try{
        if(response.statusCode==200){
          var dec = jsonDecode(response.body);
          if(dec['status']=='1'){
            c.cart.value=dec['count'];
          }
          prodList[index].count=count;
        }
      }catch(e){
        Map<String,String>map = {'email':userid,'instance':'count update and delete','error':e.toString()};
        var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),body: jsonEncode(map));
        if(respo.statusCode==200){}
      }
    }
    setState(() {

    });
  }
//----------

}
