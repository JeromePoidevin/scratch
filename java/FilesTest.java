
import java.io.* ;


class FilesTest
{
    public static void main ( String[] args )
    {
        try {
            Reader flux_fichier = new FileReader( "README" ) ;
            Reader flux_buf = new BufferedReader(flux_fichier) ;
            int c;
            for ( c=0 ; c!=-1 ; c=flux_buf.read() )
            {
                System.out.print( (char)c ) ;
            }
        }
        catch (IOException ex)
        {
            System.out.println("failed to open README") ;
        }

    }
    
}

