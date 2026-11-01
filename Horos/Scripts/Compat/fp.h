/* Compatibility shim: <fp.h> was a classic Mac OS math header that modern macOS SDKs no
 * longer ship. Old bundled libpng copies (VTK, ITK) include it when TARGET_OS_MAC is
 * defined and their <math.h> include-guard check misses the current SDK's guard name. */
#include <math.h>
