import std.stdio;
import std.getopt;
import std.format;
import std.process;
import std.datetime;
import std.random;
import std.uuid;
import std.file;
import std.path;
import core.stdc.stdlib : exit;
import std.conv;
import core.thread.osthread;
import std.json;
import std.string;

bool DEBUG = false;

enum string VERSION = "0.1.2";
enum string APP_IMAGE = "~/.local/share/icons/xrec.svg";
enum string PIDFILE = "/tmp/record.pid";
enum string SAVE_DIR = "~/Videos/Recordings";
//enum string  MIC_NAME="alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source";
enum string MIC_NAME = "@DEFAULT_SOURCE@";
enum string VIDEO_CODEC = "hevc_nvenc";
enum string VIDEO_PRESET = "p5";
enum string VIDEO_CQ = "28";
string COLOR = "FF0000";

// NOTE: using strings as cmd already needs them as string so to avoid  a cast
struct ScreenDimensions {
    string width;
    string height;
    string x;
    string y;

}

struct PIDFileStucture {
    string pid = null;
    string fileName;
    string startTime;
}

PIDFileStucture getRecordingStatus() {
    auto recording = PIDFileStucture();
    if (!exists(PIDFILE)) {
        if (DEBUG)
            writeln("PIDFILE does not exist");
        return recording;
    }
    auto data = cast(string) read(PIDFILE);
    formattedRead(data, "PID=%s\nSTARTTIME=%s\nFILENAME=%s", recording.pid,
        recording.startTime,
        recording.fileName);
    return recording;

}
// NOTE: Uses Slop to get screen dimensions
ScreenDimensions getScreenDimensions() {
    ScreenDimensions screenDim;
    auto cmd = execute(["slop", "-f", "%x %y %w %h"]);
    if (cmd.status != 0) {
        if (cmd.output == "Selection was cancelled by keystroke or right-click.") {
            exit(0);
        }
        writefln("Failed to run slop :%s", cmd.output);
        exit(1);
    }
    formattedRead(cmd.output, "%s %s %s %s", &screenDim.x, &screenDim.y, &screenDim.width, &screenDim
            .height);
    if (DEBUG)
        writefln("Got Screen Dimensions: %s", screenDim);
    return screenDim;

}

void sendNotification(string message) {
    auto rCMD = format("notify-send -a Xrec -i %s 'Screen Recording' '%s'", APP_IMAGE, message);
    auto cmd = executeShell(rCMD);
    if (cmd.status != 0) {
        writefln("Failed to spawn notify-send with error: %s", cmd.output);
    }
}

void startRecording(string fileName = "", string dir = SAVE_DIR) {
    if (fileName == "" || fileName == null) {
        //TODO: Also get the focused window name
        fileName = randomUUID().toString()[0 .. 13] ~ ".mp4";
    }
    else {
        fileName ~= ".mp4";
    }

    if (dir == "" || dir == null) {
        dir = SAVE_DIR;
    }

    dir = expandTilde(dir);
    if (!isDir(dir)) {
        if (DEBUG)
            writeln("Creating directory: " ~ dir);
        mkdir(dir);
    }
    if (exists(dir ~ "/" ~ fileName)) {
        writefln("%s already exists", fileName);
        exit(1);
    }

    ScreenDimensions screenDim = getScreenDimensions();
    string outputFile = dir ~ "/" ~ fileName;

    File stdin;
    File stdout;
    File stderr;
    if (DEBUG) {
        writefln("Starting recording to file: %s", outputFile);
        stdin = std.stdio.stdin;
        stdout = std.stdio.stdout;
        stderr = std.stdio.stderr;
    }
    else {
        stdout = File("/dev/null", "w");
        stdin = File("/dev/null", "r");
        stderr = File("/dev/null", "w");
    }

    auto p = spawnProcess([
        "ffmpeg",
        "-f", "x11grab",
        "-framerate", "30",
        "-video_size", screenDim.width ~ "x" ~ screenDim.height,
        "-i", ":0.0+" ~ screenDim.x ~ "," ~ screenDim.y,
        "-f", "pulse", "-i", "@DEFAULT_MONITOR@",
        "-f", "pulse", "-i", MIC_NAME,
        "-filter_complex", "[1:a][2:a]amix=inputs=2[a]",
        "-map", "0:v",
        "-map", "[a]",
        "-c:v", VIDEO_CODEC,
        "-preset", VIDEO_PRESET,
        "-rc", "vbr",
        "-cq", VIDEO_CQ,
        "-b:v", "0",
        "-profile:v", "main",
        "-pix_fmt", "yuv420p",
        "-tag:v", "hvc1",
        "-c:a", "aac",
        "-b:a", "128k",
        "-movflags", "+faststart",
        outputFile,
    ],
    stdin,
    stdout,
    stderr
    );

    // Check if the recording failed
    // NOTE: Sleeping for 1000 ms as ffmpeg could take some time in failing
    Thread.sleep(dur!"msecs"(1000));
    auto res = tryWait(p);
    if (res.status != 0) {
        sendNotification("Recording failed with exit code: " ~ to!string(res.status));
        writeln("Recording failed with exit code: ", res.status);
        exit(res.status);

    }
    if (DEBUG)
        writefln("Recording started with output file: %s and pid: %s", outputFile, p.processID);

    PIDFileStucture pidFile;
    pidFile.pid = to!string(p.processID);
    pidFile.fileName = outputFile;
    pidFile.startTime = to!string(Clock.currTime.toUnixTime);

    std.file.write(PIDFILE,
        "PID=" ~ pidFile.pid ~ "\n"
            ~ "STARTTIME=" ~ pidFile.startTime ~ "\n"
            ~ "FILENAME=" ~ pidFile.fileName ~ "\n"
    );

}

bool uploadRecording(string fileName) {
    string apikey = environment.get("MONARCHKEY");
    string apiURL = "https://api.monarchupload.cc/v3/upload";

    if (DEBUG)
        writefln("Uploading recording to monarch: %s", strip(fileName));

    auto result = execute([
        "curl", "-Ss",
        "-F", "secret=" ~ apikey,
        "-F", "file=@" ~ strip(fileName),
        apiURL
    ]);

    if (result.status != 0) {
        writefln("Failed to upload recording to monarch with error: %s", result.output);
        return false;
    }
    /* OUTPUT :
    {
      "data": {
        "url": "https://you-are-a.skidding.dev/XtaEiCKezwgB/aa..txt"
      },
      "message": "Uploaded file successfully",
      "status": "success"
    }
    */
    if (DEBUG)
        writeln(result.output);
    JSONValue j = parseJSON(result.output);
    if (j["status"].str != "success") {
        writeln("Failed to upload recording to monarch");
        return false;
    }
    // Copy the url to clipboard
    auto p = executeShell(
        format("echo -n %s | xclip -selection clipboard", j["data"]["url"]));
    if (p.status != 0) {
        writefln("Failed to copy url to clipboard with error: %s", p.output);
        return false;
    }
    return true;
}

void stopRecording() {
    PIDFileStucture pidfile = getRecordingStatus();
    if (pidfile.pid == null) {
        writeln("No recording in progress");
        exit(1);
    }

    auto cmd = execute(["kill", "-0", pidfile.pid]);
    if (cmd.status != 0) {
        writefln("Process with pid: %s is not running", pidfile.pid);
        std.file.remove(PIDFILE);
        exit(1);
    }
    if (DEBUG)
        writefln("Stopping recording with PID: %s", pidfile.pid);
    cmd = execute(["kill", to!string(pidfile.pid)]);
    if (cmd.status != 0) {
        writefln("Failed to kill recording app pid: %s", pidfile.pid);
    }
    else {
        writefln("Stopped recording with PID: %s", pidfile.pid);

    }
    std.file.remove(PIDFILE);

    // Sleep for 1 sec to allow the recording to stop
    Thread.sleep(dur!"msecs"(1000));
    bool status = uploadRecording(pidfile.fileName);

    if (!status) {
        writeln("Failed to upload recording");
        sendNotification("Failed to upload recording");
        exit(1);
    }
    sendNotification("Uploaded Recording to Monarch");
    remove(pidfile.fileName.strip());
}

void toggleRecording() {
    PIDFileStucture pidfile = getRecordingStatus();
    if (pidfile.pid == null) {
        writefln("No recording in progress");
        startRecording();
        exit(0);
    }
    auto cmd = execute(["kill", "-0", pidfile.pid]);
    if (cmd.status != 0) {
        writefln("Process with pid: %s is not running", pidfile.pid);
        std.file.remove(PIDFILE);
        startRecording();
        exit(0);
    }
    else {
        stopRecording();
        exit(0);

    }
}

//NOTE: Special function for xmobar
void recordingStatus() {
    PIDFileStucture pidfile = getRecordingStatus();
    if (pidfile.pid == null) {
        return;
    }
    if (COLOR[0] != '#')
        COLOR = "#" ~ COLOR;
    string elapsedTime = to!string(Clock.currTime.toUnixTime - to!long(pidfile.startTime));
    writefln("<fc=%s><fn=1> </fn>REC %02d:%02d</fc>", COLOR, (to!int(elapsedTime) / 60), (
            to!int(
            elapsedTime) % 60));
    return;
}

int main(string[] args) {
    string fileName, dir;

    void handleStartRecording(string option) {
        startRecording(fileName, dir);
    }

    auto help = getopt(
        args,
        "v|verbose", "Verbose mode", &DEBUG,
        "dir|d", "Set recording directory", &dir,
        "color|c", "Set Colour of Xmobar Status output", &COLOR,
        "file|f", "Set recording file name", &fileName,
        "stop|sr", "Stop recording", &stopRecording,
        "toggle|t", "Toggle recording", &toggleRecording,
        "status|s", "Get recording status", &recordingStatus,
        "record|r", "Start recording", &handleStartRecording,
    );

    if (help.helpWanted) {
        defaultGetoptPrinter(format(
                "Xrec v%s
Copyright (c) 2026 tr1x_em. All Rights Reserved.
Usage: %s [options]", VERSION, args[0]),
            help.options);

    }

    return 0;
}
