import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> pickAndSaveLogo() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['svg', 'png', 'jpg', 'jpeg'],
  );

  if (result == null || result.files.single.path == null) return null;

  final file = File(result.files.single.path!);
  if (file.lengthSync() > 5 * 1024 * 1024) return null;

  final dir = await getApplicationDocumentsDirectory();
  final saved = await file.copy('${dir.path}/business_logo${result.files.single.extension ?? '.png'}');
  return saved.path;
}
