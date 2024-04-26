import java.util.Arrays;

public class InstanceShape extends Shape{

    public Shape shape;
    float[][] transform, inverseTransform;

    public InstanceShape(Shape shape, Surface surface, float[][] transform)
    {
        super(surface);
//        super(surface.copyClass());
        this.shape = shape.copyClass();
        this.shape.surface = surface;

        this.transform = copyMatrix(transform);
        this.inverseTransform = inverse(this.transform);

    }


    @Override
    public Shape copyClass() {
        return null;
    }

    @Override
    public Hit getIntersection(Ray ray, boolean debug) {
        float[][] rayOrigin = convertVectorToMatrix(ray.origin, 1f);
        float[][] rayDir = convertVectorToMatrix(ray.direction, 0f);

        rayOrigin = multiply(this.inverseTransform, rayOrigin);
        rayDir = multiply(this.inverseTransform, rayDir);


        Hit hit = shape.getIntersection(new Ray(convertMatrixToVector(rayOrigin), convertMatrixToVector(rayDir)), debug);

        if(hit != null)
        {
            hit.vertex = convertMatrixToVector(multiply(this.transform, convertVectorToMatrix(hit.vertex, 1f)));
            hit.normal = convertMatrixToVector(multiply(transpose(this.inverseTransform), convertVectorToMatrix(hit.normal, 0f)));
        }
        /*
        multiple inverse with ray.origin then multiply result by ray . direction ka 4th val is 0 everywhere else 1
        shape.getIntersection();
        multiply hit point with transform hit
        and normal ko inverse ke transpose se. normal ka 4th point is zero.
         */

        //
        return hit;
    }

    @Override
    public Box getBoundingBox() {
        return this.shape.getBoundingBox();
    }

    public float[][] copyMatrix(float[][] mat)
    {
        int m = mat.length, n = mat[0].length;
        float[][] res = new float[m][n];
        for(int i = 0; i< m; i++)
        {
            res[i] = Arrays.copyOf(mat[i], mat[i].length);
        }
        return res;
    }
    private float[][] inverse(float[][] matrix)
    {
        float[][] inverse = null;
        var PMatrix3D = new PMatrix3D(matrix[0][0], matrix[0][1], matrix[0][2], matrix[0][3],
            matrix[1][0],matrix[1][1], matrix[1][2], matrix[1][3],
            matrix[2][0], matrix[2][1], matrix[2][2], matrix[2][3],
            matrix[3][0], matrix[3][1], matrix[3][2], matrix[3][3]);

        boolean res = PMatrix3D.invert();
        if(res)
        {
            inverse = new float[][]{{PMatrix3D.m00, PMatrix3D.m01, PMatrix3D.m02, PMatrix3D.m03},
                                    {PMatrix3D.m10, PMatrix3D.m11, PMatrix3D.m12, PMatrix3D.m13},
                                    {PMatrix3D.m20, PMatrix3D.m21, PMatrix3D.m22, PMatrix3D.m23},
                                    {PMatrix3D.m30, PMatrix3D.m31, PMatrix3D.m32, PMatrix3D.m33}};
        }


        return inverse;
    }

    private float[][] transpose(float[][] matrix)
    {
        var PMatrix3D = new PMatrix3D(matrix[0][0], matrix[0][1], matrix[0][2], matrix[0][3],
                matrix[1][0],matrix[1][1], matrix[1][2], matrix[1][3],
                matrix[2][0], matrix[2][1], matrix[2][2], matrix[2][3],
                matrix[3][0], matrix[3][1], matrix[3][2], matrix[3][3]);

        PMatrix3D.transpose();
        float[][] transpose = new float[][]{{PMatrix3D.m00, PMatrix3D.m01, PMatrix3D.m02, PMatrix3D.m03},
                {PMatrix3D.m10, PMatrix3D.m11, PMatrix3D.m12, PMatrix3D.m13},
                {PMatrix3D.m20, PMatrix3D.m21, PMatrix3D.m22, PMatrix3D.m23},
                {PMatrix3D.m30, PMatrix3D.m31, PMatrix3D.m32, PMatrix3D.m33}};

        return transpose;

    }

    private float[][] convertVectorToMatrix(PVector vector, float optional)
    {
        return new float[][]{{vector.x}, {vector.y}, {vector.z}, {optional}};
    }

    private PVector convertMatrixToVector(float[][] res)
    {
        return new PVector(res[0][0], res[1][0], res[2][0]);
    }

    public float[][] multiply(float[][] mat1, float[][] mat2)
    {
        int r1 = mat1.length;
        int c1 = mat1[0].length;
        int c2 = mat2[0].length;

        float[][] result = new float[r1][c2];

        for (int i = 0; i < r1; i++) {
            for (int j = 0; j < c2; j++) {
                for (int k = 0; k < c1; k++) {
                    result[i][j] += mat1[i][k] * mat2[k][j];
                }
            }
        }

        return result;

    }

}
