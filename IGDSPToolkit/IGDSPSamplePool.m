//
//  IGSamplePool.m
//
//  Created by IREUL Guo on 10/24/13.
//

#import "IGDSPSamplePool.h"

IGSamplePoolRef    IGSamplePoolCreate       (int capacity,float frame_rate,IGSamplePoolType type)
{
    IGSamplePoolRef pool = malloc(sizeof(IGSamplePool));
    pool->buffer = CArrayNew(capacity, sizeof(float));
    pool->type = type;
    pool->frame_rate = frame_rate;
    pool->fft = NULL;
    pool->frame_base_absolute_position = 0;
    return pool;
}


void    IGSamplePoolRelease(IGSamplePoolRef pool)
{
    CArrayDelete(pool->buffer);
    if (pool->fft != NULL) {
        IGFFTsRelease(pool->fft);
    }
}

int     IGSamplePoolGetSize                 (IGSamplePoolRef pool)
{
    return pool->buffer->count;
}

float   IGSamplePoolGetFrameIntervalTime            (IGSamplePoolRef pool)
{
    return 1.f/pool->frame_rate;
}

float   IGSamplePoolGetBaseTime             (IGSamplePoolRef pool)
{
    return pool->frame_base_absolute_position * IGSamplePoolGetFrameIntervalTime(pool);
}

float   IGSamplePoolGetTotalTime            (IGSamplePoolRef pool)
{
    return IGSamplePoolGetSize(pool) * IGSamplePoolGetFrameIntervalTime(pool);
}

int     IGSamplePoolGetCapacity             (IGSamplePoolRef pool)
{
    return pool->buffer->capacity;
}

void    IGSamplePoolAdd                     (IGSamplePoolRef pool,float value)
{
    if (pool->type == IGSamplePoolTypeFixedLength && pool->buffer->count == pool->buffer->capacity) {
        CArrayRemoveElement(pool->buffer, CArrayElement(pool->buffer, 0));
        pool->frame_base_absolute_position ++;
    }
    CArrayAddElement(pool->buffer, &value);
}

int     IGSamplePoolInitializeFFTs          (IGSamplePoolRef pool)
{
    if (pool->type != IGSamplePoolTypeFixedLength) {
        printf("[IGDSP][ERROR]: IGFFTs can only be created from a fix length sample pool");
        return 1;
    }
    pool->fft = IGFFTsSetup(pool->buffer->capacity, pool->frame_rate);
    return 0;
}

float   IGSamplePoolGetMaxFFTFrequency      (IGSamplePoolRef pool)
{
    if (pool->fft == NULL &&  IGSamplePoolInitializeFFTs(pool) != 0) {
        return 0.f;
    }
    IGFFTsRef fft = pool->fft;
    IGFFTsData data = IGFFTsCreateData(fft);
    IGFFTsFillDataWithCArray(fft, pool->buffer, data);
    IGFFTsComputeReal1D(fft, data, YES);
    __block float hf = 0;
    __block float hv = 0;
    IGFFTsEnumerateResult(fft, data, ^(int position, float frequency, float strength) {
        if (strength > hv) {
            hv = strength;
            hf = frequency;
        }
    });
    IGFFTsReleaseData(data);
    return hf;
}

float   IGSamplePoolGetZeroReverseFrequency (IGSamplePoolRef pool,bool direction)
{
    return IGSamplePoolGetThresholdFrequency(pool, 0, direction);
}

float   IGSamplePoolGetThresholdFrequency   (IGSamplePoolRef pool,float threshold,bool direction)
{
    float last = 0.f;
    int count = 0;
    CArrayFor(float*, value, pool->buffer) {
        if (direction) {
            if (last < threshold && *value >= threshold) {
                count ++;
            }
        } else {
            if (last > threshold && *value <= threshold) {
                count ++;
            }
        }
        last = *value;
    }
    return ((float)count) / IGSamplePoolGetTotalTime(pool);
}

float   IGSamplePoolGetAverage              (IGSamplePoolRef pool)
{
    float value = 0;
    CArrayFor(float*, v, pool->buffer) {
        value += *v;
    }
    return value / IGSamplePoolGetSize(pool);
}

void    IGSamplePoolEnumerateWithBlock      (IGSamplePoolRef pool,IGValueDirection direction,IGSamplePoolEnumeratorBlock block)
{
    int position;
    if (direction == IGValueDirectionPositive) {
        position = 0;
        CArrayFor(float *, value, pool->buffer) {
            long abs_position = (pool->frame_base_absolute_position + position);
            __block bool * stop = NULL;
            block(abs_position,abs_position * IGSamplePoolGetFrameIntervalTime(pool),value,stop);
            if (*stop) {
                break;
            }
        }
    } else {
        position = pool->buffer->count;
        CArrayForBackwards(float *, value, pool->buffer) {
            position --;
            long abs_position = (pool->frame_base_absolute_position + position);
            __block bool * stop = NULL;
            block(abs_position,abs_position * IGSamplePoolGetFrameIntervalTime(pool),value,stop);
            if (*stop) {
                break;
            }
        }
    }
}

IGSamplePoolThresholdTriggerRef IGSamplePoolCreateThresholdTriggerRef (IGSamplePoolRef pool,float threshold,IGValueDirection direction)
{
    IGSamplePoolThresholdTriggerRef ref = malloc(sizeof(IGSamplePoolThresholdTrigger)) ;
    ref->triggered_absolute_position = 0.f;
    ref->last_triggered_absolute_position = 0.f;
    ref->threshold = threshold;
    ref->direction = direction;
    return ref;
}

bool    IGSamplePoolThresholdTriggerIsTriggered (IGSamplePoolThresholdTriggerRef ref,float first_value,float last_value)
{
    if (ref->direction == IGValueDirectionPositive) {
        if (first_value < ref->threshold && last_value >= ref->threshold) {
            return true;
        }
    } else {
         if (first_value > ref->threshold && last_value <= ref->threshold) {
            return true;
         }
    }
    return false;
}

void    IGSamplePoolExecuteThresholdTrigger (IGSamplePoolRef pool,IGSamplePoolThresholdTriggerRef ref)
{
    __block float last_value = NAN;
    __block long last_abs_position = NAN;
    IGSamplePoolEnumerateWithBlock(pool, IGValueDirectionNegative, ^(long first_abs_position, double frame_absolute_time, float *first_value, bool *stop) {
        if (first_abs_position < ref->triggered_absolute_position) {
            *stop = true;
        } else {
            if (!isnan(last_abs_position)) {
                if (IGSamplePoolThresholdTriggerIsTriggered(ref, *first_value, last_value)) {
                    ref->last_triggered_absolute_position = ref->triggered_absolute_position;
                    //
                    float abs1 = fabsf((*first_value - ref->threshold));
                    float abs2 = fabsf((last_value - ref->threshold));
                    ref->triggered_absolute_position = first_abs_position + (IGSamplePoolGetFrameIntervalTime(pool) * abs1 / (abs1 + abs2));
                    //
                    ref->triggered = true;
                    return;
                }
            }
            last_value = *first_value;
            last_abs_position = first_abs_position;
        }
    });
    ref->triggered = false;
}