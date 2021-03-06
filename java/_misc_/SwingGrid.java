import javax.swing.* ;
import java.awt.* ;

class SwingGrid
{
    public SwingGrid (int x,int y,String [] buttons_l)
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
        SwingGrid g1 = new SwingGrid( 3,3, buttons1 ) ;
        SwingGrid g2 = new SwingGrid( 4,2, buttons2 ) ;
    }
}

