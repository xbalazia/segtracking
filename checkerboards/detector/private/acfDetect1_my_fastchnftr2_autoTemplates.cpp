/*******************************************************************************
* Piotr's Image&Video Toolbox      Version NEW
* Copyright 2013 Piotr Dollar.  [pdollar-at-caltech.edu]
* Please email me if you find bugs, or have suggestions or questions!
* Licensed under the Simplified BSD License [see external/bsd.txt]
*******************************************************************************/

/*in this file, we use the templates automatically generated from Generate_Tempaltes.m*/
#include "mex.h"
#include <vector>
#include <cmath>
#include <string.h>
#include <math.h>
#include <stdio.h>
using namespace std;

typedef unsigned int uint32;
typedef unsigned short ushort16;
#define MAX 16


// unique haar struct
struct HAAR_UNIQ
{ 
    char w;
    char h;
    char sign[MAX];
    float response[330][430][10];//float response[330][430][10] for INRIA;[170][250][10] for Caltech
};

//6*6 cells
const int nUniq = 39;
HAAR_UNIQ Haar_Uniq[nUniq]={
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



inline void getChild( float *chns1,  uint32 *fids,
  float *thrs, uint32 offset, uint32 &k0, uint32 &k )
{
  float ftr = chns1[fids[k]];
  k = (ftr<thrs[k]) ? 1 : 2;
  k0=k+=k0*2; k+=offset;
}
void response_image(float *chns,int nChns, int width,int height,int feature_length, int *nhaarh,int *nhaarw)
// this function compute a big feature map for the whole input image
{
    int  x1,y1, i,j,irectw,irecth, iChns,count1,count2,tag,index =0;
    int sum_pixel = width*height;    
    float *sum1 = new float[nChns];
    float *sum2 = new float[nChns];
    int sum_size = nChns*sizeof(float);
   // compute hist differences
  for(int iuniq = 0;iuniq<nUniq;iuniq++)
  {
        for (i =0;i<nhaarw[iuniq];i++)
        {
            for (j =0;j<nhaarh[iuniq];j++)
            {
                memset(sum1,0,sum_size);
                memset(sum2,0,sum_size);
                count1 =0; count2=0;
       
                for (irectw = 0;irectw<Haar_Uniq[iuniq].w;irectw++)
                {
                    x1 = (i+irectw);
                    for (irecth = 0;irecth<Haar_Uniq[iuniq].h;irecth++)
                    {
                        y1 =(j+irecth);                            
                        tag = Haar_Uniq[iuniq].sign[irecth*Haar_Uniq[iuniq].w+irectw];
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
                    	Haar_Uniq[iuniq].response[j][i][iChns] = (sum1[iChns]/count1- sum2[iChns]/count2);
                    else
                        Haar_Uniq[iuniq].response[j][i][iChns] = sum1[iChns]/count1;
                }                
            }
        }

  }
    delete sum1,sum2; 
}

float *rect_interp(int c, int r,int width, int height, int feature_length,int nChns)
// this function extract feature values for a local detection window from the big feature map
{
    float *chns1 = new float[feature_length];
    int index =0,i,j,iflt,ichn,type;
//     mexPrintf("c=%d\t r=%d\n",c,r);
    for(iflt = 0;iflt<nUniq;iflt++)
    {
        for (i =0;i<=width-Haar_Uniq[iflt].w;i++)
        {
            for (j =0;j<=height-Haar_Uniq[iflt].h;j++)
            {
                for(ichn =0;ichn<nChns;ichn++)
                {
                    chns1[index++] = Haar_Uniq[iflt].response[j+r][i+c][ichn];
                }     
            }
        }
    }

    return chns1;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
  // get inputs
  float *chns = (float*) mxGetData(prhs[0]);
  mxArray *trees = (mxArray*) prhs[1];
  const int shrink = (int) mxGetScalar(prhs[2]);
  const int modelHt = (int) mxGetScalar(prhs[3]);
  const int modelWd = (int) mxGetScalar(prhs[4]);
  const int stride = (int) mxGetScalar(prhs[5]);
  const float cascThr = (float) mxGetScalar(prhs[6]);
  const int nchc = (int) mxGetScalar(prhs[7]);
  
  // extract relevant fields from trees
  float *thrs = (float*) mxGetData(mxGetField(trees,0,"thrs"));

  float *hs = (float*) mxGetData(mxGetField(trees,0,"hs"));
  
  uint32 *fids = (uint32*) mxGetData(mxGetField(trees,0,"fids"));
  uint32 *child = (uint32*) mxGetData(mxGetField(trees,0,"child"));
  const int treeDepth = mxGetField(trees,0,"treeDepth")==NULL ? 0 :
    (int) mxGetScalar(mxGetField(trees,0,"treeDepth"));

  // get dimensions and constants
  const mwSize *chnsSize = mxGetDimensions(prhs[0]);
  const int height = (int) chnsSize[0];
  const int width = (int) chnsSize[1];
  const int nChns = mxGetNumberOfDimensions(prhs[0])<=2 ? 1 : (int) chnsSize[2];
  const mwSize *fidsSize = mxGetDimensions(mxGetField(trees,0,"fids"));
  const int nTreeNodes = (int) fidsSize[0];
  const int nTrees = (int) fidsSize[1];
  
  const int height1 = (int) ceil(float(height*shrink-modelHt+1)/stride);
  const int width1 = (int) ceil(float(width*shrink-modelWd+1)/stride);

  // construct cids array
//   int nFtrs = modelHt/shrink*modelWd/shrink*nChns;
//   uint32 *cids = new uint32[nFtrs]; 
  int m=0;
//   for( int z=0; z<nChns; z++ )
//     for( int c=0; c<modelWd/shrink; c++ )
//       for( int r=0; r<modelHt/shrink; r++ )
//         cids[m++] = z*width*height + c*height + r;
  
  // length of haar filters
  int flen[nUniq];
  int nhaarh[nUniq];
  int nhaarw[nUniq];
  int feature_length = 0;
  for(int iuniq = 0;iuniq<nUniq;iuniq++)
  {     
        flen[iuniq] = (modelWd/shrink - Haar_Uniq[iuniq].w+1) * (modelHt/shrink-Haar_Uniq[iuniq].h + 1);
        nhaarh[iuniq] = (height) - Haar_Uniq[iuniq].h +1;
        nhaarw[iuniq] = (width) - Haar_Uniq[iuniq].w +1;
        feature_length +=flen[iuniq];
  }
  feature_length *=nChns;
  // apply classifier to each patch
  vector<int> rs, cs; vector<float> hs1;
  response_image(chns,nChns,width,height, feature_length,nhaarh,nhaarw);   

  for( int c=0; c<width1; c++ ) for( int r=0; r<height1; r++ ) {     
    float h=0,*chns1;

  chns1 =rect_interp(c, r,modelWd/shrink,modelHt/shrink,feature_length,nChns);
    
    
    if( treeDepth==1 ) {
      // specialized case for treeDepth==1
      for( int t = 0; t < nTrees; t++ ) {
        uint32 offset=t*nTreeNodes, k=offset, k0=0;
        getChild(chns1,fids,thrs,offset,k0,k);
        h += hs[k]; if( h<=cascThr ) break;
      }
    } else if( treeDepth==2 ) {
      // specialized case for treeDepth==2
      for( int t = 0; t < nTrees; t++ ) {         
        uint32 offset=t*nTreeNodes, k=offset, k0=0;       
        getChild(chns1,fids,thrs,offset,k0,k);
        getChild(chns1,fids,thrs,offset,k0,k);        
        h += hs[k]; 
        if( h<=cascThr ) break;
      }
    } else if( treeDepth>2) {
      // specialized case for treeDepth>2
      for( int t = 0; t < nTrees; t++ ) {
        uint32 offset=t*nTreeNodes, k=offset, k0=0;
        for( int i=0; i<treeDepth; i++ )
          getChild(chns1,fids,thrs,offset,k0,k);
        h += hs[k]; if( h<=cascThr ) break;
      }
    } else {
      // general case (variable tree depth)
      for( int t = 0; t < nTrees; t++ ) {
        uint32 offset=t*nTreeNodes, k=offset, k0=k;
        while( child[k] ) {
          float ftr = chns1[fids[k]];
          k = (ftr<thrs[k]) ? 1 : 0;
          k0 = k = child[k0]-k+offset;
        }
        
        h += hs[k]; if( h<=cascThr ) break;
      }
    }
    delete chns1;
    if(h>cascThr) { cs.push_back(c); rs.push_back(r); hs1.push_back(h); }
  }
  m=cs.size();
  // convert to bbs
  plhs[0] = mxCreateNumericMatrix(m,5,mxDOUBLE_CLASS,mxREAL);
  double *bbs = (double*) mxGetData(plhs[0]);
  for( int i=0; i<m; i++ ) {
    bbs[i+0*m]=cs[i]*stride; bbs[i+2*m]=modelWd;
    bbs[i+1*m]=rs[i]*stride; bbs[i+3*m]=modelHt;
    bbs[i+4*m]=hs1[i];
  }
}
