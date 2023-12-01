#!/usr/bin/env gjs

imports.gi.versions.Gtk = "4.0";
imports.gi.versions.GdkX11 = "4.0";
const { GObject, Gtk, Gio, GLib, Gdk, GdkX11, Gst } = imports.gi;

// Note: GstPlay is available from GStreamer 1.20+
GstPlay = imports.gi.GstPlay;

const VideoPlayer = GObject.registerClass(
    {
        GTypeName: "VideoPlayer",
    },
    class VideoPlayer extends Gtk.Application {
        constructor() {
            super({
                application_id: "org.example.video_player",
                flags: Gio.ApplicationFlags.HANDLES_COMMAND_LINE,
            });

            this.connect("activate", () => this._buildUI());

            this.connect("command-line", (_, commandLine) => {
                let argv = commandLine.get_arguments();
                if (argv.length === 2) {
                    this.video_sink = argv[0];
                    this.uri = argv[1];
                    this.activate();
                    commandLine.set_exit_status(0);
                } else {
                    console.error("params: [video_sink] [uri]");
                    commandLine.set_exit_status(1);
                }
            });
        }

        _buildUI() {
            let sink = Gst.ElementFactory.make(
                this.video_sink,
                this.video_sink
            );

            let widget = null;
            if (this.video_sink === "gtk4paintablesink") {
                widget = new Gtk.Picture({
                    paintable: sink.paintable,
                });
            } else if (this.video_sink === "clappersink") {
                widget = sink.widget;
            } else {
                console.error("invalid video_sink");
            }

            console.log(`Using ${sink.name}`)

            this._play = GstPlay.Play.new(
                GstPlay.PlayVideoOverlayVideoRenderer.new_with_sink(null, sink)
            );
            this._play.set_uri(this.uri);
            this._play.play();

            this.window = new Gtk.ApplicationWindow({
                application: this,
                title: "Video Player",
                default_width: 1280,
                default_height: 720,
            });
            this.window.set_child(widget);
            this.window.present();
        }
    }
);

Gst.init(null);

const app = new VideoPlayer();
app.run(ARGV);
