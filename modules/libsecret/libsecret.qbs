import qbs
import qbs.Probes as Probes

Module
{
    Depends{name: "cpp"}
    Depends{name: "glib"}
    Probes.PkgConfigProbe {
        id: pkgConfig
        name: "libsecret-1"
    }
    cpp.defines: ['QT_NO_KEYWORDS', 'SECRET_WITH_UNSTABLE']
    cpp.cxxFlags: pkgConfig.cflags
    cpp.linkerFlags: pkgConfig.libs
    cpp.includePaths: ["/usr/include/libsecret-1"]
}
