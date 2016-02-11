import qbs 1.0
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Probes.PathProbe
    {
        id: includeProbe
        names: ["CL/opencl.h"]
        platformPaths: ["/usr/include", "/usr/local/include",
            qbs.getEnv("CUDA_PATH") + "/include", "usr/local/cuda/include", "/usr/local/cuda-6.5/include",
            qbs.getEnv("INTELOCLSDKROOT") + "/include", "/etc/alternatives/opencl-headers",
            qbs.getEnv("AMDAPPSDKROOT") + "/include", "/opt/AMDAPP/include"]

    }
    Probes.PathProbe
    {
        id: libProbe
        names: ["OpenCL.lib", "libOpenCL.so"]
        platformPaths:
        {
            var res = ["/usr/lib", "/usr/local/lib", "/usr/local/cuda/lib", "/usr/local/cuda-6.5/lib"];
            if(qbs.architecture == "x86") res.push(qbs.getEnv("CUDA_PATH") + "/lib/Win32",
                            qbs.getEnv("INTELOCLSDKROOT") + "/lib/Win32", "/etc/alternatives/opencl-intel-runtime/lib32",
                            qbs.getEnv("AMDAPPSDKROOT") + "/lib/x86", "/opt/AMDAPP/lib/x86");
            if(qbs.architecture == "x86_64") res.push(qbs.getEnv("CUDA_PATH") + "/lib/x64", "/usr/local/cuda/lib64",
                            qbs.getEnv("INTELOCLSDKROOT") + "/lib/x64", "/etc/alternatives/opencl-intel-runtime/lib64",
                            qbs.getEnv("AMDAPPSDKROOT") + "/lib/x86_64", "/opt/AMDAPP/lib/x86_64");
            return res;
        }
    }

    property string openclIncludePath: includeProbe.path

    property string openclLibraryPath:
    {
        return libProbe.path;
    }
    property bool found: libProbe.found && includeProbe.found
	
	cpp.includePaths: [openclIncludePath]
	cpp.libraryPaths: [openclLibraryPath]

    cpp.dynamicLibraries: ["OpenCL"]
    FileTagger {
        patterns: ["*.cl"]
        fileTags: ["opencl"]
    }
}
