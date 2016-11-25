
public class Point {
	float x;
	float y;
	Point( float x , float y ) {
		this.x = x ; this.y = y ;
	}
	Point delta(Point other) {
		Point delta = new Point(0,0) ;
		delta.x = this.x - other.x ;
		delta.y = this.y - other.y ;
		return delta ;
	}
	float dist2(Point other) {
		Point delta = this.delta(other) ;
		return delta.x*delta.x + delta.y*delta.y ;
	}
	float dist(Point other) {
		return (float) Math.sqrt( this.dist2(other) ) ;
	}
}
