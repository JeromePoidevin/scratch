import java.applet.*;
import java.awt.Graphics;

public class TestApplet extends Applet
{
    public void init() { System.out.println("INIT"); }
    public void start() { System.out.println("START"); }
    public void stop() { System.out.println("STOP"); }
    public void destroy() { System.out.println("DESTROY"); }
    public void paint( Graphics g )
    {
        System.out.println("PAINT");
        g.drawString("Hello!",20,20);
    }
}

