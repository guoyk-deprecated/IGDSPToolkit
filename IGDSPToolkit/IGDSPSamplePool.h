//
//  IGSamplePool.h
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
    IGFFTsRef fft;
    float sample_rate;
    IGSamplePoolType type;
} IGSamplePool;

typedef IGSamplePool *IGSamplePoolRef;

IGSamplePoolRef    IGSamplePoolCreate       (int capacity,float sample_rate,IGSamplePoolType type);
void    IGSamplePoolRelease                 (IGSamplePoolRef pool);

int     IGSamplePoolGetSize                 (IGSamplePoolRef pool);
float   IGSamplePoolGetTotalTime            (IGSamplePoolRef pool);
int     IGSamplePoolGetCapacity             (IGSamplePoolRef pool);
void    IGSamplePoolAdd                     (IGSamplePoolRef pool,float value);

int     IGSamplePoolInitializeFFTs          (IGSamplePoolRef pool);
float   IGSamplePoolGetMaxFFTFrequency      (IGSamplePoolRef pool);
float   IGSamplePoolGetZeroReverseFrequency (IGSamplePoolRef pool,bool direction);
float   IGSamplePoolGetThresholdFrequency   (IGSamplePoolRef pool,float threshold,bool direction);
float   IGSamplePoolGetAverage              (IGSamplePoolRef pool);