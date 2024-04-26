public class Surface {
    public Color colour;

    public Surface(Color colour)
    {
        this.colour = colour;
    }

    public Surface copyClass()
    {
        Surface copy = new Surface(new Color(this.colour.r, this.colour.g, this.colour.b));
        return copy;
    }
}
