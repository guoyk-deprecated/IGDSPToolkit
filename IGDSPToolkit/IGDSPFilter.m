//
//  IGDSPFilter.m
//
//  Created by IREUL Guo on 10/24/13.
//

#import "IGDSPFilter.h"


IGNaNFilterRef IGNaNFilterCreateRef(float initvalue)
{
    return (IGNaNFilterRef)malloc(sizeof(float));
}

void IGNaNFilter(IGNaNFilterRef ref,float* input)
{
    if (isnan(*input) || *input == INFINITY) {
        *input = *ref;
    } else {
        *ref = *input;
    }
}

IGSimpleLowPassFilterRef IGSimpleLowPassFilterCreateRef()
{
    IGSimpleLowPassFilterRef ref = malloc(sizeof(IGSimpleLowPassFilterStruct));
    ref->last_high_value = 0.f;
    ref->last_value = 0.f;
    return ref;
}

void IGSimpleLowPassFilter(IGSimpleLowPassFilterRef ref,float* value)
{
	float high_value = *value - ref->last_value;
	ref->last_value = *value;
	float low_value=(ref->last_high_value + high_value)/2;
	ref->last_high_value = high_value;
    *value = low_value;
}

void IGSimpleLowPassFilterRelease(IGSimpleLowPassFilterRef ref)
{
    free(ref);
}