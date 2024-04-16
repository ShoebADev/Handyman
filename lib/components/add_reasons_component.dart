import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/common.dart';
import '../utils/configs.dart';

class AddReasonsComponent extends StatefulWidget {
  const AddReasonsComponent({Key? key}) : super(key: key);

  @override
  State<AddReasonsComponent> createState() => _AddReasonsComponentState();
}

class _AddReasonsComponentState extends State<AddReasonsComponent> {
  TextEditingController reasonsCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.width(),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              backgroundColor: primaryColor,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //TODO String Translation
                Text("Add Reason", style: boldTextStyle(color: white)).expand(),
                CloseButton(color: Colors.white),
              ],
            ),
          ),
          AppTextField(
            textFieldType: TextFieldType.NAME,
            controller: reasonsCont,
            //TODO String Translation
            decoration: inputDecoration(context, hint: "write reason"),
          ).paddingAll(16),
          AppButton(
            text: languages.btnSave,
            color: primaryColor,
            textStyle: boldTextStyle(color: white),
            width: context.width() - context.navigationBarHeight,
            onTap: () {
              if (reasonsCont.text.isNotEmpty) {
                finish(context, reasonsCont.text);
              } else {
                //TODO String Translation
                toast("Please add Reason!");
              }
            },
          ).paddingAll(16),
        ],
      ),
    ).paddingAll(0);
  }
}
