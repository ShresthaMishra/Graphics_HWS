public class Hit {
    public PVector vertex, normal;
    public Shape shape;

    public Hit(PVector vertex, PVector normal, Shape shape)
    {
        this.vertex = vertex;
        this.normal = normal;
        this.shape = shape;
    }
}
