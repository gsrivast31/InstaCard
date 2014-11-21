//
//  ICConstants.h
//  InstaCard
//
//  Created by GAURAV SRIVASTAVA on 21/11/14.
//  Copyright (c) 2014 GAURAV SRIVASTAVA. All rights reserved.
//

#import <Foundation/Foundation.h>

// Used for saving to NSUserDefaults that a PIN has been set and as the unique identifier for the Keychain
#define PIN_SAVED @"hasSavedPIN"

// Used to help secure the PIN
// Ideally, this is randomly generated, but to avoid unneccessary complexity and overhead of storing the Salt seperately we will standardize on this key.
// !!KEEP IT A SECRET!!
#define SALT_HASH @"FvTivqTqZXsgLLx1v3P8TGRyVHaSOB1pvfm02wvGadj7RLHV8GrfxaZ84oGA8RsKdNRpxdAojXYg9iAj"

// Typedefs just to make it a little easier to read in code
typedef enum {
    kAlertTypePIN = 0,
    kAlertTypeSetup,
    kAlertTypeReset,
    kAlertTypeChange
} AlertTypes;

typedef enum {
    kTextFieldPIN = 1,
    kTextFieldSetup,
    kTextFieldReset,
    kTextFieldChange
} TextFieldTypes;

@interface ChristmasConstants : NSObject

@end
