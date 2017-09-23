import java.net.*;
import java.io.*;

class ReceptionMessage {
	public static void main(String[] arg) {
		DatagramSocket socketUDP;
		DatagramPacket message;
		byte[] tampon;
		int portLocal;
		byte[] tamponAccuse = "accuse de reception".getBytes();
		int longueurAccuse = tamponAccuse.length;
		String texte ;

		try {
			portLocal = Integer.parseInt(arg[0]);
			socketUDP = new DatagramSocket(portLocal);
			while(true) {
				// on se prépare à recevoir un datagramme
				tampon = new byte[256];
				message = new DatagramPacket(tampon, tampon.length);
				socketUDP.receive(message);
				InetAddress adresseIP = message.getAddress();
				int portDistant = message.getPort();
				texte = new String(tampon) ;
				texte = texte.substring(0, message.getLength());
				System.out.println(
						"Reception du port " + portDistant
						+ " de la machine " + adresseIP.getHostName()
						+ " : " +texte);

				// On envoie un accuse de reception
				message = new DatagramPacket(tamponAccuse, longueurAccuse, adresseIP, portDistant);
				socketUDP.send(message);
			}
		}

		catch(ArrayIndexOutOfBoundsException exc) {
			System.out.println("Avez-vous donne le numero de port sur lequel vous attendez le message ?");
		}
		catch(SocketException exc) {
			System.out.println("Probleme d'ouverture du socket");
		}
		catch(IOException exc) {
			System.out.println("Probleme sur la reception ou l'envoi du message");
		}
	}
}
