import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../Connectivity/No_internet.dart';
import '../../../Connectivity/connectivity_provider.dart';
import '../../../model/CategoryModel.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/palette.dart';
import '../bottom_nav_bar.dart';
import 'CategoryListDetailedPage.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({Key? key}) : super(key: key);
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  List<CategoryModel> category = [];

  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getData();
  }

  getData() async {
    category = [];
    Map<String, String> map = {'client': Util.clientName};
    http.Response response = await http
        .post(Uri.parse('${Util.baseurl}category.php'), body: jsonEncode(map));
    try {
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['success']) {
          category = List<CategoryModel>.from(
              dec['categorylist'].map((i) => CategoryModel.fromJson(i)));
        }
      }
    } catch (e) {
      Util.logDebug(e);
    }
    if (mounted) {
      setState(() {});
    }
  }
  Future<bool> _onWillPop() async{
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Do you want to exit?',
                style: Util.txt(Palette.black, 16, FontWeight.w500)),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    SystemNavigator.pop(), //Navigator.of(context).pop(true)
                child: Text('Yes',
                    style: Util.txt(Palette.black, 14, FontWeight.w500)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: Util.txt(Palette.black, 14, FontWeight.w500),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        color: Palette.white,
        child: Padding(
          // padding: EdgeInsets.fromLTRB(0, 0, 0, Platform.isAndroid ? 0 : 20),
          padding: EdgeInsets.all(0),
          child: Scaffold(
            backgroundColor: Palette.background,
            appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Container(),
              backgroundColor: Palette.white,
              title: Text(
                'Categories',
                style: Util.txt(Palette.black, 20, FontWeight.w700),
              ),
              centerTitle: true,
            ),
            body: checkConnection(),
            // bottomSheet: Container(
            //   // color: Palette.white,
            //   height: Util.bottomNavBarHeight,
            //   child: const NavigationItemBar(
            //     state: 1,
            //   ),
            // ),
          ),
        ),
      ),
    );
  }

  Widget checkConnection() {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        return model.isOnline ? page() : const NoInternet();
      },
    );
  }

  page1() {
    return category.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                const SizedBox(
                  height: 4,
                ),
                for (var e in category)
                  Card(
                    surfaceTintColor: Colors.white,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                    child: ListTile(
                      title: Text(
                        e.name.capitalize.toString(),
                        style:Util.txt(Palette.black,16,FontWeight.w500),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        color: Palette.black,
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductList(
                                      name: e.name,
                                      state: 1,
                                    )));
                      },
                      dense: true,
                      contentPadding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
                    ),
                  ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          )
        : const Center(
            child: CupertinoActivityIndicator(),
          );
  }

  Widget page() {
    print(category.length);
    if (category.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lottie animation at the top
              SizedBox(
                width: MediaQuery.of(context).size.width*0.7, // Adjust the height as needed
                height: MediaQuery.of(context).size.width*0.7,
                child: Lottie.asset('assets/lottie/category_list.json'),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Explore Our Dishes', style: Util.txt(Palette.black, 20, FontWeight.w600),),
                    Text('Delight in a variety of expertly crafted dishes made with fresh, high-quality ingredients.', style: Util.txt(Palette.black, 12, FontWeight.w300),),
                  ],
                ),
              ),
              // GridView inside a Container with a fixed height
              Container(
                height: MediaQuery.of(context).size.height * 0.7, // Adjust as needed
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                  ),
                  itemCount: category.length,
                  itemBuilder: (context, index) {
                    final e = category[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductList(
                              name: e.name,
                              state: 1,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Palette.blue_tone_white,
                        elevation: 20,
                        shadowColor: Palette.blue_tone_light_4,
                        surfaceTintColor: Colors.white,
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min, // Ensure Column does not overflow
                          children: [
                            AspectRatio(
                              aspectRatio: 1 / 0.7, // Adjust as needed
                              child: Lottie.asset('assets/lottie/dish_prepare.json'),
                            ),
                            Text(
                              e.name.capitalize.toString(),
                              style: Util.txt(Palette.black, 18, FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 50), // Space at the bottom if needed
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }
  }

}
