
public abstract class Shape {
    public Surface surface;
    public Box bbox;


    public Shape(Surface surface)
    {
        this.surface = surface;
    }


    public abstract Shape copyClass();

    public abstract Hit getIntersection(Ray ray, boolean debug);

    public abstract Box getBoundingBox();

}
