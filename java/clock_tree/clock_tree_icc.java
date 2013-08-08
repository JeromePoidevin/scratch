import java.util.* ;
import java.util.regex.Matcher ;
import java.util.regex.Pattern ;
import java.io.* ;
//import CTSNode ;


public class clock_tree_icc {

    // class
    public static Boolean debug = false ;

    public static CTSNode read_cts_icc ( String filename ) throws Exception
    {
        FileReader readfile = new FileReader( filename ) ;
        BufferedReader readbuf = new BufferedReader( readfile ) ;

        CTSNode CTS = new CTSNode( filename , null ) ;
        String line = "" ;
        String clk = "" ;
        Pattern pRoot = Pattern.compile( "Printing structure within exceptions of (.*) at root pin" ) ;
        ArrayList<CTSNode> hier = new ArrayList<>() ;

        while ( (line=readbuf.readLine()) != null )
        {
            Matcher m = pRoot.matcher(line) ;
            if (m.find())
            {
                clk = m.group(1) ;
                CTSNode CLK = new CTSNode( clk , CTS ) ;
                hier.clear() ;
                hier.add( CLK ) ;
                continue ;
            }
            if (clk=="") continue ;
        }

        return CTS ;
    }

    public static void main( String args[] ) throws Exception
    {
        debug = true ;
        CTSNode.debug = true ;

        CTSNode TOP = read_cts_icc( "../../py/cts/clk_main.txt" ) ;
        TOP.print_tree() ;
    }

}
