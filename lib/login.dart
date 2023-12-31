import 'package:flutter/material.dart';
import 'package:sijaliproject/get_started.dart';
import 'package:sijaliproject/home.dart';
import 'package:sijaliproject/dashboard.dart';
import 'package:sijaliproject/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:sijaliproject/home_supervisor.dart';
import 'package:sijaliproject/searching_offline.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? errormsg;
  bool? error, showprogress;
  String? username, password, role, nama;

  var _username = TextEditingController();
  var _password = TextEditingController();

  bool isOffline = false;
  bool _obscureText = true;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> checkInternetOnReturn() async {
    bool isConnected = await checkInternet();
    if (!isConnected) {
      setState(() {
        isOffline = true;
      });
      showOfflineModePopup();
    } else {
      setState(() {
        isOffline = false;
      });
    }
  }

  Future<void> initAsyncState() async {
    isOffline = !(await checkInternet());
  }

  void checkInternetOnPageOpen() async {
    bool isConnected = await checkInternet();
    if (!isConnected) {
      showOfflineModePopup();
    }
  }

  void showOfflineModePopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Make it not dismissible
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tidak Ada Koneksi Internet"),
          content: Text(
              "Anda dalam mode offline. Silakan aktifkan koneksi internet untuk melanjutkan."),
          actions: [
            TextButton(
              onPressed: () async {
                // Handle action when "Kembali" is pressed
                // Add your offline mode logic here
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: Text("Oke"),
            ),
            TextButton(
              onPressed: () async {
                // Handle action when "Mode Offline" is pressed
                // Add your offline mode logic here
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchingOffline(),
                  ),
                ).then((_) {
                  // Check internet when returning from SearchingOffline
                  checkInternetOnReturn();
                }); // Close the dialog
              },
              child: Text("Mode Offline"),
            ),
          ],
        );
      },
    );
  }

  startLogin() async {
    bool isConnected = await checkInternet();
    if (!isConnected) {
      showOfflineModePopup();
      return;
    }
    if (username == null ||
        username!.isEmpty ||
        password == null ||
        password!.isEmpty) {
      // Tampilkan SnackBar untuk memberi tahu pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Username atau password tidak boleh kosong"),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String apiurl = "https://${IpConfig.serverIp}/login.php"; //api url

    try {
      var response = await http.post(
        Uri.parse(apiurl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'username': username!,
          'password': password!,
          // 'role': role!,
        },
      );

      if (response.statusCode == 200) {
        print("200");

        String cleanedResponse =
            response.body.replaceFirst(RegExp(r'.*?({)'), '{');
        var jsondata = json.decode(cleanedResponse);

        if (jsondata["error"]) {
          print('json error');
          setState(() {
            showprogress = false;
            error = true;
            errormsg = jsondata["message"];
            print(errormsg);

            // Show SnackBar for incorrect username or password
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Username atau Password salah"),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.red,
                // adjust position of SnackBar
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        } else if (jsondata["success"]) {
          print("JSON Response: $jsondata");

          print('json success');
          setState(() {
            error = false;
            showprogress = false;
          });
          role = jsondata["role"];
          nama = jsondata["nama"];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Berhasil login sebagai $role "),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
              // adjust position of SnackBar
              behavior: SnackBarBehavior.floating,
            ),
          );
          String loggedInUsername = username ?? '';
          // Get user ID based on the username
          // int? userId = await getUserId(loggedInUsername);
          int? userId = int.tryParse(jsondata["id"].toString());

          print("User ID: $userId");
          saveSession(loggedInUsername, role, userId, nama);

          print("User ID: $userId");
        } else {
          showprogress = false;
          error = true;
          errormsg = "Something went wrong.";
          print(errormsg);
        }
      } else {
        print("Not 200");
        print(response.statusCode);
        setState(() {
          showprogress = false;
          error = true;
          errormsg = "Error during connecting to the server.";
          print(errormsg);
        });
      }
    } catch (e) {
      print('Error try1');
      print("Error: $e");
    }
  }

  saveSession(String username, String? role, int? userId, String? nama) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("username", username);
    await pref.setString("role", role ?? '');
    await pref.setString("nama", nama ?? '');
    await pref.setInt("id", userId ?? 0);
    await pref.setBool("is_login", true);

    if (role == 'mitra') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => Home(
            initialScreen: const Dashboard(),
            initialTab: 0,
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeSupervisor(
            initialScreen: const Dashboard(),
            initialTab: 0,
          ),
        ),
        (route) => false,
      );
    }
  }

  void checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");

    if (islogin != null && islogin) {
      String loggedInRole = pref.getString("role") ?? '';

      if (loggedInRole == 'mitra') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => Home(
              initialScreen: const Dashboard(),
              initialTab: 0,
            ),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomeSupervisor(
              initialScreen: const Dashboard(),
              initialTab: 0,
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  launchWhatsApp() async {
    final phoneNumber =
        "6285156570260"; // Replace with the desired WhatsApp number
    final message =
        "Halo, saya butuh bantuan dengan akun Sijali. Saya mengalami kendala lupa password";

    final whatsappUrl =
        "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeQueryComponent(message)}";

    try {
      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        // If WhatsApp is not installed, try opening in a browser
        final webUrl =
            "https://wa.me/$phoneNumber/?text=${Uri.encodeQueryComponent(message)}";
        await launch(webUrl);
      }
    } catch (e) {
      // Handle any exceptions that occur during the launch process
      print("Error launching WhatsApp: $e");
    }
  }

  @override
  void initState() {
    username = "";
    password = "";
    errormsg = "";
    error = false;
    showprogress = false;
    checkLogin();
    checkInternetOnPageOpen();
    initAsyncState();
    getConnectivity();

    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  showDialogBox() => showOfflineModePopup();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey, // Key for accessing the Scaffold
      backgroundColor: const Color(0xFFEBE4D1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.01,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: const Color(0xFFE55604),
                      size: screenHeight * 0.04,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Welcome(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Image.asset(
                  "images/bg1-removebg-preview.png",
                  height: screenHeight * 0.3,
                  width: screenWidth * 0.6,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.02,
                    bottom: screenHeight * 0.025,
                  ),
                  child: Text("Login",
                      style: TextStyle(
                        fontSize: screenWidth * 0.1,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFE55604),
                      )),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                // Show SnackBar for incorrect username or password
                // if (error != null && error!)
                //   SizedBox(
                //     height: screenHeight * 0.02,
                //     child: Text(
                //       errormsg!,
                //       style: TextStyle(
                //         color: Colors.red,
                //       ),
                //     ),
                //   ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 15,
                    ),
                    child: TextFormField(
                      controller: _username,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Username tidak boleh kosong"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.red,
                              // adjust position of SnackBar
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        ;
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username',
                      ),
                      onChanged: (value) {
                        setState(() {
                          username = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 15,
                    ),
                    child: TextFormField(
                      controller: _password,
                      obscureText:
                          _obscureText, // Use a variable to toggle visibility
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          padding: const EdgeInsets.only(left: 20.0),
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFFE55604),
                          ),
                          onPressed: () {
                            // Toggle password visibility
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Password tidak boleh kosong"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    // Handle action when "lupa password?" is pressed
                    // Misalnya, pindahkan pengguna ke halaman reset password
                    launchWhatsApp();
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Lupa password?",
                      style: TextStyle(
                        color: const Color(0xFFE55604),
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
                Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        color: const Color(0xFFE55604),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () async {
                          setState(() {
                            showprogress = true;
                          });
                          await startLogin();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: Text("Login",
                              style: TextStyle(
                                color: const Color(0xFFFFFFFF),
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
