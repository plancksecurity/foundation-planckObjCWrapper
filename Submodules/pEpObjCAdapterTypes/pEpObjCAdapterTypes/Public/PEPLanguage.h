//
//  PEPLanguage.h
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 03.05.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#ifndef PEPLanguage_h
#define PEPLanguage_h

#import <Foundation/Foundation.h>

@interface PEPLanguage : NSObject

- (instancetype _Nonnull)initWithCode:(NSString * _Nonnull)code
                                 name:(NSString * _Nonnull)name
                                 sentence:(NSString * _Nonnull)sentence;

/**
 ISO 639-1 language code
 */
@property (nonatomic, nonnull) NSString *code;

/**
 Name of the language. Should not be translated.
 */
@property (nonatomic, nonnull) NSString *name;

/**
 Sentence of the form "I want to display the trustwords in <lang>".
 Should not be translated.
 */
@property (nonatomic, nonnull) NSString *sentence;

@end

#endif
