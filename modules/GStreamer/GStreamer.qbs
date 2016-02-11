import qbs
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Probes.PkgConfigProbe
    {
        id: gstreamerProbe
        name: "gstreamer-1.0"
    }
    Probes.PathProbe
    {
        id: includeProbe
        names: ["gst/gst.h"]
        platformPaths: ["/usr/include/gstreamer-1.0", "D:/gstreamer/1.0/x86_64/include/gstreamer-1.0"]
    }
    Probes.PathProbe
    {
        id: glibIncludeProbe
        names: ["glib.h"]
        platformPaths: ["/usr/include/glib-2.0", "D:/gstreamer/1.0/x86_64/include/glib-2.0"]
    }
    Probes.PathProbe
    {
        id: libProbe
        names: ["gstreamer-1.0.lib"]
        platformPaths: ["D:/gstreamer/1.0/x86_64/lib"]
    }
    Probes.PathProbe
    {
        id: binProbe
        names: ["libgstreamer-1.0-0.dll"]
        platformPaths: ["D:/gstreamer/1.0/x86_64/bin"]
    }

    cpp.cxxFlags: gstreamerProbe.cflags;
    cpp.linkerFlags: gstreamerProbe.libs
    cpp.includePaths:
    {
        var paths = [includeProbe.path, glibIncludeProbe.path];
        if(qbs.targetOS.contains("windows")) paths.push(libProbe.path + "/glib-2.0/include", libProbe.path + "/gstreamer-1.0/include");
        return paths;
    }
    cpp.dynamicLibraries: ["gstreamer-1.0", "gobject-2.0", "glib-2.0", "gstapp-1.0"]
    cpp.libraryPaths:
    {
        return libProbe.path;
    }

    property bool found:
    {
        if(qbs.targetOS.contains("linux"))
        {
            return gstreamerProbe.found && includeProbe.found;
        }

        if(qbs.targetOS.contains("windows"))
        {
            return includeProbe.found && libProbe.found;
        }
        return false;
    }
    property string binPath: binProbe.path
    property string libraryPrefix: "lib"
    property stringList filesToInstall:
    {
        var files = [];
        if(libProbe.found)
            files = [
                        binPath + "/" + libraryPrefix + "gstreamer*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + libraryPrefix + "glib*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + libraryPrefix + "gobject*" + cpp.dynamicLibrarySuffix + "*",
                        binPath + "/" + libraryPrefix + "gstapp*" + cpp.dynamicLibrarySuffix + "*"
                    ];
        return files;
    }
}
