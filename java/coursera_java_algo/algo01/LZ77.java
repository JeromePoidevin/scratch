// Ces squelettes sont a completer et sont la  uniquement pour prevenir des
// erreurs de compilation.
class Element {
  Element (Occurrence e, int s) {}
}

class Occurrence {
	int retour;
	int taille;
	Occurrence (int retour, int taille) {
		this.retour = retour;
		this.taille = taille;
	}
	public String toString() { return taille+" "+retour ; }
}

class LZ77 {
	
	static boolean debug = false;
	
	static String extraitTableau( int[] t, int position, int taille) {
		StringBuilder extrait = new StringBuilder() ;
		for (int i=position ; i<position+taille ; i++) { extrait.append( t[i] ) ; }
		return extrait.toString() ;
	}
	
	public static Occurrence plusLongueOccurrence(
			int[] t,
			int positionCourante,
			int tailleFenetre
			) {
		int tailleMax = Math.min(positionCourante,tailleFenetre);
		int debutRecherche = Math.max(0, positionCourante - tailleMax);
		
		if (debug) System.out.println( "\n  cherche "+tailleMax+" : "+extraitTableau(t,positionCourante,tailleMax) ) ;

		Occurrence trouvee = new Occurrence(0,0);
		for (int i=debutRecherche ; i<positionCourante ; i++) {
			int j;
			for (j=0 ; j<tailleMax ; j++) {
				if ( i+j >= positionCourante ) break ;
				if ( t[i+j] != t[positionCourante+j] ) break ;
			}
			if ( j>trouvee.taille ) {
				trouvee.taille = j;
				trouvee.retour = positionCourante - i;
				if (debug) System.out.println( "  trouve "+j+" : "+extraitTableau(t,i,j)+" "+t[i+j] ) ;
			}
		}
		
		return trouvee;
	}
	
}