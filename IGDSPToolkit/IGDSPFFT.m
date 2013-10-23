//
//  IGDSPFFT.m
//
//  Created by IREUL Guo on 10/23/13.
//

#import "IGDSPFFT.h"

IGFFTs      IGFFTsSetup                 (int sample_count,int sample_rate)
{
    IGFFTs fft;
    fft.samples = sample_count;
    fft.rate = sample_rate;
    fft.samples_over2 = sample_count/2;
    fft.log2samples = round(log2(sample_count));
    fft.setup = vDSP_create_fftsetup(fft.log2samples,kFFTRadix2);
    return fft;
}

void        IGFFTsRelease           (IGFFTs ref)
{
    vDSP_destroy_fftsetup(ref.setup);
}

IGFFTsData  IGFFTsCreateData            (IGFFTs ref)
{
    IGFFTsData data;
    data.realp = (float*)malloc((ref.samples_over2)*sizeof(float));
    data.imagp = (float*)malloc((ref.samples_over2)*sizeof(float));
    return data;
}

void        IGFFTsFillDataWithFloat (IGFFTs ref,float* input,IGFFTsData data)
{
    vDSP_ctoz((COMPLEX*)input,2,&data,1,ref.samples_over2);
}

void        IGFFTsFillDataWithCArray(IGFFTs ref,CArray* array,IGFFTsData data)
{
    float * f = malloc(ref.samples * sizeof(float));
    memset(f, 0, ref.samples * sizeof(float));
    int i = 0;
    CArrayFor(float*, value, array) {
        f[i] = *value;
        i ++;
    }
    IGFFTsFillDataWithFloat(ref, f, data);
    free(f);
}

void        IGFFTsReleaseData       (IGFFTsData data)
{
    free(data.realp);
    free(data.imagp);
}

void        IGFFTsComputeReal1D     (IGFFTs ref,IGFFTsData inoutdata,BOOL direction)
{
    vDSP_fft_zrip(ref.setup,&inoutdata,1,ref.log2samples,direction?FFT_FORWARD:FFT_INVERSE);
}

void        IGFFTsEnumerateResult   (IGFFTs ref,IGFFTsData data,IGFFTsResultEnumeratorBlock enumerator)
{
    for (int i = 0; i < ref.samples_over2; i ++) {
        enumerator(i,
                   i * (((float)ref.rate)/((float)ref.samples)),
                   sqrtf(data.realp[i] * data.realp[i] + data.imagp[i] * data.imagp[i]));
    }
}