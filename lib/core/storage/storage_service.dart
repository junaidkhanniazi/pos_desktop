abstract class StorageService {
  Future<void> save(String key, String value);
  Future<String?> read(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
