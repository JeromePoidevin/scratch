import java.io.*;
import java.net.*;

public class TestURL
{
    public static void main( String[] args )
    {
        try {
            URL url = new URL( args[0] );
            InputStream in = url.openStream() ;
            int size = in.available() ;
            System.out.println( "bytes available : "+size );
            byte[] t = new byte[size];
            in.read(t);
            System.out.write(t);
        }
        catch (IOException e) {
            System.out.println( "Error : "+e.getMessage()) ;
        }
    }
}

