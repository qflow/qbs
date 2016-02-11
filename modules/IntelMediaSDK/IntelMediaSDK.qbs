import qbs 1.0
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: includeProbe
        names: ["mfxvideo.h"]
        platformPaths: [qbs.getEnv("INTELMEDIASDKROOT") + "/include", "/opt/intel/mediasdk/include", qbs.getEnv("HOME") + "/mediasdk/include"]

    }
    Probes.PathProbe
    {
        id: libProbe
        names: ["libmfx.lib", "libmfx.a"]
        Properties {
            condition: qbs.targetOS.contains("windows") && qbs.architecture == "x86"
            platformPaths: [qbs.getEnv("INTELMEDIASDKROOT") + "/lib/win32"]
        }
        Properties {
            condition: qbs.targetOS.contains("windows") && qbs.architecture == "x86_64"
            platformPaths: [qbs.getEnv("INTELMEDIASDKROOT") + "/lib/x64"]
        }
        Properties {
            condition: qbs.targetOS.contains("linux") && qbs.architecture == "x86_64"
            platformPaths: ["/opt/intel/mediasdk/lib/lin_x64"]
        }
    }

    property string includePath: includeProbe.path

    property string libraryPath: libProbe.path

    property string binPath: libraryPath
    property bool found: libProbe.found
    cpp.defines:
    {
        if(libProbe.found) return ["USE_INTELMEDIASDK"];
    }
    Properties {
        condition: qbs.targetOS == "windows" && qbs.architecture == "x86"
        binPath: libProbe.path + "/../../bin/win32"
    }
    Properties {
        condition: qbs.targetOS == "windows" && qbs.architecture == "x86_64"
        binPath: libProbe.path + "/../../bin/x64"
    }
    cpp.dynamicLibraries: {
        var libs = [];
        if(qbs.targetOS.contains("linux"))
        {
            libs = ["mfx", "dl", "va", "va-drm"];
        }

        if(qbs.targetOS.contains("windows"))
        {
            libs = ["libmfx"];
            libs.push("advapi32");
        }
        return libs;
    }
    cpp.linkerFlags: {
        var flags = [];
        if(qbs.targetOS.contains("windows"))
        {
            flags.push("/NODEFAULTLIB:LIBCMT");
            flags.push("/NODEFAULTLIB:LIBCPMT");
        }
        return flags;
    }
	
    cpp.includePaths: [includePath]
    cpp.libraryPaths:
    {
        var result = [libraryPath];
        if(qbs.targetOS.contains("windows"))
            result.push(binPath);
        return result;
    }

    validate: {
    }
}
