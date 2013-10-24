//
//  IGSamplePool.h
//
//  Created by IREUL Guo on 10/24/13.
//

#import "CArray.h"
#import "IGDSPBase.h"
#import "IGDSPFFT.h"

typedef enum {
    IGSamplePoolTypeFixedLength = 0,
    IGSamplePoolTypeVariableLength = 1,
} IGSamplePoolType;

typedef struct {
    CArray * buffer;
    IGFFTsRef fft;
    float frame_rate;
    long frame_base_absolute_position;
    IGSamplePoolType type;
} IGSamplePool;

typedef void (^IGSamplePoolEnumeratorBlock)(long frame_absolute_position,double frame_absolute_time,float* value,bool* stop);

typedef IGSamplePool *IGSamplePoolRef;

IGSamplePoolRef    IGSamplePoolCreate       (int capacity,float frame_rate,IGSamplePoolType type);
void    IGSamplePoolRelease                 (IGSamplePoolRef pool);

int     IGSamplePoolGetSize                 (IGSamplePoolRef pool);
float   IGSamplePoolGetFrameIntervalTime    (IGSamplePoolRef pool);
float   IGSamplePoolGetBaseTime             (IGSamplePoolRef pool);
float   IGSamplePoolGetTotalTime            (IGSamplePoolRef pool);
int     IGSamplePoolGetCapacity             (IGSamplePoolRef pool);
void    IGSamplePoolAdd                     (IGSamplePoolRef pool,float value);

int     IGSamplePoolInitializeFFTs          (IGSamplePoolRef pool);
float   IGSamplePoolGetMaxFFTFrequency      (IGSamplePoolRef pool);
float   IGSamplePoolGetZeroReverseFrequency (IGSamplePoolRef pool,bool direction);
float   IGSamplePoolGetThresholdFrequency   (IGSamplePoolRef pool,float threshold,bool direction);
float   IGSamplePoolGetAverage              (IGSamplePoolRef pool);
void    IGSamplePoolEnumerateWithBlock      (IGSamplePoolRef pool,IGValueDirection direction,IGSamplePoolEnumeratorBlock block);

typedef struct {
    double triggered_absolute_position;
    double last_triggered_absolute_position;
    float threshold;
    IGValueDirection direction;
    bool triggered;
} IGSamplePoolThresholdTrigger;

typedef IGSamplePoolThresholdTrigger * IGSamplePoolThresholdTriggerRef;

bool    IGSamplePoolThresholdTriggerIsTriggered (IGSamplePoolThresholdTriggerRef ref,float first_value,float last_value);

IGSamplePoolThresholdTriggerRef IGSamplePoolThresholdTriggerCreateRef (float threshold,IGValueDirection direction);
void    IGSamplePoolExecuteThresholdTrigger (IGSamplePoolRef pool,IGSamplePoolThresholdTriggerRef ref);