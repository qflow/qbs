import qbs 1.0
import '../OpenCV.qbs' as OpenCVModule

OpenCVModule
{
    moduleName: "cudaimgproc"
    cpp.defines: {
        if(found) return ["USE_OPENCV_CUDAIMGPROC"];
    }
}
