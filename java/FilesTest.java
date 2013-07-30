
import java.io.* ;


class FilesTest
{
    public static void main ( String[] args )
    {
        // java 7
        try ( Reader flux_fichier = new FileReader( "README" ) )
        {
            // java 6
            //Reader flux_fichier = new FileReader( "README" ) ;

            // BufferedReader
            Reader flux_buf = new BufferedReader(flux_fichier) ;

            // PipedReader
            PipedWriter pw = new PipedWriter();
            PipedReader pr = new PipedReader(pw);

            int c,d;
            for ( c=0 ; c!=-1 ; c=flux_fichier.read() )
            {
                pw.write(c) ;
                d = pr.read() ;
                System.out.print( (char)c ) ;
                System.out.print( (char)d ) ;
            }
        }
        catch (IOException ex)
        {
            System.out.println("failed to open README") ;
        }

    }
    
}

