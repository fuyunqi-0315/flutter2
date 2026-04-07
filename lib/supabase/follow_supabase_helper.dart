// lib/supabase/follow_supabase_helper.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class FollowSupabaseHelper {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> followUser(int followerId, int followeeId) async {
    await _client.rpc('follow_user', params: {
      '_follower_id': followerId,
      '_followee_id': followeeId,
    });
  }

  Future<void> unfollowUser(int followerId, int followeeId) async {
    await _client.rpc('unfollow_user', params: {
      '_follower_id': followerId,
      '_followee_id': followeeId,
    });
  }

  Future<bool> isFollowing(int followerId, int followeeId) async {
    final response = await _client.rpc('is_following', params: {
      '_follower_id': followerId,
      '_followee_id': followeeId,
    });
    return response.data as bool;
  }
}