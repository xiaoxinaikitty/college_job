import 'package:flutter/material.dart';

import '../models/account_role.dart';
import '../routes/app_routes.dart';
import '../routes/route_args.dart';
import '../services/auth_service.dart';
import '../viewmodels/register_view_model.dart';
import '../widgets/auth_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.initialBaseUrl,
    required this.initialRole,
  });

  final String initialBaseUrl;
  final AccountRole initialRole;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _enterpriseController = TextEditingController();
  final _creditCodeController = TextEditingController();
  final _apiController = TextEditingController();
  final _service = AuthService();

  late final RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel(
      baseUrl: widget.initialBaseUrl,
      role: widget.initialRole,
    )..addListener(_onViewModelChanged);
    _apiController.text = _viewModel.baseUrl;
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _enterpriseController.dispose();
    _creditCodeController.dispose();
    _apiController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = _viewModel.role == AccountRole.student;
    return AuthShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(
              title: '创建账号',
              subtitle: '开启你的实习求职之旅',
            ),
            const SizedBox(height: 20),
            SegmentSwitch(
              leftTitle: '登录',
              rightTitle: '注册',
              leftSelected: false,
              onTapLeft: _gotoLogin,
              onTapRight: () {},
            ),
            const SizedBox(height: 12),
            SegmentSwitch(
              leftTitle: AccountRole.student.label,
              rightTitle: AccountRole.enterprise.label,
              leftSelected: isStudent,
              onTapLeft: () => _viewModel.setRole(AccountRole.student),
              onTapRight: () => _viewModel.setRole(AccountRole.enterprise),
              backgroundColor: const Color(0xFFF3F5FA),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '手机号',
                hintText: '请输入手机号',
              ),
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) {
                  return '手机号不能为空';
                }
                if (!RegExp(r'^[0-9]{6,20}$').hasMatch(text)) {
                  return '手机号格式不正确';
                }
                return null;
              },
              onChanged: (value) => _viewModel.phone = value.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _viewModel.obscurePassword,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入 6-32 位密码',
                suffixIcon: IconButton(
                  onPressed: _viewModel.toggleObscurePassword,
                  icon: Icon(
                    _viewModel.obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) {
                  return '密码不能为空';
                }
                if (text.length < 6 || text.length > 32) {
                  return '密码长度需在 6-32 位';
                }
                return null;
              },
              onChanged: (value) => _viewModel.password = value,
            ),
            if (isStudent) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '昵称（选填）',
                  hintText: '请输入昵称',
                ),
                onChanged: (value) => _viewModel.nickname = value,
              ),
            ] else ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _enterpriseController,
                decoration: const InputDecoration(
                  labelText: '企业名称',
                  hintText: '请输入企业名称',
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return '企业名称不能为空';
                  }
                  if (text.length > 200) {
                    return '企业名称过长';
                  }
                  return null;
                },
                onChanged: (value) => _viewModel.enterpriseName = value.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creditCodeController,
                decoration: const InputDecoration(
                  labelText: '统一社会信用代码（选填）',
                  hintText: '请输入统一社会信用代码',
                ),
                onChanged: (value) => _viewModel.creditCode = value,
              ),
            ],
            const SizedBox(height: 10),
            _buildApiSettings(),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _viewModel.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B5FFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '创建账号',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  '已有账号？',
                  style: TextStyle(color: Color(0xFF6B7485), fontSize: 13),
                ),
                TextButton(
                  onPressed: _gotoLogin,
                  child: const Text('去登录'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _viewModel.toggleApiSettings,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.settings_rounded,
                    size: 18, color: Color(0xFF5778BD)),
                const SizedBox(width: 6),
                const Text(
                  '后端接口设置',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4E5F82),
                  ),
                ),
                const Spacer(),
                Icon(
                  _viewModel.showApiSettings
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: const Color(0xFF4E5F82),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _viewModel.showApiSettings
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              TextFormField(
                controller: _apiController,
                decoration: const InputDecoration(
                  labelText: '接口地址',
                  hintText: 'http://localhost:8080',
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return '接口地址不能为空';
                  }
                  final uri = Uri.tryParse(text);
                  if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
                    return '接口地址格式不正确';
                  }
                  return null;
                },
                onChanged: (value) => _viewModel.baseUrl = value.trim(),
              ),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Android 模拟器一般使用: http://10.0.2.2:8080',
                  style: TextStyle(fontSize: 12, color: Color(0xFF72809A)),
                ),
              ),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    try {
      final payload = await _viewModel.submit(_service);
      if (!mounted) {
        return;
      }
      final targetRoute = payload.userType == AccountRole.enterprise.userType
          ? AppRoutes.enterpriseHome
          : AppRoutes.studentHome;
      Navigator.pushReplacementNamed(
        context,
        targetRoute,
        arguments: DashboardRouteArgs(
          payload: payload,
          baseUrl: _viewModel.baseUrl,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(e.toString()), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _gotoLogin() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.login,
      arguments: LoginRouteArgs(
        baseUrl: _viewModel.baseUrl,
        role: _viewModel.role,
      ),
    );
  }
}
