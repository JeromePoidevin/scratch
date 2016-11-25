import java.util.regex.Matcher ;
import java.util.regex.Pattern ;

public class Regex
{
    public static void main( String args[] ){

      // String to be scanned to find the pattern.
      String line = "abc 123 def 456 ghijkl 789" ;
      String pattern = "(.d.).*?(\\d+) (.*)";

      // Create a Pattern object
      Pattern r = Pattern.compile(pattern);

      // Now create matcher object.
      Matcher m = r.matcher(line);

      if (m.find( )) {
         System.out.println("group 0 :" + m.group(0) );
         System.out.println("group 1 :" + m.group(1) );
         System.out.println("group 2 :" + m.group(2) );
         System.out.println("group 3 :" + m.group(3) );
      } else {
         System.out.println("NO MATCH");
      }
   }
}

