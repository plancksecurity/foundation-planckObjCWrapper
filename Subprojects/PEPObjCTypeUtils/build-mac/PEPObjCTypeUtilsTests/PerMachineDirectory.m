//
//  PerMachineDirectory.m
//  PEPObjCTypeUtils
//
//  Created by Dirk Zimmermann on 17.11.22.
//

#import <Foundation/Foundation.h>

/// PEPObjCTypeUtils depends on the engine, which in turn requires this memory location in order to link,
/// which is normally provided by the objc adapter for iOS.
///
/// Provide a fake in the test without having to link to the adapter.
char *perMachineDirectory = "perMachineDirectory_not_really_a_directory";
