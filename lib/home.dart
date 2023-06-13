import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';

class ftp extends StatefulWidget {
  @override
  State<ftp> createState() => _ftpState();
}

class _ftpState extends State<ftp> {
  List<String> _listOfFiles = [];

  initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final ftpConnect =
        FTPConnect('122.15.209.75', port: 50004, user: 'SURAJ', pass: 'SURAJ');
    await ftpConnect.connect();
    await ftpConnect.createFolderIfNotExist("Sitename_demo");
    await ftpConnect.changeDirectory("Sitename_demo");
    await ftpConnect.createFolderIfNotExist("Loggerid_704612");
    await ftpConnect.changeDirectory("Loggerid_704612");
    List directoryContents1 = await ftpConnect.listDirectoryContent();
    for (var i = 0; i < directoryContents1.length; i++) {
      print(directoryContents1[i].name);
      setState(() {
        _listOfFiles.add(directoryContents1[i].name);
      });
    }
    ftpConnect.currentDirectory().then((value) => print(value));
  }

  Future<void> uploadFileToFTP() async {
    final ftpConnect =
        FTPConnect('122.15.209.75', port: 50004, user: 'SURAJ', pass: 'SURAJ');
    try {
      await ftpConnect.connect();
      print('Connected');

      await ftpConnect.createFolderIfNotExist("Sitename_demo");
      await ftpConnect.changeDirectory("Sitename_demo");
      await ftpConnect.createFolderIfNotExist("Loggerid_704612");
      await ftpConnect.changeDirectory("Loggerid_704612");
      List directoryContents1 = await ftpConnect.listDirectoryContent();
      for (var i = 0; i < directoryContents1.length; i++) {
        print(directoryContents1[i].name);
      }
      ftpConnect.currentDirectory().then((value) => print(value));

      print('Directory changed');

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File fileToUpload = File(result.files.single.path!);

        await ftpConnect.uploadFile(fileToUpload);
        print('File uploaded successfully');
      } else {
        // User canceled the file picking process
        print('No file selected');
      }
      // List directoryContents = await ftpConnect.listDirectoryContent();
      // print(directoryContents);
      List directoryContents = await ftpConnect.listDirectoryContent();
      _listOfFiles = [];
      for (var i = 0; i < directoryContents.length; i++) {
        print(directoryContents[i].name);
        setState(() {
          _listOfFiles.add(directoryContents[i].name);
        });
      }

      await ftpConnect.disconnect();
      print("retrived");
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> downloadFileFromFTP(String remoteFilePath) async {
    final ftpConnect =
        FTPConnect('122.15.209.75', port: 50004, user: 'SURAJ', pass: 'SURAJ');

    try {
      await ftpConnect.connect();
      print('Connected');
      await ftpConnect.changeDirectory("Sitename_demo/Loggerid_704612");
      await ftpConnect.currentDirectory().then((value) => print(value));

      String? customDirectory = await FilePicker.platform.getDirectoryPath();

      if (customDirectory != null) {
        String fileName = remoteFilePath.split('/').last;
        String localFilePath = '${customDirectory}/$fileName';
        File localFile = File(localFilePath);

        await ftpConnect.downloadFileWithRetry(remoteFilePath, localFile);

        print('File downloaded successfully');
      } else {
        print('No directory selected');
      }

      await ftpConnect.disconnect();
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            ElevatedButton(
                onPressed: () {
                  uploadFileToFTP();
                },
                child: Text('Upload')),
            Container(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: _listOfFiles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      downloadFileFromFTP(_listOfFiles[index]);
                    },
                    child: ListTile(
                      tileColor: Colors.amber,
                      title: Text(
                        _listOfFiles[index],
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
