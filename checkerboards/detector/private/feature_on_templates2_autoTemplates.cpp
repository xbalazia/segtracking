/*******************************************************************************
* Piotr's Image&Video Toolbox      Version NEW
* Copyright 2013 Piotr Dollar.  [pdollar-at-caltech.edu]
* Please email me if you find bugs, or have suggestions or questions!
* Licensed under the Simplified BSD License [see external/bsd.txt]
*******************************************************************************/
#include "mex.h"
#include <vector>
#include <cmath>
#include <string.h>
using namespace std;

typedef unsigned int uint32;
#define MAX 16;

// haar struct
typedef struct HAAR
{ 
    char w;
    char h;
    char sign[MAX];
};


//6*6 cells
const short Nflt =39;
HAAR Haar[Nflt]={
{1,1,{1}},
{2,2,{1,1,1,1}},
{3,3,{1,1,1,1,1,1,1,1,1}},
{1,2,{1,-1}},
{1,3,{1,-1,-1}},
{1,3,{1,1,-1}},
{2,1,{1,-1}},
{2,2,{1,1,-1,-1}},
{2,2,{1,-1,1,-1}},
{2,2,{1,-1,-1,1}},
{2,3,{1,1,1,-1,-1,-1}},
{2,3,{1,-1,-1,1,-1,-1}},
{2,3,{1,1,-1,1,1,-1}},
{2,3,{1,-1,1,-1,1,-1}},
{3,1,{1,-1,-1}},
{3,1,{1,1,-1}},
{3,2,{1,1,-1,-1,-1,-1}},
{3,2,{1,1,1,1,-1,-1}},
{3,2,{1,-1,1,-1,1,-1}},
{3,2,{1,-1,-1,1,1,-1}},
{3,3,{1,1,1,-1,-1,-1,-1,-1,-1}},
{3,3,{1,1,1,1,1,1,-1,-1,-1}},
{3,3,{1,-1,-1,1,-1,-1,1,-1,-1}},
{3,3,{1,1,-1,1,1,-1,1,1,-1}},
{3,3,{1,-1,1,-1,1,-1,1,-1,1}},
{4,1,{1,-1,-1,-1}},
{4,1,{1,1,-1,-1}},
{4,1,{1,1,1,-1}},
{4,2,{1,1,-1,-1,-1,-1,-1,-1}},
{4,2,{1,1,1,1,-1,-1,-1,-1}},
{4,2,{1,1,1,1,1,1,-1,-1}},
{4,2,{1,-1,1,-1,1,-1,1,-1}},
{4,2,{1,-1,-1,1,1,-1,-1,1}},
{4,3,{1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1}},
{4,3,{1,1,1,1,1,1,-1,-1,-1,-1,-1,-1}},
{4,3,{1,1,1,1,1,1,1,1,1,-1,-1,-1}},
{4,3,{1,-1,-1,1,-1,-1,1,-1,-1,1,-1,-1}},
{4,3,{1,1,-1,1,1,-1,1,1,-1,1,1,-1}},
{4,3,{1,-1,1,-1,1,-1,1,-1,1,-1,1,-1}}
  };


  
float* response_image(float *chns,int nChns, int width,int height,int feature_length)
{
    int  x1,y1, i,j,irectw,irecth, iChns,count1,count2,tag,index =0, index_res=0;
    int sum_pixel = width*height;     
    float *sum1 = new float[nChns];
    float *sum2 = new float[nChns];
    float *res = new float[feature_length];
    int sum_size = nChns*sizeof(float);
   // compute hist differences
  for(int iflt = 0;iflt<Nflt;iflt++)
  {
        for (i =0;i<=width-Haar[iflt].w;i++)
        {
            for (j =0;j<=height-Haar[iflt].h;j++)
            {
                memset(sum1,0,sum_size);
                memset(sum2,0,sum_size);
                count1 =0; count2=0;
       
                for (irectw = 0;irectw<Haar[iflt].w;irectw++)
                {
                    x1 = (i+irectw);
                    for (irecth = 0;irecth<Haar[iflt].h;irecth++)
                    {
                        y1 =(j+irecth);                            
                        tag = Haar[iflt].sign[irecth*Haar[iflt].w+irectw];
                        if (tag== 1)
                        {
                            count1++;
                            for (iChns=0;iChns<nChns;iChns++)
                            {
                                   index =  iChns*sum_pixel + x1*height + y1;   
                                   sum1[iChns] += chns[index];
                                   
                            }
                        }
                        else if (tag == -1)
                        {
                            count2++;
                            for (iChns=0;iChns<nChns;iChns++)
                            {
                                   index =  iChns*sum_pixel + x1*height + y1;   
                                    sum2[iChns] += chns[index];
                            }
                        }
                    }
                }
                
                
                for (iChns=0;iChns<nChns;iChns++)
                {
                    if(count2>0)
                    	res[index_res++] = (sum1[iChns]/count1- sum2[iChns]/count2);
                    else
                        res[index_res++] = sum1[iChns]/count1;  
                } 
            }
        }

  }
    delete sum1,sum2; 

    return res;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  // get inputs
  float *chns = (float*) mxGetData(prhs[0]);
  const int shrink = (int) mxGetScalar(prhs[1]);

  // get dimensions and constants
  const mwSize *chnsSize = mxGetDimensions(prhs[0]);
  const int height = (int) chnsSize[0];
  const int width = (int) chnsSize[1];
  const int nChns = mxGetNumberOfDimensions(prhs[0])<=2 ? 1 : (int) chnsSize[2];

  // length of haar filters
  int flen[Nflt];
  int nhaarh[Nflt];
  int nhaarw[Nflt];
  int feature_length = 0;
  for(int iflt = 0;iflt<Nflt;iflt++)
  {
        nhaarw[iflt] = width - Haar[iflt].w +1;
        nhaarh[iflt] =   height-Haar[iflt].h + 1;      
        flen[iflt] = nhaarh[iflt] * nhaarw[iflt];
    
        feature_length += flen[iflt];
  }
  feature_length *=nChns;
  
  plhs[0] = mxCreateNumericMatrix(1, feature_length, mxSINGLE_CLASS, mxREAL);
  float *res = (float *) mxGetData(plhs[0]);
  float* res1 = response_image(chns,nChns,width,height, feature_length);   
      for (int i=0;i<feature_length;i++)
        res[i]=res1[i];
  delete res1;
}
