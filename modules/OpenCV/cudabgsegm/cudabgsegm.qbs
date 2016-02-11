import qbs 1.0
import '../OpenCV.qbs' as OpenCVModule

OpenCVModule
{
    moduleName: "cudabgsegm"
    cpp.defines: {
        if(found) return ["USE_OPENCV_CUDABGSEGM"];
    }
}
