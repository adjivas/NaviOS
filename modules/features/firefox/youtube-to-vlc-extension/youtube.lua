-- YouTube playlist resolver for VLC
-- ~/.local/share/vlc/lua/playlist/youtube.lua

local yt_dlp = "yt-dlp"

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

function probe()
    return
        (vlc.access == "http" or vlc.access == "https")
        and (
            string.match(vlc.path, "youtube%.com")
            or string.match(vlc.path, "youtu%.be")
        )
end

function parse()
    local youtube_url = vlc.access .. "://" .. vlc.path

    vlc.msg.info(
        "[YouTube Resolver] URL: " .. youtube_url
    )

    local quality =
        youtube_url:match("[&?]quality=(%d+)[pP]?")

    youtube_url = youtube_url
        :gsub("([&?])quality=%d+[pP]?", "%1")
        :gsub("%?&", "?")
        :gsub("&&+", "&")
        :gsub("[?&]$", "")

    local allowed_qualities = {
        ["360"] = true,
        ["480"] = true,
        ["720"] = true,
        ["1080"] = true,
        ["2160"] = true,
    }

    -- local format_string = "bestvideo+bestaudio"
    local format_string = "bestvideo[vcodec^=avc1]+bestaudio"

    if quality and allowed_qualities[quality] then
        format_string =
            "bestvideo[height=" .. quality .. "]+bestaudio"

        vlc.msg.info(
            "[YouTube Resolver] quality: "
            .. quality
            .. "p"
        )
    end

    local command =
        yt_dlp
        .. " --no-warnings"
        .. " --no-playlist"
        .. " -f "
        .. shell_quote(format_string)
        .. " -g -- "
        .. shell_quote(youtube_url)
        .. " 2>/dev/null"

    vlc.msg.info(
        "[YouTube Resolver] Running yt-dlp"
    )

    local handle = io.popen(command)

    if handle == nil then
        vlc.msg.err(
            "[YouTube Resolver] Failed to execute yt-dlp"
        )

        return {}
    end

    local video_url = handle:read("*l")
    local audio_url = handle:read("*l")

    handle:close()

    if video_url then
        video_url = video_url
            :gsub("^%s+", "")
            :gsub("%s+$", "")
    end

    if audio_url then
        audio_url = audio_url
            :gsub("^%s+", "")
            :gsub("%s+$", "")
    end

    if not video_url or video_url == "" then
        vlc.msg.err(
            "[YouTube Resolver] yt-dlp returned no video URL"
        )

        return {}
    end

    vlc.msg.info(
        "[YouTube Resolver] Video URL resolved"
    )

    if audio_url and audio_url ~= "" then
        vlc.msg.info(
            "[YouTube Resolver] Separate audio URL resolved"
        )

        return {
            {
                path = video_url,
                name = "YouTube",
                options = {
                    ":input-slave=" .. audio_url,
                },
            },
        }
    end

    vlc.msg.info(
        "[YouTube Resolver] Single media URL resolved"
    )

    return {
        {
            path = video_url,
            name = "YouTube",
        },
    }
end
