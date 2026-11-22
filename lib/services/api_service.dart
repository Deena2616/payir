
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../models/models.dart';
import '../core/units.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/buyer_api';

  // API 1: Fetch users
  static Future<List<dynamic>> getUsers() async {
    final url = Uri.parse('$baseUrl/get_users.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          return data['users'] as List<dynamic>;
        }
      }

      throw Exception('Failed to fetch users');
    } catch (e) {
      throw Exception('API connection failed: $e');
    }
  }

  // API 2: Send OTP
  static Future<Map<String, dynamic>> sendOtp(String mobile) async {
    final url = Uri.parse('$baseUrl/send_otp.php');

    try {
      final response = await http.post(
        url,
        body: {'mobile': mobile},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(data['message'] ?? 'Could not send OTP');
    } catch (e) {
      throw Exception('Send OTP API failed: $e');
    }
  }

  // API 3: Verify OTP and receive session token
  static Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify_otp.php');

    try {
      final response = await http.post(
        url,
        body: {
          'mobile': mobile,
          'otp': otp,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success' &&
          data['token'] != null) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'OTP verification failed',
      );
    } catch (e) {
      throw Exception('Verify OTP API failed: $e');
    }
  }

  // API 4: Register buyer
  static Future<Map<String, dynamic>> registerBuyer({
    required String mobile,
    required CompanyProfile profile,
    required Map<String, PlatformFile> documents,
  }) async {
    final url = Uri.parse('$baseUrl/register_buyer.php');

    try {
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'mobile': mobile,
        'legal_name': profile.legalName,
        'trade_name': profile.tradeName,
        'buyer_type': profile.type,
        'gstin': profile.gstin,
        'pan': profile.pan,
        'cin': profile.cin,
        'fssai': profile.fssai,
        'registered_address': profile.regAddress,
        'warehouse_address': profile.whAddress,
        'contact_person': profile.contact,
        'designation': profile.designation,
        'email': profile.email,
        'commodities': profile.commodities,
        'monthly_volume': profile.monthlyVolume,
        'volume_unit': profile.volumeUnit.name,
        'purchase_districts': profile.districts,
        'varieties': profile.varieties,
        'languages': jsonEncode(profile.languages),
      });

      for (final entry in documents.entries) {
        final file = entry.value;

        if (file.bytes == null) {
          throw Exception(
            'Could not read selected file: ${file.name}',
          );
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            entry.key,
            file.bytes!,
            filename: file.name,
          ),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 ||
          response.statusCode == 201) &&
          data['status'] == 'success') {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Buyer registration failed',
      );
    } catch (e) {
      throw Exception('Registration API failed: $e');
    }
  }

  // API 5: Get buyer profile
  static Future<Map<String, dynamic>> getBuyerProfile(
      String mobile,
      ) async {
    final url = Uri.parse('$baseUrl/get_buyer_profile.php');

    try {
      final response = await http.post(
        url,
        body: {'mobile': mobile},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not fetch buyer profile',
      );
    } catch (e) {
      throw Exception('Get buyer profile API failed: $e');
    }
  }

  // API 6: Get farmer listings
  static Future<List<Listing>> getFarmerListings() async {
    final url = Uri.parse('$baseUrl/get_farmer_listings.php');

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        final List<dynamic> items = data['listings'];

        return items.map((item) {
          final json = Map<String, dynamic>.from(item);

          return Listing(
            id: json['id'].toString(),
            crop: json['crop'].toString(),
            variety: json['variety'].toString(),
            grade: json['grade'].toString(),
            village: json['village'].toString(),
            district: json['district'].toString(),
            farmerFirstName:
            json['farmer_first_name'].toString(),
            quantity: double.parse(
              json['quantity'].toString(),
            ),
            unit: QtyUnit.values.firstWhere(
                  (u) => u.name == json['unit'].toString(),
            ),
            expectedPrice: double.parse(
              json['expected_price'].toString(),
            ),
            readyDate: DateTime.parse(
              json['ready_date'].toString(),
            ),
            listedAt: DateTime.parse(
              json['listed_at'].toString(),
            ),
          );
        }).toList();
      }

      throw Exception(
        data['message'] ?? 'Failed to fetch listings',
      );
    } catch (e) {
      throw Exception('Get farmer listings API failed: $e');
    }
  }

  // API 7: Validate saved buyer session
  static Future<Map<String, dynamic>> validateSession(
      String token,
      ) async {
    final url = Uri.parse('$baseUrl/validate_session.php');

    try {
      final response = await http.post(
        url,
        body: {'token': token},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Session validation failed',
      );
    } catch (e) {
      throw Exception('Validate session API failed: $e');
    }
  }

  // API 8: Post buyer requirement
  static Future<Map<String, dynamic>> postRequirement({
    required String token,
    required Requirement requirement,
  }) async {
    final url = Uri.parse('$baseUrl/post_requirement.php');

    try {
      final neededBy = requirement.neededBy;

      final response = await http.post(
        url,
        body: {
          'token': token,
          'crop': requirement.crop,
          'quantity': requirement.quantity.toString(),
          'unit': requirement.unit.name,
          'district': requirement.district,
          'needed_by':
          '${neededBy.year.toString().padLeft(4, '0')}-'
              '${neededBy.month.toString().padLeft(2, '0')}-'
              '${neededBy.day.toString().padLeft(2, '0')}',
          'notes': requirement.notes,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not post requirement',
      );
    } catch (e) {
      throw Exception('Post requirement API failed: $e');
    }
  }

  // API 9: Get buyer requirements
  static Future<List<Requirement>> getBuyerRequirements({
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/get_buyer_requirements.php',
    );

    try {
      final response = await http.post(
        url,
        body: {'token': token},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        final List<dynamic> items = data['requirements'];

        return items.map((item) {
          final json = Map<String, dynamic>.from(item);

          return Requirement(
            id: json['id'].toString(),
            crop: json['crop'].toString(),
            district: json['district'].toString(),
            notes: json['notes']?.toString() ?? '',
            quantity: double.parse(
              json['quantity'].toString(),
            ),
            unit: QtyUnit.values.firstWhere(
                  (u) => u.name == json['unit'].toString(),
            ),
            neededBy: DateTime.parse(
              json['needed_by'].toString(),
            ),
          );
        }).toList();
      }

      throw Exception(
        data['message'] ?? 'Could not fetch requirements',
      );
    } catch (e) {
      throw Exception('Get requirements API failed: $e');
    }
  }

  // API 10: Update buyer profile
  static Future<Map<String, dynamic>> updateBuyerProfile({
    required String token,
    required CompanyProfile profile,
  }) async {
    final url = Uri.parse(
      '$baseUrl/update_buyer_profile.php',
    );

    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'warehouse_address': profile.whAddress,
          'contact_person': profile.contact,
          'designation': profile.designation,
          'email': profile.email,
          'commodities': profile.commodities,
          'monthly_volume': profile.monthlyVolume,
          'volume_unit': profile.volumeUnit.name,
          'purchase_districts': profile.districts,
          'varieties': profile.varieties,
          'languages': jsonEncode(profile.languages),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not update buyer profile',
      );
    } catch (e) {
      throw Exception('Update buyer profile API failed: $e');
    }
  }

  // API 11: Save a farmer listing
  static Future<Map<String, dynamic>> saveListing({
    required String token,
    required String listingId,
  }) async {
    final url = Uri.parse('$baseUrl/save_listing.php');

    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'listing_id': listingId,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not save listing',
      );
    } catch (e) {
      throw Exception('Save listing API failed: $e');
    }
  }

  // API 12: Get saved listings
  static Future<List<Listing>> getSavedListings({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/get_saved_listings.php');

    try {
      final response = await http.post(
        url,
        body: {'token': token},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        final List<dynamic> items = data['listings'];

        return items.map((item) {
          final json = Map<String, dynamic>.from(item);

          return Listing(
            id: json['id'].toString(),
            crop: json['crop'].toString(),
            variety: json['variety'].toString(),
            grade: json['grade'].toString(),
            village: json['village'].toString(),
            district: json['district'].toString(),
            farmerFirstName:
            json['farmer_first_name'].toString(),
            quantity: double.parse(
              json['quantity'].toString(),
            ),
            unit: QtyUnit.values.firstWhere(
                  (u) => u.name == json['unit'].toString(),
            ),
            expectedPrice: double.parse(
              json['expected_price'].toString(),
            ),
            readyDate: DateTime.parse(
              json['ready_date'].toString(),
            ),
            listedAt: DateTime.parse(
              json['listed_at'].toString(),
            ),
          );
        }).toList();
      }

      throw Exception(
        data['message'] ?? 'Could not fetch saved listings',
      );
    } catch (e) {
      throw Exception('Get saved listings API failed: $e');
    }
  }

  // API 13: Remove saved listing
  static Future<Map<String, dynamic>> removeSavedListing({
    required String token,
    required String listingId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/remove_saved_listing.php',
    );

    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'listing_id': listingId,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['status'] == 'success') {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not remove saved listing',
      );
    } catch (e) {
      throw Exception('Remove saved listing API failed: $e');
    }
  }

  // API 14: Get buyer notifications
  static Future<List<Map<String, dynamic>>> getBuyerNotifications({
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/get_buyer_notifications.php',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        final List<dynamic> items = data['notifications'];

        return items.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      }

      throw Exception(
        data['message'] ?? 'Could not fetch notifications',
      );
    } catch (e) {
      throw Exception('Get notifications API failed: $e');
    }
  }

  // API 15: Mark notifications as read
  static Future<Map<String, dynamic>> markNotificationsRead({
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/mark_notifications_read.php',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not mark notifications as read',
      );
    } catch (e) {
      throw Exception('Mark notifications read API failed: $e');
    }
  }

  // API 16: Create buyer notification
  static Future<Map<String, dynamic>> createBuyerNotification({
    required String token,
    required String titleEn,
    required String titleTa,
    required String bodyEn,
    required String bodyTa,
  }) async {
    final url = Uri.parse(
      '$baseUrl/create_notification.php',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'title_en': titleEn,
          'title_ta': titleTa,
          'body_en': bodyEn,
          'body_ta': bodyTa,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not create notification',
      );
    } catch (e) {
      throw Exception('Create notification API failed: $e');
    }
  }

  // API 17: Clear buyer notifications
  static Future<Map<String, dynamic>> clearBuyerNotifications({
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/clear_buyer_notifications.php',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not clear notifications',
      );
    } catch (e) {
      throw Exception('Clear notifications API failed: $e');
    }
  }

  // API 18: Start or reopen a chat
  static Future<Map<String, dynamic>> startChat({
    required String token,
    required String listingId,
  }) async {
    final url = Uri.parse('$baseUrl/start_chat.php');

    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'listing_id': listingId,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data['chat']);
      }

      throw Exception(
        data['message'] ?? 'Could not start chat',
      );
    } catch (e) {
      throw Exception('Start chat API failed: $e');
    }
  }

  // API 19: Get buyer chat list
  static Future<List<Map<String, dynamic>>> getBuyerChats({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/get_buyer_chats.php');

    try {
      final response = await http.post(
        url,
        body: {'token': token},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        final List<dynamic> items = data['chats'];

        return items.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      }

      throw Exception(
        data['message'] ?? 'Could not retrieve chats',
      );
    } catch (e) {
      throw Exception('Get buyer chats API failed: $e');
    }
  }

  // API 20: Get messages in a chat
  static Future<List<Map<String, dynamic>>> getChatMessages({
    required String token,
    required String chatId,
  }) async {
    final url = Uri.parse('$baseUrl/get_chat_messages.php');

    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'chat_id': chatId,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        final List<dynamic> items = data['messages'];

        return items.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      }

      throw Exception(
        data['message'] ?? 'Could not retrieve chat messages',
      );
    } catch (e) {
      throw Exception('Get chat messages API failed: $e');
    }
  }

  // API 21: Send a chat message
  static Future<Map<String, dynamic>> sendChatMessage({
    required String token,
    required String chatId,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/send_chat_message.php');

    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'chat_id': chatId,
          'message': message,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not send chat message',
      );
    } catch (e) {
      throw Exception('Send chat message API failed: $e');
    }
  }

  // API 22: Block or report a chat
  static Future<Map<String, dynamic>> updateChatStatus({
    required String token,
    required String chatId,
    required String action,
  }) async {
    final url = Uri.parse(
      '$baseUrl/update_chat_status.php',
    );

    if (action != 'block' && action != 'report') {
      throw ArgumentError(
        'Action must be either block or report',
      );
    }

    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'chat_id': chatId,
          'action': action,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not update chat status',
      );
    } catch (e) {
      throw Exception('Update chat status API failed: $e');
    }
  }

  // API 23: Create buyer agreement
  static Future<Map<String, dynamic>> createBuyerAgreement({
    required String token,
    required String listingId,
    required double quantity,
    required String unit,
    required double pricePerUnit,
    required String collectionPlace,
    required DateTime collectionDate,
  }) async {
    final url = Uri.parse(
      '$baseUrl/create_buyer_agreement.php',
    );

    try {
      final date =
          '${collectionDate.year.toString().padLeft(4, '0')}-'
          '${collectionDate.month.toString().padLeft(2, '0')}-'
          '${collectionDate.day.toString().padLeft(2, '0')}';

      final response = await http.post(
        url,
        body: {
          'token': token,
          'listing_id': listingId,
          'quantity': quantity.toString(),
          'unit': unit,
          'price_per_unit': pricePerUnit.toString(),
          'collection_place': collectionPlace,
          'collection_date': date,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not create agreement',
      );
    } catch (e) {
      throw Exception('Create agreement API failed: $e');
    }
  }

  // API 24: Get buyer agreements
  static Future<List<Map<String, dynamic>>> getBuyerAgreements({
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/get_buyer_agreements.php',
    );

    try {
      final response = await http.post(
        url,
        body: {'token': token},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        final List<dynamic> items = data['agreements'];

        return items.map((item) {
          return Map<String, dynamic>.from(item);
        }).toList();
      }

      throw Exception(
        data['message'] ?? 'Could not retrieve agreements',
      );
    } catch (e) {
      throw Exception('Get agreements API failed: $e');
    }
  }

  // API 25: Confirm or cancel buyer agreement
  static Future<Map<String, dynamic>> updateBuyerAgreement({
    required String token,
    required String agreementId,
    required String action,
  }) async {
    if (action != 'confirm' && action != 'cancel') {
      throw ArgumentError(
        'Action must be confirm or cancel',
      );
    }

    final url = Uri.parse(
      '$baseUrl/update_buyer_agreement.php',
    );

    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'agreement_id': agreementId,
          'action': action,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }

      throw Exception(
        data['message'] ?? 'Could not update agreement',
      );
    } catch (e) {
      throw Exception('Update agreement API failed: $e');
    }
  }
}
