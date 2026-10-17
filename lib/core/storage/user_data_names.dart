/// Every piece of local data that belongs to one user. Listed in one place so
/// per-user scoping, the one-time legacy migration and account deletion all
/// reach the same set — a box missing here would leak across accounts.
abstract final class UserDataNames {
  static const namiFinancesBox = 'nami_finances';
  static const vegapunkChatHistoryBox = 'vegapunk_chat_history';
  static const namiRagIndexMetaBox = 'nami_rag_index_meta';
  static const vegapunkRagIndexMetaBox = 'vegapunk_rag_index_meta';

  static const userBoxes = [
    namiFinancesBox,
    vegapunkChatHistoryBox,
    namiRagIndexMetaBox,
    vegapunkRagIndexMetaBox,
  ];

  static const vegapunkRagDatabase = 'opfan_rag';
  static const namiRagDatabase = 'nami_finances_store';

  static const userDatabases = [vegapunkRagDatabase, namiRagDatabase];

  /// Shared by whoever uses the device, but still encrypted.
  static const authCacheBox = 'auth_cache';

  static const deviceBoxes = [authCacheBox];
}
