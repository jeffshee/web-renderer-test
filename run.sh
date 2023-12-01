#!/bin/sh

### Git clone
GSTCEFSRC_REPO="https://github.com/centricular/gstcefsrc.git"
GST_PLUGIN_RS_REPO="https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs.git"
GST_PLUGIN_RS_REPO_BRANCH="0.11"
git clone $GSTCEFSRC_REPO
git clone $GST_PLUGIN_RS_REPO -b $GST_PLUGIN_RS_REPO_BRANCH
###

### Build gstcefsrc
# https://github.com/centricular/gstcefsrc
CEF_VERSION="103.0.9+gd0bbcbb+chromium-103.0.5060.114"
cd gstcefsrc || exit 1
mkdir build && cd build || exit 1
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCEF_VERSION=$CEF_VERSION ..
cmake --build .
cmake --install . --prefix="../../build/lib/gstreamer-1.0"
###

### Build gst-plugin-gtk4
# https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs
cd gst-plugins-rs || exit 1
cargo install cargo-c
cargo cbuild -p gst-plugin-gtk4
cargo cinstall -p gst-plugin-gtk4 --prefix="../build"
###

### Print plugin details
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
gst-inspect-1.0 cef
gst-inspect-1.0 gtk4
gst-inspect-1.0 clapper
###

### Test 1 (full pipeline)
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
gst-launch-1.0 \
    cefsrc url="https://soundcloud.com/platform/sama" ! \
    video/x-raw, width=1920, height=1080, framerate=60/1 ! cefdemux name=d d.video ! \
    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! videoconvert ! \
    xvimagesink audiotestsrc do-timestamp=true is-live=true volume=0.00 ! audiomixer name=mix ! \
    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! audioconvert ! pulsesink \
    d.audio ! mix.
###

### Test 2 (full pipeline w/ gtk4paintablesink)
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
gst-launch-1.0 \
    cefsrc url="https://soundcloud.com/platform/sama" ! \
    video/x-raw, width=1920, height=1080, framerate=60/1 ! cefdemux name=d d.video ! \
    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! videoconvert ! \
    gtk4paintablesink audiotestsrc do-timestamp=true is-live=true volume=0.00 ! audiomixer name=mix ! \
    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! audioconvert ! pulsesink \
    d.audio ! mix.
###

### Test 3 (full pipeline w/ clappersink)
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
gst-launch-1.0 \
    cefsrc url="https://soundcloud.com/platform/sama" ! \
    video/x-raw, width=1920, height=1080, framerate=60/1 ! cefdemux name=d d.video ! \
    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! videoconvert ! \
    clappersink audiotestsrc do-timestamp=true is-live=true volume=0.00 ! audiomixer name=mix ! \
    queue max-size-bytes=0 max-size-buffers=0 max-size-time=3000000000 ! audioconvert ! pulsesink \
    d.audio ! mix.
###

### Test 4 (cefbin w/ xvimagesink)
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
gst-launch-1.0 \
    cefbin name=cef cefsrc::url="https://soundcloud.com/platform/sama" \
    cef.video ! video/x-raw, width=1920, height=1080, framerate=60/1 ! videoconvert ! xvimagesink \
    cef.audio ! audioconvert ! audiomixer ! autoaudiosink
###

### Test 5 (cefbin w/ gtk4paintablesink)
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
gst-launch-1.0 cefbin name=cef cefsrc::url="https://www.soundcloud.com/platform/sama" \
    cefsrc::gpu=true ! video/x-raw, width=1920, height=1080, framerate=60/1 ! videoconvert ! gtk4paintablesink \
    cef.audio ! audioconvert ! audiomixer ! autoaudiosink
###

### Test 6 (cefbin w/ clappersink)
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
gst-launch-1.0 cefbin name=cef cefsrc::url="https://www.soundcloud.com/platform/sama" \
    cefsrc::gpu=true ! video/x-raw, width=1920, height=1080, framerate=60/1 ! videoconvert ! clappersink \
    cef.audio ! audioconvert ! audiomixer ! autoaudiosink
###

### Test 7 (playbin3)
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
gst-launch-1.0 playbin3 uri=web+https://www.soundcloud.com/platform/sama
###

### Test 8 (video playbin3 w/ gtk4paintablesink)
export GST_DEBUG=WARNING
export GST_DEBUG_DUMP_DOT_DIR=dotdir-08
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
mkdir $GST_DEBUG_DUMP_DOT_DIR
gst-launch-1.0 playbin3 uri=file://"$(pwd)"/resource/video.mp4 \
    video-sink=gtk4paintablesink
###

### Test 9 (playbin3 w/ gtk4paintablesink)
export GST_DEBUG=WARNING
export GST_DEBUG_DUMP_DOT_DIR=dotdir-09
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
mkdir $GST_DEBUG_DUMP_DOT_DIR
gst-launch-1.0 playbin3 uri=web+https://www.soundcloud.com/platform/sama \
    video-sink=gtk4paintablesink
###

### Test 10 (video playbin3 w/ clappersink)
export GST_DEBUG=WARNING
export GST_DEBUG_DUMP_DOT_DIR=dotdir-10
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
mkdir $GST_DEBUG_DUMP_DOT_DIR
gst-launch-1.0 playbin3 uri=file://"$(pwd)"/resource/video.mp4 \
    video-sink=clappersink
###

### Test 11 (playbin3 w/ clappersink)
export GST_DEBUG=WARNING
export GST_DEBUG_DUMP_DOT_DIR=dotdir-11
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
mkdir $GST_DEBUG_DUMP_DOT_DIR
gst-launch-1.0 playbin3 uri=web+https://www.soundcloud.com/platform/sama \
    video-sink=clappersink
###

### Test 12 (video gjs w/ gtk4paintablesink)
export GST_DEBUG=WARNING
export GST_DEBUG_DUMP_DOT_DIR=dotdir-12
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
mkdir $GST_DEBUG_DUMP_DOT_DIR
gjs player.js gtk4paintablesink file://"$(pwd)"/resource/video.mp4
###

### Test 13 (gjs w/ gtk4paintablesink)
export GST_DEBUG=WARNING
export GST_DEBUG_DUMP_DOT_DIR=dotdir-13
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
mkdir $GST_DEBUG_DUMP_DOT_DIR
gjs player.js gtk4paintablesink web+https://www.soundcloud.com/platform/sama
###

### Test 14 (video gjs w/ clappersink)
export GST_DEBUG=WARNING
export GST_DEBUG_DUMP_DOT_DIR=dotdir-14
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
mkdir $GST_DEBUG_DUMP_DOT_DIR
gjs player.js clappersink file://"$(pwd)"/resource/video.mp4
###

### Test 15 (gjs w/ clappersink)
export GST_DEBUG=WARNING
export GST_DEBUG_DUMP_DOT_DIR=dotdir-15
export GST_PLUGIN_PATH=build/lib/gstreamer-1.0:"$GST_PLUGIN_PATH"
mkdir $GST_DEBUG_DUMP_DOT_DIR
gjs player.js clappersink web+https://www.soundcloud.com/platform/sama
###