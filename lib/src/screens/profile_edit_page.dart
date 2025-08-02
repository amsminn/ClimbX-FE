import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fquery/fquery.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../api/user.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.userProfile});

  final UserProfile userProfile;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _statusController;

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: widget.userProfile.nickname,
    );
    _statusController = TextEditingController(
      text: widget.userProfile.statusMessage,
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final queryClient = QueryClientProvider.of(context).queryClient;

    final currentNickname = widget.userProfile.nickname;
    final newNickname = _nicknameController.text.trim();
    final newStatus = _statusController.text.trim();

    try {
      await UserApi.updateProfile(
        currentNickname: currentNickname,
        newNickname: newNickname != currentNickname ? newNickname : null,
        newStatusMessage: newStatus != widget.userProfile.statusMessage
            ? newStatus
            : null,
      );

      await UserApi.updateProfileImage(
        nickname: newNickname.isNotEmpty ? newNickname : currentNickname,
        file: _selectedImage,
      );

      // invalidate cache so ProfileBody reloads
      queryClient.invalidateQueries(['user_profile']);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('프로필이 업데이트되었습니다.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 프로필 이미지
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: _selectedImage != null
                        ? FileImage(File(_selectedImage!.path))
                        : (widget.userProfile.profileImageUrl != null
                              ? NetworkImage(
                                      widget.userProfile.profileImageUrl!,
                                    )
                                    as ImageProvider
                              : const AssetImage('assets/images/avatar.png')),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 닉네임
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '닉네임을 입력하세요' : null,
              ),
              const SizedBox(height: 16),

              // 상태 메세지
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: '상태 메세지'),
                maxLength: 50,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
