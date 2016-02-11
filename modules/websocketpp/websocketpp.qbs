import qbs 1.0
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: includeProbe
        names: ["websocketpp/server.hpp"]
        platformPaths:
        {
            var res = ["C:/websocketpp", qbs.getEnv("HOME") + "/websocketpp", "/usr/include"];
            return res;
        }
    }

    property string includePath: includeProbe.path

    property bool found: includeProbe.found
	
    cpp.includePaths:
    {
        var result = [includePath];
        return result;
    }
    cpp.defines:
    {
        if(includeProbe.found) return ["_SCL_SECURE_NO_WARNINGS", "_WEBSOCKETPP_CPP11_STL_", "WEBSOCKETPP_FOUND"];
    }
    cpp.dynamicLibraries:
    {
        var libs = [];
        if(qbs.targetOS == "windows") libs = ["ws2_32"];
        return libs;
    }
}
