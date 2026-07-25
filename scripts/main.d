import std.stdio;
import std.file;
import std.path;
import std.process;

void main() {
    string targetDir = expandTilde("~/.local/bin");

    if (!exists(targetDir)) {
        mkdirRecurse(targetDir);
        writefln("Created directory: %s", targetDir);
    }

    int successCount = 0;
    int failCount = 0;

    foreach (DirEntry entry; dirEntries(".", SpanMode.depth)) {

        if (entry.isFile && entry.name.extension == ".d") {
            string sourceFile = entry.name;

            if (sourceFile.dirName == ".") {
                continue;
            }

            string binName = sourceFile.baseName.stripExtension;
            string targetPath = buildPath(targetDir, binName);

            writefln("Compiling: %s", sourceFile);

            auto result = execute(["dmd", sourceFile, "-of=" ~ targetPath]);

            if (result.status == 0) {
                writefln("  -> Saved to %s", targetPath);
                successCount++;

                string objFile = targetPath ~ ".o";
                if (exists(objFile)) {
                    remove(objFile);
                }
            }
            else {
                writefln("  -> FAILED:\n%s", result.output);
                failCount++;
            }
        }
    }

    writefln("\nDone! Successfully compiled: %d | Failed: %d", successCount, failCount);
}
