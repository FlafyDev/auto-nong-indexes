resf="${HOME}/issue-parser-result.json"  # Form result file for easy access

case $(jq -r .source "$resf") in
  "Youtube")
    yt_id=$(jq -r .\"youtube-link\" "$resf" | grep -oP '(?<=youtu\.be/|v=|\/|^)[^&?/]+' | tail -1)
    
    jq '{
        name: .["song-name"],
        artist: .["artist-name"],
        source: "youtube",
        startOffset: (.["start-offset"] // "0" | tonumber? // 0),
        "yt-id": "'"$yt_id"'",
        songs: [(.["song-id"] | tonumber)]
      }' "$resf" > result.json
    
    cat result.json
    ;;
  
  "Direct file download")
    jq '{
        name: .["song-name"],
        artist: .["artist-name"],
        source: "host",
        startOffset: (.["start-offset"] // "0" | tonumber? // 0),
        url: .["direct-link"],
        songs: [(.["song-id"] | tonumber)]
      }' "$resf" > result.json
    ;;
  
  *)
    echo "Invalid source"
    exit 1
    ;;
esac
