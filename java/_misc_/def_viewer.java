
import javax.swing.* ;
import java.awt.* ;
import java.util.HashMap ;

class MainFrame extends JComponent
{
    @Override
    public void paintComponent(Graphics g)
    {
        g.setColor(Color.white) ;
        g.fillRect(0,0,getWidth(),getHeight() ) ;
        def_viewer.draw(g) ;        
    }

    @Override
    public Dimension getPreferredSize()
    {
        return new Dimension(330,250) ;
    }

}

class Inst
{
    int x,y ;
    int sx,sy ;
    String name ;
    
    public Inst(String name, int x, int y)
    {
        this.name = name ;
        this.x = x ; this.y = y ;
        this.sx = 2 ; this.sy = 2 ;
    }
    public Inst(String name, int x, int y, int sx, int sy)
    {
        this.name = name ;
        this.x = x ; this.y = y ;
        this.sx = sx ; this.sy = sy ;
    }
    public void draw(Graphics g, Color c, boolean draw_name)
    {
        g.setColor(c) ;
        g.fillRect(this.x,this.y,this.sx,this.sy) ;
        g.setColor(Color.black) ;
        g.drawRect(this.x,this.y,this.sx,this.sy) ;
        if ( draw_name ) g.drawString(this.name,this.x,this.y) ;
    }
}

class def_viewer
{
    static HashMap<String,Inst> inst = new HashMap<String,Inst>() ;
    
    public static void main(String[] args)
    {
        inst.put("A",new Inst("A",100,100,150,120)) ;
        inst.put("B",new Inst("B",100,40,25,15)) ;
        
        JFrame fenetre = new JFrame("def_viewer") ;
        fenetre.add( new MainFrame() ) ;
        fenetre.pack() ;
        fenetre.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE) ;
        fenetre.setVisible(true) ;
    }
    
    public static void draw(Graphics g)
    {
        inst.get("A").draw(g,Color.blue,false) ;
        inst.get("B").draw(g,Color.green,true) ;
    }
}

