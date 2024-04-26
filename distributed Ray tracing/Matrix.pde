float[][] mat_mult(float[][] mat1, float[][] mat2)
{
  float[][] mat = new float[4][4];
  
  for(int i = 0; i< 4; i++)
  {
    for(int j = 0; j< 4; j++)
    {
      for(int k = 0 ; k< 4; k++)
      {
        mat[i][j] += mat1[i][k] * mat2[k][j];
      }
    }
  }
  
  return mat;
}

float[][] scale_mat(PVector v)
{
  float[][] mat = new float[][]{{v.x, 0, 0, 0} , {0, v.y, 0, 0}, {0, 0, v.z, 0}, {0, 0, 0, 1}};
  return mat;
}

float[][] rotate_mat(float angle , PVector v)
{
  float[][] mat = new float[][]{{1, 0, 0, 0} , {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
  
  float c = cos(angle), s = sin(angle);
  
  if(v.x == 1)
  {
    mat[1][1] = c;
    mat[1][2] = -s;
    mat[2][1] = s;
    mat[2][2] = c;
  }
  else if(v.y == 1)
  {
    mat[0][0] = c;
    mat[0][2] = s;
    mat[2][0] = -s;
    mat[2][2] = c;
  }
  else if(v.z == 1)
  {
    mat[0][0] = c;
    mat[0][1] = -s;
    mat[1][0] = s;
    mat[1][1] = c;
  }
  
  return mat;
}

float [][] translate_mat(PVector tr){
  float[][] tr_matrix = new float[][]{{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}};
  tr_matrix[0][3] = tr.x;
  tr_matrix[1][3] = tr.y;
  tr_matrix[2][3] = tr.z;
  
  return tr_matrix;
}

PVector mat_vect_mult(PMatrix3D C, PVector v)
{
  PVector res = new PVector(C.m00 * v.x + C.m01 * v.y + C.m02 * v.z + C.m03,
                            C.m10 * v.x + C.m11 * v.y + C.m12 * v.z + C.m13,
                            C.m20 * v.x + C.m21 * v.y + C.m22 * v.z + C.m23);
                                    
  return res;
}
