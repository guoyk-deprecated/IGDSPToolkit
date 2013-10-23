//
//  IGSamplePool.m
//  IGDSPToolkitDemo
//
//  Created by IREUL Guo on 10/24/13.
//

#import "IGDSPSamplePool.h"

IGSamplePool    IGSamplePoolCreate(int capacity,float sample_rate,IGSamplePoolType type)
{
    IGSamplePool pool = {
        .buffer = CArrayNew(capacity, sizeof(float)),
        .type = type,
        .sample_rate = sample_rate,
        .fft = NULL
    };
    return pool;
}


void            IGSamplePoolRelease(IGSamplePool pool)
{
    CArrayDelete(pool.buffer);
    if (pool.fft != NULL) {
        IGFFTsRelease(*pool.fft);
    }
}

void            IGSamplePoolAdd(IGSamplePool pool,float value)
{
    if (pool.type == IGSamplePoolTypeFixedLength && pool.buffer->count == pool.buffer->capacity) {
        CArrayRemoveElement(pool.buffer, CArrayElement(pool.buffer, 0));
    }
    CArrayAddElement(pool.buffer, &value);
}

int             IGSamplePoolGetSize(IGSamplePool pool)
{
    return pool.buffer->count;
}

int             IGSamplePoolGetCapacity(IGSamplePool pool)
{
    return pool.buffer->capacity;
}


float           IGSamplePoolGetTotalTime(IGSamplePool pool)
{
    return IGSamplePoolGetSize(pool) / pool.sample_rate;
}

int             IGSamplePoolInitializeFFTs(IGSamplePool pool)
{
    if (pool.type != IGSamplePoolTypeFixedLength) {
        printf("[IGDSP][ERROR]: IGFFTs can only be created from a fix length sample pool");
        return 1;
    }
    IGFFTs fft = IGFFTsSetup(pool.buffer->capacity, pool.sample_rate);
    pool.fft = &fft;
    return 0;
}

float           IGSamplePoolGetMaxFFTFrequency(IGSamplePool pool)
{
    if (pool.fft == NULL &&  IGSamplePoolInitializeFFTs(pool) != 0) {
        return 0.f;
    }
    IGFFTs fft = *pool.fft;
    IGFFTsData data = IGFFTsCreateData(fft);
    IGFFTsFillDataWithCArray(fft, pool.buffer, data);
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

float           IGSamplePoolGetZeroReverseFrequency(IGSamplePool pool)
{
    float last = 0.f;
    int count = 0;
    CArrayFor(float*, value, pool.buffer) {
        if (last < 0 && *value >= 0) {
            count ++;
        }
        last = *value;
    }
    return ((float)count) / IGSamplePoolGetTotalTime(pool);
}