import qbs
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: glibIncludeProbe
        names: ["glib.h"]
        platformPaths: ["/usr/include/glib-2.0", "D:/gstreamer/1.0/x86_64/include/glib-2.0"]
    }
    Probes.PkgConfigProbe {
        id: pkgConfig
        name: "glib-2.0"
    }
    cpp.cxxFlags: pkgConfig.cflags
    cpp.linkerFlags: pkgConfig.libs

    cpp.includePaths:
    {
        var paths = [glibIncludeProbe.path];
        return paths;
    }
    cpp.dynamicLibraries: ["glib-2.0"]

}
