import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'upi_app_model.dart';

class UpiPayScreen extends StatefulWidget {
  final List<UpiResponse> installedUpiAppList;
  const UpiPayScreen(this.installedUpiAppList, {super.key});

  @override
  State<UpiPayScreen> createState() => _UpiPayScreenState();
}

class _UpiPayScreenState extends State<UpiPayScreen> {
  List<UpiApps> upiApps = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UpiApps().upiAppList.forEach((element) {
      Map<String, String> data = element;
      bool exists = false;
      widget.installedUpiAppList.forEach((installedList) {
        print('elemey same ${installedList.packageName} == ${data['packageName']}  -->  ${installedList.packageName == data['packageName']}');
        if (installedList.packageName == data['packageName']) {
          exists = installedList.packageName == data['packageName'];
          UpiApps upiApp = UpiApps(name: data['name'], imagePath: data['image'], packageName: data['packageName']);
          upiApps.add(upiApp);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upi Apps')),
      body: Container(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
            itemCount: upiApps.length,
            itemBuilder: (BuildContext context, int index) {
              UpiApps data = upiApps[index];
              //bool exists = false;
              // widget.installedUpiAppList.forEach((element) {
              //   print('elemey same ${element.packageName} == ${data['packageName']}  -->  ${element.packageName == data['packageName']}');
              //   if (element.packageName == data['packageName']) {
              //     exists = element.packageName == data['packageName'];
              //   }
              // });
              // print("exists : $exists");

              return InkWell(
                  onTap: () {
                    finish(context, data.packageName);
                    //return data.packageName;
                  },
                  child: Container(height: 75, width: 75, color: Colors.white, margin: EdgeInsets.all(10), child: Image(image: AssetImage(data.imagePath!))));
            }),
      ),
    );
  }
}
