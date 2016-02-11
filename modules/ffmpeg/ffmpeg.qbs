import qbs 1.0
import qbs.Probes as Probes


/*./configure --prefix="$HOME/ffmpeg_build" --enable-libx264 --enable-libvpx --enable-shared --enable-gpl --enable-pic --disable-libxcb --disable-libxcb-shm --disable-sdl*/

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: includeProbe
        names: ["libavformat/avformat.h"]
        platformPaths:
        {
            var res = [qbs.getEnv("HOME") + "/ffmpeg_build/include", "/usr/include", "/usr/local/include",
            "c:/ffmpeg/include", "c:/ffmpeg_build/include", "c:/libav/include",
            "d:/ffmpeg/include", "d:/ffmpeg_build/include",
            qbs.getEnv("FFMPEG_DIR") + "/include", qbs.getEnv("FFMPEG_HOME") + "/include", qbs.getEnv("FFMPEG_ROOT") + "/include"];

            if(qbs.architecture == "x86") res.push("c:/ffmpeg32/include");

            if(qbs.architecture == "x86_64") res.push("c:/ffmpeg64/include", "/usr/include/x86_64-linux-gnu");

            return res;
        }
    }
    property stringList libSearchPaths:
    {
        var res = [qbs.getEnv("HOME") + "/ffmpeg_build/lib", "/usr/lib", "/usr/local/lib",
        "c:/ffmpeg/lib", "c:/ffmpeg_build/lib", "c:/libav/bin",
        "d:/ffmpeg/lib", "d:/ffmpeg_build/lib",
        qbs.getEnv("FFMPEG_DIR") + "/lib", qbs.getEnv("FFMPEG_HOME") + "/lib", qbs.getEnv("FFMPEG_ROOT") + "/lib"];

        if(qbs.architecture == "x86_64") res.push("c:/ffmpeg64/lib", "/usr/lib/x86_64-linux-gnu");

        if(qbs.architecture == "x86") res.push("c:/ffmpeg32/lib");

        return res;
    }

    Probes.PathProbe
    {
        id: libProbe
        names: ["avformat.lib", "libavformat.so", "libavformat.a"]
        platformPaths: libSearchPaths
    }
    Probes.PathProbe
    {
        id: x264Probe
        names: ["libx264.so"]
        platformPaths: libSearchPaths
    }
    Probes.PathProbe
    {
        id: vpxProbe
        names: ["libvpx.so"]
        platformPaths: libSearchPaths
    }
    Probes.PathProbe
    {
        id: asoundProbe
        names: ["libasound.so"]
        platformPaths: libSearchPaths
    }

    property string includePath: includeProbe.path

    property bool found: libProbe.found
    property string libraryPath: libProbe.path

    property string binPath:
    {
        if(qbs.targetOS == "windows")
            return libraryPath + "/../bin";
        return libraryPath;
    }
	
    cpp.includePaths:
    {
        var result = [includePath];
        return result;
    }
    cpp.libraryPaths:
    {
        var result = [libraryPath];
        if(qbs.targetOS == "windows")
            result.push(binPath);
        return result;
    }

    cpp.dynamicLibraries: ["swscale", "avcodec", "avdevice", "avformat", "avutil"]

    function getModulePath(name)
    {
        return dynamicLibraryPath + "/" + cpp.dynamicLibraryPrefix + name + "*" + cpp.dynamicLibrarySuffix;
    }
    property stringList filesToInstall:
    {
        var files = [];
        if(libProbe.found)
            files = [
                        binPath + "/" + cpp.dynamicLibraryPrefix + "avdevice*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + cpp.dynamicLibraryPrefix + "avformat*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + cpp.dynamicLibraryPrefix + "avcodec*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + cpp.dynamicLibraryPrefix + "avutil*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + cpp.dynamicLibraryPrefix + "swscale*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + cpp.dynamicLibraryPrefix + "avfilter*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + cpp.dynamicLibraryPrefix + "postproc*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + cpp.dynamicLibraryPrefix + "swresample*" + cpp.dynamicLibrarySuffix + "*",
                        x264Probe.path + "/" + cpp.dynamicLibraryPrefix + "x264*" + cpp.dynamicLibrarySuffix + "*",
                        vpxProbe.path + "/" + cpp.dynamicLibraryPrefix + "vpx*" + cpp.dynamicLibrarySuffix + "*",
                        asoundProbe.path + "/" + cpp.dynamicLibraryPrefix + "asound*" + cpp.dynamicLibrarySuffix + "*"
                    ];
        return files;
    }
}
