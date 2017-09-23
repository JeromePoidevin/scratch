
public class Geometrie {

	public static void main(String[] args) {
		Triangle T1 = new Triangle(0,0,0,1,1,0) ;
		Triangle T2 = new Triangle(0,0,0,1,2,0) ;
		System.out.println( "T1 : " + T1.perimetre() + " : " + T1.isocele() ) ;
		System.out.println( "T2 : " + T2.perimetre() + " : " + T2.isocele() ) ;
	}

}
