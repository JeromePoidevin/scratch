package gui;

import java.awt.Color;
import java.awt.Graphics;

public class MacroInst extends Instance {

    //super// static boolean debug = true;
    
    //super// String name;
    //super// int x, y;
    int x1, y1, dx, dy;
    
    public MacroInst(String name, int x, int y, int dx, int dy) {
        super( name, x+(dx/2) , y+(dy/2) );
        this.x1 = x  ; this.y1 = y;
        this.dx = dx ; this.dy = dy;
        //super// if (debug) System.out.println(this);
    }

    public String toString() {
        return String.format("MacroInst ( %d , %d ) %s" , x, y, name);
    }
    
    public void draw_bbox(Graphics g, Color c) {
        g.setColor(c);
        g.fillRect(x1,y1,dx,dy);
        g.setColor(Color.black);
        g.drawRect(x1,y1,dx,dy);        
    }

}
