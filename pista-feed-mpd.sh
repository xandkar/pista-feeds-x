#! /bin/bash

current_state() {
    printf 'status\ncurrentsong\nclose\n' | nc 127.0.0.1 6600 \
    | awk '
        # Msg separator
        /^OK/ {msg_count++; next}

        # Msg content
        /^[a-zA-Z-]+: / {
            key = $1
            val = $0
            sub(".*" key " *", "", val)
            sub(":$", "", key)
            key = tolower(key)
            # Note that we expect a particular order of response messages (also
            # reflected in the name of this script file): "status" THEN "currentsong"
                 if (msg_count == 1) {status[key]      = val}
            else if (msg_count == 2) {currentsong[key] = val}
            else {
                printf("Unexpected msg_count in mpd response: %d\n", msg_count) \
                    > "/dev/stderr"
                exit 1
            }
            next
        }

        END {
            name  = currentsong["name"]
            title = currentsong["title"]
            file  = currentsong["file"]

            if (name) {
                song = name
            } else if (title) {
                song = title
            } else if (file) {
                last = split(file, parts, "/")
                song = parts[last]
            } else {
                song = "?"
            }

            format_time(status["time"], time)
            time_min_units  = time["minimal_units"]
            time_percentage = time["percentage"]
            state           = status["state"]

            if (state == "play") {
                symbol = ">"
            } else if (state == "pause") {
                symbol = "="
            } else if (state == "stop") {
                symbol = "-"
            } else {
                printf("Unexpected state value: %s\n", state) > "/dev/stderr"
                exit 1
            }

            printf "%s %8s %4s\n", symbol, time_min_units, time_percentage
        }

        function format_time(time_str, time_arr,    \
            \
            time_str_parts,
            seconds_current,
            seconds_total,
            hours,
            secs_beyond_hours,
            mins,
            secs,
            time_percentage \
        ) {
            split(time_str, time_str_parts, ":")
            seconds_current = time_str_parts[1]
            seconds_total   = time_str_parts[2]

            hours = int(seconds_current / 60 / 60);
            secs_beyond_hours = seconds_current - (hours * 60 * 60);
            mins = int(secs_beyond_hours / 60);
            secs = secs_beyond_hours - (mins * 60);

            if (hours > 0) {
                time_arr["minimal_units"] = sprintf("%d:%.2d:%.2d", hours, mins, secs)
            } else {
                time_arr["minimal_units"] = sprintf("%.2d:%.2d", mins, secs)
            }

            if (seconds_total > 0) {
                time_percentage = (seconds_current / seconds_total) * 100
                time_arr["percentage"] = sprintf("%d%%", time_percentage)
            } else {
                time_arr["percentage"] = "~"
            }
        }
    '
}

trap '' PIPE

while :
do
    current_state
    sleep 1
done
