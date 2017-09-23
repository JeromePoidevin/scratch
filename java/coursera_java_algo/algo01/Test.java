public class Test {

  public static void main(String[] args) {
    testRle1();
    testRle2();
    testRle3();
    testRle4();
    testLz1();
    testLz2();
    testLz3();
    testLz4();
    testLz5();
  }

  public static void testRle1() {
    /*
    System.out.printf("testRle1 ");
    for (int[] line: Data.testsRle) {
      System.out.printf("%d ", RLE.longueurRLE(line));
    }
    System.out.printf("done\n");
    */
  }

  public static void testRle2() {
    /*
    System.out.printf("testRle2 ");
    for (int[] line: Data.testsRle) {
      int[] rle = RLE.RLE(line);
      for (int i: rle)
        System.out.printf("%d ", i);
      System.out.printf("| ");
    }
    System.out.printf("done\n");
    */
  }

  public static void testRle3() {
    /*
    System.out.printf("testRle3 ");
    for (int[] line: Data.testsRleInverse) {
      System.out.printf("%d ", RLE.longueurRLEInverse(line));
    }
    System.out.printf("done\n");
    */
  }

  public static void testRle4() {
    /*
    System.out.printf("testRle4 ");
    for (int[] line: Data.testsRleInverse) {
      int[] rle = RLE.RLEInverse(line);
      for (int i: rle)
        System.out.printf("%d ", i);
      System.out.printf("| ");
    }
    System.out.printf("done\n");
    */
  }

  public static void testLz1() {
    System.out.printf("testLz1 ");
    Occurrence o;
    o = LZ77.plusLongueOccurrence(Data.testsLzOccurrence[0], 0, Data.tailleFenetre);
    System.out.printf("%d %d | ", o.taille, o.retour);
    o = LZ77.plusLongueOccurrence(Data.testsLzOccurrence[1], 0, Data.tailleFenetre);
    System.out.printf("%d %d | ", o.taille, o.retour);
    o = LZ77.plusLongueOccurrence(Data.testsLzOccurrence[2], 0, Data.tailleFenetre);
    System.out.printf("%d %d | ", o.taille, o.retour);
    o = LZ77.plusLongueOccurrence(Data.testsLzOccurrence[2], 1, Data.tailleFenetre);
    System.out.printf("%d %d | ", o.taille, o.retour);
    o = LZ77.plusLongueOccurrence(Data.testsLzOccurrence[3], 0, Data.tailleFenetre);
    System.out.printf("%d %d | ", o.taille, o.retour);
    o = LZ77.plusLongueOccurrence(Data.testsLzOccurrence[3], 2, Data.tailleFenetre);
    System.out.printf("%d %d | ", o.taille, o.retour);
    o = LZ77.plusLongueOccurrence(Data.testsLzOccurrence[4], 143, Data.tailleFenetre);
    System.out.printf("%d %d | ", o.taille, o.retour);
    o = LZ77.plusLongueOccurrence(Data.testsLzOccurrence[4], 298, Data.tailleFenetre);
    System.out.printf("%d %d | ", o.taille, o.retour);
    System.out.printf("done\n");
  }

  public static void testLz2() {
    /*
    System.out.printf("testLz2 ");
    for (int[] line: Data.testsLz)
      System.out.printf("%d ", LZ77.LZ77Longueur(line, Data.tailleFenetre));
    System.out.printf("done\n");
    */
  }

  public static void testLz3() {
    /*
    System.out.printf("testLz3 ");
    for (int[] line: Data.testsLz)
      LZ77.afficheEncode(LZ77.LZ77(line, Data.tailleFenetre));
    System.out.printf("done\n");
    */
  }

  public static void testLz4() {
    /*
    System.out.printf("testLz4 ");
    for (Element[] line: Data.testsLzInverse)
      System.out.printf("%d ", LZ77.LZ77InverseLongueur(line));
    System.out.printf("done\n");
    */
  }

  public static void testLz5() {
    /*
    System.out.printf("testLz5 ");
    for (Element[] line: Data.testsLzInverse)
      LZ77.afficheDecode(LZ77.LZ77Inverse(line));
    System.out.printf("done\n");
    */
  }

}
