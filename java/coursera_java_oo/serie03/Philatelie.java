import java.util.ArrayList;

class Timbre {

    public static final int ANNEE_COURANTE = 2014;
    public static final int VALEUR_TIMBRE_DEFAUT = 1;
    public static final String PAYS_DEFAUT = "Suisse";
    public static final String CODE_DEFAUT = "lambda";

    public static final int BASE_1_EXEMPLAIRES = 100;
    public static final int BASE_2_EXEMPLAIRES = 1000;
    public static final double PRIX_BASE_1 = 600;
    public static final double PRIX_BASE_2 = 400;
    public static final double PRIX_BASE_3 = 50;

    /*******************************************
     * Completez le programme a partir d'ici.
     *******************************************/
    private String code = CODE_DEFAUT ;
    private int annee = ANNEE_COURANTE ;
    private String pays = PAYS_DEFAUT ;
    private double valeur = VALEUR_TIMBRE_DEFAUT ;
    
    Timbre(String code, int annee, String pays, double valeur) {
    	this.code = code ; this.annee = annee ;
    	this.pays = pays ; this.valeur = valeur ;
    }
    Timbre(String code, int annee, String pays) {
    	this.code = code ; this.annee = annee ;
    	this.pays = pays ;
    }
    Timbre(String code, int annee) {
    	this.code = code ; this.annee = annee ;
    }
    Timbre(String code) { this.code = code ; }
    Timbre() {}

    public int age() { return ANNEE_COURANTE - annee ; }
    public double vente() {
    	int age = age() ;
    	if (age<5) { return valeur ; }
    	else { return valeur * age * 2.5 ; }
    }
    public String toString() {
    	return "Timbre de code "+code+" datant de "+annee+" (provenance "+pays+")"
    			+ " ayant pour valeur faciale "+valeur+" francs" ;
    }
    public String getCode() {return code ; }
    public int getAnnee() {return annee ; }
    public String getPays() {return pays ; }
    public double getValeurFaciale() {return valeur ; }
}


class Rare extends Timbre {
	private int exemplaires ;
    Rare(String code, int annee, String pays, double valeur, int exemplaires) {
    	super(code,annee,pays,valeur) ;	this.exemplaires = exemplaires ;
    }
    Rare(String code, int annee, String pays, int exemplaires) {
    	super(code,annee,pays) ; this.exemplaires = exemplaires ;
    }
    Rare(String code, int annee, int exemplaires) {
    	super(code,annee) ; this.exemplaires = exemplaires ;
    }
    Rare(String code, int exemplaires) {
    	super(code) ; this.exemplaires = exemplaires ;
    }
    Rare(int exemplaires) {
    	super() ; this.exemplaires = exemplaires ;
    }
    public double vente() {
    	double prixBase ;
    	if      (exemplaires<BASE_1_EXEMPLAIRES) { prixBase = PRIX_BASE_1 ; }
    	else if (exemplaires<BASE_2_EXEMPLAIRES) { prixBase = PRIX_BASE_2 ; }
    	else                                     { prixBase = PRIX_BASE_3 ; }
    	return prixBase * age() / 10.0 ;
    }
    public String toString() {
    	return super.toString()+"\n"+"Nombre d'exemplaires -> "+exemplaires ;
    }
    public int getExemplaires() {return exemplaires ; }
}


class Commemoratif extends Timbre {
	Commemoratif(String code, int annee, String pays, double valeur) { super(code,annee,pays,valeur) ; }
	Commemoratif(String code, int annee, String pays) {	super(code,annee,pays) ; }
	Commemoratif(String code, int annee) { super(code,annee) ; }
	Commemoratif(String code) {	super(code) ; }
	Commemoratif() { super() ; }
    
	public double vente() { return 2 * super.vente() ; }
    public String toString() {
    	return super.toString()+"\n"+"Timbre celebrant un evenement" ;
    }
}


/*******************************************
 * Ne rien modifier apres cette ligne.
 *******************************************/

class Philatelie {

    public static void main(String[] args) {

        // ordre des parametres: nom, annee d'emission, pays, valeur faciale,
        // nombre d'exemplaires
        Rare t1 = new Rare("Guarana-4574", 1960, "Mexique", 0.2, 98);

        // ordre des parametres: nom, annee d'emission, pays, valeur faciale
        Commemoratif t2 = new Commemoratif("700eme-501", 2002, "Suisse", 1.5);
        Timbre t3 = new Timbre("Setchuan-302", 2004, "Chine", 0.2);

        Rare t4 = new Rare("Yoddle-201", 1916, "Suisse", 0.8, 3);


        ArrayList<Timbre> collection = new ArrayList<Timbre>();

        collection.add(t1);
        collection.add(t2);
        collection.add(t3);
        collection.add(t4);

        for (Timbre timbre : collection) {
            System.out.println(timbre);
            System.out.println("Prix vente : " + timbre.vente() + " francs");
            System.out.println();
        }
    }
}

