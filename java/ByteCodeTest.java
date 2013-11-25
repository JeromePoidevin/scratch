
public class ByteCodeTest {

    public static void main(String args[]) {

        int i = 5 ;
        float f = (float) 5.0 ;
        
        int [] itab = new int[4] ;
        float [] ftab = new float[4] ;

        itab[1] = 11 ;
        ftab[2] = 12 ;

        final int [] iconst = {4,3,2,1} ;
        final float [] fconst = {8,7,6,5} ;

        itab = iconst ;
        ftab = fconst ;

        for (i=1;i<4;i++) { itab[i]*=3 ; ftab[i]*=5 ; }
    }
}

