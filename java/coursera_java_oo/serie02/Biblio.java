import java.util.ArrayList;

class Auteur {

    /*******************************************
     * Completez le programme a partir d'ici.
     *******************************************/
	private String nom ;
	private boolean prix ;
	Auteur(String nom, boolean prix) {
		this.nom = nom ;
		this.prix = prix ;
	}
	String getNom() { return nom ; }
	boolean getPrix() { return prix ; }
}

class Oeuvre {
	private String titre ;
	private Auteur auteur ;
	private String langue ;
	Oeuvre(String titre, Auteur auteur, String langue) {
		this.titre = titre ;
		this.auteur = auteur ;
		this.langue = langue ;
	}
	Oeuvre(String titre, Auteur auteur) { this(titre,auteur,"francais") ; }
	String getTitre() { return titre ; }
	Auteur getAuteur() { return auteur ; }
	String getLangue() { return langue ; }
	void afficher() { System.out.println(titre+", "+auteur.getNom()+", en "+langue) ; }
}

class Exemplaire {
	private Oeuvre oeuvre ;
	Exemplaire(Oeuvre oeuvre) {
		this.oeuvre = oeuvre ;
		System.out.print("Nouvel exemplaire -> ") ;
		oeuvre.afficher() ;
	}
	Exemplaire(Exemplaire autre) {
		this.oeuvre = autre.oeuvre ;
		System.out.print("Copie d'un exemplaire de -> ") ;
		oeuvre.afficher() ;
	}
	Oeuvre getOeuvre() { return oeuvre ; }
	void afficher() {
		System.out.print("Un exemplaire de ") ;
		oeuvre.afficher();
	}
}

class Bibliotheque {
	private String nom ;
	private ArrayList<Exemplaire> exemplaires = new ArrayList<Exemplaire>() ;
	Bibliotheque( String nom ) {
		this.nom = nom ;
		System.out.println("La bibliothèque "+nom+" est ouverte !") ;
	}
	String getNom() { return nom ; }
	void stocker( Oeuvre oeuvre, int n ) {
		for (int i=0;i<n;i++) { exemplaires.add(new Exemplaire(oeuvre) ) ; }
	}
	void stocker( Oeuvre oeuvre ) { exemplaires.add(new Exemplaire(oeuvre) ) ; }
	
	ArrayList<Exemplaire> listerExemplaires(String langue) {
		if (langue=="") { return exemplaires ; }
		ArrayList<Exemplaire> trouve = new ArrayList<Exemplaire> () ;
        for (Exemplaire exemplaire : exemplaires) {
            if (exemplaire.getOeuvre().getLangue()==langue) { trouve.add(exemplaire) ; }
        }
		return trouve ;
	}
	ArrayList<Exemplaire> listerExemplaires() {	return exemplaires ; }
	
	int compterExemplaires(Oeuvre oeuvre) {
		int n = 0 ;
        for (Exemplaire exemplaire : exemplaires) {
            if (exemplaire.getOeuvre()==oeuvre) { n++ ; }
        }
		return n ;
	}
	void afficherAuteur(boolean prix) {
        for (Exemplaire exemplaire : exemplaires) {
            if (exemplaire.getOeuvre().getAuteur().getPrix()==prix) { System.out.println(exemplaire.getOeuvre().getAuteur().getNom()) ; }
        }
	}
	void afficherAuteur() { afficherAuteur(true) ; }
	
}

/*******************************************
 * Ne pas modifier apres cette ligne
 * pour pr'eserver les fonctionnalit'es et
 * le jeu de test fourni.
 * Votre programme sera test'e avec d'autres
 * donn'ees.
 *******************************************/

public class Biblio {

    public static void afficherExemplaires(ArrayList<Exemplaire> exemplaires) {
        for (Exemplaire exemplaire : exemplaires) {
            System.out.print("\t");
            exemplaire.afficher();
        }
    }

    public static void main(String[] args) {
        // create and store all the exemplaries
        Auteur a1 = new Auteur("Victor Hugo", false);
        Auteur a2 = new Auteur("Alexandre Dumas", false);
        Auteur a3 = new Auteur("Raymond Queneau", true);

        Oeuvre o1 = new Oeuvre("Les Miserables", a1, "francais");
        Oeuvre o2 = new Oeuvre("L\'Homme qui rit", a1, "francais");
        Oeuvre o3 = new Oeuvre("Le Comte de Monte-Cristo", a2, "francais");
        Oeuvre o4 = new Oeuvre("Zazie dans le metro", a3, "francais");
        Oeuvre o5 = new Oeuvre("The count of Monte-Cristo", a2, "anglais");

        Bibliotheque biblio = new Bibliotheque("municipale");
        biblio.stocker(o1, 2);
        biblio.stocker(o2);
        biblio.stocker(o3, 3);
        biblio.stocker(o4);
        biblio.stocker(o5);

        // ...
        System.out.println("La bibliotheque " + biblio.getNom() + " offre ");
        afficherExemplaires(biblio.listerExemplaires());
        String langue = "anglais";
        System.out.println("Les exemplaires en " + langue + " sont  ");
        afficherExemplaires(biblio.listerExemplaires(langue));
        System.out.println("Les auteurs a succes sont  ");
        biblio.afficherAuteur();
        System.out.print("Il y a " + biblio.compterExemplaires(o3) + " exemplaires");
        System.out.println(" de  " + o3.getTitre());
    }
}

