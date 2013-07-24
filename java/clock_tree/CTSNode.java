import java.util.* ;
import java.util.regex.Matcher ;
import java.util.regex.Pattern ;



/**
 * quite general class for n-trees
 *
 * self.up = one parent
 * self.down = many children
 * self.show = show or hide
 *
 * self.fanout = number of direct children
 * self.cone = number of all cells below
 * self.ff = number of sink pins
 */

public class CTSNode {

    // class
    public static Boolean debug = false ;
    private static int number = 0 ;

    // instances
    String name ;
    Integer n, level ;
    Boolean show, highlight ;
    CTSNode up ;
    ArrayList<CTSNode> down ;
    Object gui ; // FIXME pointer to gui object
    Integer fanout, cone, ff ;
   
    public CTSNode (String name, CTSNode up, int level) {
	number += 1 ;
	this.n = number ;
        this.name = name ;
	this.attach(up,level) ;
        this.up = up ;
        this.down = new ArrayList<CTSNode>() ;
	this.show = true ;
	this.highlight = false ;
	// pointer to gui object
	this.gui = null ;
	// custom additional attributes for statistics
	this.fanout = 0 ;
	this.cone = 0 ;
	this.ff = 0 ;
    }

    public CTSNode (String name, CTSNode up) {
	this(name,up,0) ;
    }

    public void attach(CTSNode up, Integer level) {
        if (up==null)
            this.level = level ;
        else {
            this.level = up.level + 1 ;
            up.down.add(this) ;
        }
    }

    public String toString () {
        if (debug)
            return n+" # "+level+" # "+name+" : "+show+" "+highlight+" : "+down.size()+" : "+fanout+" "+cone+" "+ff ;
	else
            return name+" : "+down.size()+" : "+fanout+" "+cone+" "+ff ;
    }

    public void print_tree () {
        if (!show) return ;
        String blank = "" ;
        for (int i=0 ; i<level ; i++ ) blank += " " ;
        System.out.println( blank + this ) ;
        for (CTSNode d : this.down)
            d.print_tree() ;
    }

    public void show_hide_below (boolean show) {
        this.show = show ;
        for (CTSNode d : this.down)
            d.show_hide_below(show) ;
    }

// main

    public static void main(String args[]) {

        debug = false ;

        CTSNode TOP = new CTSNode("TOP",null) ;
        CTSNode clk = new CTSNode("clk",TOP) ;
        String letters = "abcdefghijklmnopqrstuvwxyz" ;
        String digits = "123" ;
        for (int i=0 ; i<letters.length() ; i++) {
            String letter = letters.substring(i,i+1) ;
            CTSNode l = new CTSNode(letter,clk);
            for (int j=0 ; j<digits.length() ; j++) {
                String digit = digits.substring(j,j+1) ;
                new CTSNode(letter+digit,l) ;
            }
        }

        debug = true ;

        System.out.println( "\n==== full tree ====" ) ;
        TOP.print_tree() ;

    }
}

