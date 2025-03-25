import 'dart:convert';

import 'package:http/http.dart' as http;

class Flight_api_call {
  Future<String> Authentication_api_token() async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST',
        Uri.parse('https://test.api.amadeus.com/v1/security/oauth2/token'));
    request.bodyFields = {
      'client_id': '2v90Aj708Z1PdOHGPcyrERnTnhaI3gFT',
      'client_secret': 'LRjPQTh9f9zazUQq',
      'grant_type': 'client_credentials'
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      //print(await response.stream.bytesToString());
      var apiKeyContainer = await response.stream.bytesToString();
      // Convert the response string to a JSON object
      var jsonResponse = jsonDecode(apiKeyContainer);
      if (jsonResponse is Map<String, dynamic>) {
        // print(jsonResponse.keys); // Print all top-level keys
        return jsonResponse['access_token']; // Example: Access 'data' node
      } else if (jsonResponse is List) {
        print(jsonResponse.length); // Example: If it's a list, print length
      }
//print(api_key_container.access_token);
    } else {
      print(response.reasonPhrase);
    }

    return "I am here";
  }

get_flight_details() async {
    //String destination, String Origin
    Flight_api_call flightApi = Flight_api_call();
    String apiKey = await flightApi.Authentication_api_token();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://test.api.amadeus.com/v2/shopping/flight-offers?originLocationCode=NYC&destinationLocationCode=MAD&departureDate=2025-03-18&adults=1'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
      //print(await response.stream.bytesToString());
      var flightDetails = await response.stream.bytesToString();
      // Convert the response string to a JSON object
      var jsonResponse = jsonDecode(flightDetails);
      if (jsonResponse is Map<String, dynamic>) {
        // print(jsonResponse.keys); // Print all top-level keys
        print(jsonResponse); // Example: Access 'data' node
      } else if (jsonResponse is List) {
      print(jsonResponse.length); // Example: If it's a list, print length
      }
//print(api_key_container.access_token);
    } else {
      print(response.stream);
    }
  }
}
