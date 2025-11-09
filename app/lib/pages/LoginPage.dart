import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';

class LoginPage extends StatelessWidget {
  final appState = Get.find<StateController>();
  final logger = Get.find<Logger>();
  final isRegister = false.obs;
  final isLoading = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  LoginPage({super.key});

  Future<void> login() async {
    try {
      isLoading.value = true;
      await appState.login(email.text, password.text);
      Get.offAllNamed('/');
    } catch (e) {
      logger.e(e);
      // show snackbar
      Get.snackbar(
        '登录失败',
        '登录失败，请检查邮箱和密码是否正确',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    try {
      isLoading.value = true;
      await appState.register(email.text, password.text, confirmPassword.text);
      Get.offAllNamed('/');
    } catch (e) {
      logger.e(e);
      // show snackbar
      Get.snackbar('注册失败', '注册失败，请检查邮箱和密码是否正确');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(isRegister.value ? '注册' : '登录')),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 用户名/邮箱输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  hintText: '请输入邮箱',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                controller: email,
              ),
            ),

            // 密码输入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                controller: password,
              ),
            ),

            // 确认密码输入框（仅在注册模式显示）
            Obx(
              () => isRegister.value
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: TextField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '确认密码',
                          hintText: '请再次输入密码',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        controller: confirmPassword,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 20),

            // 登录/注册按钮
            ElevatedButton(
              onPressed: () async {
                // 防抖动：如果是加载中，直接返回
                if (isLoading.value) return;
                if (isRegister.value) {
                  // 处理注册逻辑
                  if (password.text != confirmPassword.text) {
                    // show snackbar
                    Get.snackbar(
                      '注册失败',
                      '密码和确认密码不匹配',
                      // colorText: Theme.of(Get.context!).colorScheme.onError,
                      // backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.5),
                    );
                    return;
                  }
                  await register();
                } else {
                  // 处理登录逻辑
                  await login();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor: Get.theme.colorScheme.primary,
              ),
              child: Obx(() {
                if (isLoading.value) {
                  return const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }
                return Text(
                  isRegister.value ? '注册' : '登录',
                  style: TextStyle(color: Get.theme.colorScheme.onPrimary),
                );
              }),
            ),

            const SizedBox(height: 10),

            // 登录/注册切换链接
            TextButton(
              onPressed: () {
                isRegister.value = !isRegister.value;
                logger.d('切换到${isRegister.value ? "注册" : "登录"}模式');
              },
              child: Obx(
                () => Text(isRegister.value ? '已有账号？点击登录' : '没有账号？点击注册'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
