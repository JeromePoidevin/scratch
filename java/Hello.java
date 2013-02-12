
class Hello
{
    static int n = 0 ;

    public Hello ( String name )
    {
        n++ ;
        System.out.println( "Hello "+n+" "+name );
    }

    public static void main ( String [] argv )
    {
        Hello h1 = new Hello("world") ;
        Hello h2 = new Hello("Nantes") ;
    }
}

