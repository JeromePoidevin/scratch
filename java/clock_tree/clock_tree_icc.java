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
        Matcher m ;
        Pattern reRoot = Pattern.compile( "Printing structure within exceptions of (.*) at root pin" ) ;
        Pattern reTreeStructure = Pattern.compile( " *.([0-9]+). (.*?)" ) ;
        ArrayList<CTSNode> hier = new ArrayList<>() ;

        while ( (line=readbuf.readLine()) != null )
        {
            // clock declaration
            m = reRoot.matcher(line) ;
            if (m.find())
            {
                clk = m.group(1) ;
                CTSNode CLK = new CTSNode( clk , CTS ) ;
                hier.clear() ;
                hier.add( CLK ) ;
                continue ;
            }

            if (clk=="") continue ;

            // line matches tree structure
            m = reTreeStructure.matcher(line) ;
            if (! m.find()) continue ;

            int level = Integer.parseInt(m.group(1)) ;
            String inst = m.group(2) ;

            // test level and hier
            if (level <= (hier.size()-1))  // step up in hier
                for (int i=hier.size()-1 ;  i>level ; i--)
                    hier.remove(i);
            CTSNode UP = hier.get( hier.size()-1 ) ;
            CTSNode CURRENT = new CTSNode( line , UP ) ;
            hier.add( CURRENT ) ;

            if (debug)
                System.out.println( "\nUP = "+UP+"\nCURRENT = "+CURRENT );
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
