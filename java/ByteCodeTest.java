
public class ByteCodeTest {

    public static void main(String args[]) {

        int i,j ;
        final int [] iconst = {1,2,3,4,5,6,7,8} ;
        final float [] fconst = {1,2,3,4,5,6,7,8} ;
        int [] itab = iconst ;
        float [] ftab = fconst ;

        for (i=1;i<10;i++) { System.out.println(i) ; itab[i]*=3 ; ftab[i]*=5 ; }
    }
}

