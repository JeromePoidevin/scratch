
public class Triangle {
	private Point a,b,c;
	private float ab,bc,ca;
	Triangle( float ax, float ay, float bx, float by, float cx, float cy) {
		a = new Point(ax,ay) ;
		b = new Point(bx,by) ;
		c = new Point(cx,cy) ;
		ab = a.dist(b) ;
		bc = b.dist(c) ;
		ca = c.dist(a) ;
	}
	float perimetre() { return ab+bc+ca ; }
	boolean isocele() { return (ab==bc)||(bc==ca)||(ca==ab) ; }
}
