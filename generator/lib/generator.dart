import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

Future<void> jsonToIndexFile(File file, Map<String, Object?> data) async {
  await file.writeAsString(JsonEncoder().convert(data));
}

Future<Map<String, Object?>> convertOfficialIndex() async {
  final res = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/FlafyDev/auto-nong-indexes/main/official.json'));
  final obj = (json.decode(res.body) as List<dynamic>)
      .cast<Map<String, dynamic>>();

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

    final id = uuid.v5(
      "8dd3aa81-28f2-40ca-afad-314ddd5caadd",
      name + artist + songs.toString() + ytID + startOffset.toString(),
    );

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
    "name": "NONG Index",
    "id": "nong-index",
    "description": "Official NONG Index",
    "lastUpdate": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "links": {
      "discord": "https://discord.gg/twuZ3X35yM",
    },
    "features": {
      "submit": {
        "supportedSongTypes": ["youtube"],
        "preSubmitMessage": """
Pressing continue will redirect you to the GitHub issue page to submit your song request. It will be auto-filled with the data you provided.

**Submissions that do not respect the following rules will almost always be rejected**

1. NONG replacement songs (not remixes/mashups) should only be accepted if the level that it was made for is judged very popular. Exceptions to this rule can be made if the replacement Newgrounds song that is used in the level is not used and not likely to be used by any level (e.g., [Chilled 1](https://www.newgrounds.com/audio/listen/1)).
2. Do not accept submissions that replace songs used by other popular levels, especially if one of these levels is rated. For example, do not replace Stereo Madness or Tennobyte - Fly Away with an unrelated song.
3. Before accepting a submission, ensure all the fields (Name, Artist, etc.) are written correctly.
4. **Test the submission in-game** before submitting/accepting it. If it has a corresponding level, ensure it syncs with it. If it's a remix/mashup, ensure it syncs with the replaced song. Test in-game by adding a new song and copying the YouTube ID from the submission.
5. Links from Google Drive, Mediafire, Dropbox, etc., are not allowed. Only submit YouTube video links or **permanent** direct download links from CDNs that Jukebox has permission to download from. Currently, no CDNs are allowed. If you don't want to upload to YouTube, submit to the SFH.

Only NONG Index moderators can accept or reject submissions by commenting "accept" or "reject" under a submission.
"""
            .trim(),
        "requestParams": {
          "url":
              "https://github.com/FlafyDev/auto-nong-indexes/issues/new?template=add-nong-song.yml&extra=From%20Jukebox&",
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
  final obj = (json.decode(res.body) as List<dynamic>)
      .cast<Map<String, dynamic>>();

  final hostedSongs = obj.fold<Map<String, dynamic>>({}, (acc, entry) {
    var songID = int.tryParse(entry['songID'] ?? "");

    songID ??= switch ((entry['songID'] as String).toLowerCase()) {
      "stereomadness" => -1,
      "backontrack" => -2,
      "polargeist" => -3,
      "dryout" => -4,
      "baseafterbase" => -5,
      "cantletgo" => -6,
      "jumper" => -7,
      "timemachine" => -8,
      "cycles" => -9,
      "xstep" => -10,
      "clutterfunk" => -11,
      "theoryofeverything" => -12,
      "electromanadventures" => -13,
      "electroman" => -13,
      "clubstep" => -14,
      "electrodynamix" => -15,
      "hexagonforce" => -16,
      "blastprocessing" => -17,
      "theoryofeverything2" => -18,
      "geometricaldominator" => -19,
      "deadlocked" => -20,
      "fingerdash" => -21,
      "dash" => -22,
      _ => null,
    };

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
      songName = songFullName.substring(songFullName.indexOf(" - ") + 3).trim();
      artistName =
          songFullName.substring(0, songFullName.indexOf(" - ")).trim();
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
    "name": "Song File Hub",
    "id": "song-file-hub-index",
    "description": "Song File Hub Index",
    "lastUpdate": DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "links": {
      "discord": "https://discord.gg/maSgd4zpEF",
    },
    "features": {
      "submit": {
        "supportedSongTypes": ["local", "youtube", "hosted"],
        "preSubmitMessage": """
To submit your own song(s), please use the Song File Hub Discord Bot with the /submit command to be reviewed by helpers.
Please read the rules and walkthroughs for the commands before submitting!

Only mp3/ogg files are supported.

Disclaimer: It may take a bit to show on Jukebox's song list after being accepted.
"""
            .trim(),
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
