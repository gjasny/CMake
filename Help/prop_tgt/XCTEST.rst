XCTEST
------

This target is a XCTest CFBundle on the Mac.

If a module library target has this property set to true it will be
built as a CFBundle when built on the mac.  It will have the directory
structure required for a CFBundle.

This property implies :prop_tgt:`BUNDLE`.
