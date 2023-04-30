import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_web/model/login/login_model.dart';
import 'package:get/get.dart';

import '../chat/chat_viewmodel.dart';

class LoginViewModel extends GetxController {
  final Rx<LoginModel> _loginModel = LoginModel().obs;
  final RxBool isLoading = false.obs;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String get jwtToken => _loginModel.value.jwtToken;
  List get apiKeys => _loginModel.value.apiKeys;
  GlobalKey<FormBuilderState> get formKey => _loginModel.value.formKey;
  String get username => _loginModel.value.username;
  String get selectedApiKey => _loginModel.value.selectedApiKey;
  bool get isRemembered => _loginModel.value.isRemembered;
  set isRemembered(bool value) => _loginModel.update((val) {
        val!.isRemembered = value;
      });

  @override
  void onInit() async {
    super.onInit();
    final SnackBarModel? snackbar = await _loginModel.value.init();
    if (snackbar != null) {
      Get.snackbar(
        snackbar.title,
        snackbar.message,
        duration: snackbar.duration,
        snackPosition: snackbar.snackPosition,
        backgroundColor: snackbar.backgroundColor,
      );
    }
    _loginModel.update((_) {});
  }

  @override
  void onClose() {
    super.onClose();
    _loginModel.update((val) {
      val!.close();
    });
  }

  Future<void> register(String email, String password) async {
    final SnackBarModel snackbar =
        await _loginModel.value.register(email, password);
    _loginModel.update((_) {
      Get.snackbar(
        snackbar.title,
        snackbar.message,
        duration: snackbar.duration,
        backgroundColor: snackbar.backgroundColor,
        snackPosition: snackbar.snackPosition,
      );
    });
  }

  Future<void> login(String email, String password) async {
    final SnackBarModel snackbar =
        await _loginModel.value.login(email, password);
    Get.snackbar(
      snackbar.title,
      snackbar.message,
      duration: snackbar.duration,
      backgroundColor: snackbar.backgroundColor,
      snackPosition: snackbar.snackPosition,
    );
    _loginModel.update((_) {});
  }

  Future<void> logout() async {
    await _loginModel.value.logout();
    _loginModel.update((_) {});
    await Get.find<ChatViewModel>().endChat();
  }

  Future<void> onClickApiKey(
      {required String accessKey, required String userMemo}) async {
    _loginModel.update((val) {
      val!.onClickApiKey(accessKey: accessKey, userMemo: userMemo);
    });
    // pop all dialogs until the root dialog is reached
    scaffoldKey.currentState?.closeDrawer();
    Get.snackbar(
      'API Key $userMemo Selected',
      '$userMemo가 선택되었습니다.',
      duration: const Duration(seconds: 1),
    );
    await Get.find<ChatViewModel>().beginChat(
      apiKey: accessKey,
    );
  }
}
