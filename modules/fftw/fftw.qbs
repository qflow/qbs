import qbs 1.0
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: includeProbe
        names: ["fftw3.h"]
        platformPaths: ["c:/fftw", "d:/fftw", "/usr/include", "/usr/local/include",
            qbs.getEnv("FFTW3_DIR"), qbs.getEnv("FFTW3_DIR") + "/include",
            qbs.getEnv("FFTW3_HOME"), qbs.getEnv("FFTW3_HOME") + "/include"]
        Properties {
            condition: qbs.targetOS.contains("windows") && qbs.architecture == "x86"
            platformPaths: ["c:/fftw-3.3.4-dll32"]
        }
        Properties {
            condition: qbs.targetOS.contains("windows") && qbs.architecture == "x86_64"
            platformPaths: ["c:/fftw-3.3.4-dll64"]
        }
    }
    Probes.PathProbe
    {
        id: libProbe
        names: ["libfftw3-3.lib", "libfftw3-3.so"]
        platformPaths: ["c:/fftw", "d:/fftw", "/usr/lib", "/usr/local/lib",
            qbs.getEnv("FFTW3_DIR"), qbs.getEnv("FFTW3_DIR") + "/lib",
            qbs.getEnv("FFTW3_HOME"), qbs.getEnv("FFTW3_HOME") + "/lib"]
        Properties {
            condition: qbs.targetOS.contains("windows") && qbs.architecture == "x86"
            platformPaths: ["c:/fftw-3.3.4-dll32"]
        }
        Properties {
            condition: qbs.targetOS.contains("windows") && qbs.architecture == "x86_64"
            platformPaths: ["c:/fftw-3.3.4-dll64"]
        }
    }
    files:[
        "FourierPluginResources.qrc"
    ]
    cpp.includePaths: [includeProbe.path]
    cpp.libraryPaths: [libProbe.path]
    cpp.dynamicLibraries:
    {
        if(libProbe.found)
            return ["libfftw3-3", "libfftw3f-3"];
    }
    property stringList filesToInstall:
    {
        var files = [];
        if(libProbe.found)
            files = [
                        libProbe.path + "/libfftw3-3" + cpp.dynamicLibrarySuffix,
                        libProbe.path + "/libfftw3f-3" + cpp.dynamicLibrarySuffix
                    ];
        return files;
    }

    property bool found: libProbe.found
}
