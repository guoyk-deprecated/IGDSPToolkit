//
//  IGSample.h
//  IGDSPToolkitDemo
//
//  Created by IREUL Guo on 10/24/13.
//

#import "CArray.h"
#import "IGDSPFFT.h"

typedef enum {
    IGSamplePoolTypeFixedLength = 0,
    IGSamplePoolTypeVariableLength = 1,
} IGSamplePoolType;

typedef struct {
    CArray * buffer;
    IGFFTs * fft;
    float sample_rate;
    IGSamplePoolType type;
} IGSamplePool;

IGSamplePool    IGSamplePoolCreate(int capacity,float sample_rate,IGSamplePoolType type);
void            IGSamplePoolRelease(IGSamplePool pool);

int             IGSamplePoolGetSize(IGSamplePool pool);
int             IGSamplePoolGetCapacity(IGSamplePool pool);
void            IGSamplePoolAdd(IGSamplePool pool,float value);

int             IGSamplePoolInitializeFFTs(IGSamplePool pool);
float           IGSamplePoolGetMaxFFTFrequency(IGSamplePool pool);
float           IGSamplePoolGetZeroReverseFrequency(IGSamplePool pool);