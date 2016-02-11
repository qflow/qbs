import qbs 1.0
import qbs.Probes as Probes
import qbs.ModUtils

//http://sourceforge.net/projects/opencvprebuilt/

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: libProbe
        names: [libraryName + ".lib", "lib" + libraryName + cpp.dynamicLibrarySuffix]
        platformPaths:
        {
            var res = [];
            if(qbs.architecture == "x86") res.push("D:/opencv_build/install/x86/vc11/lib");
            if(qbs.architecture == "x86_64") res.push("D:/opencv_build/install/x64/vc12/lib", "D:/opencv/x64/vc12/lib");
            res.push(qbs.getEnv("OPENCV_DIR") + "/lib", "/usr/lib", "/usr/local/lib");
            return res;
        }
    }
    Probes.PathProbe
    {
        id: includeProbe
        names: ["opencv2/opencv.hpp"]
        platformPaths: [qbs.getEnv("OPENCV_DIR") + "/../../include", "D:/opencv_build/install/include", "D:/opencv/include", "/usr/include", "/usr/local/include"]
    }
    property string libraryPath:
    {
        if(!libProbe.found) print("OpenCV library " + libraryName + " could not be found");
        else print("OpenCV library " + libraryName  + " found in " + libProbe.path);
        return libProbe.path
    }

    property string includePath: includeProbe.path
    property string binPath: libProbe.path
    Properties {
        condition: qbs.targetOS == "windows"
        binPath: libProbe.path + "/../bin"
    }
	
    cpp.includePaths: [includePath]
    cpp.libraryPaths:
    {
        var result = [libraryPath];
        if(qbs.targetOS == "windows")
            result.push(binPath);
        return result;
    }

    property string libraryPrefix: "opencv_"
    property string librarySuffix:
    {
        if(qbs.targetOS == "windows") return "300";
        return "";
    }
    property string moduleName
    property string libraryName: libraryPrefix + moduleName + librarySuffix
    property string dynamicLibraryFilePath: binPath + "/" + cpp.dynamicLibraryPrefix + libraryName + cpp.dynamicLibrarySuffix

    cpp.dynamicLibraries: {
        if(moduleName) return [libraryName];
        return [];
    }

    property bool found: libProbe.found && includeProbe.found
    cpp.defines:
    {
        if(libProbe.found) return ["USE_OPENCV"];
    }
}
