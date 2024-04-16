import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

const APP_NAME = 'Handyman Services';
const DEFAULT_LANGUAGE = 'en';

const primaryColor = Color(0xFF5F60B9);

const DOMAIN_URL = ''; // Don't add slash at the end of the url

const BASE_URL = "$DOMAIN_URL/api/";

/// You can specify in Admin Panel, These will be used if you don't specify in Admin Panel
const IOS_LINK_FOR_PARTNER = "https://apps.apple.com/in/app/handyman-provider-app/id1596025324";

const TERMS_CONDITION_URL = 'https://iqonic.design/terms-of-use/';
const PRIVACY_POLICY_URL = 'https://iqonic.design/privacy-policy/';
const INQUIRY_SUPPORT_EMAIL = 'hello@iqonic.design';

const GOOGLE_MAPS_API_KEY = '<YOUR_GOOGLE_MAPS_API_KEY>';

DateTime todayDate = DateTime(2022, 8, 24);

//Airtel Money Payments
///It Supports ["UGX", "NGN", "TZS", "KES", "RWF", "ZMW", "CFA", "XOF", "XAF", "CDF", "USD", "XAF", "SCR", "MGA", "MWK"]
const AIRTEL_CLIENT_ID = '<YOUR_AIRTEL_CLIENT_ID>';
const AIRTEL_CLIENT_SECRET = '<YOUR_AIRTEL_CLIENT_SECRET>';
const AIRTEL_CURRENCY_CODE = "MWK";
const AIRTEL_COUNTRY_CODE = "MW";
const AIRTEL_MONEY_ON = true; //To Enable/disable Accepting payments Via Airtel Money
// const AIRTEL_BASE = 'https://openapiuat.airtel.africa/'; //Test Url
const AIRTEL_BASE = 'https://openapi.airtel.africa/'; // Live Url


//Phone Pay
/// PhonePe Test key
const PHONE_PAY_APPID = "<YOUR_PHONE_PAY_APPID>";
const PHONE_PAY_MERCHANTID = "PGTESTPAYUAT";
const PHONE_PAY_SALTKEY = "<YOUR_PHONE_PAY_SALTKEY>";
const PHONE_PAY_ENVIRONMENT = 'UAT';

/// PhonePe Live Key
// const PHONE_PAY_APPID = "YOUR_PHONE_PAY_APPID";
// const PHONE_PAY_MERCHANTID = "YOUR_PHONE_PAY_MERCHANTID";
// const PHONE_PAY_SALTKEY = "YOUR_PHONE_PAY_SALTKEY";
// const PHONE_PAY_ENVIRONMENT = 'YOUR_PHONE_PAY_ENVIRONMENT';
//
const PHONE_PAY_SALTINDEX = '1';

/// PAYSTACK PAYMENT DETAIL
const PAYSTACK_TEST_PUBLIC_KEY = '<YOUR_PAYSTACK_TEST_PUBLIC_KEY>';
const PAYSTACK_CURRENCY_CODE = 'NGN'; /// Nigeria Currency

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

/// RAZORPAY PAYMENT DETAIL
const RAZORPAY_CURRENCY_CODE = 'INR';

/// PAYPAL PAYMENT DETAIL
const PAYPAL_CURRENCY_CODE = 'USD';

/// STRIPE PAYMENT DETAIL
const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';
const STRIPE_CURRENCY_CODE = 'INR';

Country defaultCountry() {
  return Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 91,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
    fullExampleWithPlusSign: '+919123456789',
  );
}
