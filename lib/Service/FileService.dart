import 'dart:io';

import 'package:cryptovoteui/Utililities/FileType.dart';

class
FileService
{
  final tokenDir = 'lib/Resources/Files/Token';
  final walletDir = 'lib/Resources/Files/Wallet';
  final IdDir = 'lib/Resources/Files/ID';

  FileService.empty();
  Future<List<String>> _ListOfFileNames(String dir) async
  {
    final directory = Directory(dir);
    final List<String> fileNames = [];
    print('priting dir:' + dir);
    await for(FileSystemEntity entity in directory.list(recursive: false))
      {
        if(entity is File)
        {
         final foundFile = entity.path.split(Platform.pathSeparator).last;
         final name = foundFile.split('.').first;
         print('priting file:' + name);
         fileNames.add(name);
        }
      }

    return fileNames;

  }

  Future<List<String>> getListOfFile(FileType typ)
  {


    switch(typ.name) {
      case 'TOKEN':
      return _ListOfFileNames(tokenDir);
      case 'ID' :
       return  _ListOfFileNames(IdDir);
      case 'WALLET':
        return _ListOfFileNames(walletDir);
      default: return _ListOfFileNames('');

    }


  }

}