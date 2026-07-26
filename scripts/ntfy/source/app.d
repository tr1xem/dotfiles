import std.stdio;
import std.string;
import std.net.curl;
import std.process;
import std.json;
import std.getopt;
import std.datetime;
import core.thread;
import std.concurrency;

bool DEBUG = false;
enum string APP_IMAGE = "~/.local/share/icons/ntfy.png";

/*
 * Names of Clients to subscribe
 */
string[] clients = [
    "trix",
    "tr1x_em-website-baby"
];

//NOTE: Send notification using system find notify-send
void sendNotification(string topic, string message) {
    if (DEBUG)
        writef("Received Message: %s from %s\n", message, topic);
    // Show a notification with an app's icon and name:
    // notify-send "Test" [-i|--icon] google-chrome [-a|--app-name] "Google Chrome"
    auto rCMD = format("notify-send -a ntfy.sh -i %s '%s' '%s'", APP_IMAGE, topic, message);
    auto cmd = executeShell(rCMD);
    if (cmd.status != 0) {
        writef("Failed to spawn notify-send  with error: %s", cmd.output);
    }
}

void setupClient(JSONValue data) {
    if (data.object["event"].str == "open") {
        if (DEBUG)
            writef("Connected Succesfully to %s\n", data.object["topic"]);
    }
    if (data.object["event"].str == "message") {
        sendNotification(data.object["topic"].str, data.object["message"].str);
    }
}

//NOTE: We would use the json interface provided by ntfy.sh
// https://docs.ntfy.sh/subscribe/api/#subscribe-as-json-stream
void subscribe(string client) {
    client = "https://ntfy.sh/" ~ client ~ "/json";

    writeln("Subscribing to " ~ client);
    if (DEBUG)
        writeln("Subscribing to " ~ client);

    while (true) {
        try {
            auto http = HTTP();
            http.method = HTTP.Method.get;
            http.url = client;

            http.onReceive = (ubyte[] data) {
                setupClient(cast(JSONValue) parseJSON(cast(string)(data)));
                return data.length;
            };

            http.perform();
            break;
        }
        catch (CurlException e) {
            if (DEBUG)
                writeln("Network error: ", e.msg, ". Retrying in 5 seconds...");
            Thread.sleep(dur!("seconds")(5));
        }
        catch (Exception e) {
            if (DEBUG)
                writeln("An error occurred: ", e.msg);
            break;
        }
    }
}

int main(string[] args) {

    auto help = getopt(
        args,
        "verbose|v", &DEBUG,
    );

    if (help.helpWanted) {
        defaultGetoptPrinter("Usage: app [options] file", help.options);
        return 0;
    }

    thread_joinAll();
    foreach (client; clients) {
        Tid tid = spawn(&subscribe, client);
    }
    thread_joinAll();
    return 0;
}
