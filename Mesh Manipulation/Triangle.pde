public class Triangle extends Shape{

    public PVector v1, v2, v3, ab, bc, ac, normal;
    float d;

    public Triangle(PVector v1, PVector v2, PVector v3, Surface surface)  {
        super(surface);
        this.v1 = v1;
        this.v2 = v2;
        this.v3 = v3;
        this.ab = PVector.sub(v2 , v1);
        this.bc = PVector.sub(v3 , v2);
        this.ac = PVector.sub(v3 , v1);
        this.normal = ab.cross(ac);
        this.d = -normal.dot(v1);
        this.bbox = getBoundingBox();
    }

    @Override
    public Shape copyClass()
    {
        Triangle triangle = new Triangle(this.v1.copy(), this.v2.copy(), this.v3.copy(), this.surface);
        return triangle;
    }
    @Override
    public Hit getIntersection(Ray ray, boolean debug) {
        var t = -(normal.dot(ray.origin) + d) / normal.dot(ray.direction);
        if (t < 0) return null;
        PVector pt = PVector.add(ray.origin, PVector.mult(ray.direction, t));

        PVector ap = PVector.sub(pt, v1);
        PVector bp = PVector.sub(pt, v2);
        PVector cp = PVector.sub(pt, v3);

        return normal.dot(ab.cross(ap)) >= 0 &&
                normal.dot(bc.cross(bp)) >= 0 &&
                normal.dot(PVector.mult(ac, -1).cross(cp)) >= 0 ? new Hit(pt, this.normal, this) : null;
    }

    @Override
    public Box getBoundingBox() {
        float minx = Math.min(Math.min(v1.x, v2.x), v3.x);
        float miny = Math.min(Math.min(v1.y, v2.y), v3.y);
        float minz = Math.min(Math.min(v1.z, v2.z), v3.z);

        float maxx = Math.max(Math.max(v1.x, v2.x), v3.x);
        float maxy = Math.max(Math.max(v1.y, v2.y), v3.y);
        float maxz = Math.max(Math.max(v1.z, v2.z), v3.z);

        PVector min = new PVector(minx, miny, minz);
        PVector max = new PVector(maxx, maxy, maxz);
        Box bbox = new Box(min, max, this.surface);

        return bbox;
    }


}
