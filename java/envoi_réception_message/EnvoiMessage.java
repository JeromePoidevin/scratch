import java.net.*;
import java.io.*;

class EnvoiMessage {
	public static void main(String[] arg) {
		int portDestinataire;
		InetAddress adresseIP;
		DatagramSocket socketUDP;
		DatagramPacket message;
		BufferedReader entree;
		String ligne;
		int longueur;
		byte[] tampon;

		try {
			socketUDP = new DatagramSocket();
			System.out.println("Port local : " + socketUDP.getLocalPort());
			adresseIP = InetAddress.getByName(arg[0]);
			portDestinataire = Integer.parseInt(arg[1]);
			entree = new BufferedReader(new InputStreamReader(System.in));

			while(true) {
				ligne = entree.readLine();

				// on construit le paquet à envoyer
				tampon = ligne.getBytes();
				longueur = tampon.length;
				message = new DatagramPacket(tampon, longueur, adresseIP, portDestinataire);
				socketUDP.send(message);

				// on attend un accusé de réception
				tampon = new byte[256];
				message = new DatagramPacket(tampon, tampon.length);
				socketUDP.receive(message);
				ligne = new String(tampon);
				ligne = ligne.substring(0, message.getLength());
				System.out.println(
						"Du port " + message.getPort()
						+	" de la machine " + message.getAddress().getHostName()
						+ " : " + ligne);
			}
		}
		catch(ArrayIndexOutOfBoundsException exc) {
			System.out.println("Avez-vous donne le nom de la machine destinatrice et le numero de port du client ?");
		}
		catch(UnknownHostException exc) {
			System.out.println("Destinataire inconnu");
		}
		catch(SocketException exc) {
			System.out.println("Probleme d'ouverture de la socket");
		}
		catch(IOException exc) {
			System.out.println("Probleme sur la reception ou l'envoi du message");
		}
		catch(NumberFormatException exc) {
			System.out.println("Le second argument doit etre un entier");
		}
	}
}
