import java.awt.*;
import javax.swing.*;
import java.awt.event.*;

class Ardoise extends JPanel {
	int heure = 1;
	int taille;

	Ardoise(int taille) {
		this.taille = taille;
		setBackground(Color.blue);
		Font font = new Font("Arial", Font.PLAIN, taille);
		setFont(font);
	}

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		g.drawString(Long.toString(heure), getWidth()/2 - taille, getHeight()/2);
	}
}

public class Compteur extends JApplet implements ActionListener {
	// Container interieur;
	Timer timer;
	Ardoise ardoise;

	public void init() {
		ardoise = new Ardoise(Integer.parseInt(getParameter("taille")));
		setContentPane(ardoise);
		timer = new Timer(1000, this);
	}

	public void start() {
		timer.restart();
	}

	public void stop() {
		timer.stop();
	}

	public void actionPerformed(ActionEvent e) {
		ardoise.heure++;
		ardoise.repaint();
	}
}
