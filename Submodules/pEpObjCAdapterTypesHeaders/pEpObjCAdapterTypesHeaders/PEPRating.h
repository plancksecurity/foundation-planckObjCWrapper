//
//  PEPRating.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 19.11.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#ifndef PEPRating_h
#define PEPRating_h

typedef NS_CLOSED_ENUM(int, PEPRating) {
    PEPRatingUndefined = 0, // PEP_rating_undefined
    PEPRatingCannotDecrypt = 1, // PEP_rating_cannot_decrypt
    PEPRatingHaveNoKey = 2, // PEP_rating_have_no_key
    PEPRatingUnencrypted = 3, // PEP_rating_unencrypted
    PEPRatingUnreliable = 5, // PEP_rating_unreliable
    PEPRatingReliable = 6, // PEP_rating_reliable
    PEPRatingTrusted = 7, // PEP_rating_trusted
    PEPRatingTrustedAndAnonymized = 8, // PEP_rating_trusted_and_anonymized
    PEPRatingFullyAnonymous = 9, // PEP_rating_fully_anonymous

    PEPRatingMistrust = -1, // PEP_rating_mistrust
    PEPRatingB0rken = -2, // PEP_rating_b0rken
    PEPRatingUnderAttack = -3 // PEP_rating_under_attack
};

#endif /* PEPRating_h */
