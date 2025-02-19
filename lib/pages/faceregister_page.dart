import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/collection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'home_page.dart';
import 'app_colors.dart';
import '../ml/detector.dart';
import '../ml/utils.dart';
import '../ml/model.dart';
import '../utils/globals.dart';
import '../utils/localizations.dart';
import '../utils/session_manager.dart';
import '../controllers/facerecognition_controller.dart';

class FaceRegisterPage extends StatefulWidget {
  const FaceRegisterPage({Key? key}) : super(key: key);

  @override
  State<FaceRegisterPage> createState() => _FaceRegisterPageState();
}

class _FaceRegisterPageState extends State<FaceRegisterPage>
    with WidgetsBindingObserver {
  String username = '';
  late FaceRecognitionController controller;

  @override
  void initState() {
    super.initState();
    username = SessionManager().getNamaUser() ?? '';
    controller = FaceRecognitionController();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _start();
  }

  void _start() async {
    interpreter = await loadModel();
    initialCamera();
  }

  void sendDataToApi() async {
    try {
      await controller.sendFaceRecognition(e1);

      List<FaceRecognitionData> faceRecognitionList =
          await controller.getFaceRecognition();

      if (faceRecognitionList.length == 1 && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const FaceRegisterPage(),
          ),
        );
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: AppLocalizations(globalLanguage).translate("registerAgain"),
            message:
                AppLocalizations(globalLanguage).translate("register2More"),
            contentType: ContentType.warning,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else if (faceRecognitionList.length == 2 && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const FaceRegisterPage(),
          ),
        );
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: AppLocalizations(globalLanguage).translate("registerAgain"),
            message:
                AppLocalizations(globalLanguage).translate("register1More"),
            contentType: ContentType.warning,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } else if (faceRecognitionList.length == 3 && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: AppLocalizations(globalLanguage).translate("registered"),
            message: AppLocalizations(globalLanguage)
                .translate("registerFaceSuccess"),
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);

        await _camera!.dispose();
      }

      debugPrint('API request successful');
    } catch (error) {
      debugPrint('API request failed: $error');
    }
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    if (_camera != null) {
      await _camera!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));
      await _camera!.dispose();
      _camera = null;
    }
    super.dispose();
  }

  late File jsonFile;
  var interpreter;
  CameraController? _camera;
  dynamic data = {};
  bool _isDetecting = false;
  double threshold = 1.0;
  dynamic _scanResults;
  String _predRes = '';
  bool isStream = true;
  Directory? tempDir;
  bool faceFound = false;
  bool _verify = false;
  List? e1;
  bool loading = true;

  void initialCamera() async {
    CameraDescription description = await getCamera(CameraLensDirection.front);
    _camera = CameraController(
      description,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _camera!.initialize();
    await Future.delayed(const Duration(milliseconds: 500));
    loading = false;
    tempDir = await getApplicationDocumentsDirectory();
    String embPath = '${tempDir!.path}/emb.json';
    jsonFile = File(embPath);
    if (jsonFile.existsSync()) {
      data = json.decode(jsonFile.readAsStringSync());
    }

    await Future.delayed(const Duration(milliseconds: 500));

    _camera!.startImageStream((CameraImage image) async {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        dynamic finalResult = Multimap<String, Face>();

        detect(image, getDetectionMethod()).then((dynamic result) async {
          if (result.length == 0 || result == null) {
            faceFound = false;
            _predRes =
                AppLocalizations(globalLanguage).translate("notRecognized");
          } else {
            faceFound = true;
          }

          String res;
          Face face;

          imglib.Image convertedImage =
              convertCameraImage(image, CameraLensDirection.front);

          for (face in result) {
            double x, y, w, h;
            x = (face.boundingBox.left - 10);
            y = (face.boundingBox.top - 10);
            w = (face.boundingBox.width + 10);
            h = (face.boundingBox.height + 10);
            imglib.Image croppedImage = imglib.copyCrop(
                convertedImage, x.round(), y.round(), w.round(), h.round());
            croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
            res = recog(croppedImage);
            finalResult.add(res, face);
          }

          _scanResults = finalResult;
          _isDetecting = false;
          setState(() {});
        }).catchError(
          (_) async {
            debugPrint('error: $_');
            _isDetecting = false;
            if (_camera != null) {
              await _camera!.stopImageStream();
              await Future.delayed(const Duration(milliseconds: 400));
              await _camera!.dispose();
              await Future.delayed(const Duration(milliseconds: 400));
              _camera = null;
            }

            if (mounted) {
              Navigator.pop(context);
            }
          },
        );
      }
    });
  }

  String recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1!).toUpperCase();
  }

  String compare(List currEmb) {
    double minDist = 999;
    double currDist = 0.0;
    _predRes = AppLocalizations(globalLanguage).translate("notRecognized");
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        _predRes = label;
        if (_verify == false) {
          _verify = true;
        }
      }
    }
    return _predRes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            padding: const EdgeInsets.only(top: 0, bottom: 0),
            child: Builder(builder: (context) {
              if ((_camera == null || !_camera!.value.isInitialized) ||
                  loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return _camera == null
                  ? const Center(child: SizedBox())
                  : Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CameraPreview(_camera!),
                        _buildResults(),
                      ],
                    );
            }),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    AppLocalizations(globalLanguage)
                        .translate("faceRecognition"),
                    style: const TextStyle(fontSize: 24, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  children: [
                    Text(username),
                    ElevatedButton(
                      onPressed: () async {
                        sendDataToApi();
                      },
                      child: Text(
                          AppLocalizations(globalLanguage).translate("save")),
                    )
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildResults() {
    Center noResultsText = Center(
        child: Text(
            '${AppLocalizations(globalLanguage).translate("pleaseWait")}...',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.deepGreen)));
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }
}
