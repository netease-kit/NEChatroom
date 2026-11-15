import 'package:supabase_flutter/supabase_flutter.dart';

/// Client operations use the signed-in user's session. RLS remains authoritative.
class DataRepository {
  DataRepository(this.client);
  final SupabaseClient client;

  String get userId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw AuthException('يجب تسجيل الدخول أولاً');
    return id;
  }

  Future<List<Map<String, dynamic>>> _rows(
    String table, {
    String order = 'created_at',
    bool ascending = false,
    int limit = 100,
  }) async {
    final result = await client.from(table).select().order(
          order,
          ascending: ascending,
        ).limit(limit);
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> rooms() async {
    final result = await client.from('rooms').select()
        .eq('status', 'active').order('created_at', ascending: false);
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> createRoom({
    required String title,
    String? description,
    required bool isPrivate,
  }) async {
    final row = await client.from('rooms').insert({
      'owner_id': userId,
      'title': title.trim(),
      'description': (description ?? '').trim().isEmpty
          ? null
          : description!.trim(),
      'room_type': isPrivate ? 'private' : 'public',
      'status': 'active',
    }).select().single();
    await client.from('room_members').insert({
      'room_id': row['id'],
      'user_id': userId,
      'role': 'owner',
    });
    return Map<String, dynamic>.from(row);
  }

  Future<void> joinRoom(String roomId) async {
    final existing = await client.from('room_members').select('room_id')
        .eq('room_id', roomId).eq('user_id', userId).maybeSingle();
    if (existing != null) return;
    await client.from('room_members').insert({
      'room_id': roomId,
      'user_id': userId,
      'role': 'member',
    });
  }

  Stream<List<Map<String, dynamic>>> roomMessages(String roomId) => client
      .from('chat_messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', roomId)
      .order('created_at', ascending: true)
      .map((rows) => rows
          .where((row) => row['deleted_at'] == null)
          .map((row) => Map<String, dynamic>.from(row))
          .toList());

  Future<void> sendRoomMessage(String roomId, String body) async {
    final text = body.trim();
    if (text.isEmpty) return;
    await client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': userId,
      'message_type': 'text',
      'body': text,
    });
  }

  Future<Map<String, dynamic>?> profile() async => client
      .from('profiles').select().eq('id', userId).maybeSingle();

  Future<Map<String, dynamic>> ensureProfile() async {
    final current = await profile();
    if (current != null) return current;
    final authUser = client.auth.currentUser!;
    final base = (authUser.email?.split('@').first ?? 'user')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final username = '${base}_${userId.substring(0, 6)}';
    return await client.from('profiles').insert({
      'id': userId,
      'username': username,
      'display_name': authUser.email?.split('@').first ?? 'مستخدم جديد',
    }).select().single();
  }

  Future<void> updateDisplayName(String name) async {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError('الاسم مطلوب');
    await client.from('profiles').update({'display_name': value})
        .eq('id', userId);
  }

  Future<Map<String, dynamic>?> wallet() async => client
      .from('wallets').select().eq('user_id', userId).maybeSingle();

  Future<List<Map<String, dynamic>>> myMessages() async {
    final result = await client.from('chat_messages')
        .select('id, room_id, sender_id, body, message_type, created_at, rooms(id,title,cover_url)')
        .order('created_at', ascending: false).limit(100);
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> families() => _rows('families');
  Future<List<Map<String, dynamic>>> agencies() => _rows('agencies');
  Future<List<Map<String, dynamic>>> gifts() => client.from('gifts').select()
      .eq('is_active', true).then((r) => r.map((e) => Map<String,dynamic>.from(e)).toList());
  Future<List<Map<String, dynamic>>> vipPackages() => client.from('vip_packages')
      .select().eq('is_active', true)
      .then((r) => r.map((e) => Map<String,dynamic>.from(e)).toList());
  Future<List<Map<String, dynamic>>> notifications() async {
    final result = await client.from('notifications').select()
        .eq('user_id', userId).order('created_at', ascending: false).limit(50);
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> createFamily(String name) async {
    final family = await client.from('families').insert({
      'owner_id': userId,
      'name': name.trim(),
    }).select('id').single();
    await client.from('family_members').insert({
      'family_id': family['id'],
      'user_id': userId,
      'role': 'owner',
    });
  }

  Future<void> createAgency(String name) async {
    final agency = await client.from('agencies').insert({
      'owner_id': userId,
      'name': name.trim(),
    }).select('id').single();
    await client.from('agency_members').insert({
      'agency_id': agency['id'],
      'user_id': userId,
      'role': 'owner',
    });
  }

  Future<void> sendGift({
    required String giftId,
    required String receiverId,
    String? roomId,
    int quantity = 1,
  }) async {
    await client.rpc('send_gift', params: {
      'p_gift_id': giftId,
      'p_receiver_id': receiverId,
      'p_room_id': roomId,
      'p_quantity': quantity,
    });
  }
}
