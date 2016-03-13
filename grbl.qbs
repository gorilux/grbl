import qbs
import qbs.File
import qbs.FileInfo
import qbs.TextFile

Product {

    name: "grbl_cnc"    
    Depends { name: "cpp" }


    type: ["application", "avr-hex"]

    cpp.optimization: "fast"
    cpp.positionIndependentCode: false
    property string MMCU: "atmega1280"
    property string F_CPU: "16000000L"

    cpp.platformDefines: [
        "F_CPU=" + F_CPU
    ]
//    cpp.includePaths : [
//        "ArduinoCore",
//        //"gstdcpp",
//        //"GrlxLibs/GrlxTmpl/",
//        //"GrlxLibs/GrlxFSM/"
//    ]
    cpp.commonCompilerFlags: [
        "-ffunction-sections",
        "-fdata-sections"
    ]
    cpp.cxxFlags: [
        "-mmcu=" + MMCU,
        "-fno-exceptions",
        "-felide-constructors",
        "-std=c++11"

    ]
    cpp.cFlags: [
        "-mmcu=" + MMCU,
    ]

    cpp.linkerFlags: [
        "-mmcu=" + MMCU,
        "-Wl,--start-group",
        "-Wl,-lm",
        "-Wl,--end-group",
        "-Wl,--gc-sections"
    ]



    files: [
        "grbl/**/*.c",
        "grbl/**/*.h"
    ]

    Rule{
        id: avr_objCopy
        condition: true
        inputs: ["application"]
        Artifact {
            fileTags: ["avr-hex"]
            filePath:  input.filePath + ".hex"

        }
        prepare: {

            var cmds = [];
            var args = [];


            args.push("-j", ".text");
            args.push("-j", ".data");
            args.push("-O", "ihex");
            args.push(input.filePath);
            args.push(output.filePath);

            var cmdObjCopy = new Command("avr-objcopy", args);
            cmdObjCopy.silent = false;
            cmdObjCopy.description = 'avr-objcopy' + args;
            cmdObjCopy.highlight = "linker";

            var cmdAvrSize = new Command( "avr-size", ["--format=berkeley", input.filePath]);
            cmdAvrSize.silent = false;
            cmdAvrSize.highlight = "linker";

            cmds.push(cmdObjCopy);
            cmds.push(cmdAvrSize);
            return cmds;

        }

    }




}
