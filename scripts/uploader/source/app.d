import std.stdio;
import std.process;
import std.getopt;
import std.format;

bool DEBUG = false;
enum string VERSION = "0.1.0";
// string EZAUTH = environment.get("EZAUTH");
// string MOANARCHAUTH = environment.get("MONARCHKEY");

enum string EZURLT = "https://api.e-z.host/paste/file";
enum string EZURLF = "https://api.e-z.host/files";
enum string MONARCHURL = "https://api.monarchupload.cc/v3/upload";

enum UPLOADER {
    MONARCH,
    EZ
}

enum FILETYPE {
    TEXT,
    OTHER
}

int main(string[] args) {

    auto help = getopt(args,
        "v|verbose", "Verbose mode", &DEBUG,
    );
    if (help.helpWanted) {
        defaultGetoptPrinter(format(
                "Uploader v%s
Copyright (c) 2026 tr1x_em. All Rights Reserved.
Usage: %s [options]", VERSION, args[0]),
            help.options);

    }

    return 0;
}
