# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:5000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authLoginPost**](DefaultApi.md#authloginpost) | **POST** /auth/login | Login user
[**authRegisterPost**](DefaultApi.md#authregisterpost) | **POST** /auth/register | Register a new user
[**bookingsGet**](DefaultApi.md#bookingsget) | **GET** /bookings/ | Get user&#39;s bookings
[**bookingsPost**](DefaultApi.md#bookingspost) | **POST** /bookings/ | Create a booking
[**flightsGet**](DefaultApi.md#flightsget) | **GET** /flights/ | List all flights
[**helpTicketsGet**](DefaultApi.md#helpticketsget) | **GET** /help/tickets | Get user&#39;s help tickets
[**helpTicketsPost**](DefaultApi.md#helpticketspost) | **POST** /help/tickets | Submit help ticket


# **authLoginPost**
> AuthTokens authLoginPost(authLoginPostRequest)

Login user

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final AuthLoginPostRequest authLoginPostRequest = ; // AuthLoginPostRequest | 

try {
    final response = api.authLoginPost(authLoginPostRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->authLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authLoginPostRequest** | [**AuthLoginPostRequest**](AuthLoginPostRequest.md)|  | 

### Return type

[**AuthTokens**](AuthTokens.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRegisterPost**
> JsonObject authRegisterPost(authRegisterPostRequest)

Register a new user

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final AuthRegisterPostRequest authRegisterPostRequest = ; // AuthRegisterPostRequest | 

try {
    final response = api.authRegisterPost(authRegisterPostRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->authRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authRegisterPostRequest** | [**AuthRegisterPostRequest**](AuthRegisterPostRequest.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookingsGet**
> BuiltList<Booking> bookingsGet()

Get user's bookings

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.bookingsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->bookingsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Booking&gt;**](Booking.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **bookingsPost**
> JsonObject bookingsPost(bookingRequest)

Create a booking

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final BookingRequest bookingRequest = ; // BookingRequest | 

try {
    final response = api.bookingsPost(bookingRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->bookingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bookingRequest** | [**BookingRequest**](BookingRequest.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flightsGet**
> BuiltList<Flight> flightsGet()

List all flights

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.flightsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->flightsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Flight&gt;**](Flight.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **helpTicketsGet**
> BuiltList<Inquiry> helpTicketsGet()

Get user's help tickets

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.helpTicketsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->helpTicketsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Inquiry&gt;**](Inquiry.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **helpTicketsPost**
> JsonObject helpTicketsPost(ticketRequest)

Submit help ticket

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final TicketRequest ticketRequest = ; // TicketRequest | 

try {
    final response = api.helpTicketsPost(ticketRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->helpTicketsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ticketRequest** | [**TicketRequest**](TicketRequest.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

