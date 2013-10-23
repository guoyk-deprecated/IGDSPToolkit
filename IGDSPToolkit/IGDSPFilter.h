//
//  IGDSPFilter.h
//
//  Created by IREUL Guo on 10/24/13.
//

typedef float *IGNaNFilterRef;

IGNaNFilterRef IGNaNFilterCreateRef(float initvalue);

void IGNaNFilter(IGNaNFilterRef ref,float* input);

typedef struct {
    float last_value;
    float last_high_value;
} IGSimpleLowPassFilterStruct;

typedef IGSimpleLowPassFilterStruct * IGSimpleLowPassFilterRef;

IGSimpleLowPassFilterRef IGSimpleLowPassFilterCreateRef();

void IGSimpleLowPassFilter(IGSimpleLowPassFilterRef ref,float* value);

void IGSimpleLowPassFilterRelease(IGSimpleLowPassFilterRef ref);