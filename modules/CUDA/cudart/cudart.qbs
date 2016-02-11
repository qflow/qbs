import qbs 1.0
import qbs.Probes as Probes
import '../CUDA.qbs' as CUDAModule

CUDAModule
{
    moduleName: "cudart"
    cpp.dynamicLibraries:
    {
       var libs = [];
       if(found) libs.push("cuda", moduleName);
       //if(qbs.targetOS.contains("windows")) libs.push(["/NODEFAULTLIB:LIBCMT", "/NODEFAULTLIB:LIBCPMT"]);
       return libs;
    }
    Probes.PathProbe
    {
        id: nvccProbe
        names: ["nvcc", "nvcc.exe"]
        platformPaths: [qbs.getEnv("CUDA_PATH") + "/bin", "/usr/local/cuda/bin", "/usr/local/cuda-6.5/bin"]
    }
    property string nvccPath: nvccProbe.filePath

    /*Rule {
        inputs: "cuda"
        multiplex: true
        outputFileTags: "obj";
        outputArtifacts: {
            var result = [];
            for (var i in inputs.cuda)
            {
                var input = inputs.cuda[i];
                var artifact = {filePath: '.obj/' + input.baseDir + '/' + input.completeBaseName + '.o', fileTags: "obj"};
                result.push(artifact);
            }
            return result;
        }

        prepare: {
            var args = [];
            args.push("-c");
            var targetOS = product.moduleProperty('qbs', 'targetOS');
            if(product.moduleProperty('qbs', 'debugInformation'))
            {
                args.push("-g");
                args.push("-D_DEBUG");
                args.push("-Xcompiler");
                if(targetOS.contains("windows")) args.push("/MDd");
            }
            else
            {
                args.push("-Xcompiler");
                if(targetOS.contains("windows")) args.push("/MD");
            }

            var arch = product.moduleProperty('qbs', 'architecture');
            if(arch == "x86")
                args.push("-m32");
            if(arch == "x86_64")
                args.push("-m64");
            args.push("-odir");
            args.push(product.destinationDirectory + "/.obj");
            for (var i in inputs.cuda)
                args.push(inputs.cuda[i].filePath);
            var nvcc = product.moduleProperty('CUDA.cudart', 'nvccPath');
            var cmd = new Command(nvcc, args);
            cmd.description = "Executing nvcc";
            cmd.highlight = 'compiler';
            return cmd;
        }
    }*/
}
