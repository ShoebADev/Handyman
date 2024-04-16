import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import '../../../../components/app_widgets.dart';
import '../../../../components/cached_image_widget.dart';
import '../../../../networks/network_utils.dart';
import '../../../../utils/common.dart';
import '../../../../utils/configs.dart';
import '../../../../utils/images.dart' hide delete;
import 'airtel_payment_response.dart';
import 'aritel_auth_model.dart';

class AirtelMoneyDialog extends StatefulWidget {
  final String reference;
  final int bookingId;
  final num amount;
  final Function(Map<String, dynamic>) onComplete;
  const AirtelMoneyDialog({
    super.key,
    required this.onComplete,
    required this.reference,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<AirtelMoneyDialog> createState() => _AirtelMoneyDialogState();
}

class _AirtelMoneyDialogState extends State<AirtelMoneyDialog> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _textFieldMSISDN = TextEditingController();

  bool isTxnInProgress = false;
  bool isSuccess = false;
  bool isFailToGenerateReq = false;
  String responseCode = "";

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: context.width(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isFailToGenerateReq
                  ? Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
                          child: const Icon(Icons.close_sharp, color: Colors.white),
                        ),
                        10.height,
                        Text(getAirtelMoneyReasonTextFromCode(responseCode).$1, style: boldTextStyle()),
                        16.height,
                        Text(getAirtelMoneyReasonTextFromCode(responseCode).$2, textAlign: TextAlign.center, style: secondaryTextStyle()),
                      ],
                    ).paddingAll(16)
                  : isSuccess
                      ? Column(
                          children: [
                            CachedImageWidget(url: ic_verified, height: 60),
                            10.height,
                            //TODO localization
                            Text("Payment Success", style: boldTextStyle()),
                            16.height,
                            //TODO localization
                            Text("Redirecting to bookings..", textAlign: TextAlign.center, style: secondaryTextStyle()),
                          ],
                        ).paddingAll(16)
                      : isTxnInProgress
                          ? Column(
                              children: [
                                LoaderWidget(),
                                10.height,
                                //TODO localization
                                Text("Transaction is in process...", style: boldTextStyle()),
                                16.height,
                                //TODO localization
                                Text("Please check the payment request is sent to your number", textAlign: TextAlign.center, style: secondaryTextStyle()),
                              ],
                            ).paddingAll(16)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Form(
                                  key: formKey,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  child: AppTextField(
                                    controller: _textFieldMSISDN,
                                    textFieldType: TextFieldType.NAME,
                                    //TODO localization
                                    decoration: inputDecoration(context, hint: "Enter your msisdn here"),
                                  ),
                                ),
                                16.height,
                                AppButton(
                                  color: primaryColor,
                                  height: 40,
                                  text: languages.lblSubmit,
                                  textStyle: boldTextStyle(color: Colors.white),
                                  width: context.width() - context.navigationBarHeight,
                                  onTap: () {
                                    hideKeyboard(context);
                                    maxApiCallCount = 30;
                                    _handleClick();
                                  },
                                ),
                              ],
                            ).paddingAll(16)
            ],
          ),
        ),
        Observer(
          builder: (context) => LoaderWidget().withSize(height: 80, width: 80).visible(appStore.isLoading && !isTxnInProgress),
        )
      ],
    );
  }

  void _handleClick() async {
    String transactionId = "${const Uuid().v1()}-${widget.bookingId}";

    isFailToGenerateReq = false;
    responseCode = "";

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.isLoading = true;
      await authorizeAirtelClient().then((value) async {
        log('acess tokn ${value.accessToken}');
        await paymentAirtelClient(
          reference: APP_NAME,
          txnId: transactionId,
          msisdn: _textFieldMSISDN.text.trim(),
          amount: widget.amount,
          accessToken: value.accessToken.validate(),
        ).then((value) async {
          if (value.status != null && value.status!.responseCode == AirtelMoneyResponseCodes.IN_PROCESS) {
            isTxnInProgress = true;
            setState(() {});
            isSuccess = await checkAirtelPaymentStatus(
              transactionId,
              loderOnOFF: (p0) {
                appStore.setLoading(p0);
              },
            );
            setState(() {});
            if (isSuccess) {
              widget.onComplete.call({
                'transaction_id': transactionId,
              });
            }
          } else if (value.status != null) {
            isFailToGenerateReq = true;
            responseCode = value.status!.responseCode.validate();
            setState(() {});
          }
        });
        appStore.setLoading(false);
      });
    }
  }
}

//region airtel pay
Future<AirtelAuthModel> authorizeAirtelClient() async {
  Map<dynamic, dynamic>? request = {"client_id": AIRTEL_CLIENT_ID, "client_secret": AIRTEL_CLIENT_SECRET, "grant_type": "client_credentials"};

  return AirtelAuthModel.fromJson(await handleResponse(await airtelPayBuildHttpResponse('auth/oauth2/token', request: request, method: HttpMethodType.POST)));
}

Future<AirtelPaymentResponse> paymentAirtelClient({
  required String reference,
  required String accessToken,
  required String txnId,
  required String msisdn,
  required num amount,
}) async {
  Map<dynamic, dynamic>? request = {
    "reference": reference,
    "subscriber": {"country": AIRTEL_COUNTRY_CODE, "currency": AIRTEL_CURRENCY_CODE, "msisdn": msisdn},
    "transaction": {"amount": amount, "country": AIRTEL_COUNTRY_CODE, "currency": AIRTEL_CURRENCY_CODE, "id": txnId}
  };

  return AirtelPaymentResponse.fromJson(
    await handleResponse(
      await airtelPayBuildHttpResponse(
        'merchant/v1/payments/',
        request: request,
        method: HttpMethodType.POST,
        extraKeys: {'X-Country': AIRTEL_COUNTRY_CODE, 'X-Currency': AIRTEL_CURRENCY_CODE, 'access_token': accessToken, 'isAirtelMoney': true},
      ),
    ),
  );
}

int maxApiCallCount = 30;
AirtelPaymentResponse res = AirtelPaymentResponse();
Future<bool> checkAirtelPaymentStatus(
  String txnId, {
  required Function(bool) loderOnOFF,
}) async {
  bool isSuccess = false;
  if (maxApiCallCount <= 0) {
    return isSuccess;
  }
  await authorizeAirtelClient().then((value) async {
    log('acess tokn ${value.accessToken}');
    log('maxApiCallCount is $maxApiCallCount');

    res = AirtelPaymentResponse.fromJson(await handleResponse(
        await airtelPayBuildHttpResponse('standard/v1/payments/$txnId', extraKeys: {'X-Country': AIRTEL_COUNTRY_CODE, 'X-Currency': AIRTEL_CURRENCY_CODE, 'access_token': '${value.accessToken}', 'isAirtelMoney': true}, method: HttpMethodType.GET)));
    if (res.status != null && res.status!.responseCode == AirtelMoneyResponseCodes.SUCCESS) {
      isSuccess = true;
      return isSuccess;
    } else if (maxApiCallCount > 0 && res.status != null && res.status!.responseCode == AirtelMoneyResponseCodes.IN_PROCESS) {
      await Future.delayed(const Duration(seconds: 2));
      maxApiCallCount--;
      // toast("$maxApiCallCount");
      isSuccess = await checkAirtelPaymentStatus(txnId, loderOnOFF: loderOnOFF);
    } else {
      loderOnOFF(false);
      log('return here');
      return isSuccess;
    }
  });
  return isSuccess;
}

Future<Response> airtelPayBuildHttpResponse(
  String endPoint, {
  HttpMethodType method = HttpMethodType.GET,
  Map? request,
  Map? extraKeys,
}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens(extraKeys: extraKeys);
    //  Uri url = buildBaseUrl(endPoint);
    Uri url = Uri.parse(endPoint);
    url = Uri.parse('$AIRTEL_BASE$endPoint');

    Response response;
    print('url : $url');
    if (method == HttpMethodType.POST) {
      log('Request: ${jsonEncode(request)}');
      response = await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethodType.DELETE) {
      response = await delete(url, headers: headers);
    } else if (method == HttpMethodType.PUT) {
      response = await put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await get(url, headers: headers);
    }

    log('Response (${method.name}) ${response.statusCode}: ${response.body}');

    return response;
  } else {
    throw errorInternetNotAvailable;
  }
}

//Airtel Money Constants
// region AirtelMoney Const
class AirtelMoneyResponseCodes {
  static const AMBIGUOUS = "DP00800001000";
  static const SUCCESS = "DP00800001001";
  static const INCORRECT_PIN = "DP00800001002";
  static const LIMIT_EXCEEDED = "DP00800001003";
  static const INVALID_AMOUNT = "DP00800001004";
  static const INVALID_TRANSACTION_ID = "DP00800001005";
  static const IN_PROCESS = "DP00800001006";
  static const INSUFFICIENT_BALANCE = "DP00800001007";
  static const REFUSED = "DP00800001008";
  static const DO_NOT_HONOR = "DP00800001009";
  static const TRANSACTION_NOT_PERMITTED = "DP00800001010";
  static const TRANSACTION_TIMED_OUT = "DP00800001024";
  static const TRANSACTION_NOT_FOUND = "DP00800001025";
  static const FORBIDDEN = "DP00800001026";
  static const FETCHED_ENCRYPTION_KEY_SUCCESSFULLY = "DP00800001027";
  static const ERROR_FETCHING_ENCRYPTION_KEY = "DP00800001028";
  static const TRANSACTION_EXPIRED = "DP00800001029";
}

//TODO localization all below reasons
(String, String) getAirtelMoneyReasonTextFromCode(String code) {
  switch (code) {
    case AirtelMoneyResponseCodes.AMBIGUOUS:
      return ("Ambiguous", "The transaction is still processing and is in ambiguous state. Please do the transaction enquiry to fetch the transaction status.");
    case AirtelMoneyResponseCodes.SUCCESS:
      return ("Success", "Transaction is successful");
    case AirtelMoneyResponseCodes.INCORRECT_PIN:
      return ("Incorrect Pin", "Incorrect Pin has been entered");
    case AirtelMoneyResponseCodes.LIMIT_EXCEEDED:
      return ("Exceeds withdrawal amount limit(s) / Withdrawal amount limit exceeded", "The User has exceeded their wallet allowed transaction limit");
    case AirtelMoneyResponseCodes.INVALID_AMOUNT:
      return ("Invalid Amount", "The amount User is trying to transfer is less than the minimum amount allowed");
    case AirtelMoneyResponseCodes.INVALID_TRANSACTION_ID:
      return ("Transaction ID is invalid", "User didn't enter the pin");
    case AirtelMoneyResponseCodes.IN_PROCESS:
      return ("In process", "Transaction in pending state. Please check after sometime");
    case AirtelMoneyResponseCodes.INSUFFICIENT_BALANCE:
      return ("Not enough balance", "User wallet does not have enough money to cover the payable amount");
    case AirtelMoneyResponseCodes.REFUSED:
      return ("Refused", "The transaction was refused");
    case AirtelMoneyResponseCodes.DO_NOT_HONOR:
      return ("Do not honor", "This is a generic refusal that has several possible causes");
    case AirtelMoneyResponseCodes.TRANSACTION_NOT_PERMITTED:
      return ("Transaction not permitted to Payee", "Payee is already initiated for churn or barred or not registered on Airtel Money platform");
    case AirtelMoneyResponseCodes.TRANSACTION_TIMED_OUT:
      return ("Transaction Timed Out", "The transaction was timed out.");
    case AirtelMoneyResponseCodes.TRANSACTION_NOT_FOUND:
      return ("Transaction Not Found", "The transaction was not found.");
    case AirtelMoneyResponseCodes.FORBIDDEN:
      return ("Forbidden", "x-signature and payload did not match");
    case AirtelMoneyResponseCodes.FETCHED_ENCRYPTION_KEY_SUCCESSFULLY:
      return ("Successfully fetched Encryption Key", "Encryption key has been fetched successfully");
    case AirtelMoneyResponseCodes.ERROR_FETCHING_ENCRYPTION_KEY:
      return ("Error while fetching encryption key", "Could not fetch encryption key");
    case AirtelMoneyResponseCodes.TRANSACTION_EXPIRED:
      return ("Transaction Expired", "Transaction has been expired");
    default:
      return ("Something went wrong", "Something went wrong");
  }
}
//endregion AirtelMoney