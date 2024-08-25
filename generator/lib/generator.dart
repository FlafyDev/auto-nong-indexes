import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

final uuid = Uuid();

Future<void> jsonToIndexFile(File file, Map<String, Object?> data) async {
  await file.writeAsString(JsonEncoder().convert(data));
}

Future<Map<String, Object?>> covnertOfficialIndex() async {
  final res = await http.get(Uri.parse('https://raw.githubusercontent.com/FlafyDev/auto-nong-indexes/main/official.json'));
  final obj = (json.decode(res.body) as List<dynamic>).cast<Map<String, dynamic>>();

  final ytSongs = obj.fold<Map<String, dynamic>>({}, (acc, entry) {
    final ytID = entry['yt-id'];
    if (ytID is! String) return acc;

    final name = entry['name'];
    if (name is! String) return acc;

    final artist = entry['artist'];
    if (artist is! String) return acc;

    final songs = entry['songs'];
    if (songs is! List) return acc;

    final startOffset = entry['startOffset'] ?? 0;

    final id = uuid.v5("8dd3aa81-28f2-40ca-afad-314ddd5caadd", name+artist+songs.toString()+ytID+startOffset.toString());

    return {
      ...acc,
      id: {
        "name": name,
        "artist": artist,
        "startOffset": startOffset,
        "ytID": ytID,
        "songs": songs,
      },
    };
  });

  return {
    "manifest": 1,
    "name": "Auto Nong Index",
    "id": "auto-nong-index",
    "description": "Official Auto Nong Index",
    "lastUpdate": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "links": {
      "discord": "https://discord.gg/twuZ3X35yM",
    },
    "features": {
      "submit": {
        "supportedSongTypes": ["youtube"],
        "requestParams": {
          "url": "https://github.com/FlafyDev/auto-nong-indexes/issues/new?template=add-nong-song.yml&extra=From%20Jukebox&",
          "params": true,
        },
      },
    },
    "nongs": {
      "hosted": {},
      "youtube": ytSongs,
    },
  };
}

Future<Map<String, Object?>> genSFHIndex() async {
  final res = await http.get(Uri.parse('https://api.songfilehub.com/songs'));
  final obj = (json.decode(res.body) as List<dynamic>).cast<Map<String, dynamic>>();

  final hostedSongs = obj.fold<Map<String, dynamic>>({}, (acc, entry) {
    final songID = int.tryParse(entry['songID'] ?? "");

    if (songID == null) return acc;

    final id = entry['_id'];
    if (id is! String) return acc;

    final url = entry['downloadUrl'];
    if (url is! String) return acc;

    final songFullName = entry['songName'];
    if (songFullName is! String) return acc;
    final String songName;
    final String artistName;
    if (songFullName.contains(" - ")) {
      songName = songFullName.substring(0, songFullName.indexOf(" - ")).trim();
      artistName = songFullName.substring(songFullName.indexOf(" - ")+3).trim();
    } else {
      songName = songFullName;
      artistName = "";
    }

    return {
      ...acc,
      id: {
        "name": songName,
        "artist": artistName,
        "startOffset": 0,
        "url": url,
        "songs": [songID],
      },
    };
  });


  return {
    "manifest": 1,
    "name": "Song File Hub Index",
    "id": "song-file-hub-index",
    "description": "Song File Hub Index",
    "lastUpdate": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "links": {
      "discord": "https://discord.gg/maSgd4zpEF",
    },
    "features": {
      "submit": {
        "supportedSongTypes": ["local", "youtube", "hosted"],
        "requestParams": {
          "url": "https://discord.gg/maSgd4zpEF",
          "params": false,
        },
      },
    },
    "nongs": {
      "youtube": {},
      "hosted": hostedSongs,
    },
  };
}
