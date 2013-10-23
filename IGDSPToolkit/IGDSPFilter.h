//
//  IGDSPFilter.h
//
//  Created by IREUL Guo on 10/24/13.
//

typedef float IGNaNFilterRef;

void IGNaNFilter(IGNaNFilterRef ref,float* input);

typedef struct {
    float last_value;
    float last_high_value;
} IGSimpleLowPassFilterRef;

void IGSimpleLowPassFilter(IGSimpleLowPassFilterRef ref,float* value);