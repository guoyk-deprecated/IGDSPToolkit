//
//  IGDSPFFT.h
//
//  Created by IREUL Guo on 10/23/13.
//

#import <Accelerate/Accelerate.h>
#import "CArray.h"

//struct to store datas related with a float FFT
typedef struct {
    FFTSetup    setup;
    int         samples;
    int         samples_over2;
    int         log2samples;
    int         rate;
} IGFFTs;

typedef IGFFTs * IGFFTsRef;

//rename COMPLEX_SPLIT for convenient
typedef COMPLEX_SPLIT IGFFTsData;

//define a block to enumerate through fft result
typedef void (^IGFFTsResultEnumeratorBlock)(int position,float frequency,float strength);

//Create a IGFFTs struct
IGFFTsRef   IGFFTsSetup             (int sample_count,int sample_rate);

//Release IGFFTs struct
void        IGFFTsRelease           (IGFFTsRef ref);

//Create a IGFFTs data to store input and output data
IGFFTsData  IGFFTsCreateData        (IGFFTsRef ref);

//Fill Data with float
void        IGFFTsFillDataWithFloat (IGFFTsRef ref,float* input,IGFFTsData data);

//Fill Data with CArray with float, the CArray must have same size of ref.samples
void        IGFFTsFillDataWithCArray(IGFFTsRef ref,CArray* array,IGFFTsData data);

//Release a previously created IGFFTs data
void        IGFFTsReleaseData       (IGFFTsData data);

//Calculate 1D Real FFT
void        IGFFTsComputeReal1D     (IGFFTsRef ref,IGFFTsData inoutdata,BOOL direction);

//Enumerate throuth a IGFFTs result
void        IGFFTsEnumerateResult   (IGFFTsRef ref,IGFFTsData data,IGFFTsResultEnumeratorBlock enumerator);