package gui;

import java.awt.Color;
import java.awt.Graphics;

public class Instance {

    static boolean debug = true;
    
    String name;
    int x, y;
    
    Instance(String name, int x, int y) {
        this.name = name;
        this.x = x;
        this.y = y;
        if (debug) System.out.println(this);
    }

    public String toString() {
        return String.format("Instance ( %d , %d ) %s" , x, y, name);
    }
    
    public void draw_point(Graphics g, Color c) {
        g.setColor(c);
        g.drawRect(x-1,y-1,2,2);        
    }

    public void draw_point(Graphics g) {
        draw_point( g, Color.black ); // specialize method draw()
    }

}
