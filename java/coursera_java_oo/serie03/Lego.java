/*******************************************
 * Completez le programme a partir d'ici.
 *******************************************/
import java.util.ArrayList;

class Piece {
	private String nom ;
	Piece (String nom) { this.nom=nom ; }
	String getNom() { return nom ; }
	public String toString() { return nom ; }
}

class Composant {
	private Piece piece ;
	private int quantite ;
	Composant (Piece p, int n) { piece=p ; quantite=n ; }
	public Piece getPiece() { return piece ; }
	public int getQuantite() { return quantite ; }
	public String toString() { return piece.toString()+" (quantite "+quantite+")" ; }
}

class Simple extends Piece {
	private String orientation ;
	Simple (String nom) { super(nom) ; this.orientation="aucune" ; }
	Simple (String nom, String orientation) {
		super(nom) ;
		switch (orientation)
		{
			case "gauche" :
			case "droit" :
			case "droite" :
				this.orientation=orientation ;
				break ;
			default :
				this.orientation="aucune" ;
		}
	}
	String getOrientation() { return orientation ; }
	public String toString() { 
		if (orientation=="aucune") { return super.toString() ; }
		else { return super.toString()+" "+orientation ; }
	}
}

class Composee extends Piece {
	private ArrayList<Piece> liste ;
	private int tailleMax ;
	Composee(String nom, int tailleMax) { super(nom) ; liste=new ArrayList<Piece>() ; this.tailleMax=tailleMax ; }
	int taille() { return liste.size() ; }
	int tailleMax() { return tailleMax ; }
	void construire(Piece p) {
		if (taille()==tailleMax) { System.out.println("Construction impossible") ; }
		else { liste.add(p) ; }
	}
	public String toString() {
		String to = super.toString() +" (" ;
		for (Piece p : liste) { to += p+"," ; }
		to = to.substring(0, to.length()-1 ) ;
		to += ")" ;
		return to ;
	}
}

class Construction {
	private ArrayList<Composant> liste ;
	private int tailleMax ;
	Construction(int tailleMax) { liste= new ArrayList<Composant>() ; this.tailleMax=tailleMax ; }
	int taille() { return liste.size() ; }
	int tailleMax() { return tailleMax ; }
	void ajouterComposant(Piece p, int q) {
		if (taille()==tailleMax) { System.out.println("Ajout de composant impossible") ; }
		else { liste.add(new Composant(p,q)) ; }
	}
	public String toString() {
		String to = "" ;
		for (Composant c : liste) { to += c+"\n" ; }
		return to ;
	}
}


/*******************************************
 * Ne pas modifier apres cette ligne
 * pour pr'eserver les fonctionnalit'es et
 * le jeu de test fourni.
 * Votre programme sera test'e avec d'autres
 * donn'ees.
 *******************************************/

class Lego {

    public static void main(String[] args) {
        // declare un jeu de construction de 10 pieces
        Construction maison = new Construction(10);

        // ce jeu a pour premier composant: 59 briques standard
        // une brique standard a par defaut "aucune" comme orientation
        maison.ajouterComposant(new Simple("brique standard"), 59);

        // declare une piece dont le nom est "porte", composee de 2 autres pieces
        Composee porte = new Composee("porte", 2);

        // cette piece composee est constituee de deux pieces simples:
        // un cadran de porte orient'e a gauche
        // un battant orient'e a gauche
        porte.construire(new Simple("cadran porte", "gauche"));
        porte.construire(new Simple("battant", "gauche"));

        // le jeu a pour second composant: 1 porte
        maison.ajouterComposant(porte, 1);

        // déclare une piece composee de 3 autres pieces dont le nom est "fenetre"
        Composee fenetre = new Composee("fenetre", 3);

        // cette piece composee est constitu'ee des trois pieces simples:
        // un cadran de fenetre (aucune orientation)
        // un volet orient'e a gauche
        // un volet orient'e a droite
        fenetre.construire(new Simple("cadran fenetre"));
        fenetre.construire(new Simple("volet", "gauche"));
        fenetre.construire(new Simple("volet", "droit"));

        // le jeu a pour troisieme composant: 2 fenetres
        maison.ajouterComposant(fenetre, 2);

        // affiche tous les composants composants (nom de la piece et quantit'e)
        // pour les pieces compos'ees : affiche aussi chaque piece les constituant
        System.out.println("Affichage du jeu de construction : ");
        System.out.println(maison);
    }
}
