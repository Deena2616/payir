
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n.dart';
import '../core/units.dart';
import '../models/models.dart';
import '../services/api_service.dart';

// Single source of truth for the buyer app.
class AppState extends ChangeNotifier {
  AppState() {
    unawaited(restoreSession());
  }

  // ---------- language ----------

  bool isTamil = false;

  String t(String key) => trKey(key, isTamil);

  void setTamil(bool v) {
    isTamil = v;
    notifyListeners();
  }

  // ---------- auth ----------

  bool loggedIn = false;
  bool isCheckingSession = true;

  String phone = '';
  String? sessionToken;

  // Local development only. Not an SMS OTP.
  String? developmentOtp;

  // Buyer profile photo.
  Uint8List? profilePhoto;

  void setProfilePhoto(Uint8List? bytes) {
    profilePhoto = bytes;
    notifyListeners();
  }

  // Send OTP through PHP backend.
  Future<bool> sendOtp(String mobile) async {
    try {
      final response = await ApiService.sendOtp(mobile);

      phone = mobile;
      developmentOtp = response['development_otp']?.toString();

      return true;
    } catch (e) {
      debugPrint('Send OTP error: $e');
      developmentOtp = null;
      return false;
    }
  }

  // ---------- company + verification ----------

  CompanyProfile? profile;
  BuyerStatus status = BuyerStatus.none;
  String returnReason = '';

  bool get approved => status == BuyerStatus.approved;

  // Load buyer profile from MySQL.
  Future<void> loadBuyerProfile(String mobile) async {
    final data = await ApiService.getBuyerProfile(mobile);

    if (data['has_profile'] != true) {
      profile = null;
      status = BuyerStatus.none;
      returnReason = '';
      return;
    }

    final row = Map<String, dynamic>.from(
      data['profile'] as Map,
    );

    final p = CompanyProfile();

    p.legalName = (row['legal_name'] ?? '').toString();
    p.tradeName = (row['trade_name'] ?? '').toString();
    p.type = (row['buyer_type'] ?? 'trader').toString();
    p.gstin = (row['gstin'] ?? '').toString();
    p.pan = (row['pan'] ?? '').toString();
    p.cin = (row['cin'] ?? '').toString();
    p.fssai = (row['fssai'] ?? '').toString();

    p.regAddress =
        (row['registered_address'] ?? '').toString();

    p.whAddress =
        (row['warehouse_address'] ?? '').toString();

    p.contact =
        (row['contact_person'] ?? '').toString();

    p.designation =
        (row['designation'] ?? '').toString();

    p.email = (row['email'] ?? '').toString();

    p.commodities =
        (row['commodities'] ?? '').toString();

    p.monthlyVolume =
        (row['monthly_volume'] ?? '').toString();

    p.districts =
        (row['purchase_districts'] ?? '').toString();

    p.varieties =
        (row['varieties'] ?? '').toString();

    final unitName =
    (row['volume_unit'] ?? 'tonne').toString();

    p.volumeUnit = QtyUnit.values.firstWhere(
          (unit) => unit.name == unitName,
      orElse: () => QtyUnit.tonne,
    );

    final languages = row['languages'];

    if (languages is List) {
      p.languages = languages
          .map((language) => language.toString())
          .toList();
    }

    profile = p;

    final statusName =
    (row['status'] ?? 'pending').toString().toLowerCase();

    status = BuyerStatus.values.firstWhere(
          (value) => value.name == statusName,
      orElse: () => BuyerStatus.pending,
    );

    returnReason =
        (row['return_reason'] ?? '').toString();
  }

  // Refresh buyer approval status from MySQL.
  Future<void> refreshBuyerStatus() async {
    if (phone.isEmpty || !loggedIn) return;

    try {
      await loadBuyerProfile(phone);

      debugPrint(
        'Buyer status refreshed: ${status.name}',
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Buyer status refresh error: $e');
    }
  }

  // Verify OTP, save session token and load buyer profile.
  Future<bool> verifyOtp(String code) async {
    try {
      final authData = await ApiService.verifyOtp(
        mobile: phone,
        otp: code,
      );

      final token = authData['token']?.toString();

      if (token == null || token.isEmpty) {
        debugPrint('Session token was not received');
        return false;
      }

      await loadBuyerProfile(phone);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('buyer_session_token', token);
      await prefs.setString('buyer_phone', phone);

      sessionToken = token;
      loggedIn = true;
      developmentOtp = null;

      await loadSavedListings();
      await loadNotifications();
      await loadChats();
      await loadAgreements();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Verify OTP / profile loading error: $e');
      return false;
    }
  }

  // Restore login after app restart or browser refresh.
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedToken =
      prefs.getString('buyer_session_token');

      if (savedToken == null || savedToken.isEmpty) {
        return;
      }

      final response =
      await ApiService.validateSession(savedToken);

      if (response['status'] != 'success') {
        await prefs.remove('buyer_session_token');
        await prefs.remove('buyer_phone');
        return;
      }

      final validatedMobile =
      response['mobile']?.toString();

      if (validatedMobile == null ||
          validatedMobile.isEmpty) {
        throw Exception('Buyer mobile was not returned');
      }

      phone = validatedMobile;
      sessionToken = savedToken;

      await loadBuyerProfile(phone);

      loggedIn = true;
      developmentOtp = null;

      await prefs.setString('buyer_phone', phone);

      await loadSavedListings();
      await loadNotifications();
      await loadChats();
      await loadAgreements();

      debugPrint('Buyer session restored successfully');
    } catch (e) {
      loggedIn = false;
      phone = '';
      sessionToken = null;

      debugPrint('Session restoration error: $e');
    } finally {
      isCheckingSession = false;
      notifyListeners();
    }
  }

  // Logout and remove the locally saved session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('buyer_session_token');
    await prefs.remove('buyer_phone');

    loggedIn = false;
    phone = '';
    sessionToken = null;
    developmentOtp = null;
    profile = null;
    profilePhoto = null;
    status = BuyerStatus.none;
    returnReason = '';

    chats.clear();
    agreements.clear();
    requirements.clear();
    notifications.clear();

    savedListings.clear();
    savedListingsError = null;
    isLoadingSavedListings = false;

    agreementsError = null;
    isLoadingAgreements = false;

    openChatId = null;

    notifyListeners();
  }

  void submitApplication(CompanyProfile p) {
    profile = p;
    status = BuyerStatus.pending;
    returnReason = '';

    _notify(
      'Application submitted',
      'விண்ணப்பம் சமர்ப்பிக்கப்பட்டது',
      'Your company is waiting for verification.',
      'உங்கள் நிறுவனம் சரிபார்ப்புக்காக காத்திருக்கிறது.',
    );

    notifyListeners();
  }

  bool updateSensitive({
    required String legalName,
    required String gstin,
    required String regAddress,
  }) {
    final p = profile!;

    final changed =
        p.legalName != legalName ||
            p.gstin != gstin ||
            p.regAddress != regAddress;

    p.legalName = legalName;
    p.gstin = gstin;
    p.regAddress = regAddress;

    if (changed) {
      status = BuyerStatus.pending;

      _notify(
        'Details changed',
        'விவரங்கள் மாற்றப்பட்டன',
        'Chat is locked until an officer approves the change.',
        'அதிகாரி அங்கீகரிக்கும் வரை அரட்டை பூட்டப்படும்.',
      );
    }

    notifyListeners();
    return changed;
  }

  // Save edited buyer profile to MySQL.
  Future<void> saveBuyerProfile(CompanyProfile updated) async {
    if (!approved) {
      throw Exception('Your buyer account is not approved.');
    }

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    if (phone.isEmpty) {
      throw Exception('Buyer session not found.');
    }

    await ApiService.updateBuyerProfile(
      token: token,
      profile: updated,
    );

    await loadBuyerProfile(phone);

    notifyListeners();

    debugPrint('Buyer profile updated successfully.');
  }

  // ---------- listings ----------

  final List<Listing> listings = _seedListings();
  final ListingFilter filter = ListingFilter();

  bool isLoadingListings = false;
  String? listingsError;

  Future<void> loadListings() async {
    isLoadingListings = true;
    listingsError = null;
    notifyListeners();

    try {
      final loadedListings =
      await ApiService.getFarmerListings();

      listings
        ..clear()
        ..addAll(loadedListings);

      debugPrint(
        'Successfully loaded ${listings.length} listings from database',
      );
    } catch (e) {
      listingsError = e.toString();
      debugPrint('Load listings error: $e');
    } finally {
      isLoadingListings = false;
      notifyListeners();
    }
  }

  void applyFilter({
    String? crop,
    String? district,
    double? minQty,
    DateTime? readyBy,
    QtyUnit? unit,
  }) {
    filter
      ..crop = crop
      ..district = district
      ..minQty = minQty
      ..readyBy = readyBy
      ..unit = unit;

    notifyListeners();
  }

  void clearFilter() => applyFilter();

  List<Listing> get liveListings =>
      listings.where((l) => l.quantity > 0).toList();

  List<Listing> get filteredListings {
    return liveListings.where((l) {
      if (filter.crop != null && l.crop != filter.crop) {
        return false;
      }

      if (filter.district != null &&
          l.district != filter.district) {
        return false;
      }

      if (filter.unit != null && l.unit != filter.unit) {
        return false;
      }

      if (filter.readyBy != null &&
          l.readyDate.isAfter(filter.readyBy!)) {
        return false;
      }

      if (filter.minQty != null) {
        final listingKg = toKg(
          l.quantity,
          l.unit,
          l.crop,
        );

        if (listingKg == null ||
            listingKg < filter.minQty!) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => b.listedAt.compareTo(a.listedAt));
  }

  Listing? listingById(String id) {
    for (final l in listings) {
      if (l.id == id) return l;
    }
    return null;
  }

  // ---------- saved listings ----------

  final List<Listing> savedListings = [];

  bool isLoadingSavedListings = false;
  String? savedListingsError;

  bool isListingSaved(String id) {
    return savedListings.any(
          (listing) => listing.id == id,
    );
  }

  Future<void> loadSavedListings() async {
    final token = sessionToken;

    if (token == null || token.isEmpty) {
      savedListingsError = 'Please login again.';
      notifyListeners();
      return;
    }

    isLoadingSavedListings = true;
    savedListingsError = null;
    notifyListeners();

    try {
      final loaded = await ApiService.getSavedListings(
        token: token,
      );

      savedListings
        ..clear()
        ..addAll(loaded);

      debugPrint(
        'Loaded ${savedListings.length} saved listings',
      );
    } catch (e) {
      savedListingsError = e.toString();
      debugPrint('Load saved listings error: $e');
    } finally {
      isLoadingSavedListings = false;
      notifyListeners();
    }
  }

  Future<void> saveListing(Listing listing) async {
    if (!approved) {
      throw Exception('Your buyer account is not approved.');
    }

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    await ApiService.saveListing(
      token: token,
      listingId: listing.id,
    );

    await loadSavedListings();

    debugPrint('Listing saved successfully.');
  }

  Future<void> removeSavedListing(String listingId) async {
    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    await ApiService.removeSavedListing(
      token: token,
      listingId: listingId,
    );

    await loadSavedListings();

    debugPrint('Saved listing removed successfully.');
  }

  int get newSinceYesterday => liveListings
      .where(
        (l) => l.listedAt.isAfter(
      DateTime.now().subtract(
        const Duration(hours: 24),
      ),
    ),
  )
      .length;

  int get districtCount =>
      liveListings.map((l) => l.district).toSet().length;

  List<SupplyTotal> get supplyTotals {
    final map = <String, SupplyTotal>{};

    for (final l in filteredListings) {
      final k = '${l.crop}|${l.unit.name}';

      final tot = map.putIfAbsent(
        k,
            () => SupplyTotal(l.crop, l.unit),
      );

      tot.quantity += l.quantity;
      tot.count++;

      final kg = l.kg;

      if (kg == null) {
        tot.kgKnown = false;
      } else {
        tot.kg += kg;
      }
    }

    final list = map.values.toList()
      ..sort(
            (a, b) => a.crop == b.crop
            ? a.unit.index.compareTo(b.unit.index)
            : a.crop.compareTo(b.crop),
      );

    return list;
  }

  String listingsCsv() {
    final b = StringBuffer(
      'crop,variety,grade,quantity,unit,kg_equivalent,village,district,ready_date,farmer_first_name,expected_price_per_unit\n',
    );

    for (final l in filteredListings) {
      final kg = l.kg;

      b.writeln([
        l.crop,
        l.variety,
        l.grade,
        fmtNum(l.quantity).replaceAll(',', ''),
        l.unit.name,
        kg == null ? '' : fmtNum(kg).replaceAll(',', ''),
        l.village,
        l.district,
        fmtDate(l.readyDate),
        l.farmerFirstName,
        l.expectedPrice.toStringAsFixed(0),
      ].map((e) => '"$e"').join(','));
    }

    return b.toString();
  }

  Future<void> copyCsv() =>
      Clipboard.setData(ClipboardData(text: listingsCsv()));

  // ---------- chat ----------

  final List<Chat> chats = [];
  String? openChatId;

  int get unreadChats =>
      chats.fold(0, (total, chat) => total + chat.unread);

  Chat? chatById(String id) {
    for (final chat in chats) {
      if (chat.id == id) return chat;
    }
    return null;
  }

  Future<void> loadChats() async {
    final token = sessionToken;

    if (token == null || token.isEmpty) return;

    try {
      final data = await ApiService.getBuyerChats(
        token: token,
      );

      final loadedChats = data
          .map((item) => Chat.fromJson(item))
          .toList();

      chats
        ..clear()
        ..addAll(loadedChats);

      notifyListeners();

      debugPrint('Loaded ${chats.length} chats from MySQL.');
    } catch (e) {
      debugPrint('Load chats error: $e');
    }
  }

  Future<Chat> startChat(Listing listing) async {
    if (!approved) {
      throw Exception('Your buyer account is not approved.');
    }

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    for (final chat in chats) {
      if (chat.listingId == listing.id) {
        await loadChatMessages(chat);
        return chat;
      }
    }

    final response = await ApiService.startChat(
      token: token,
      listingId: listing.id,
    );

    final rawChat = response['chat'] ?? response;

    if (rawChat is! Map) {
      throw Exception('Invalid chat response from server.');
    }

    final chat = Chat.fromJson(
      Map<String, dynamic>.from(rawChat),
    );

    chats.removeWhere((item) => item.id == chat.id);
    chats.add(chat);

    await loadChatMessages(chat);

    notifyListeners();

    return chat;
  }

  Future<void> loadChatMessages(Chat chat) async {
    final token = sessionToken;

    if (token == null || token.isEmpty) return;

    try {
      final data = await ApiService.getChatMessages(
        token: token,
        chatId: chat.id,
      );

      chat.msgs
        ..clear()
        ..addAll(
          data.map((item) => ChatMsg.fromJson(item)),
        );

      chat.unread = 0;

      notifyListeners();

      debugPrint(
        'Loaded ${chat.msgs.length} messages for chat ${chat.id}.',
      );
    } catch (e) {
      debugPrint('Load chat messages error: $e');
      rethrow;
    }
  }

  List<Chat> get sortedChats =>
      [...chats]..sort(
            (a, b) => b.lastTime.compareTo(a.lastTime),
      );

  Future<void> _refreshChatMessages(Chat chat) async {
    try {
      await loadChatMessages(chat);
    } catch (e) {
      debugPrint('Background chat refresh error: $e');
    }
  }

  void setOpenChat(String? id) {
    openChatId = id;

    if (id != null) {
      final chat = chatById(id);

      if (chat != null) {
        chat.unread = 0;
        unawaited(_refreshChatMessages(chat));
      }
    }

    notifyListeners();
  }

  Future<void> sendMessage(Chat chat, String text) async {
    final message = text.trim();

    if (!approved || chat.blocked || message.isEmpty) {
      return;
    }

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    await ApiService.sendChatMessage(
      token: token,
      chatId: chat.id,
      message: message,
    );

    await loadChatMessages(chat);

    debugPrint('Buyer message saved to MySQL.');
  }

  Future<void> reportChat(Chat chat) async {
    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    await ApiService.updateChatStatus(
      token: token,
      chatId: chat.id,
      action: 'report',
    );

    chat.reported = true;

    notifyListeners();

    debugPrint('Chat reported successfully.');
  }

  Future<void> blockChat(Chat chat) async {
    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    await ApiService.updateChatStatus(
      token: token,
      chatId: chat.id,
      action: 'block',
    );

    chat.blocked = true;

    notifyListeners();

    debugPrint('Chat blocked successfully.');
  }

  // ---------- agreements (BY-14) ----------

  final List<Agreement> agreements = [];

  bool isLoadingAgreements = false;
  String? agreementsError;

  Agreement? agreementById(String id) {
    for (final a in agreements) {
      if (a.id == id) return a;
    }
    return null;
  }

  // Convert a database row into the Agreement model.
  Agreement _agreementFromJson(Map<String, dynamic> row) {
    final unitName = (row['unit'] ?? 'bag').toString();

    final unit = QtyUnit.values.firstWhere(
          (value) => value.name == unitName,
      orElse: () => QtyUnit.bag,
    );

    final statusName =
    (row['status'] ?? 'pending').toString().toLowerCase();

    final collectionDateValue =
    (row['collection_date'] ?? '').toString();

    final collectionDate =
        DateTime.tryParse(collectionDateValue) ??
            DateTime.now();

    final buyerConfirmed =
        row['buyer_confirmed'].toString() == '1' ||
            row['buyer_confirmed'] == true;

    final farmerConfirmed =
        row['farmer_confirmed'].toString() == '1' ||
            row['farmer_confirmed'] == true;

    return Agreement(
      id: (row['id'] ?? '').toString(),
      listingId: (row['listing_id'] ?? '').toString(),
      farmerName: (row['farmer_name'] ?? '').toString(),
      crop: (row['crop'] ?? '').toString(),
      place: (row['collection_place'] ?? '').toString(),
      quantity: double.tryParse(
        (row['quantity'] ?? '0').toString(),
      ) ??
          0,
      pricePerUnit: double.tryParse(
        (row['price_per_unit'] ?? '0').toString(),
      ) ??
          0,
      unit: unit,
      collectionDate: collectionDate,
      buyerConfirmed: buyerConfirmed,
      farmerConfirmed: farmerConfirmed,
      cancelled: statusName == 'cancelled',
    );
  }

  // Load this buyer's agreements from MySQL.
  Future<void> loadAgreements() async {
    final token = sessionToken;

    if (token == null || token.isEmpty) return;

    isLoadingAgreements = true;
    agreementsError = null;
    notifyListeners();

    try {
      final data = await ApiService.getBuyerAgreements(
        token: token,
      );

      final loadedAgreements = data
          .map((item) => _agreementFromJson(item))
          .toList();

      agreements
        ..clear()
        ..addAll(loadedAgreements);

      debugPrint(
        'Loaded ${agreements.length} agreements from MySQL.',
      );
    } catch (e) {
      agreementsError = e.toString();
      debugPrint('Load agreements error: $e');
    } finally {
      isLoadingAgreements = false;
      notifyListeners();
    }
  }

  // Create a new agreement and save it in MySQL.
  Future<Agreement> proposeAgreement({
    required Listing listing,
    required double quantity,
    required QtyUnit unit,
    required double price,
    required String place,
    required DateTime date,
  }) async {
    if (!approved) {
      throw Exception('Your buyer account is not approved.');
    }

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    if (quantity <= 0 || price <= 0) {
      throw Exception('Enter a valid quantity and price.');
    }

    if (place.trim().isEmpty) {
      throw Exception('Enter the collection place.');
    }

    final response = await ApiService.createBuyerAgreement(
      token: token,
      listingId: listing.id,
      quantity: quantity,
      unit: unit.name,
      pricePerUnit: price,
      collectionPlace: place.trim(),
      collectionDate: date,
    );

    final rawAgreement = response['agreement'];

    Agreement agreement;

    if (rawAgreement is Map) {
      agreement = _agreementFromJson(
        Map<String, dynamic>.from(rawAgreement),
      );
    } else {
      final agreementId =
      (response['id'] ?? response['agreement_id'] ?? '')
          .toString();

      if (agreementId.isEmpty) {
        throw Exception(
          'Agreement was saved, but the server did not return its ID.',
        );
      }

      agreement = Agreement(
        id: agreementId,
        listingId: listing.id,
        farmerName: listing.farmerFirstName,
        crop: listing.crop,
        place: place.trim(),
        quantity: quantity,
        pricePerUnit: price,
        unit: unit,
        collectionDate: date,
        buyerConfirmed: false,
        farmerConfirmed: false,
      );
    }

    agreements.removeWhere(
          (item) => item.id == agreement.id,
    );

    agreements.insert(0, agreement);

    notifyListeners();

    debugPrint(
      'Agreement ${agreement.id} saved to MySQL.',
    );

    return agreement;
  }

  // Buyer confirms an agreement in MySQL.
  Future<void> confirmAgreement(Agreement agreement) async {
    if (agreement.cancelled) {
      throw Exception('This agreement has been cancelled.');
    }

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    await ApiService.updateBuyerAgreement(
      token: token,
      agreementId: agreement.id,
      action: 'confirm',
    );

    agreement.buyerConfirmed = true;

    notifyListeners();

    debugPrint(
      'Buyer confirmation saved for agreement ${agreement.id}.',
    );

    await loadAgreements();
  }

  // Buyer cancels an agreement in MySQL.
  Future<void> cancelAgreement(Agreement agreement) async {
    if (!agreement.canCancel) {
      throw Exception(
        'This agreement can no longer be cancelled.',
      );
    }

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    await ApiService.updateBuyerAgreement(
      token: token,
      agreementId: agreement.id,
      action: 'cancel',
    );

    agreement.cancelled = true;

    notifyListeners();

    debugPrint(
      'Agreement ${agreement.id} cancelled in MySQL.',
    );

    await loadAgreements();
  }

  // ---------- requirements ----------

  final List<Requirement> requirements = [];

  bool isLoadingRequirements = false;
  String? requirementsError;

  Future<void> loadRequirements() async {
    final token = sessionToken;

    if (token == null || token.isEmpty) {
      requirementsError = 'Please login again.';
      notifyListeners();
      return;
    }

    isLoadingRequirements = true;
    requirementsError = null;
    notifyListeners();

    try {
      final loadedRequirements =
      await ApiService.getBuyerRequirements(token: token);

      requirements
        ..clear()
        ..addAll(loadedRequirements);

      debugPrint(
        'Successfully loaded ${requirements.length} requirements from database',
      );
    } catch (e) {
      requirementsError = e.toString();
      debugPrint('Load requirements error: $e');
    } finally {
      isLoadingRequirements = false;
      notifyListeners();
    }
  }

  Future<void> postRequirement(Requirement r) async {
    if (!approved) {
      throw Exception('Your buyer account is not approved.');
    }

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    await ApiService.postRequirement(
      token: token,
      requirement: r,
    );

    await loadRequirements();

    debugPrint('Requirement posted successfully.');
  }

  // ---------- notifications ----------

  final List<AppNotification> notifications = [];

  bool isLoadingNotifications = false;
  String? notificationsError;

  int get unreadNotifications =>
      notifications.where((n) => !n.read).length;

  Future<void> loadNotifications() async {
    final token = sessionToken;

    if (token == null || token.isEmpty) {
      return;
    }

    isLoadingNotifications = true;
    notificationsError = null;
    notifyListeners();

    try {
      final data = await ApiService.getBuyerNotifications(
        token: token,
      );

      final loaded = data
          .map((item) => AppNotification.fromJson(item))
          .toList();

      notifications
        ..clear()
        ..addAll(loaded);

      debugPrint(
        'Loaded ${notifications.length} notifications from MySQL',
      );
    } catch (e) {
      notificationsError = e.toString();
      debugPrint('Load notifications error: $e');
    } finally {
      isLoadingNotifications = false;
      notifyListeners();
    }
  }

  void _notify(String te, String tt, String be, String bt) {
    final notification = AppNotification(te, tt, be, bt);

    notifications.insert(0, notification);
    notifyListeners();

    final token = sessionToken;

    if (token != null && token.isNotEmpty) {
      unawaited(
        _saveNotificationToServer(
          token: token,
          titleEn: te,
          titleTa: tt,
          bodyEn: be,
          bodyTa: bt,
        ),
      );
    }
  }

  Future<void> _saveNotificationToServer({
    required String token,
    required String titleEn,
    required String titleTa,
    required String bodyEn,
    required String bodyTa,
  }) async {
    try {
      await ApiService.createBuyerNotification(
        token: token,
        titleEn: titleEn,
        titleTa: titleTa,
        bodyEn: bodyEn,
        bodyTa: bodyTa,
      );

      await loadNotifications();

      debugPrint('Notification saved to MySQL successfully.');
    } catch (e) {
      debugPrint('Save notification error: $e');
    }
  }

  Future<void> clearNotifications() async {
    final token = sessionToken;

    if (token == null || token.isEmpty) {
      throw Exception('Please login again.');
    }

    try {
      await ApiService.clearBuyerNotifications(
        token: token,
      );

      notifications.clear();
      notificationsError = null;

      notifyListeners();

      debugPrint(
        'Notifications cleared from MySQL successfully.',
      );
    } catch (e) {
      debugPrint('Clear notifications error: $e');
      rethrow;
    }
  }

  Future<void> markAllRead() async {
    for (final n in notifications) {
      n.read = true;
    }

    notifyListeners();

    final token = sessionToken;

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await ApiService.markNotificationsRead(
        token: token,
      );

      debugPrint('Notifications marked as read in MySQL.');
    } catch (e) {
      debugPrint('Mark notifications read error: $e');
    }
  }
}

// ---------- supply total ----------

class SupplyTotal {
  final String crop;
  final QtyUnit unit;

  double quantity = 0, kg = 0;
  int count = 0;
  bool kgKnown = true;

  SupplyTotal(this.crop, this.unit);
}

// ---------- sample listings ----------

List<Listing> _seedListings() {
  final now = DateTime.now();

  DateTime d(int days) => now.add(Duration(days: days));

  return [
    Listing(
      id: 'l1',
      crop: 'Paddy',
      variety: 'ADT 45',
      grade: 'A',
      village: 'Papanasam',
      district: 'Thanjavur',
      farmerFirstName: 'Murugan',
      quantity: 120,
      unit: QtyUnit.bag,
      expectedPrice: 1750,
      readyDate: d(3),
      listedAt: now.subtract(const Duration(hours: 5)),
    ),
    Listing(
      id: 'l2',
      crop: 'Paddy',
      variety: 'CR 1009',
      grade: 'B',
      village: 'Kudavasal',
      district: 'Tiruvarur',
      farmerFirstName: 'Selvi',
      quantity: 8,
      unit: QtyUnit.tonne,
      expectedPrice: 22000,
      readyDate: d(7),
      listedAt: now.subtract(const Duration(hours: 30)),
    ),
    Listing(
      id: 'l3',
      crop: 'Groundnut',
      variety: 'TMV 7',
      grade: 'A',
      village: 'Thalavadi',
      district: 'Erode',
      farmerFirstName: 'Karthik',
      quantity: 450,
      unit: QtyUnit.kg,
      expectedPrice: 68,
      readyDate: d(2),
      listedAt: now.subtract(const Duration(hours: 2)),
    ),
    Listing(
      id: 'l4',
      crop: 'Turmeric',
      variety: 'Salem',
      grade: 'A',
      village: 'Bhavani',
      district: 'Erode',
      farmerFirstName: 'Lakshmi',
      quantity: 25,
      unit: QtyUnit.quintal,
      expectedPrice: 9200,
      readyDate: d(10),
      listedAt: now.subtract(const Duration(hours: 50)),
    ),
    Listing(
      id: 'l5',
      crop: 'Maize',
      variety: 'NK 6240',
      grade: 'B',
      village: 'Perambalur',
      district: 'Trichy',
      farmerFirstName: 'Anbu',
      quantity: 60,
      unit: QtyUnit.bag,
      expectedPrice: 1400,
      readyDate: d(5),
      listedAt: now.subtract(const Duration(hours: 8)),
    ),
    Listing(
      id: 'l6',
      crop: 'Banana',
      variety: 'Nendran',
      grade: 'A',
      village: 'Pollachi',
      district: 'Coimbatore',
      farmerFirstName: 'Raja',
      quantity: 3,
      unit: QtyUnit.tonne,
      expectedPrice: 28000,
      readyDate: d(4),
      listedAt: now.subtract(const Duration(hours: 12)),
    ),
    Listing(
      id: 'l7',
      crop: 'Paddy',
      variety: 'ADT 45',
      grade: 'A',
      village: 'Orathanadu',
      district: 'Thanjavur',
      farmerFirstName: 'Priya',
      quantity: 200,
      unit: QtyUnit.bag,
      expectedPrice: 1760,
      readyDate: d(6),
      listedAt: now.subtract(const Duration(hours: 70)),
    ),
    Listing(
      id: 'l8',
      crop: 'Black gram',
      variety: 'VBN 8',
      grade: 'A',
      village: 'Sirkazhi',
      district: 'Nagapattinam',
      farmerFirstName: 'Gopal',
      quantity: 15,
      unit: QtyUnit.quintal,
      expectedPrice: 7400,
      readyDate: d(1),
      listedAt: now.subtract(const Duration(hours: 1)),
    ),
  ];
}
