import java.util.*;

import java.util.ArrayList;
import java.util.List;

public class Cell {
    public List<Shape> shapes;

    public Cell()
    {
        this.shapes = new ArrayList<>();
    }


    public Hit getHitDetails(Ray ray, boolean debug)
    {
        var minDist = Float.MAX_VALUE;
        Hit hit = null;
        for(Shape shape : shapes) {
            Hit currHit = shape.getIntersection(ray, debug);
            if(currHit == null) continue;
            float dist = ray.origin.dist(currHit.vertex);
            if(dist > 0.01 && dist < minDist)
            {
                minDist = dist;
                hit = currHit;
            }
        }
        return hit;
    }
}
