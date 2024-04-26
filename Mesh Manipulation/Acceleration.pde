import java.util.List;

public class Acceleration extends Shape{
    List<Shape> shapes;
    Cell[][][] grid;
    PVector cellDimension;
    int[] resolution;



    public Acceleration(Surface surface, List<Shape> shapes)
    {
        super(surface);
        this.shapes = shapes;
        this.bbox = getBoundingBox();
        buildGrid();
    }

    public void buildGrid()
    {
        resolution = new int[3];
        float[] size =  bbox.max.copy().sub(bbox.min).array();

        float cubeRoot = (float) Math.cbrt(shapes.size() / (size[0] * size[1] * size[2]));



        for (int i = 0; i < 3; ++i) {
            resolution[i] = (int) Math.floor(size[i] * cubeRoot);
            if(resolution[i] < 1) resolution[i] = 1;
            else if(resolution[i] > 128) resolution[i] = 128;
        }

        cellDimension = new PVector(size[0] / resolution[0], size[1] / resolution[1], size[2] / resolution[2]);


        this.grid = new Cell[(int)resolution[0]][(int)resolution[1]][(int)resolution[2]];



        for(Shape shape: shapes)
        {
            Box aabb = shape.bbox;
            PVector min = aabb.min.copy().sub(bbox.min);
            PVector max = aabb.max.copy().sub(bbox.min);

            min.x /= cellDimension.x;
            min.y /= cellDimension.y;
            min.z /= cellDimension.z;

            max.x /= cellDimension.x;
            max.y /= cellDimension.y;
            max.z /= cellDimension.z;

            min.x = Math.max(0, Math.min(min.x,  (float)(resolution[0] - 1)));
            min.y = Math.max(0, Math.min(min.y, (float)(resolution[1] - 1)));
            min.z = Math.max(0, Math.min(min.z, (float)(resolution[2] - 1)));

            max.x = Math.max(0.0f, Math.min(max.x, (float)(resolution[0] - 1)));
            max.y = Math.max(0.0f, Math.min(max.y, (float)(resolution[1] - 1)));
            max.z = Math.max(0.0f, Math.min(max.z, (float)(resolution[2] - 1)));




            for(int z = (int) min.z; z <= max.z; z++)
            {
                for(int y = (int) min.y; y <= max.y; y++)
                {
                    for(int x = (int) min.x; x <= max.x; x++)
                    {
                        if(grid[x][y][z] == null) grid[x][y][z] = new Cell();

                        grid[x][y][z].shapes.add(shape);
                    }
                }
            }

        }


    }
    @Override
    public Shape copyClass() {
        return this;
    }

    @Override
    public Hit getIntersection(Ray ray, boolean debug) {

        Hit hit  = bbox.getIntersection(ray, debug);
        if(hit == null) return null;

        int[] pos = new int[3], step = new int[3];
        float[] deltaT = new float[3], out = new float[3], nextCrossingT = new float[3];
        float[] origin = ray.origin.array(), direction = ray.direction.array(), hitOrigin = hit.vertex.array();

        for(int i = 0; i< 3; i++)
        {
            float tHitBox = (hitOrigin[i] - origin[i])/direction[i];
            float entryCell = hitOrigin[i] - bbox.min.array()[i];

            pos[i] = (int)Math.max(0, Math.min(Math.floor(entryCell/cellDimension.array()[i]), resolution[i] - 1));

            if(direction[i] < 0)
            {
                deltaT[i] = -cellDimension.array()[i] / direction[i];
                nextCrossingT[i] = tHitBox + (pos[i] * cellDimension.array()[i] - entryCell)/ direction[i];
                out[i] = -1;
                step[i] = -1;
            }
            else {
                deltaT[i] = cellDimension.array()[i] / direction[i];
                nextCrossingT[i] = tHitBox + (((pos[i] + 1) * cellDimension.array()[i] - entryCell)/ direction[i]);
                out[i] = resolution[i];
                step[i] = 1;
            }
        }



        Hit closestHit = null;

        while(true)
        {
            var cell = grid[pos[0]][pos[1]][pos[2]];

            if(cell != null)
            {
                closestHit = cell.getHitDetails(ray, false);
            }
            if(closestHit != null)
            {
                break;
            }
            int stepAxis = 0;

            if(nextCrossingT[0] < nextCrossingT[1] && nextCrossingT[0] < nextCrossingT[2])stepAxis = 0;
            else if(nextCrossingT[1] < nextCrossingT[2]) stepAxis = 1;
            else stepAxis = 2;

            pos[stepAxis]+= step[stepAxis];
            if(pos[stepAxis] == out[stepAxis]) break;
            nextCrossingT[stepAxis] += deltaT[stepAxis];
        }

        return closestHit;
    }


    @Override
    public Box getBoundingBox() {
        PVector min = shapes.get(0).bbox.min.copy();
        PVector max = shapes.get(0).bbox.max.copy();

        for (Shape shape : shapes) {
            min.x = Math.min(min.x, shape.bbox.min.x);
            max.x = Math.max(max.x, shape.bbox.max.x);

            min.y = Math.min(min.y,  shape.bbox.min.y);
            max.y = Math.max(max.y, shape.bbox.max.y);

            min.z = Math.min(min.z, shape.bbox.min.z);
            max.z = Math.max(max.z, shape.bbox.max.z);
        }

        return new Box(min, max, this.surface);
    }




}
