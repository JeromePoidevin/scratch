import javax.swing.* ;
import java.awt.* ;

class Grid
{
    public Grid (int x,int y,String [] buttons_l)
    {
        JFrame fenetre = new JFrame("Grille");
        fenetre.setLayout(new GridLayout(y,x,1,1));

        for (String b : buttons_l )
            fenetre.add(new JButton(b));

        fenetre.pack();
        fenetre.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        fenetre.setVisible(true);
    }

    public static void main(String [] args)
    {
        String [] buttons1 = {"1","2","3","4","5","6","7","8","9"};
        String [] buttons2 = {"aa","bb","cc","dd","ee","ff","gg","hh"};
        Grid g1 = new Grid( 3,3, buttons1 ) ;
        Grid g2 = new Grid( 4,2, buttons2 ) ;
    }
}

