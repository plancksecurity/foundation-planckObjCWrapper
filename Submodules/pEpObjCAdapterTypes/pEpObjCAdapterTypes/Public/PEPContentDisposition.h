//
//  PEPContentDisposition.h
//  pEpObjCAdapterTypes
//
//  Created by Dirk Zimmermann on 30.11.20.
//

#ifndef PEPContentDisposition_h
#define PEPContentDisposition_h

typedef NS_CLOSED_ENUM(int, PEPContentDisposition) {
    PEPContentDispositionAttachment = 0, // PEP_CONTENT_DISP_ATTACHMENT
    PEPContentDispositionInline = 1, // PEP_CONTENT_DISP_INLINE
    PEPContentDispositionOther = -1 // PEP_CONTENT_DISP_OTHER
};

#endif /* PEPContentDisposition_h */
