import java.util.ArrayList;
import java.util.Random;

/*******************************************
 * Completez le programme à partir d'ici.
 *******************************************/
class Postulant {
	private String nom ;
	private int votes ;
	Postulant (String nom) {
		this.nom = nom ; this.votes = 0 ;
	}
	public void elect() { votes++ ; }
	public void init() { votes=0 ; }
	public String getNom() { return nom ; }
	public int getVotes() { return votes ; }
}

class Scrutin {
	ArrayList<Postulant> candidats ;
	int jour ;
	int nombreElecteurs ;
	int nombreVotants ;
	Scrutin( ArrayList<Postulant> candidats , int nombreElecteurs , int jour ) {
		this.candidats = candidats ;
		this.jour = jour ;
		this.nombreElecteurs = nombreElecteurs ;
	}
	void calculerVotants() {
		nombreVotants=0 ;
		for ( Postulant c : candidats ) {
			nombreVotants += c.getVotes() ;
		}
	}
	void init() {
		for ( Postulant c : candidats ) { c.init() ; }
	}
	void resultats() {
		calculerVotants() ;
		double participation = 100.0 * nombreVotants / nombreElecteurs ;
		System.out.println( "Taux de participation -> " + participation + " pour cent" ) ;
		System.out.println( "Nombre effectif de votants -> " + nombreVotants ) ;
		
		String chef="" ;
		int score=0 ;
		for ( Postulant c : candidats ) {
			if ( c.getVotes() > score ) { chef = c.getNom() ; score = c.getVotes() ; }
		}
		System.out.println( "Le chef choisi est -> " + chef ) ;
		System.out.println( "\nRepartition des electeurs" ) ; 
		for ( Postulant c : candidats ) {
			double pct = 100.0 * c.getVotes() / nombreVotants ;
			System.out.println( c.getNom() + " -> " + pct + " pour cent des electeurs" ) ;
		}
		System.out.println() ;
	}
	void simuler (double d, int i) {} ;
	void compterVotes() {} ;
}

class Vote {
	
}


/*******************************************
 * Ne pas modifier les parties fournies
 * pour pr'eserver les fonctionnalit'es et
 * le jeu de test fourni.
 * Votre programme sera test'e avec d'autres
 * donn'ees.
 *******************************************/

class Utils {

    private static final Random RANDOM = new Random();

    // NE PAS UTILISER CETTE METHODE DANS LES PARTIES A COMPLETER
    public static void setSeed(long seed) {
        RANDOM.setSeed(seed);
    }

    // génère un entier entre 0 et max (max non compris)
    public static int randomInt(int max) {
        return RANDOM.nextInt(max);
    }
}

/**
 * Classe pour tester la simulation
 */

class Votation {

    public static void main(String args[]) {
        // TEST 1
        System.out.println("Test partie I:");
        System.out.println("--------------");

        ArrayList<Postulant> postulants = new ArrayList<Postulant>();
        postulants.add(new Postulant("Tarek Oxlama"));
        postulants.add(new Postulant("Nicolai Tarcozi"));
        postulants.add(new Postulant("Vlad Imirboutine"));
        postulants.add(new Postulant("Angel Anerckjel"));

        postulants.get(0).elect();
        postulants.get(0).elect();

        postulants.get(1).elect();
        postulants.get(1).elect();
        postulants.get(1).elect();

        postulants.get(2).elect();

        postulants.get(3).elect();
        postulants.get(3).elect();
        postulants.get(3).elect();
        postulants.get(3).elect();

        // 30 -> nombre maximal de votants
        // 15 jour du scrutin
        Scrutin scrutin = new Scrutin(postulants, 30, 15);
        scrutin.calculerVotants();
        scrutin.resultats();

        // FIN TEST 1

        // TEST 2
        System.out.println("Test partie II:");
        System.out.println("---------------");

        scrutin = new Scrutin(postulants, 30, 15);
        scrutin.init();
        // tous les bulletins passent le check de la date
        // les parametres de simuler sont dans l'ordre:
        // le pourcentage de votants et le jour du vote
        scrutin.simuler(0.75, 12);
        scrutin.compterVotes();
        scrutin.resultats();

        scrutin = new Scrutin(postulants, 30, 15);
        scrutin.init();
        // seuls les bulletins papier passent
        scrutin.simuler(0.75, 15);
        scrutin.compterVotes();
        scrutin.resultats();

        scrutin = new Scrutin(postulants, 30, 15);
        scrutin.init();
        // les bulletins electroniques ne passent pas
        scrutin.simuler(0.75, 15);
        scrutin.compterVotes();
        scrutin.resultats();
        //FIN TEST 2

    }
}
