//
//  IGSample.h
//  IGDSPToolkitDemo
//
//  Created by IREUL Guo on 10/24/13.
//

#import "CArray.h"

typedef enum {
    IGSamplePoolTypeFixedLength = 0,
    IGSamplePoolTypeVariableLength = 1,
} IGSamplePoolType;

typedef struct {
    CArray * buffer;
    float sample_rate;
    IGSamplePoolType type;
} IGSamplePool;

IGSamplePool    IGSamplePoolCreate(int capacity,float sample_rate,IGSamplePoolType type);
void            IGSamplePoolRelease(IGSamplePool pool);

void            IGSamplePoolAdd(IGSamplePool pool,float value);