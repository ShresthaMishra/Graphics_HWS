import java.util.*;

public class Box extends Shape{
    public PVector min, max;

    public Box(PVector min, PVector max, Surface surface)
    {
        super(surface);
        this.min = min;
        this.max = max;
        this.bbox = getBoundingBox();
    }

    @Override
    public Shape copyClass()
    {
        Box box = new Box(this.min.copy(), this.max.copy(), this.surface.copyClass());

        return box;
    }

    public Hit getIntersection(Ray ray, boolean debug)
    {
        var t1 = new Pair((min.x - ray.origin.x)/ray.direction.x, new PVector(-1, 0, 0));
        var t2 = new Pair((max.x - ray.origin.x)/ray.direction.x, new PVector(1, 0, 0));

        var t3= new Pair((min.y - ray.origin.y)/ray.direction.y, new PVector(0, -1, 0));
        var t4= new Pair((max.y - ray.origin.y)/ray.direction.y, new PVector(0, 1, 0));

        var t5 = new Pair((min.z - ray.origin.z)/ray.direction.z, new PVector(0, 0, -1));
        var t6 = new Pair((max.z - ray.origin.z)/ray.direction.z, new PVector(0, 0, 1));


        Pair tmin = max(max(min(t1, t2), min(t3, t4)), min(t5, t6));
        Pair tmax = min(min(max(t1, t2), max(t3, t4)), max(t5, t6));
        Pair t = null;
        if(debug)
        {
            System.out.println("tmax" + " " + tmax);
            System.out.println("tmim" + " " + tmin);
        }


        if(tmax.getKey() < 0 || tmin.getKey() > tmax.getKey()) return null;
        else{
            if(tmin.getKey() < 0)
            {
                t = tmax;
            }
            else {
                t = tmin;
            }
            PVector pt = PVector.add(ray.origin, PVector.mult(ray.direction, t.getKey()));
            return new Hit(pt, t.getValue(), this);
        }

    }

    @Override
    public Box getBoundingBox() {
        return this;
    }

    public Pair min(Pair t1, Pair t2)
    {
        if(t1.getKey() < t2.getKey()) return t1;
        return t2;
    }
    public Pair max(Pair t1, Pair t2)
    {
        if(t1.getKey() > t2.getKey()) return t1;
        return t2;
    }
}

 class Pair extends AbstractMap.SimpleEntry<Float, PVector>{

    public Pair(Float key, PVector val)
    {
        super(key, val);
    }
}
