//
//  IGDSPFilter.m
//  IGDSPToolkitDemo
//
//  Created by YANKE Guo on 10/24/13.
//

#import "IGDSPFilter.h"

void IGNaNFilter(IGNaNFilterRef ref,float* input)
{
    if (isnan(*input) || *input == INFINITY) {
        *input = ref;
    } else {
        ref = *input;
    }
}

void IGSimpleLowPassFilter(IGSimpleLowPassFilterRef ref,float* value)
{
	float high_value = *value - ref.last_value;
	ref.last_value = *value;
	float low_value=(ref.last_high_value + high_value)/2;
	ref.last_high_value = high_value;
    *value = low_value;
}