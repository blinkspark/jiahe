import 'package:app/state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/web.dart';

class LoginPage extends StatelessWidget {
  final appState = Get.find<StateController>();
  final logger = Get.find<Logger>();
  final isRegister = false.obs;
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final password = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(isRegister.value ? '注册' : '登录')),
        centerTitle: true
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

            const SizedBox(height: 20),

            // 登录/注册按钮
            ElevatedButton(
              onPressed: () {
                if (isRegister.value) {
                  // 处理注册逻辑
                  logger.d('注册 - 邮箱: ${email.text}, 密码: ${password.text}');
                } else {
                  // 处理登录逻辑
                  logger.d('登录 - 邮箱: ${email.text}, 密码: ${password.text}');
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: Obx(() => Text(isRegister.value ? '注册' : '登录')),
            ),

            const SizedBox(height: 10),

            // 登录/注册切换链接
            TextButton(
              onPressed: () {
                isRegister.value = !isRegister.value;
                logger.d('切换到${isRegister.value ? "注册" : "登录"}模式');
              },
              child: Obx(() => Text(isRegister.value ? '已有账号？点击登录' : '没有账号？点击注册')),
            ),
          ],
        ),
      ),
    );
  }
}
