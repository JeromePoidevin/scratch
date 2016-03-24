
http://www.linuxhowtos.org/C_C++/socket.htm


The socket() system call creates a new socket. It takes three arguments :
(1) address domain of the socket ; two possible address domains
    - AF_UNIX the unix domain for two processes which share a common file system 
    - AF_INET the Internet domain for any two hosts on the Internet
(2) type of socket ; two choices here
    - SOCK_STREAM stream socket in which characters are read in a continuous stream as if from a file or pipe
    - SOCK_DGRAM datagram socket, in which messages are read in chunks
(3) the protocol. If this argument is zero (and it always should be except for unusual circumstances), the operating system will choose the most appropriate protocol. It will choose TCP for stream sockets and UDP for datagram sockets.

The socket system call returns an entry into the file descriptor table (i.e. a small integer). This value is used for all subsequent references to this socket. If the socket call fails, it returns -1.


http://www.cs.virginia.edu/~cs458/material/Redbook-ibm-tcpip-Chp5.pdf

