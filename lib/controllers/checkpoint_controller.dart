import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/globals.dart';
import '../utils/session_manager.dart';
import 'response_model.dart';

class CheckPointController {

  Future<List<Map<String, dynamic>>> fetchCheckPointUser() async {
    final String? userId = SessionManager().userId;
    final url = '$apiBaseUrl?function=get_list_checkpoint_tour&userid=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 1) {
          final List<Map<String, dynamic>> overtimeList = List.from(data['data']);
          return overtimeList;
        } else {
          print('API Error: ${data['message']}');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception: $e');
      return [];
    }
  }

   static Future<ResponseModel> fetchDataScan({required String cp_barcode}) async {
    SessionManager sessionManager = SessionManager();
    String? userIdString = sessionManager.userId;

    if (userIdString == null) {
      throw Exception('User ID tidak tersedia.');
    }

    int userId = int.parse(userIdString);

    final response = await http.post(
      Uri.parse('$apiBaseUrl?function=post_checkpoint_tour'), 
      body: {
        'userid': userId.toString(),
        'cp_barcode': cp_barcode,
      },
    );

    print('${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return ResponseModel.fromJson(responseData);
    } else {
      throw Exception('Gagal upload data');
    }
  }
}