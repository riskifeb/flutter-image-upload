import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery/main.dart';

class ImageDetailScreen extends StatefulWidget {
  final String apiKey;

  ImageDetailScreen(this.apiKey);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  final List<String> imageUrlList = [];

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  void fetchImages() async {
    String apiUrl = 'https://kifeb.fly.dev/get-image';

    // Menyiapkan data permintaan
    Map<String, dynamic> requestBody = {
      'api_key': widget.apiKey,
    };

    // Mengirim permintaan POST ke API
    try {
      final response =
          await http.post(Uri.parse(apiUrl), body: jsonEncode(requestBody));

      if (response.statusCode == 200) {
        // Berhasil mendapatkan gambar
        var imageListData = json.decode(response.body);
        // print(imageListData); // ini ada
        setState(() {
          for (var i in imageListData["data"]) {
            imageUrlList.add(i);
          }
          // imageUrlList.add(imageListData["image"][0].toString());
        });
      } else {
        // Gagal mendapatkan gambar
        _showErrorDialog(
            'Failed to fetch images. Error: ${response.statusCode}');
      }
    } catch (error) {
      // Gagal melakukan permintaan
      _showErrorDialog('Error: $error');
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Detail'),
      ),
      body: Container(
          width: double.infinity,
          height: double.maxFinite,
          child: imageUrlList.isNotEmpty
              ? ListView.builder(
                  itemCount: imageUrlList.length,
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 9,
                                  offset: Offset(1, 1))
                            ]),
                            padding: EdgeInsets.all(10),
                            width: 300,
                            child: Image.memory(
                              base64Decode(imageUrlList[index]),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    );
                  })
              : Center(
                  child: Text("Image Empty"),
                )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return UploadImageScreen();
                  }));
                },
                child: const Text('Upload Image'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
