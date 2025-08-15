import 'dart:io';

abstract class IFile
{

  Future<void>saveToFile(String fileName);

  Future<IFile> loadFromFile(String fileName);




}