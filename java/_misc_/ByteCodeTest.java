
public class ByteCodeTest {

    public static void main(String args[]) {

        int i = 5 ;
        int [] itab = new int[4] ;
        itab[1] = 11 ;
        final int [] iconst = {4,3,2,1} ;
        itab = iconst ;
        for (i=1;i<4;i++) { itab[i]*=3 ; }

        float f = (float) 5.5 ;
        float [] ftab = new float[4] ;
        ftab[2] = (float) 12.12 ;
        final float [] fconst = {8,7,6,5} ;
        ftab = fconst ;
        for (i=1;i<4;i++) { ftab[i]*=5 ; }

        String s = "a" ;
        String stab = "" ;
        final String sconst = "hello" ;
        stab = sconst ;

    }
}

