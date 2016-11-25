package gui;

import java.awt.* ;
import java.awt.event.* ;
import java.util.* ;

public class def_viewer extends Frame {
    
    LinkedHashMap<String,MacroInst> floorplan;
    LinkedHashMap<String,Instance> inst;
    
    public def_viewer(int x, int y){
        super("DEF viewers");
        setSize(x,y);
        addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent windowEvent){
                System .exit(0);
            }
        });
        floorplan.put( "i1" , new MacroInst("i1",100, 150, 200,100) );
        floorplan.put( "i2" , new MacroInst("i2",200, 250, 200,100) );
        inst.put( "i3" , new Instance("i3",100, 350) );
        inst.put( "i4" , new Instance("i4",400, 150) );
    }
    
    @ Override
    public void paint(Graphics g) {
        
        for ( String i : floorplan.keySet() )
        {
            floorplan.get(i).draw_bbox(g,Color.gray);
        }
        
        for ( String i : inst.keySet() )
        {
            inst.get(i).draw_point(g);
        }
        
        Font font = new Font("Serif", Font.PLAIN, 24);
        g.setFont(font);
        g.drawString("Test", 50, 70);
    }
    
    public static void main(String[] args){
        def_viewer awt_example = new def_viewer(500,500);
        awt_example.setVisible(true);
    }
    
}
