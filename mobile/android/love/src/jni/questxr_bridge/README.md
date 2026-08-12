# Optional Android OpenXR bridge

This directory is compiled only when the `questVr` library flavor passes
`QUEST_XR=1`. It produces `libquestxr.so`; it is not part of `liblove.so` or
the stock `embed` flavor.

The packaged runtime loader is Khronos's
`org.khronos.openxr:openxr_loader_for_android:1.1.60` Maven artifact. The three
generated headers retained under `third_party/` are the matching OpenXR 1.1.60
Khronos headers (`openxr.h`, `openxr_platform.h`, and
`openxr_platform_defines.h`). Their file headers identify the license as
`Apache-2.0 OR MIT`. Unused reflection and loader-negotiation headers are not
vendored.

The bridge owns Android context transfer, an early OpenXR quad session,
fixed-size panel capture, and generic Touch input events. Game selection,
launcher policy, ROM importing, and mod-specific VR rendering remain outside
this native library.
