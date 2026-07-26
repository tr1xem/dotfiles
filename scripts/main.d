import std.stdio;
import std.file;
import std.path;
import std.process;
import std.datetime;
import std.conv : octal;

void main() {
    string targetDir = expandTilde("~/.local/bin");

    if (!exists(targetDir)) {
        mkdirRecurse(targetDir);
        writefln("Created directory: %s", targetDir);
    }

    int successCount = 0;
    int failCount = 0;
    int skippedCount = 0;

    // Use SpanMode.shallow to avoid scanning inside project source trees individually
    foreach (DirEntry entry; dirEntries(".", SpanMode.shallow)) {
        string path = entry.name;

        bool isSingleD = (entry.isFile && path.extension == ".d" && path.dirName != ".");
        bool isDubProject = (entry.isDir && (exists(buildPath(path, "dub.json")) || exists(buildPath(path, "dub.sdl"))));

        if (isSingleD || isDubProject) {
            string projectName;
            SysTime latestSourceTime = SysTime.min;

            if (isSingleD) {
                projectName = path.baseName.stripExtension;
                try {
                    latestSourceTime = path.timeLastModified;
                }
                catch (Exception e) {
                }
            }
            else {
                projectName = path.baseName;
                try {
                    foreach (DirEntry sub; dirEntries(path, SpanMode.depth)) {
                        if (sub.isFile) {
                            auto t = sub.timeLastModified;
                            if (t > latestSourceTime)
                                latestSourceTime = t;
                        }
                    }
                }
                catch (Exception e) {
                }
            }

            string targetPath = buildPath(targetDir, projectName);

            bool needsBuild = true;
            if (exists(targetPath)) {
                try {
                    SysTime binTime = targetPath.timeLastModified;
                    if (binTime >= latestSourceTime) {
                        needsBuild = false;
                    }
                }
                catch (Exception e) {
                }
            }

            if (!needsBuild) {
                writefln("Skipping (up-to-date): %s", projectName);
                skippedCount++;
                continue;
            }

            writefln("Building: %s", projectName);

            int status;
            string output;

            if (isSingleD) {
                auto res = execute(["dmd", path, "-of=" ~ targetPath]);
                status = res.status;
                output = res.output;
            }
            else {
                auto res = execute([
                    "dub", "build", "--root=" ~ path, "--build=release", "--force"
                ]);
                status = res.status;
                output = res.output;

                if (status == 0) {
                    string foundBin = "";
                    try {
                        foreach (DirEntry sub; dirEntries(path, SpanMode.shallow)) {
                            if (sub.isFile && sub.name.baseName == projectName) {
                                foundBin = sub.name;
                                break;
                            }
                        }
                        if (foundBin == "") {
                            string binSubDir = buildPath(path, "bin");
                            if (exists(binSubDir)) {
                                foreach (DirEntry sub; dirEntries(binSubDir, SpanMode.shallow)) {
                                    if (sub.isFile) {
                                        foundBin = sub.name;
                                        break;
                                    }
                                }
                            }
                        }

                        if (foundBin != "") {
                            std.file.copy(foundBin, targetPath);
                            setAttributes(targetPath, octal!"755");
                            std.file.remove(foundBin);
                        }
                        else {
                            status = 1;
                            output = "Could not locate compiled binary in dub project folder.";
                        }
                    }
                    catch (Exception e) {
                        status = 1;
                        output = e.msg;
                    }
                }
            }

            if (status == 0) {
                writefln("  -> Saved to %s", targetPath);
                successCount++;

                string objFile = targetPath ~ ".o";
                if (exists(objFile)) {
                    remove(objFile);
                }
            }
            else {
                writefln("  -> FAILED:\n%s", output);
                failCount++;
            }
        }
    }

    writefln("\nDone! Compiled: %d | Skipped: %d | Failed: %d", successCount, skippedCount, failCount);
}
