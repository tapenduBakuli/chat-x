import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
class ImageUploadDb {
  String generateUniqueSuffix() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final random = Random().nextInt(1e9.toInt());
  return '$now-$random';
}

 Future<String?> saveBase64Image(String base64String, String uploadPath) async {


  try {
    // Decode the base64 string into a list of bytes
    var bytes = base64Decode(base64String);

    // Generate a unique file name
    String uniqueSuffix = generateUniqueSuffix();
    String fileName = '$uniqueSuffix.png';

    // Create the directory if it doesn't exist
    Directory directory = Directory(uploadPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Create the file path
    String filePath = '${directory.path}/$fileName';

    print("-------------------------");
    //image saving 
    
    print("${filePath}");
    print("--------------------------------");
    // Write the bytes to a file
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    // Return the file path
    return filePath;
  } catch (e) {
    print('Error saving image: $e');
    return null;
  }
}


Future<void> deleteFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = path.join(directory.path, fileName);
  final file = File(filePath);

  // Check if the file exists before deleting
  if (await file.exists()) {
    await file.delete();
    print('File deleted');
  } else {
    print('File not found');
  }
}

Future<File> createFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory(); // or getTemporaryDirectory()
  final filePath = path.join(directory.path, fileName);
  final file = File(filePath);
  return file.create(); // This creates the file
}
}
