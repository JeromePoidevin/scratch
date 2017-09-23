/*******************************************
 * Completez le programme a partir d'ici.
 *******************************************/
import java.util.ArrayList;


class Vehicule {
	private String nom ;
	private double vitesse ;
	private int poids ;
	private int carburant ;
	
	Vehicule () { nom="Anonyme" ; vitesse=130 ; poids=1000 ; carburant=0 ; }
	Vehicule ( String nom , double vitesse , int poids , int carburant ) {
		this.nom = nom ;
		this.vitesse = vitesse ;
		this.poids = poids ;
		this.carburant = carburant ;
	}
	String getNom() { return nom ; }
	double getVitesseMax() { return vitesse ; }
	int getPoids() { return poids ; }
	int getCarburant() { return carburant ; }
	public String toString() {
		return nom+" -> vitesse max = "+vitesse+" km/h, poids = "+poids+" kg" ;
	}
	double performance() { return vitesse/poids ; }
	boolean meilleur(Vehicule autre) { return this.performance()>=autre.performance() ; }
	boolean estDeuxRoues() { return false ; }
}

class Voiture extends Vehicule {
	private String categorie ;
	Voiture() { super() ; categorie = "tourisme" ; }
	Voiture ( String nom , double vitesse , int poids , int carburant ) {
		super(nom,vitesse,poids,carburant) ; categorie = "tourisme" ;
	}
	Voiture ( String nom , double vitesse , int poids , int carburant, String categorie ) {
		super(nom,vitesse,poids,carburant) ; this.categorie = categorie ;
	}
	public String getCategorie() { return categorie ; }
	public String toString() {
		return super.toString()+", Voiture de "+categorie ;
	}
	boolean estDeuxRoues() { return false ; }
}

class Moto extends Vehicule {
	private boolean sidecar ;
	Moto() { super() ; sidecar = false ; }
	Moto ( String nom , double vitesse , int poids , int carburant ) {
		super(nom,vitesse,poids,carburant) ; sidecar = false ;
	}
	Moto ( String nom , double vitesse , int poids , int carburant, boolean sidecar ) {
		super(nom,vitesse,poids,carburant) ; this.sidecar = sidecar ;
	}
	public String toString() {
		return super.toString()+", Moto"+(sidecar ? ", avec sidecar" : "" ) ;
	}
	boolean estDeuxRoues() { return ! sidecar ; }
}

abstract class Rallye {
	abstract boolean check() ;
}

class GrandPrix extends Rallye {
	private ArrayList<Vehicule> liste ;
	GrandPrix() { liste = new ArrayList<Vehicule> () ; }
	void ajouter(Vehicule v) { liste.add(v) ; }
	boolean check() {
		int deuxRoues = 0 ;
		int autres = 0 ;
		for (Vehicule vehicule : liste) {
			if (vehicule.estDeuxRoues()) { deuxRoues++ ; }
			else { autres++ ; }
		}
		return (deuxRoues==0 || autres==0) ;
	}
	void run ( int tours ) {
		
		if ( !check() ) { System.out.println("Pas de Grand Prix") ; return ; }
		
		ArrayList<Vehicule> arrivee = new ArrayList<Vehicule> () ;
		for (Vehicule vehicule : liste) {
			if (vehicule.getCarburant() > tours) { arrivee.add(vehicule) ; }
		}
		if (arrivee.isEmpty()) { System.out.println("Elimination de tous les vehicules") ; return ; }
		
		Vehicule meilleur = new Vehicule() ;
		for (Vehicule vehicule : arrivee) {
			if ( vehicule.performance() >= meilleur.performance() ) { meilleur = vehicule ; }
		}
		System.out.println( "Le gagnant du grand prix est ->\n" + meilleur ) ;
		
	}
}


/*******************************************
 * Ne pas modifier apres cette ligne
 * pour pr'eserver les fonctionnalit'es et
 * le jeu de test fourni.
 * Votre programme sera test'e avec d'autres
 * donn'ees.
 *******************************************/
public class Course {

    public static void main(String[] args) {

        // PARTIE 1
        System.out.println("Test partie 1 : ");
        System.out.println("----------------");
        Vehicule v0 = new Vehicule();
        System.out.println(v0);

        // les arguments du constructeurs sont dans l'ordre:
        // le nom, la vitesse, le poids, le carburant
        Vehicule v1 = new Vehicule("Ferrari", 300.0, 800, 30);
        Vehicule v2 = new Vehicule("Renault Clio", 180.0, 1000, 20);
        System.out.println();
        System.out.println(v1);
        System.out.println();
        System.out.println(v2);

        if (v1.meilleur(v2)) {
            System.out.println("Le premier vehicule est meilleur que le second");
        } else {
            System.out.println("Le second vehicule est meilleur que le premier");
        }
        // FIN PARTIE 1

        // PARTIE2
        System.out.println();
        System.out.println("Test partie 2 : ");
        System.out.println("----------------");

        // les trois premiers arguments sont dans l'ordre:
        // le nom, la vitesse, le poids, le carburant
        // le dernier argument indique la presence d'un sidecar
        Moto m1 = new Moto("Honda", 200.0, 250, 15, true);
        Moto m2 = new Moto("Kawasaki", 280.0, 180, 10);
        System.out.println(m1);
        System.out.println();
        System.out.println(m2);
        System.out.println();

        // les trois premiers arguments sont dans l'ordre:
        // le nom, la vitesse, le poids, le carburant
        // le dernier argument indique la categorie
        Voiture vt1 = new Voiture("Lamborghini", 320, 1200, 40, "course");
        Voiture vt2 = new Voiture("BMW", 190, 2000, 35, "tourisme");
        System.out.println(vt1);
        System.out.println();
        System.out.println(vt2);
        System.out.println();
        // FIN PARTIE 2

        // PARTIE 3
        System.out.println();
        System.out.println("Test partie 3 : ");
        System.out.println("----------------");

        GrandPrix gp1 = new GrandPrix();
        gp1.ajouter(v1);
        gp1.ajouter(v2);
        System.out.println(gp1.check());

        GrandPrix gp2 = new GrandPrix();
        gp2.ajouter(vt1);
        gp2.ajouter(vt2);
        gp2.ajouter(m2);
        System.out.println(gp2.check());

        GrandPrix gp3 = new GrandPrix();
        gp3.ajouter(vt1);
        gp3.ajouter(vt2);
        gp3.ajouter(m1);
        System.out.println(gp3.check());

        GrandPrix gp4 = new GrandPrix();
        gp4.ajouter(m1);
        gp4.ajouter(m2);
        System.out.println(gp4.check());
        // FIN PARTIE 3

        // PARTIE 4
        System.out.println();
        System.out.println("Test partie 4 : ");
        System.out.println("----------------");
        GrandPrix gp5 = new GrandPrix();
        gp5.ajouter(vt1);
        gp5.ajouter(vt2);

        System.out.println("Premiere course :");
        gp5.run(11);
        System.out.println();

        System.out.println("Deuxieme  course :");
        gp3.run(40);
        System.out.println();

        System.out.println("Troisieme  course :");
        gp2.run(11);
        // FIN PARTIE 4
    }

}
