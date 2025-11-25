import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:pocketbase/pocketbase.dart';

class UserService {
  late final PocketBase pb;
  late final Logger logger;
  UserService({required this.pb, required this.logger});

  void onAuthChanged(Function(AuthStoreEvent)? callback) {
    pb.authStore.onChange.listen((event) {
      callback?.call(event);
    });
  }

  String? getUserID() {
    return pb.authStore.record?.id;
  }

  String? getUserName() {
    return pb.authStore.record?.getStringValue('name');
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final res = await pb
          .collection('users')
          .getFullList(
            filter: "name ~ '$query' && id != '${getUserID()}'",
            fields: 'id,name',
          );
      return res.map((user) async {
        var isFollowed = false;
        try {
          await pb
              .collection('follows')
              .getFullList(
                filter:
                    "from = '${getUserID()}' && to = '${user.get<String>('id')}'",
              );
          isFollowed = true;
        } catch (e) {
          logger.d('未关注');
        }
        return {
          "id": user.get<String>('id'),
          "name": user.get<String>('name'),
          "isFollowed": isFollowed,
        };
      }).wait;
    } catch (e) {
      logger.e('搜索用户失败: $e');
      return [];
    }
  }
}
