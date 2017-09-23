class Souris {

    public static final int ESPERANCE_VIE_DEFAUT = 36;

    /*******************************************
     * Completez le programme a partir d'ici.
     *******************************************/
    private int poids ;
    private String couleur ;
    private int age = 0 ;
    private int esperanceVie = ESPERANCE_VIE_DEFAUT ;
    private boolean clonee = false ;
    
    public Souris ( int poids, String couleur, int age, int ev ) {
    	this.poids = poids ;
    	//this.couleur = new String(couleur) ;
    	this.couleur = couleur ;
    	this.age = age ;
    	this.esperanceVie = ev ;
    	System.out.println("Une nouvelle souris !") ;
    }
    public Souris ( int poids, String couleur, int age ) {
    	this(poids,couleur,age,ESPERANCE_VIE_DEFAUT) ;
    }
    public Souris ( int poids, String couleur ) {
    	this(poids,couleur,0,ESPERANCE_VIE_DEFAUT) ;
    }
    public Souris ( Souris autre ) {
    	poids = autre.poids ;
    	//couleur = new String(autre.couleur) ;
    	couleur = autre.couleur ;
    	age = autre.age ;
    	esperanceVie = autre.esperanceVie * 4 / 5 ;
    	clonee = true ;
    	System.out.println("Clonage d'une souris !") ;
    }
    public String toString () {
    	return "Une souris " + couleur + (clonee ? ", clonee, " : "") + " de " + age + " mois et pesant " + poids + " grammes" ;
    }
    public void vieillir() {
    	age += 1 ;
    	if (clonee && (age>esperanceVie/2) ) { couleur = "verte" ; }
    }
    public void evolue () {
    	while (age < esperanceVie) { this.vieillir() ; }
    }
}

/*******************************************
 * Ne rien modifier après cette ligne.
 *******************************************/

public class Labo {

    public static void main(String[] args) {
        Souris s1 = new Souris(50, "blanche", 2);
        Souris s2 = new Souris(45, "grise");
        Souris s3 = new Souris(s2);

        System.out.println(s1);
        System.out.println(s2);
        System.out.println(s3);
        s1.evolue();
        s2.evolue();
        s3.evolue();
        System.out.println(s1);
        System.out.println(s2);
        System.out.println(s3);
    }
}
