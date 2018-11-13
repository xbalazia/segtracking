#include "mex.h"
//#include "stdafx.h"
#include "math.h"
#include "matrix.h"
#include <cstdio>
#include <cstdlib>

//Entry Function: The name should always be 'mexFunction'
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
	//Get the Input data
	//The image data
	double*	ubuff = mxGetPr(prhs[0]);
    int	ncellh = mxGetScalar(prhs[1]);
    int	ncellw = mxGetScalar(prhs[2]);
    int	nch = mxGetScalar(prhs[3]);
    int	shrink = mxGetScalar(prhs[4]);

	//Get some infomation of the image
	const mwSize *dims = mxGetDimensions( prhs[0] );
    const int pixNum = dims[0] *dims[1];
	
	//Initialize the output data
    const mwSize dims_out[]={ncellh,ncellw,nch};
    plhs[0] = (mxArray *)mxCreateNumericArray(3,dims_out, mxDOUBLE_CLASS, mxREAL);// mxCreateNumericArray(2,dims, mxINT16_CLASS, mxREAL);
	double* pOut_feature = mxGetPr(plhs[0]);

	//Convert the image to the 1 dimention array
	//Be ware the matrix in matlab is indexed along the collomn 
	int x,y,ich,i,j,icellh,icellw,index,index_out;
    double value;
    for(i=0;i<ncellh*ncellw*nch;i++)
        pOut_feature[i] =0;
	int height = ncellh*shrink;
	int width = ncellw*shrink;
    int ncell = ncellh*ncellw;

	for (y = 0; y < height; y++) 
	{
		for (x = 0; x < width; x++) 
		{
            icellh = (y/shrink);
            icellw =(x/shrink);
            
            index = x*dims[0] + y;
            for (ich =0; ich<nch;ich++)
            {
                value = ubuff[pixNum*ich + index];
                index_out = icellh+icellw*ncellh + ich*ncell;                
                pOut_feature[index_out] += value;
            }
            
		}
	}
 }		
