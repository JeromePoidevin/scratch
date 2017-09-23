/*******************************************
 * Completez le programme a partir d'ici.
 *******************************************/

abstract class Navire {
	private int x,y,drapeau ;
	private boolean detruit ;
	Navire (int x, int y, int drapeau) {
		this.x=x ; this.y=y ; this.drapeau=drapeau ;
		limiteXY() ;
	}
	private void limiteXY() {
		if (x>Piraterie.MAX_X) { x=Piraterie.MAX_X ; }
		if (y>Piraterie.MAX_Y) { y=Piraterie.MAX_Y ; }
		if (x<0) { x=0 ; }
		if (y<0) { y=0 ; }
	}
	public int getX() { return x ; }
	public int getY() { return y ; }
	public int getDrapeau() { return drapeau ; }
	public String getNom() { return "Bateau" ; }
	public boolean estPacifique() { return true ; }
	public boolean estDetruit() { return detruit ; }
	public boolean estEndommage() { return false ; }	
	public String getEtat() {
		if (estDetruit()) { return "detruit" ; }
		else if (estEndommage()) { return "ayant subi des dommages" ; }
		else { return "intact" ; }
	}
	public String toString() {
		return getNom() + " avec drapeau " + getDrapeau()
				+ " en (" + getX() + "," + getY() +") -> " + getEtat() ;
	}
	public double distance( Navire o ) {
		return Math.sqrt( (x-o.x)*(x-o.x) + (y-o.y)*(y-o.y) ) ;
	}
	public void avance(int dx, int dy) {
		x += dx ; y+= dy ;
		limiteXY() ;
	}
	public void coule() { detruit = true ; }
	public void rencontre(Navire o) {
		if (drapeau==o.drapeau) { return ; }
		if (distance(o)>Piraterie.RAYON_RENCONTRE) { return ; }
		combat(o) ;
	}
	public abstract void combat(Navire o) ;
	public abstract void recoitBoulet() ;
}

class Pirate extends Navire {
	private boolean endommage ;
	Pirate(int x, int y, int drapeau, boolean endommage) {
		super(x,y,drapeau) ;
		this.endommage = endommage ;		
	}
	public String getNom() { return "Bateau pirate" ; }
	public boolean estPacifique() { return false ; }
	public boolean estEndommage() { return endommage ; }
	public String toString() { return super.toString() ; }
	public void combat(Navire o) {
		//System.out.println( "combat : "+this+" <> "+o) ;
		o.recoitBoulet() ;
		if (!o.estPacifique()) { this.recoitBoulet() ; }
	}
	public void recoitBoulet() {
		if (estEndommage()) { super.coule() ; }  // detruit
		else                { endommage = true ; }
	}
}

class Marchand extends Navire {
	Marchand(int x, int y, int drapeau) {
		super(x,y,drapeau) ;
	}
	public String getNom() { return "Bateau marchand" ; }
	public String toString() { return super.toString() ; }
	public void combat(Navire o) {
		//System.out.println( "combat : "+this+" <> "+o) ;
		if (!o.estPacifique()) { this.recoitBoulet() ; }
	}
	public void recoitBoulet() { super.coule() ; }
}

/*******************************************
 * Ne pas modifier apres cette ligne
 * pour pr'eserver les fonctionnalit'es et
 * le jeu de test fourni.
 * Votre programme sera test'e avec d'autres
 * donn'ees.
 *******************************************/
class Piraterie {

    static public final int MAX_X = 500;
    static public final int MAX_Y = 500;
    static public final double RAYON_RENCONTRE = 10;

    static public void main(String[] args) {

    	Navire p = new Pirate(502, 510,34,false) ;
    	System.out.println(p);
    	
    	// Test de la partie 1
        System.out.println("***Test de la partie 1***");
        System.out.println();
        // un bateau pirate 0,0 avec le drapeau 1 et avec dommages
        Navire ship1 = new Pirate(0, 0, 1, true);
        // un bateau marchand en 25,0 avec le drapeau 2
        Navire ship2 = new Marchand(25, 0, 2);
        System.out.println(ship1);
        System.out.println(ship2);
        System.out.println("Distance: " + ship1.distance(ship2));
        System.out.println("Quelques deplacements horizontaux et verticaux");
        // se deplace de 75 unites a droite et 100 en haut
        ship1.avance(75, 100);
        System.out.println(ship1);
        System.out.println(ship2);
        System.out.println("Un deplacement en bas:");
        ship1.avance(0, -5);
        System.out.println(ship1);
        ship1.coule();
        ship2.coule();
        System.out.println("Apres destruction:");
        System.out.println(ship1);
        System.out.println(ship2);

        // Test de la partie 2
        System.out.println();
        System.out.println("***Test de la partie 2***");
        System.out.println();

        // deux vaisseaux sont enemis s'ils ont des drapeaux differents

        System.out.println("Bateau pirate et marchand ennemis (trop loins):");
        // bateau pirate intact
        ship1 = new Pirate(0, 0, 1, false);
        ship2 = new Marchand(0, 25, 2);
        System.out.println(ship1);
        System.out.println(ship2);
        ship1.rencontre(ship2);
        System.out.println("Apres la rencontre:");
        System.out.println(ship1);
        System.out.println(ship2);
        System.out.println();

        System.out.println("Bateau pirate et marchand ennemis (proches):");
        // bateau pirate intact
        ship1 = new Pirate(0, 0, 1, false);
        ship2 = new Marchand(2, 0, 2);
        System.out.println(ship1);
        System.out.println(ship2);
        ship1.rencontre(ship2);
        System.out.println("Apres la rencontre:");
        System.out.println(ship1);
        System.out.println(ship2);
        System.out.println();

        System.out.println("Bateau pirate et marchand amis (proches):");
        // bateau pirate intact
        ship1 = new Pirate(0, 0, 1, false);
        ship2 = new Marchand(2, 0, 1);
        System.out.println(ship1);
        System.out.println(ship2);
        ship1.rencontre(ship2);
        System.out.println("Apres la rencontre:");
        System.out.println(ship1);
        System.out.println(ship2);
        System.out.println();

        System.out.println("Deux bateaux pirates ennemis intacts (proches):");
        // bateaux pirates intacts
        ship1 = new Pirate(0, 0, 1, false);
        ship2 = new Pirate(2, 0, 2, false);
        System.out.println(ship1);
        System.out.println(ship2);
        ship1.rencontre(ship2);
        System.out.println("Apres la rencontre:");
        System.out.println(ship1);
        System.out.println(ship2);
        System.out.println();

        System.out.println("Un bateau pirate intact et un avec dommages, ennemis:");
        // bateau pirate intact
        Navire ship3 = new Pirate(0, 2, 3, false);
        System.out.println(ship1);
        System.out.println(ship3);
        ship3.rencontre(ship1);
        System.out.println("Apres la rencontre:");
        System.out.println(ship1);
        System.out.println(ship3);
        System.out.println();

        System.out.println("Deux bateaux pirates ennemis avec dommages:");
        System.out.println(ship2);
        System.out.println(ship3);
        ship3.rencontre(ship2);
        System.out.println("Apres la rencontre:");
        System.out.println(ship2);
        System.out.println(ship3);
        System.out.println();
    }
}
