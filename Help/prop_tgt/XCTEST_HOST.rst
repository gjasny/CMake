XCTEST_HOST
-----------

XCTest works by injecting an XCTest CFBundle directly into an AppBundle.
This property names this destination target under test.

This property is only useful with the Xcode Generator and also needs the
:prop_tgt:`XCTEST` property enabled on the target.
