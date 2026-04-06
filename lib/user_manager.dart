class UserManager {
  static int? currentUserId;

  static void setUserId(int userId) {
    currentUserId = userId;
  }

  static int? getUserId() {
    return currentUserId;
  }

  static void clearUserId() {
    currentUserId = null;
  }
}