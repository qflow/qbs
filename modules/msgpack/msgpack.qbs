import qbs 1.0
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: includeProbe
        names: ["msgpack.hpp"]
        platformPaths:
        {
            var res = ["C:/msgpack-c/include", qbs.getEnv("HOME") + "/msgpack-c/include", "/usr/include"];
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
        if(includeProbe.found) return ["MSGPACK_FOUND"];
    }
}
