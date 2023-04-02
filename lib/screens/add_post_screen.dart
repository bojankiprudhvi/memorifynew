import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:slide_to_act/slide_to_act.dart';
/// Screen to choose photos and add a new feed post.

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  static const double maxImageHeight = 1000;
  static const double maxImageWidth = 800;
String? _currentAddress;
Position? _currentPosition;
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
final slideActionKey = GlobalKey<SlideActionState>();
  XFile? _pickedFile;
  bool loading = false;

  final picker = ImagePicker();

  Future<void> _pickFile() async {
    _getCurrentPosition();
    _pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: maxImageHeight,
      maxWidth: maxImageWidth,
      imageQuality: 70,
    );
    setState(() {});
  }
  void _setLoading(bool state, {bool shouldCallSetState = true}) {
    if (loading != state) {
      loading = state;
      if (shouldCallSetState) {
        setState(() {});
      }
    }
  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }
Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.name},${place.street}, ${place.subLocality},${place.locality}, ${place.subAdministrativeArea},${place.administrativeArea} ,${place.country},${place.postalCode}';
            //KRN Complex,KRN Complex, NSTL,Visakhapatnam, ,Andhra Pradesh ,India,530009
     print(_currentAddress);
      }); 
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Uploading...')
                ],
              ),
            )
          : Column(
            children:  <Widget>[
               Expanded(
              flex: 4,
              child: InkWell(
                  onTap: _pickFile,
                  child: Expanded(
                    child: (_pickedFile != null)
                        ? FadeInImage(
                            fit: BoxFit.contain,
                            placeholder: MemoryImage(kTransparentImage),
                            image: Image.file(File(_pickedFile!.path)).image,
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    AppColors.bottomGradient,
                                    AppColors.topGradient
                                  ]),
                            ),
                            height: 300,
                            child: const Center(
                              child: Text(
                                'Tap to select an image',
                                style: TextStyle(
                                  color: AppColors.light,
                                  fontSize: 18,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(2.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black54,
                                    ),
                                    Shadow(
                                      offset: Offset(1.0, 1.5),
                                      blurRadius: 5.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
               ),
               
              Expanded(
                    flex: 4,
                child:  Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
            children:  <Widget>[
              Expanded(
                    flex: 4,
              child:Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _text,
                      decoration: const InputDecoration(
                        hintText: 'Write a caption',
                        border: InputBorder.none,
                      ),
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Caption is empty';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
 Expanded(
                    flex: 4,
              child:  Text('ADDRESS: ${_currentAddress ?? ""}', textAlign: TextAlign.left,),),
                

              Expanded(
                    flex: 4,

              child: SlideAction(
          key:slideActionKey,
innerColor: Colors.blue,
outerColor: Colors.blue [200],
text: 'Slide to Post',
textStyle: const TextStyle(
color: Colors.white,
fontSize: 24,
), // TextStyle
sliderRotate: false,

onSubmit:(){
  Future.delayed(const Duration(seconds: 3), () {
                      slideActionKey.currentState!.reset();
                    });
}
// do // SlideAction
 ), ),
            ],),
                 ),
                
              ],
            ),
    );
  }
}

abstract class AppColors {
  /// Dark color.
  static const dark = Colors.black;

  static const light = Color(0xFFFAFAFA);

  /// Grey background accent.
  static const grey = Color(0xFF262626);

  /// Primary text color
  static const primaryText = Colors.white;

  /// Secondary color.
  static const secondary = Color(0xFF0095F6);

  /// Color to use for favorite icons (indicating a like).
  static const like = Colors.red;

  /// Grey faded color.
  static const faded = Colors.grey;

  /// Light grey color
  static const ligthGrey = Color(0xFFEEEEEE);

  /// Top gradient color used in various UI components.
  static const topGradient = Color(0xFFE60064);

  /// Bottom gradient color used in various UI components.
  static const bottomGradient = Color(0xFFFFB344);
}
