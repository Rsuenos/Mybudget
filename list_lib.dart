import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final outputFile = File('lib_yapisi.txt');

  if (!libDir.existsSync()) {
    stdout.writeln('lib klasörü bulunamadı.');
    return;
  }

  final sink = outputFile.openWrite();
  sink.writeln('lib/');
  _listDirectory(libDir, sink, '');

  sink.close();
  stdout.writeln('lib_yapisi.txt dosyasına yazıldı.');
}

void _listDirectory(Directory dir, IOSink sink, String indent) {
  final entities = dir.listSync().toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (var entity in entities) {
    final name = entity.uri.pathSegments.last;
    if (entity is File) {
      sink.writeln('$indent├── $name');
    } else if (entity is Directory) {
      sink.writeln('$indent├── $name/');
      _listDirectory(entity, sink, '$indent│   ');
    }
  }
}
