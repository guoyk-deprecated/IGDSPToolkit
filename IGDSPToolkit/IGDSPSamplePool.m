//
//  IGSamplePool.m
//
//  Created by IREUL Guo on 10/24/13.
//

#import "IGDSPSamplePool.h"

IGSamplePoolRef    IGSamplePoolCreate       (int capacity,float sample_rate,IGSamplePoolType type)
{
    IGSamplePoolRef pool = malloc(sizeof(IGSamplePool));
    pool->buffer = CArrayNew(capacity, sizeof(float));
    pool->type = type;
    pool->sample_rate = sample_rate;
    pool->fft = NULL;
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


float   IGSamplePoolGetTotalTime            (IGSamplePoolRef pool)
{
    return IGSamplePoolGetSize(pool) / pool->sample_rate;
}

int     IGSamplePoolGetCapacity             (IGSamplePoolRef pool)
{
    return pool->buffer->capacity;
}

void    IGSamplePoolAdd                     (IGSamplePoolRef pool,float value)
{
    if (pool->type == IGSamplePoolTypeFixedLength && pool->buffer->count == pool->buffer->capacity) {
        CArrayRemoveElement(pool->buffer, CArrayElement(pool->buffer, 0));
    }
    CArrayAddElement(pool->buffer, &value);
}

int     IGSamplePoolInitializeFFTs          (IGSamplePoolRef pool)
{
    if (pool->type != IGSamplePoolTypeFixedLength) {
        printf("[IGDSP][ERROR]: IGFFTs can only be created from a fix length sample pool");
        return 1;
    }
    pool->fft = IGFFTsSetup(pool->buffer->capacity, pool->sample_rate);
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