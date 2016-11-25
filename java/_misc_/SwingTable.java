import javax.swing.* ;
import java.awt.* ;
import java.util.* ;

class SwingTable
{
    public static void main(String [] args)
    {
        JFrame fenetre = new JFrame("JTable in BorderLayout");
        fenetre.setLayout(new BorderLayout(2,2));

        // datalist : static vs ArrayList

        String [] title = { "aa" , "bb" , "cc" } ;

        /*
        Object [][] data = {
            { "1" , "one" , "un" } ,
            { "2" , "two" , "deux" } ,
            { "3" , "three" , "trois" }
        } ;
        */

        ArrayList <String []> data = new ArrayList <String []> ();
        String[] a = { "1" , "one" , "un" } ; data.add(a);
        String[] b = { "2" , "two" , "deux" } ; data.add(b) ;
        String[] c = { "3" , "three" , "trois" } ; data.add(c) ;
 
        Object [][] dataobj = new Object [data.size()] [3] ;
        for (int i=0 ; i<data.size() ; i++ )
            dataobj[i] = data.get(i) ;

        JTable table = new JTable( dataobj , title ) ;

        fenetre.add( new JScrollPane( table ) ) ; // fenetre layout : default center

        fenetre.pack();
        fenetre.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        fenetre.setVisible(true);
    }

}

