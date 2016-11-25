import java.util.Arrays ;
import java.util.Random ;
import java.awt.* ;
import javax.swing.* ;


class Oval extends JPanel {
	Oval() {
    	setBackground(Color.WHITE);
    	setPreferredSize(new Dimension(200, 150));	
	}
	public void paintComponent(Graphics g){
	    super.paintComponent(g);
	    g.setColor(Color.RED);
	    g.drawOval(50,20,100,100); 
	}
 }


class Graph extends JPanel {
	int[] a = Median.table;
	int[] b = Median.median;
	int scale = 40;
	Graph() {
    	setBackground(Color.WHITE);
    	setPreferredSize(new Dimension(10*scale,10*scale));	
	}
	void drawOneGraph (Graphics g, int[] data) {
		int oldy=0;
	    for (int i=0;i<data.length;i++) {
	    	int x=i*scale;
	    	int y=data[i]*scale;
	    	g.drawLine(x,oldy,x,y);
	        g.drawLine(x,y,x+scale,y);
	        oldy=y;
	    }
	}
	public void paintComponent(Graphics g){
	    super.paintComponent(g);
        g.setColor(Color.GREEN);
        drawOneGraph(g,a);
        g.setColor(Color.BLUE);
        drawOneGraph(g,b);
	}
 }

class Median {

    static int[] table = new int[10] ;
    static int[] median = new int[10] ;

    public static void main(String[] arg) {

        // init table with Random

        Random alea = new Random(System.currentTimeMillis()) ;

        for (int i=0;i<table.length;i++) {
            table[i]= alea.nextInt(10) ;
        }
        System.out.println( Arrays.toString(table) ) ;

        // pick median values 3 by 3 using Arrays.sort

        for (int i=1;(i<table.length-1);i++) {
           int [] sort3 = { table[i-1] , table[i] , table[i+1] } ;
           Arrays.sort( sort3 ) ;
           median[i] = sort3[1] ;
           System.out.printf( "%d  %d  %d : %d\n" , table[i-1] , table[i] , table[i+1] , median[i] ) ;
        }
        System.out.println( Arrays.toString(median) ) ;

        // create Frame + Panel + Graphics
        
        JFrame cadre = new JFrame() ;
        JPanel ardoise = new Graph() ;
        cadre.setVisible(true) ;
        cadre.setContentPane(ardoise) ;
        cadre.pack() ;
        cadre.setLocation(100,100) ;
    }

}

