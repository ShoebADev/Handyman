import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

import '../../../../main.dart';
import '../../../../utils/configs.dart';
import 'upi_app_model.dart';
import 'upi_pay.dart';

class PhonePeServices {
  bool enableLogs = true;

  String apiEndPoint = "/pg/v1/pay";
  String packageName = "com.phonepe.app";
  Map<String, String> headers = {};
  Map<String, String> pgHeaders = {"Content-Type": "application/json"};
  String callback = "https://webhook.site/callback-url";
  String saltIndex = '1';
  Map<dynamic, dynamic>? result;
  late String body;
  late String checkSum;
  late String generatedMerchantTransId;
  late String generatedUsersId;

  //PhonePe
  String generateRandomString(int len) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    var s = String.fromCharCodes(Iterable.generate(len, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    print('merchantTransactionId $s');
    print('merchantTransactionId ${s.toUpperCase()}');
    return s;
  }

  Future<void> createBodyAndCheckSum(double amount, String payType) async {
    print('payType is $payType');
    generatedMerchantTransId = generateRandomString(10).toUpperCase();
    generatedUsersId = generateRandomString(8).toUpperCase();
    Map<String, dynamic> requestBody = {
      "merchantId": PHONE_PAY_MERCHANTID,
      "merchantTransactionId": generatedMerchantTransId,
      "merchantUserId": generatedUsersId,
      "amount": amount,
      "redirectUrl": "https://webhook.site/redirect-url",
      "redirectMode": "REDIRECT",
      "callbackUrl": "https://webhook.site/callback-url",
      "mobileNumber": appStore.userContactNumber,
      //"paymentInstrument": {"type": "UPI_INTENT", "targetApp": "com.google.android.apps.nbu.paisa.user"},
      "paymentInstrument": payType == "PAY_PAGE" ? {"type": payType} : {"type": "UPI_INTENT", "targetApp": payType}
    };
    String jsonString = jsonEncode(requestBody);
    body = base64Encode(utf8.encode(jsonString));
    String bodyWithSaltKey = body + apiEndPoint + PHONE_PAY_SALTKEY;
    var shaValue = sha256.convert(utf8.encode(bodyWithSaltKey));
    String shaString = shaValue.toString();
    checkSum = shaString + '###' + saltIndex;
  }

  Future<Map<dynamic, dynamic>?> openPayment({
    required BuildContext context,
    required double amount,
    VoidCallback? finish,
  }) async {
    bool isInitialized = false;
    try {
      //  initPhonePeSdk();
      isInitialized = await PhonePePaymentSdk.init(PHONE_PAY_ENVIRONMENT, PHONE_PAY_APPID, PHONE_PAY_MERCHANTID, enableLogs).catchError((error) {
        finish?.call();
        return error;
      });
    } catch (e) {
      if (e is PlatformException) {
        if (e.details is Map && Map.from(e.details)['response'] != null) {
          throw '${e.message ?? ''} ${Map.from(e.details)['response']}';
        } else {
          throw '${e.message ?? ''} ${e.details}';
        }
      } else {
        finish?.call();
        rethrow;
      }
    }

    if (isInitialized) {
      PhonePePaymentSdk.getInstalledUpiAppsForAndroid().then((value) async {
        print('get uip app response $value');
        Iterable resp = jsonDecode(value!);
        List<UpiResponse> installedUpiAppList = resp.map((e) => UpiResponse.fromJson(e)).toList();

        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      //Navigator.pop(context);
                      String packageName = await UpiPayScreen(installedUpiAppList).launch(context);
                      await createBodyAndCheckSum(amount, packageName);
                      Future<Map<dynamic, dynamic>?> response = PhonePePaymentSdk.startPGTransaction(body, callback, checkSum, pgHeaders, apiEndPoint, packageName);
                      await response.then((val) {
                        result = val;
                        return val;
                      }).catchError((error) {
                        return error;
                      });
                    },
                    child: const Text('Pay With Upi Apps'),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () async {
                      //Navigator.pop(context);
                      await createBodyAndCheckSum(amount, "PAY_PAGE");
                      Future<Map<dynamic, dynamic>?> response = PhonePePaymentSdk.startPGTransaction(body, callback, checkSum, pgHeaders, apiEndPoint, packageName);
                      await response.then((val) {
                        result = val;
                        return val;
                      }).catchError((error) {
                        return error;
                      });
                    },
                    child: const Text('Pay with Cards'),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
    return result;
  }
}

// getPackageSignatureForAndroid();
void getPackageSignatureForAndroid() {
  if (Platform.isAndroid) {
    PhonePePaymentSdk.getPackageSignatureForAndroid().then((packageSignature) {
      print('PhonePeSdk packageSignature $packageSignature');
    }).catchError((error) {
      return error;
    });
  }
}
