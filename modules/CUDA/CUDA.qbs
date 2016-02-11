import qbs 1.0
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: includeProbe
        names: ["cuda.h"]
        platformPaths: ["/usr/include", "/usr/local/include", "usr/local/cuda/include", "/usr/local/cuda-7.5/include", "/usr/local/cuda-7.5/targets/x86_64-linux/include",
            qbs.getEnv("CUDA_PATH") + "/include"]

    }
    Probes.PathProbe
    {
        id: libProbe
        names: [moduleName + ".lib", "lib" + moduleName + cpp.dynamicLibrarySuffix]
        platformPaths:
        {
            var res = ["/usr/lib", "/usr/local/lib", "/usr/local/cuda/lib", "/usr/local/cuda-7.5/lib", "/usr/lib/nvidia-352"]
            if(qbs.architecture == "x86") res.push(qbs.getEnv("CUDA_PATH") + "/lib/Win32");
            if(qbs.architecture == "x86_64") res.push(qbs.getEnv("CUDA_PATH") + "/lib/x64", "/usr/local/cuda/lib64", "/usr/local/cuda-7.5/lib64");
            return res;
        }
    }
    Probes.PathProbe
    {
        id: binProbe
        platformPaths: [qbs.getEnv("CUDA_PATH") + "/bin"]
        Properties
        {
            condition: qbs.architecture == "x86"
            names: [moduleName + "32_65" + cpp.dynamicLibrarySuffix]
        }
        Properties
        {
            condition: qbs.architecture == "x86_64"
            names: [moduleName + "64_65" + cpp.dynamicLibrarySuffix]
        }
    }
    property string binPath:
    {
        if(binProbe.found)
            return binProbe.path;
    }


    property bool found: libProbe.found
    cpp.defines:
    {
        if(libProbe.found) return ["USE_CUDA"];
    }
    property string includePath: includeProbe.path
    property string dynamicLibraryFilePath:
    {
        if(qbs.targetOS.contains("linux")) return libProbe.filePath;
        if(binProbe.found)
            return binProbe.filePath;
        return "undefined";
    }
    property string libraryPath: libProbe.path
    cpp.includePaths:
    {
        if(includeProbe.found) return [includePath];
    }
    cpp.libraryPaths:
    {
        var result = [libraryPath];
        if(qbs.targetOS == "windows" && binPath)
            result.push(binPath);
        return result;
    }

    property string moduleName: "undefined"
    cpp.dynamicLibraries:
    {
        if(libProbe.found) return [moduleName];
        return [];
    }

    FileTagger {
        patterns: ["*.cu"]
        fileTags: ["cuda"]
    }
}
