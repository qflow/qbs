import qbs
import qbs.File
import qbs.TextFile
import qbs.Process
import qbs.ModUtils

DynamicLibrary
{
    cpp.cxxLanguageVersion: "c++11"
    type: ["dynamiclibrary", "qmltypes", "qmldir"]
    Depends{name: "cpp"}
    Depends{name: "Qt"; submodules: ["core", "qml"]}
    cpp.defines: [product.name.toUpperCase() + "_LIBRARY"]
    property string pluginRootPath: "plugins"
    property string pluginNamespace: ""
    property string pluginRelativePath: {
        return pluginNamespace.replace('.', '/').replace('.', '/');
    }
    property string pluginPath: pluginRootPath + "/" + pluginRelativePath
    property string infix: {
        var newInfix = Qt.core.libInfix;
        if(Qt.core.qtBuildVariant == "debug") newInfix += "d";
        return newInfix;
    }
    Group
    {
        name: "qmldir"
        files: [
            "qmldir"
        ]
        fileTags: ["qmldir_in"]
    }
    Group
    {
        name: "metadata"
        files: [product.name.toLowerCase() + "_metadata.json"]
        fileTags: ["metadata"]
    }

    /*Group
    {
        qbs.install: true
        qbs.installDir: pluginPath
        fileTagsFilter: product.type
    }*/

    Rule
    {
        inputs: ["qmldir_in", "dynamiclibrary", "qmlfiletype"]
        Artifact
        {
            fileTags: ["qmldir"]
            filePath: product.pluginRelativePath + "/" + input.fileName
        }
        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Copying '" + input.filePath + "'";
            cmd.highlight = "codegen";
            cmd.sourceCode = function() {
                File.copy(input.filePath, output.filePath);
            }

            return cmd;
        }
    }
    Rule {
        inputs: ["qmldir"]
        //condition: !qbs.debugInformation
        condition: false
        multiplex: true
        Artifact {
            fileTags: ["qmltypes"]
            filePath: "plugins.qmltypes"
        }
        prepare: {
            var pat = product.moduleProperties("cpp", "libraryPaths");
            var str = "";
            for (var i in pat)
            {
                str += pat[i] + ";";
            }
            var cmd = new JavaScriptCommand();
            cmd.description = "generating plugins.qmltypes " + str;
            cmd.highlight = "codegen";
            cmd.sourceCode = function() {

                var pat = product.moduleProperties("cpp", "libraryPaths");
                var str = "";
                for (var i in pat)
                {
                    str += pat[i] + ";";
                }
                var args = [];
                //args.push("-v");
                args.push("-nonrelocatable");
                args.push(product.pluginNamespace);
                args.push("1.0");
                args.push(product.buildDirectory);
                var process = new Process();
                process.setEnv("PATH", str);
                var binPath = product.moduleProperty('Qt.core', 'binPath');
                process.exec(binPath + "/qmlplugindump", args, false);
                var stdout = process.readStdOut();
                var file = new TextFile(output.filePath, TextFile.WriteOnly);
                file.truncate();
                file.write(stdout);
                file.close();
            }
            return cmd;
        }
    }
    Export {
        Depends { name: "cpp" }
        cpp.includePaths: "."
        cpp.libraryPaths: product.buildDirectory
    }
}
