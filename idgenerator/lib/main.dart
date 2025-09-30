import 'package:flutter/material.dart';

import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'dart:typed_data';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student ID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      //home: const MyHomePage(title: 'Syed Huzzatullah Mihad 210041218'),
      home: idFormCard(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String name;
  final String id;
  final String nationality;
  final String department;
  final String title;
  final Uint8List? profileImage;

  const MyHomePage({
    super.key,
    required this.name,
    required this.id,
    required this.nationality,
    required this.department,
    required this.title,
    required this.profileImage,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Color containerColor = Colors.white; // initial color
  Color containerColor2 = const Color.fromARGB(
    255,
    26,
    76,
    53,
  ); // initial color

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void changeColor() {
    setState(() {
      containerColor = Color.fromRGBO(
        Random().nextInt(256), // Red 0–255
        Random().nextInt(256), // Green 0–255
        Random().nextInt(256), // Blue 0–255
        1, // Opacity
      );
    });
  }

  void changeColorHalf() {
    setState(() {
      containerColor2 = Color.fromRGBO(
        Random().nextInt(256), // Red 0–255
        Random().nextInt(256), // Green 0–255
        Random().nextInt(256), // Blue 0–255
        1, // Opacity
      );
    });
  }

  late TextStyle currentFont;

  static final List<TextStyle Function()> fontList = [
    () => GoogleFonts.lato(),
    () => GoogleFonts.roboto(),
    () => GoogleFonts.poppins(),
    () => GoogleFonts.montserrat(),
    () => GoogleFonts.oswald(),
    () => GoogleFonts.raleway(),
    () => GoogleFonts.openSans(),
    () => GoogleFonts.merriweather(),
    () => GoogleFonts.sourceSans3(),
    () => GoogleFonts.nunito(),
  ];

  @override
  void initState() {
    super.initState();
    // set default font

    currentFont = GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.normal,
    );
  }

  void changeFont() {
    final random = Random();
    setState(() {
      currentFont = fontList[random.nextInt(fontList.length)]().copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ID CARD BOX
            Container(
              width: 300,
              height: 450,
              decoration: BoxDecoration(
                color: containerColor,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none, // allow overflow
                    children: [
                      // Green Header
                      Container(
                        width: double.infinity,
                        height: 150,
                        color: containerColor2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/iutlogo.png',
                                width: 75,
                                height: 75,
                                fit: BoxFit.contain,
                              ),
                              const Text(
                                'ISLAMIC UNIVERSITY OF TECHNOLOGY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  //fontFamily: 'Impact',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Profile Image (half in green, half in white)
                      Positioned(
                        top: 102,
                        left: 100, // adjust as needed to center
                        child: Container(
                          width: 100, // rectangle width
                          height: 130, // rectangle height
                          decoration: BoxDecoration(
                            color: Color.fromARGB(
                              255,
                              20,
                              57,
                              40,
                            ), // outer border color
                            // rounded corners
                            border: Border.all(
                              color: const Color.fromARGB(255, 25, 78, 40),
                              width: 4,
                            ), // optional border
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: widget.profileImage != null
                                ? Image.memory(
                                    widget.profileImage!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/mihad.jpg',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 83), // space below profile image
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.key,
                            size: 20,
                            color: const Color.fromARGB(255, 55, 109, 39),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Student ID',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            20,
                            60,
                            45,
                          ), // Dark green
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 15,
                              height: 15,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00BCD4), // Cyan circle
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              widget.id,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 20,
                            color: const Color.fromARGB(255, 55, 109, 39),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Student Name',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: 17,
                              color: const Color.fromARGB(255, 6, 50, 13),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school,
                            size: 20,
                            color: const Color.fromARGB(255, 55, 109, 39),
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                              children: [
                                TextSpan(text: 'Program - '),
                                TextSpan(
                                  text: 'B.Sc. in ${widget.department}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            size: 20,
                            color: const Color.fromARGB(255, 55, 109, 39),
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                              children: [
                                TextSpan(text: 'Department - '),
                                TextSpan(
                                  text: widget.department,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: const Color.fromARGB(255, 55, 109, 39),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.nationality,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: containerColor2,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'A subsidiary organ of OIC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              changeColor();
              changeColorHalf();
            },
            child: Text("Change Color"),
          ),
          const SizedBox(height: 10), // space between buttons
          ElevatedButton(onPressed: changeFont, child: Text("Change Font")),
        ],
      ),
    );
  }
}

class idFormCard extends StatefulWidget {
  const idFormCard({super.key});

  @override
  State<idFormCard> createState() => _idFormCardState();
}

class _idFormCardState extends State<idFormCard> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _departmentController = TextEditingController();

  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes(); // read as bytes for web
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ID Form Card')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // validation key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _selectedImageBytes != null
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage: MemoryImage(_selectedImageBytes!),
                    )
                  : const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/prifile.png'),
                    ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Select Image"),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your ID' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nationalityController,
                decoration: const InputDecoration(
                  labelText: 'Nationality',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your nationality'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your department'
                    : null,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      // On success, navigate to ID card page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(
                            name: _nameController.text,
                            id: _idController.text,
                            nationality: _nationalityController.text,
                            department: _departmentController.text,
                            title: "Generated Student ID",
                            profileImage: _selectedImageBytes,
                          ),
                        ),
                      );
                    }
                  },

                  child: const Text("Generate ID Card"),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          color: Colors.blue,
          child: const Center(
            child: Text(
              'Bottom Navigation Bar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      drawer: Drawer(),
      endDrawer: Drawer(),
    );
  }
}
