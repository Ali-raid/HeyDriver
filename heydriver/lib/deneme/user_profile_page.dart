import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heydriver/constants/theme_colors.dart';
import 'package:heydriver/deneme/main_screen.dart';
import 'package:heydriver/widgets/custom_buttom.dart';
import 'package:heydriver/widgets/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<UserProfilePage> {
  File? image;
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      this.image = imageTemporary;
      setState(() {
        this.image = imageTemporary;
      });
      _updateProfilePhotos().then((value) => ScaffoldMessenger.of(context)
          .showSnackBar(
              const SnackBar(content: Text("Fotoğraf Güncellenmiştir."))));
    } on PlatformException catch (e) {
      debugPrint("failed to pick image: $image$e");
    }
  }

  final _driverProfileFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _certificateController = TextEditingController();

  bool dataFetched = false;
  String email = "";
  String fullName = "";
  String imageUrl = "";
  String certificate = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String uid = _auth.currentUser!.uid;
  final _profileReference = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getProfileDetails();
  }

  Future<void> _updateProfileDetails() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref.child("User/$uid").update({
      "emailAddress": _emailController.text,
      "fullName": _nameController.text,
      "certificateNo": certificate,
    }).then(
        (value) => {showSnackBar(context, "Bilgileriniz Güncellenmiştir.")});
    FirebaseAuth.instance.currentUser!.updateDisplayName(
        _nameController.text);
  }

  Future<void> _updateProfilePhotos() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref.child("User/$uid").update({
      "image": await _uploadProfilePhoto(),
    });
    FirebaseAuth.instance.currentUser!.updatePhotoURL(
        await _uploadProfilePhoto()); //firebase auth user profile photo update
  }

  void showAlertDialog(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.black,
        context: context,
        builder: (context) {
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                title: const Text(
                  'Kamera',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album, color: Colors.white),
                title: const Text(
                  'Galeri',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void showSnackBar(
    BuildContext context,
    String text,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late Reference _storageRef;
//uplaod pics////0/////////////////////////////////////////////////////////
  Future<String> uploadFile(
      String userID, String fileType, File uploadedFile) async {
    _storageRef = _firebaseStorage
        .ref()
        .child(userID)
        .child(fileType)
        .child("Profile_photo.png");

    UploadTask uploadTask = _storageRef.putFile(uploadedFile);
    var url = await (await uploadTask).ref.getDownloadURL();
    return url;
  }

///////////////////////////////////////////////////////////////////////////////////////
  Future<String?> _uploadProfilePhoto() async {
    if (image != null) {
      return await uploadFile(uid, 'profilephoto', image!);
    } else {
      return null;
    }
  }

  Future<void> _getProfileDetails() async {
    _profileReference.child("User/$uid").onValue.listen((event) {
      Map<dynamic, dynamic> data =
          event.snapshot.value as Map<dynamic, dynamic>;

      email = data["emailAddress"];
      fullName = data["fullName"];
      imageUrl = data["image"] ??
          "https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1331&q=80";
      certificate = data["certificateNo"];
      if (mounted) {
        setState(() {
          dataFetched = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const MainScreen()));
        return false;
      },
      child: Scaffold(
        backgroundColor: ThemeColors.offWhite,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MainScreen()));
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  )),
              GestureDetector(
                child: const Text("Kullanıcı Profili"),
                onTap: () {},
              ),
              GestureDetector(
                child: const Text(""),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: dataFetched == true
            ? SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: ThemeColors.white,
                        child: Form(
                          key: _driverProfileFormKey,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 75,
                                    backgroundImage: (image == null
                                            ? NetworkImage(imageUrl)
                                            : image != null
                                                ? FileImage(image!)
                                                : const NetworkImage(
                                                    'https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png'))
                                        as ImageProvider,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showAlertDialog(context);
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.black,
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),
                              CustomTextField(
                                controller: _nameController,
                                hintText: "Adınız Soyadınız",
                                text: fullName,
                              ),
                              const SizedBox(height: 5),
                              CustomTextField(
                                controller: _emailController,
                                hintText: "Email Adresiniz",
                                text: email,
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                controller: _certificateController,
                                hintText: "Plakanız",
                                text: certificate,
                              ),
                              // Align(
                              //   alignment: Alignment.centerLeft,
                              //   child: Text(
                              //       "Konum : $locationLatitude -$locationLongitude"),
                              // ),
                              const SizedBox(height: 10),
                              CustomButton(
                                  buttonSize: 150,
                                  color: ThemeColors.black,
                                  text: "Profili Güncelle",
                                  onTap: () {
                                    if (_driverProfileFormKey.currentState!
                                        .validate()) {
                                      _updateProfileDetails();
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ),
                      //Text(id),
                    ],
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
