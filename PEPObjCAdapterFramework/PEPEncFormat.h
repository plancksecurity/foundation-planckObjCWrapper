//
//  PEPEncFormat.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 19.11.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#ifndef PEPEncFormat_h
#define PEPEncFormat_h

typedef NS_CLOSED_ENUM(int, PEPEncFormat) {
    PEPEncFormatNone = 0, // PEP_enc_none
    PEPEncFormatPieces, // PEP_enc_pieces, PEP_enc_inline
    PEPEncFormatSMIME, // PEP_enc_S_MIME
    PEPEncFormatPGPMIME, // PEP_enc_PGP_MIME
    PEPEncFormatPEP, // PEP_enc_PEP
    PEPEncFormatPGPMIMEOutlook1 // PEP_enc_PGP_MIME_Outlook1
};

#endif /* PEPEncFormat_h */
