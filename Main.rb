require 'socket'

BUFFER_SIZE = 1024

socket = UDPSocket.new #UDPSocket comes with Ruby
socket.bind('192.168.0.1', 4321) #4321 is TCP/UDP protocol

loop do
	message, sender = socket.recvfrom(BUFFER_SIZE)
	
	port = sender[1]
	host = sender[2]
	
	socket.send(message.upcase, 0, host, port)
end

IFREQ_SIZE= 0x0028 #IFREQ structure is found in C code for networks, we have to fake it in ruby (this isn't C)

IFINDEX_SIZE = 0x0004 #size in bytes of the ifindex field in the ifreq structure

SIOCGIFINDEX = 0x8933 #operation number

socket = Socket.open(:PACKET, :RAW)

ifreq = %w[eth0].pack("a#{IFREQ_SIZE}") #convert the interface name to bytes

socket.ioctl(SIOCGIFINDEX, ifreq) #syscall

index = ifreq[Socket::IFNAMSIZ, IFINDEX_SIZE] #get the bytes with the results

ETH_P_ALL = 0x0300 #receive every packet

SOCKADDR_LL_SIZE = 0x0014

sockaddr = [Socket::AF_PACKET].pack('s')
sockaddr << [ETH_P_ALL].pack('s')
sockaddr << index
sockaddr << ("\x00" * (SOCKADDR_LL_SIZE - sockaddr.length))

socket.bind(sockaddr) 

require 'hexdump' #we need this to decode the UDP data
BUFFER_SIZE = 1024

loop do								#continuously decodes and outputs the data we receive
	data = socket.recv(BUFFER_SIZE)	#
	Hexdump.dump(data)				      #
end									              #
