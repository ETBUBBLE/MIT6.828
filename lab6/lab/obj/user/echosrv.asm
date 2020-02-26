
obj/user/echosrv.debug：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 91 04 00 00       	call   8004c2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 b0 27 80 00       	push   $0x8027b0
  80003f:	e8 71 05 00 00       	call   8005b5 <cprintf>
	exit();
  800044:	e8 bf 04 00 00       	call   800508 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <handle_client>:

void
handle_client(int sock)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 30             	sub    $0x30,%esp
  800057:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005a:	6a 20                	push   $0x20
  80005c:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	56                   	push   %esi
  800061:	e8 62 14 00 00       	call   8014c8 <read>
  800066:	89 c3                	mov    %eax,%ebx
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	79 0a                	jns    800079 <handle_client+0x2b>
		die("Failed to receive initial bytes from client");
  80006f:	b8 b4 27 80 00       	mov    $0x8027b4,%eax
  800074:	e8 ba ff ff ff       	call   800033 <die>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  800079:	8d 7d c8             	lea    -0x38(%ebp),%edi
  80007c:	eb 3b                	jmp    8000b9 <handle_client+0x6b>
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	53                   	push   %ebx
  800082:	57                   	push   %edi
  800083:	56                   	push   %esi
  800084:	e8 19 15 00 00       	call   8015a2 <write>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	39 c3                	cmp    %eax,%ebx
  80008e:	74 0a                	je     80009a <handle_client+0x4c>
			die("Failed to send bytes to client");
  800090:	b8 e0 27 80 00       	mov    $0x8027e0,%eax
  800095:	e8 99 ff ff ff       	call   800033 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	6a 20                	push   $0x20
  80009f:	57                   	push   %edi
  8000a0:	56                   	push   %esi
  8000a1:	e8 22 14 00 00       	call   8014c8 <read>
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 0a                	jns    8000b9 <handle_client+0x6b>
			die("Failed to receive additional bytes from client");
  8000af:	b8 00 28 80 00       	mov    $0x802800,%eax
  8000b4:	e8 7a ff ff ff       	call   800033 <die>
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000b9:	85 db                	test   %ebx,%ebx
  8000bb:	7f c1                	jg     80007e <handle_client+0x30>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000bd:	83 ec 0c             	sub    $0xc,%esp
  8000c0:	56                   	push   %esi
  8000c1:	e8 c6 12 00 00       	call   80138c <close>
}
  8000c6:	83 c4 10             	add    $0x10,%esp
  8000c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <umain>:

void
umain(int argc, char **argv)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 40             	sub    $0x40,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000da:	6a 06                	push   $0x6
  8000dc:	6a 01                	push   $0x1
  8000de:	6a 02                	push   $0x2
  8000e0:	e8 01 1b 00 00       	call   801be6 <socket>
  8000e5:	89 c6                	mov    %eax,%esi
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	79 0a                	jns    8000f8 <umain+0x27>
		die("Failed to create socket");
  8000ee:	b8 60 27 80 00       	mov    $0x802760,%eax
  8000f3:	e8 3b ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	68 78 27 80 00       	push   $0x802778
  800100:	e8 b0 04 00 00       	call   8005b5 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800105:	83 c4 0c             	add    $0xc,%esp
  800108:	6a 10                	push   $0x10
  80010a:	6a 00                	push   $0x0
  80010c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  80010f:	53                   	push   %ebx
  800110:	e8 e9 0b 00 00       	call   800cfe <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  800115:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800120:	e8 6c 01 00 00       	call   800291 <htonl>
  800125:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800128:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80012f:	e8 43 01 00 00       	call   800277 <htons>
  800134:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800138:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  80013f:	e8 71 04 00 00       	call   8005b5 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  800144:	83 c4 0c             	add    $0xc,%esp
  800147:	6a 10                	push   $0x10
  800149:	53                   	push   %ebx
  80014a:	56                   	push   %esi
  80014b:	e8 04 1a 00 00       	call   801b54 <bind>
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	85 c0                	test   %eax,%eax
  800155:	79 0a                	jns    800161 <umain+0x90>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800157:	b8 30 28 80 00       	mov    $0x802830,%eax
  80015c:	e8 d2 fe ff ff       	call   800033 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	6a 05                	push   $0x5
  800166:	56                   	push   %esi
  800167:	e8 57 1a 00 00       	call   801bc3 <listen>
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	85 c0                	test   %eax,%eax
  800171:	79 0a                	jns    80017d <umain+0xac>
		die("Failed to listen on server socket");
  800173:	b8 54 28 80 00       	mov    $0x802854,%eax
  800178:	e8 b6 fe ff ff       	call   800033 <die>

	cprintf("bound\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 97 27 80 00       	push   $0x802797
  800185:	e8 2b 04 00 00       	call   8005b5 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  80018d:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  800190:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	57                   	push   %edi
  80019b:	8d 45 c8             	lea    -0x38(%ebp),%eax
  80019e:	50                   	push   %eax
  80019f:	56                   	push   %esi
  8001a0:	e8 78 19 00 00       	call   801b1d <accept>
  8001a5:	89 c3                	mov    %eax,%ebx
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	79 0a                	jns    8001b8 <umain+0xe7>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001ae:	b8 78 28 80 00       	mov    $0x802878,%eax
  8001b3:	e8 7b fe ff ff       	call   800033 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	ff 75 cc             	pushl  -0x34(%ebp)
  8001be:	e8 1b 00 00 00       	call   8001de <inet_ntoa>
  8001c3:	83 c4 08             	add    $0x8,%esp
  8001c6:	50                   	push   %eax
  8001c7:	68 9e 27 80 00       	push   $0x80279e
  8001cc:	e8 e4 03 00 00       	call   8005b5 <cprintf>
		handle_client(clientsock);
  8001d1:	89 1c 24             	mov    %ebx,(%esp)
  8001d4:	e8 75 fe ff ff       	call   80004e <handle_client>
	}
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb b2                	jmp    800190 <umain+0xbf>

008001de <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	57                   	push   %edi
  8001e2:	56                   	push   %esi
  8001e3:	53                   	push   %ebx
  8001e4:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001ed:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001f0:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001f7:	0f b6 0f             	movzbl (%edi),%ecx
  8001fa:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001ff:	0f b6 d9             	movzbl %cl,%ebx
  800202:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  800205:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  800208:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80020b:	66 c1 e8 0b          	shr    $0xb,%ax
  80020f:	89 c3                	mov    %eax,%ebx
  800211:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800214:	01 c0                	add    %eax,%eax
  800216:	29 c1                	sub    %eax,%ecx
  800218:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  80021a:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  80021c:	8d 72 01             	lea    0x1(%edx),%esi
  80021f:	0f b6 d2             	movzbl %dl,%edx
  800222:	83 c0 30             	add    $0x30,%eax
  800225:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800229:	89 f2                	mov    %esi,%edx
    } while(*ap);
  80022b:	84 db                	test   %bl,%bl
  80022d:	75 d0                	jne    8001ff <inet_ntoa+0x21>
  80022f:	c6 07 00             	movb   $0x0,(%edi)
  800232:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800235:	eb 0d                	jmp    800244 <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  800237:	0f b6 c2             	movzbl %dl,%eax
  80023a:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  80023f:	88 01                	mov    %al,(%ecx)
  800241:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800244:	83 ea 01             	sub    $0x1,%edx
  800247:	80 fa ff             	cmp    $0xff,%dl
  80024a:	75 eb                	jne    800237 <inet_ntoa+0x59>
  80024c:	89 f0                	mov    %esi,%eax
  80024e:	0f b6 f0             	movzbl %al,%esi
  800251:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  800254:	8d 46 01             	lea    0x1(%esi),%eax
  800257:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025a:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  80025d:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800260:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800263:	39 c7                	cmp    %eax,%edi
  800265:	75 90                	jne    8001f7 <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  800267:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  80026a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  80027a:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80027e:	66 c1 c0 08          	rol    $0x8,%ax
}
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    

00800284 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  return htons(n);
  800287:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  80028b:	66 c1 c0 08          	rol    $0x8,%ax
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  800297:	89 d1                	mov    %edx,%ecx
  800299:	c1 e1 18             	shl    $0x18,%ecx
  80029c:	89 d0                	mov    %edx,%eax
  80029e:	c1 e8 18             	shr    $0x18,%eax
  8002a1:	09 c8                	or     %ecx,%eax
  8002a3:	89 d1                	mov    %edx,%ecx
  8002a5:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002ab:	c1 e1 08             	shl    $0x8,%ecx
  8002ae:	09 c8                	or     %ecx,%eax
  8002b0:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002b6:	c1 ea 08             	shr    $0x8,%edx
  8002b9:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 20             	sub    $0x20,%esp
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002c9:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002cc:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002cf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002d2:	0f b6 ca             	movzbl %dl,%ecx
  8002d5:	83 e9 30             	sub    $0x30,%ecx
  8002d8:	83 f9 09             	cmp    $0x9,%ecx
  8002db:	0f 87 94 01 00 00    	ja     800475 <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002e1:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002e8:	83 fa 30             	cmp    $0x30,%edx
  8002eb:	75 2b                	jne    800318 <inet_aton+0x5b>
      c = *++cp;
  8002ed:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002f1:	89 d1                	mov    %edx,%ecx
  8002f3:	83 e1 df             	and    $0xffffffdf,%ecx
  8002f6:	80 f9 58             	cmp    $0x58,%cl
  8002f9:	74 0f                	je     80030a <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002fb:	83 c0 01             	add    $0x1,%eax
  8002fe:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800301:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800308:	eb 0e                	jmp    800318 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80030a:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80030e:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800311:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800318:	83 c0 01             	add    $0x1,%eax
  80031b:	be 00 00 00 00       	mov    $0x0,%esi
  800320:	eb 03                	jmp    800325 <inet_aton+0x68>
  800322:	83 c0 01             	add    $0x1,%eax
  800325:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800328:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80032b:	0f b6 fa             	movzbl %dl,%edi
  80032e:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800331:	83 f9 09             	cmp    $0x9,%ecx
  800334:	77 0d                	ja     800343 <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  800336:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  80033a:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  80033e:	0f be 10             	movsbl (%eax),%edx
  800341:	eb df                	jmp    800322 <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  800343:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  800347:	75 32                	jne    80037b <inet_aton+0xbe>
  800349:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  80034c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80034f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800352:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800358:	83 e9 41             	sub    $0x41,%ecx
  80035b:	83 f9 05             	cmp    $0x5,%ecx
  80035e:	77 1b                	ja     80037b <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800360:	c1 e6 04             	shl    $0x4,%esi
  800363:	83 c2 0a             	add    $0xa,%edx
  800366:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  80036a:	19 c9                	sbb    %ecx,%ecx
  80036c:	83 e1 20             	and    $0x20,%ecx
  80036f:	83 c1 41             	add    $0x41,%ecx
  800372:	29 ca                	sub    %ecx,%edx
  800374:	09 d6                	or     %edx,%esi
        c = *++cp;
  800376:	0f be 10             	movsbl (%eax),%edx
  800379:	eb a7                	jmp    800322 <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  80037b:	83 fa 2e             	cmp    $0x2e,%edx
  80037e:	75 23                	jne    8003a3 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800380:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800383:	8d 7d f0             	lea    -0x10(%ebp),%edi
  800386:	39 f8                	cmp    %edi,%eax
  800388:	0f 84 ee 00 00 00    	je     80047c <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  80038e:	83 c0 04             	add    $0x4,%eax
  800391:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800394:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  800397:	8d 43 01             	lea    0x1(%ebx),%eax
  80039a:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  80039e:	e9 2f ff ff ff       	jmp    8002d2 <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003a3:	85 d2                	test   %edx,%edx
  8003a5:	74 25                	je     8003cc <inet_aton+0x10f>
  8003a7:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003af:	83 f9 5f             	cmp    $0x5f,%ecx
  8003b2:	0f 87 d0 00 00 00    	ja     800488 <inet_aton+0x1cb>
  8003b8:	83 fa 20             	cmp    $0x20,%edx
  8003bb:	74 0f                	je     8003cc <inet_aton+0x10f>
  8003bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c0:	83 ea 09             	sub    $0x9,%edx
  8003c3:	83 fa 04             	cmp    $0x4,%edx
  8003c6:	0f 87 bc 00 00 00    	ja     800488 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003d2:	29 c2                	sub    %eax,%edx
  8003d4:	c1 fa 02             	sar    $0x2,%edx
  8003d7:	83 c2 01             	add    $0x1,%edx
  8003da:	83 fa 02             	cmp    $0x2,%edx
  8003dd:	74 20                	je     8003ff <inet_aton+0x142>
  8003df:	83 fa 02             	cmp    $0x2,%edx
  8003e2:	7f 0f                	jg     8003f3 <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003e9:	85 d2                	test   %edx,%edx
  8003eb:	0f 84 97 00 00 00    	je     800488 <inet_aton+0x1cb>
  8003f1:	eb 67                	jmp    80045a <inet_aton+0x19d>
  8003f3:	83 fa 03             	cmp    $0x3,%edx
  8003f6:	74 1e                	je     800416 <inet_aton+0x159>
  8003f8:	83 fa 04             	cmp    $0x4,%edx
  8003fb:	74 38                	je     800435 <inet_aton+0x178>
  8003fd:	eb 5b                	jmp    80045a <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800404:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  80040a:	77 7c                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  80040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80040f:	c1 e0 18             	shl    $0x18,%eax
  800412:	09 c6                	or     %eax,%esi
    break;
  800414:	eb 44                	jmp    80045a <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80041b:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800421:	77 65                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800423:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800426:	c1 e2 18             	shl    $0x18,%edx
  800429:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80042c:	c1 e0 10             	shl    $0x10,%eax
  80042f:	09 d0                	or     %edx,%eax
  800431:	09 c6                	or     %eax,%esi
    break;
  800433:	eb 25                	jmp    80045a <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80043a:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800440:	77 46                	ja     800488 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800445:	c1 e2 18             	shl    $0x18,%edx
  800448:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80044b:	c1 e0 10             	shl    $0x10,%eax
  80044e:	09 c2                	or     %eax,%edx
  800450:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800453:	c1 e0 08             	shl    $0x8,%eax
  800456:	09 d0                	or     %edx,%eax
  800458:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  80045a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80045e:	74 23                	je     800483 <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800460:	56                   	push   %esi
  800461:	e8 2b fe ff ff       	call   800291 <htonl>
  800466:	83 c4 04             	add    $0x4,%esp
  800469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80046c:	89 03                	mov    %eax,(%ebx)
  return (1);
  80046e:	b8 01 00 00 00       	mov    $0x1,%eax
  800473:	eb 13                	jmp    800488 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	eb 0c                	jmp    800488 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	eb 05                	jmp    800488 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  800483:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800496:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800499:	50                   	push   %eax
  80049a:	ff 75 08             	pushl  0x8(%ebp)
  80049d:	e8 1b fe ff ff       	call   8002bd <inet_aton>
  8004a2:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8004ac:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	e8 d4 fd ff ff       	call   800291 <htonl>
  8004bd:	83 c4 04             	add    $0x4,%esp
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    

008004c2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	56                   	push   %esi
  8004c6:	53                   	push   %ebx
  8004c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ca:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8004cd:	e8 ac 0a 00 00       	call   800f7e <sys_getenvid>
  8004d2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004df:	a3 18 40 80 00       	mov    %eax,0x804018

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7e 07                	jle    8004ef <libmain+0x2d>
        binaryname = argv[0];
  8004e8:	8b 06                	mov    (%esi),%eax
  8004ea:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	53                   	push   %ebx
  8004f4:	e8 d8 fb ff ff       	call   8000d1 <umain>

    // exit gracefully
    exit();
  8004f9:	e8 0a 00 00 00       	call   800508 <exit>
}
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80050e:	e8 a4 0e 00 00       	call   8013b7 <close_all>
	sys_env_destroy(0);
  800513:	83 ec 0c             	sub    $0xc,%esp
  800516:	6a 00                	push   $0x0
  800518:	e8 20 0a 00 00       	call   800f3d <sys_env_destroy>
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80052c:	8b 13                	mov    (%ebx),%edx
  80052e:	8d 42 01             	lea    0x1(%edx),%eax
  800531:	89 03                	mov    %eax,(%ebx)
  800533:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800536:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80053a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80053f:	75 1a                	jne    80055b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	68 ff 00 00 00       	push   $0xff
  800549:	8d 43 08             	lea    0x8(%ebx),%eax
  80054c:	50                   	push   %eax
  80054d:	e8 ae 09 00 00       	call   800f00 <sys_cputs>
		b->idx = 0;
  800552:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800558:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80055b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80055f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80056d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800574:	00 00 00 
	b.cnt = 0;
  800577:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80057e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800581:	ff 75 0c             	pushl  0xc(%ebp)
  800584:	ff 75 08             	pushl  0x8(%ebp)
  800587:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	68 22 05 80 00       	push   $0x800522
  800593:	e8 1a 01 00 00       	call   8006b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800598:	83 c4 08             	add    $0x8,%esp
  80059b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005a1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005a7:	50                   	push   %eax
  8005a8:	e8 53 09 00 00       	call   800f00 <sys_cputs>

	return b.cnt;
}
  8005ad:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005b3:	c9                   	leave  
  8005b4:	c3                   	ret    

008005b5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005be:	50                   	push   %eax
  8005bf:	ff 75 08             	pushl  0x8(%ebp)
  8005c2:	e8 9d ff ff ff       	call   800564 <vcprintf>
	va_end(ap);

	return cnt;
}
  8005c7:	c9                   	leave  
  8005c8:	c3                   	ret    

008005c9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	57                   	push   %edi
  8005cd:	56                   	push   %esi
  8005ce:	53                   	push   %ebx
  8005cf:	83 ec 1c             	sub    $0x1c,%esp
  8005d2:	89 c7                	mov    %eax,%edi
  8005d4:	89 d6                	mov    %edx,%esi
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005df:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ea:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005f0:	39 d3                	cmp    %edx,%ebx
  8005f2:	72 05                	jb     8005f9 <printnum+0x30>
  8005f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005f7:	77 45                	ja     80063e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005f9:	83 ec 0c             	sub    $0xc,%esp
  8005fc:	ff 75 18             	pushl  0x18(%ebp)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800605:	53                   	push   %ebx
  800606:	ff 75 10             	pushl  0x10(%ebp)
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80060f:	ff 75 e0             	pushl  -0x20(%ebp)
  800612:	ff 75 dc             	pushl  -0x24(%ebp)
  800615:	ff 75 d8             	pushl  -0x28(%ebp)
  800618:	e8 a3 1e 00 00       	call   8024c0 <__udivdi3>
  80061d:	83 c4 18             	add    $0x18,%esp
  800620:	52                   	push   %edx
  800621:	50                   	push   %eax
  800622:	89 f2                	mov    %esi,%edx
  800624:	89 f8                	mov    %edi,%eax
  800626:	e8 9e ff ff ff       	call   8005c9 <printnum>
  80062b:	83 c4 20             	add    $0x20,%esp
  80062e:	eb 18                	jmp    800648 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	ff 75 18             	pushl  0x18(%ebp)
  800637:	ff d7                	call   *%edi
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb 03                	jmp    800641 <printnum+0x78>
  80063e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800641:	83 eb 01             	sub    $0x1,%ebx
  800644:	85 db                	test   %ebx,%ebx
  800646:	7f e8                	jg     800630 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	56                   	push   %esi
  80064c:	83 ec 04             	sub    $0x4,%esp
  80064f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800652:	ff 75 e0             	pushl  -0x20(%ebp)
  800655:	ff 75 dc             	pushl  -0x24(%ebp)
  800658:	ff 75 d8             	pushl  -0x28(%ebp)
  80065b:	e8 90 1f 00 00       	call   8025f0 <__umoddi3>
  800660:	83 c4 14             	add    $0x14,%esp
  800663:	0f be 80 a5 28 80 00 	movsbl 0x8028a5(%eax),%eax
  80066a:	50                   	push   %eax
  80066b:	ff d7                	call   *%edi
}
  80066d:	83 c4 10             	add    $0x10,%esp
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80067e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800682:	8b 10                	mov    (%eax),%edx
  800684:	3b 50 04             	cmp    0x4(%eax),%edx
  800687:	73 0a                	jae    800693 <sprintputch+0x1b>
		*b->buf++ = ch;
  800689:	8d 4a 01             	lea    0x1(%edx),%ecx
  80068c:	89 08                	mov    %ecx,(%eax)
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	88 02                	mov    %al,(%edx)
}
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80069e:	50                   	push   %eax
  80069f:	ff 75 10             	pushl  0x10(%ebp)
  8006a2:	ff 75 0c             	pushl  0xc(%ebp)
  8006a5:	ff 75 08             	pushl  0x8(%ebp)
  8006a8:	e8 05 00 00 00       	call   8006b2 <vprintfmt>
	va_end(ap);
}
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	c9                   	leave  
  8006b1:	c3                   	ret    

008006b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006b2:	55                   	push   %ebp
  8006b3:	89 e5                	mov    %esp,%ebp
  8006b5:	57                   	push   %edi
  8006b6:	56                   	push   %esi
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 2c             	sub    $0x2c,%esp
  8006bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8006be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006c4:	eb 12                	jmp    8006d8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	0f 84 42 04 00 00    	je     800b10 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8006ce:	83 ec 08             	sub    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	50                   	push   %eax
  8006d3:	ff d6                	call   *%esi
  8006d5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d8:	83 c7 01             	add    $0x1,%edi
  8006db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006df:	83 f8 25             	cmp    $0x25,%eax
  8006e2:	75 e2                	jne    8006c6 <vprintfmt+0x14>
  8006e4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006e8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006f6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800702:	eb 07                	jmp    80070b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800704:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800707:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070b:	8d 47 01             	lea    0x1(%edi),%eax
  80070e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800711:	0f b6 07             	movzbl (%edi),%eax
  800714:	0f b6 d0             	movzbl %al,%edx
  800717:	83 e8 23             	sub    $0x23,%eax
  80071a:	3c 55                	cmp    $0x55,%al
  80071c:	0f 87 d3 03 00 00    	ja     800af5 <vprintfmt+0x443>
  800722:	0f b6 c0             	movzbl %al,%eax
  800725:	ff 24 85 e0 29 80 00 	jmp    *0x8029e0(,%eax,4)
  80072c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80072f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800733:	eb d6                	jmp    80070b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800735:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800738:	b8 00 00 00 00       	mov    $0x0,%eax
  80073d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800740:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800743:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800747:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80074a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80074d:	83 f9 09             	cmp    $0x9,%ecx
  800750:	77 3f                	ja     800791 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800752:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800755:	eb e9                	jmp    800740 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8b 00                	mov    (%eax),%eax
  80075c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 40 04             	lea    0x4(%eax),%eax
  800765:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800768:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80076b:	eb 2a                	jmp    800797 <vprintfmt+0xe5>
  80076d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800770:	85 c0                	test   %eax,%eax
  800772:	ba 00 00 00 00       	mov    $0x0,%edx
  800777:	0f 49 d0             	cmovns %eax,%edx
  80077a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800780:	eb 89                	jmp    80070b <vprintfmt+0x59>
  800782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800785:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80078c:	e9 7a ff ff ff       	jmp    80070b <vprintfmt+0x59>
  800791:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800794:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800797:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80079b:	0f 89 6a ff ff ff    	jns    80070b <vprintfmt+0x59>
				width = precision, precision = -1;
  8007a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007a7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8007ae:	e9 58 ff ff ff       	jmp    80070b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007b3:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007b9:	e9 4d ff ff ff       	jmp    80070b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8d 78 04             	lea    0x4(%eax),%edi
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	53                   	push   %ebx
  8007c8:	ff 30                	pushl  (%eax)
  8007ca:	ff d6                	call   *%esi
			break;
  8007cc:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007cf:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007d5:	e9 fe fe ff ff       	jmp    8006d8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 78 04             	lea    0x4(%eax),%edi
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	99                   	cltd   
  8007e3:	31 d0                	xor    %edx,%eax
  8007e5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007e7:	83 f8 0f             	cmp    $0xf,%eax
  8007ea:	7f 0b                	jg     8007f7 <vprintfmt+0x145>
  8007ec:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  8007f3:	85 d2                	test   %edx,%edx
  8007f5:	75 1b                	jne    800812 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8007f7:	50                   	push   %eax
  8007f8:	68 bd 28 80 00       	push   $0x8028bd
  8007fd:	53                   	push   %ebx
  8007fe:	56                   	push   %esi
  8007ff:	e8 91 fe ff ff       	call   800695 <printfmt>
  800804:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800807:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80080d:	e9 c6 fe ff ff       	jmp    8006d8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800812:	52                   	push   %edx
  800813:	68 75 2c 80 00       	push   $0x802c75
  800818:	53                   	push   %ebx
  800819:	56                   	push   %esi
  80081a:	e8 76 fe ff ff       	call   800695 <printfmt>
  80081f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800822:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800825:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800828:	e9 ab fe ff ff       	jmp    8006d8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	83 c0 04             	add    $0x4,%eax
  800833:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800836:	8b 45 14             	mov    0x14(%ebp),%eax
  800839:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80083b:	85 ff                	test   %edi,%edi
  80083d:	b8 b6 28 80 00       	mov    $0x8028b6,%eax
  800842:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800845:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800849:	0f 8e 94 00 00 00    	jle    8008e3 <vprintfmt+0x231>
  80084f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800853:	0f 84 98 00 00 00    	je     8008f1 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 d0             	pushl  -0x30(%ebp)
  80085f:	57                   	push   %edi
  800860:	e8 33 03 00 00       	call   800b98 <strnlen>
  800865:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800868:	29 c1                	sub    %eax,%ecx
  80086a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80086d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800870:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800874:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800877:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80087a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80087c:	eb 0f                	jmp    80088d <vprintfmt+0x1db>
					putch(padc, putdat);
  80087e:	83 ec 08             	sub    $0x8,%esp
  800881:	53                   	push   %ebx
  800882:	ff 75 e0             	pushl  -0x20(%ebp)
  800885:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800887:	83 ef 01             	sub    $0x1,%edi
  80088a:	83 c4 10             	add    $0x10,%esp
  80088d:	85 ff                	test   %edi,%edi
  80088f:	7f ed                	jg     80087e <vprintfmt+0x1cc>
  800891:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800894:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800897:	85 c9                	test   %ecx,%ecx
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
  80089e:	0f 49 c1             	cmovns %ecx,%eax
  8008a1:	29 c1                	sub    %eax,%ecx
  8008a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8008a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008ac:	89 cb                	mov    %ecx,%ebx
  8008ae:	eb 4d                	jmp    8008fd <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008b4:	74 1b                	je     8008d1 <vprintfmt+0x21f>
  8008b6:	0f be c0             	movsbl %al,%eax
  8008b9:	83 e8 20             	sub    $0x20,%eax
  8008bc:	83 f8 5e             	cmp    $0x5e,%eax
  8008bf:	76 10                	jbe    8008d1 <vprintfmt+0x21f>
					putch('?', putdat);
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	6a 3f                	push   $0x3f
  8008c9:	ff 55 08             	call   *0x8(%ebp)
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	eb 0d                	jmp    8008de <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8008d1:	83 ec 08             	sub    $0x8,%esp
  8008d4:	ff 75 0c             	pushl  0xc(%ebp)
  8008d7:	52                   	push   %edx
  8008d8:	ff 55 08             	call   *0x8(%ebp)
  8008db:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008de:	83 eb 01             	sub    $0x1,%ebx
  8008e1:	eb 1a                	jmp    8008fd <vprintfmt+0x24b>
  8008e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8008e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008ec:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008ef:	eb 0c                	jmp    8008fd <vprintfmt+0x24b>
  8008f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8008f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008fd:	83 c7 01             	add    $0x1,%edi
  800900:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800904:	0f be d0             	movsbl %al,%edx
  800907:	85 d2                	test   %edx,%edx
  800909:	74 23                	je     80092e <vprintfmt+0x27c>
  80090b:	85 f6                	test   %esi,%esi
  80090d:	78 a1                	js     8008b0 <vprintfmt+0x1fe>
  80090f:	83 ee 01             	sub    $0x1,%esi
  800912:	79 9c                	jns    8008b0 <vprintfmt+0x1fe>
  800914:	89 df                	mov    %ebx,%edi
  800916:	8b 75 08             	mov    0x8(%ebp),%esi
  800919:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80091c:	eb 18                	jmp    800936 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	53                   	push   %ebx
  800922:	6a 20                	push   $0x20
  800924:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800926:	83 ef 01             	sub    $0x1,%edi
  800929:	83 c4 10             	add    $0x10,%esp
  80092c:	eb 08                	jmp    800936 <vprintfmt+0x284>
  80092e:	89 df                	mov    %ebx,%edi
  800930:	8b 75 08             	mov    0x8(%ebp),%esi
  800933:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800936:	85 ff                	test   %edi,%edi
  800938:	7f e4                	jg     80091e <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80093a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80093d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800940:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800943:	e9 90 fd ff ff       	jmp    8006d8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800948:	83 f9 01             	cmp    $0x1,%ecx
  80094b:	7e 19                	jle    800966 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80094d:	8b 45 14             	mov    0x14(%ebp),%eax
  800950:	8b 50 04             	mov    0x4(%eax),%edx
  800953:	8b 00                	mov    (%eax),%eax
  800955:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800958:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80095b:	8b 45 14             	mov    0x14(%ebp),%eax
  80095e:	8d 40 08             	lea    0x8(%eax),%eax
  800961:	89 45 14             	mov    %eax,0x14(%ebp)
  800964:	eb 38                	jmp    80099e <vprintfmt+0x2ec>
	else if (lflag)
  800966:	85 c9                	test   %ecx,%ecx
  800968:	74 1b                	je     800985 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	8b 00                	mov    (%eax),%eax
  80096f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800972:	89 c1                	mov    %eax,%ecx
  800974:	c1 f9 1f             	sar    $0x1f,%ecx
  800977:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80097a:	8b 45 14             	mov    0x14(%ebp),%eax
  80097d:	8d 40 04             	lea    0x4(%eax),%eax
  800980:	89 45 14             	mov    %eax,0x14(%ebp)
  800983:	eb 19                	jmp    80099e <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8b 00                	mov    (%eax),%eax
  80098a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098d:	89 c1                	mov    %eax,%ecx
  80098f:	c1 f9 1f             	sar    $0x1f,%ecx
  800992:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800995:	8b 45 14             	mov    0x14(%ebp),%eax
  800998:	8d 40 04             	lea    0x4(%eax),%eax
  80099b:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80099e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8009a4:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8009a9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009ad:	0f 89 0e 01 00 00    	jns    800ac1 <vprintfmt+0x40f>
				putch('-', putdat);
  8009b3:	83 ec 08             	sub    $0x8,%esp
  8009b6:	53                   	push   %ebx
  8009b7:	6a 2d                	push   $0x2d
  8009b9:	ff d6                	call   *%esi
				num = -(long long) num;
  8009bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009be:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009c1:	f7 da                	neg    %edx
  8009c3:	83 d1 00             	adc    $0x0,%ecx
  8009c6:	f7 d9                	neg    %ecx
  8009c8:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d0:	e9 ec 00 00 00       	jmp    800ac1 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009d5:	83 f9 01             	cmp    $0x1,%ecx
  8009d8:	7e 18                	jle    8009f2 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8009da:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dd:	8b 10                	mov    (%eax),%edx
  8009df:	8b 48 04             	mov    0x4(%eax),%ecx
  8009e2:	8d 40 08             	lea    0x8(%eax),%eax
  8009e5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8009e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ed:	e9 cf 00 00 00       	jmp    800ac1 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8009f2:	85 c9                	test   %ecx,%ecx
  8009f4:	74 1a                	je     800a10 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8009f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f9:	8b 10                	mov    (%eax),%edx
  8009fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a00:	8d 40 04             	lea    0x4(%eax),%eax
  800a03:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a06:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0b:	e9 b1 00 00 00       	jmp    800ac1 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800a10:	8b 45 14             	mov    0x14(%ebp),%eax
  800a13:	8b 10                	mov    (%eax),%edx
  800a15:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a1a:	8d 40 04             	lea    0x4(%eax),%eax
  800a1d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a20:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a25:	e9 97 00 00 00       	jmp    800ac1 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	53                   	push   %ebx
  800a2e:	6a 58                	push   $0x58
  800a30:	ff d6                	call   *%esi
			putch('X', putdat);
  800a32:	83 c4 08             	add    $0x8,%esp
  800a35:	53                   	push   %ebx
  800a36:	6a 58                	push   $0x58
  800a38:	ff d6                	call   *%esi
			putch('X', putdat);
  800a3a:	83 c4 08             	add    $0x8,%esp
  800a3d:	53                   	push   %ebx
  800a3e:	6a 58                	push   $0x58
  800a40:	ff d6                	call   *%esi
			break;
  800a42:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800a48:	e9 8b fc ff ff       	jmp    8006d8 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800a4d:	83 ec 08             	sub    $0x8,%esp
  800a50:	53                   	push   %ebx
  800a51:	6a 30                	push   $0x30
  800a53:	ff d6                	call   *%esi
			putch('x', putdat);
  800a55:	83 c4 08             	add    $0x8,%esp
  800a58:	53                   	push   %ebx
  800a59:	6a 78                	push   $0x78
  800a5b:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a60:	8b 10                	mov    (%eax),%edx
  800a62:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a67:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a6a:	8d 40 04             	lea    0x4(%eax),%eax
  800a6d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a70:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a75:	eb 4a                	jmp    800ac1 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a77:	83 f9 01             	cmp    $0x1,%ecx
  800a7a:	7e 15                	jle    800a91 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800a7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7f:	8b 10                	mov    (%eax),%edx
  800a81:	8b 48 04             	mov    0x4(%eax),%ecx
  800a84:	8d 40 08             	lea    0x8(%eax),%eax
  800a87:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a8a:	b8 10 00 00 00       	mov    $0x10,%eax
  800a8f:	eb 30                	jmp    800ac1 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800a91:	85 c9                	test   %ecx,%ecx
  800a93:	74 17                	je     800aac <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	8b 10                	mov    (%eax),%edx
  800a9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9f:	8d 40 04             	lea    0x4(%eax),%eax
  800aa2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800aa5:	b8 10 00 00 00       	mov    $0x10,%eax
  800aaa:	eb 15                	jmp    800ac1 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800aac:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaf:	8b 10                	mov    (%eax),%edx
  800ab1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab6:	8d 40 04             	lea    0x4(%eax),%eax
  800ab9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800abc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ac1:	83 ec 0c             	sub    $0xc,%esp
  800ac4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800ac8:	57                   	push   %edi
  800ac9:	ff 75 e0             	pushl  -0x20(%ebp)
  800acc:	50                   	push   %eax
  800acd:	51                   	push   %ecx
  800ace:	52                   	push   %edx
  800acf:	89 da                	mov    %ebx,%edx
  800ad1:	89 f0                	mov    %esi,%eax
  800ad3:	e8 f1 fa ff ff       	call   8005c9 <printnum>
			break;
  800ad8:	83 c4 20             	add    $0x20,%esp
  800adb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ade:	e9 f5 fb ff ff       	jmp    8006d8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ae3:	83 ec 08             	sub    $0x8,%esp
  800ae6:	53                   	push   %ebx
  800ae7:	52                   	push   %edx
  800ae8:	ff d6                	call   *%esi
			break;
  800aea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800af0:	e9 e3 fb ff ff       	jmp    8006d8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800af5:	83 ec 08             	sub    $0x8,%esp
  800af8:	53                   	push   %ebx
  800af9:	6a 25                	push   $0x25
  800afb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	eb 03                	jmp    800b05 <vprintfmt+0x453>
  800b02:	83 ef 01             	sub    $0x1,%edi
  800b05:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b09:	75 f7                	jne    800b02 <vprintfmt+0x450>
  800b0b:	e9 c8 fb ff ff       	jmp    8006d8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	83 ec 18             	sub    $0x18,%esp
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b24:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b27:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b2b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	74 26                	je     800b5f <vsnprintf+0x47>
  800b39:	85 d2                	test   %edx,%edx
  800b3b:	7e 22                	jle    800b5f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b3d:	ff 75 14             	pushl  0x14(%ebp)
  800b40:	ff 75 10             	pushl  0x10(%ebp)
  800b43:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b46:	50                   	push   %eax
  800b47:	68 78 06 80 00       	push   $0x800678
  800b4c:	e8 61 fb ff ff       	call   8006b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b51:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b54:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b5a:	83 c4 10             	add    $0x10,%esp
  800b5d:	eb 05                	jmp    800b64 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b5f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b6c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b6f:	50                   	push   %eax
  800b70:	ff 75 10             	pushl  0x10(%ebp)
  800b73:	ff 75 0c             	pushl  0xc(%ebp)
  800b76:	ff 75 08             	pushl  0x8(%ebp)
  800b79:	e8 9a ff ff ff       	call   800b18 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8b:	eb 03                	jmp    800b90 <strlen+0x10>
		n++;
  800b8d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b90:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b94:	75 f7                	jne    800b8d <strlen+0xd>
		n++;
	return n;
}
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	eb 03                	jmp    800bab <strnlen+0x13>
		n++;
  800ba8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bab:	39 c2                	cmp    %eax,%edx
  800bad:	74 08                	je     800bb7 <strnlen+0x1f>
  800baf:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800bb3:	75 f3                	jne    800ba8 <strnlen+0x10>
  800bb5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	53                   	push   %ebx
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc3:	89 c2                	mov    %eax,%edx
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	83 c1 01             	add    $0x1,%ecx
  800bcb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800bcf:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bd2:	84 db                	test   %bl,%bl
  800bd4:	75 ef                	jne    800bc5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	53                   	push   %ebx
  800bdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be0:	53                   	push   %ebx
  800be1:	e8 9a ff ff ff       	call   800b80 <strlen>
  800be6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800be9:	ff 75 0c             	pushl  0xc(%ebp)
  800bec:	01 d8                	add    %ebx,%eax
  800bee:	50                   	push   %eax
  800bef:	e8 c5 ff ff ff       	call   800bb9 <strcpy>
	return dst;
}
  800bf4:	89 d8                	mov    %ebx,%eax
  800bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
  800c00:	8b 75 08             	mov    0x8(%ebp),%esi
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c06:	89 f3                	mov    %esi,%ebx
  800c08:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c0b:	89 f2                	mov    %esi,%edx
  800c0d:	eb 0f                	jmp    800c1e <strncpy+0x23>
		*dst++ = *src;
  800c0f:	83 c2 01             	add    $0x1,%edx
  800c12:	0f b6 01             	movzbl (%ecx),%eax
  800c15:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c18:	80 39 01             	cmpb   $0x1,(%ecx)
  800c1b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c1e:	39 da                	cmp    %ebx,%edx
  800c20:	75 ed                	jne    800c0f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c22:	89 f0                	mov    %esi,%eax
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8b 55 10             	mov    0x10(%ebp),%edx
  800c36:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c38:	85 d2                	test   %edx,%edx
  800c3a:	74 21                	je     800c5d <strlcpy+0x35>
  800c3c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c40:	89 f2                	mov    %esi,%edx
  800c42:	eb 09                	jmp    800c4d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c44:	83 c2 01             	add    $0x1,%edx
  800c47:	83 c1 01             	add    $0x1,%ecx
  800c4a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c4d:	39 c2                	cmp    %eax,%edx
  800c4f:	74 09                	je     800c5a <strlcpy+0x32>
  800c51:	0f b6 19             	movzbl (%ecx),%ebx
  800c54:	84 db                	test   %bl,%bl
  800c56:	75 ec                	jne    800c44 <strlcpy+0x1c>
  800c58:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c5a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c5d:	29 f0                	sub    %esi,%eax
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c69:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c6c:	eb 06                	jmp    800c74 <strcmp+0x11>
		p++, q++;
  800c6e:	83 c1 01             	add    $0x1,%ecx
  800c71:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c74:	0f b6 01             	movzbl (%ecx),%eax
  800c77:	84 c0                	test   %al,%al
  800c79:	74 04                	je     800c7f <strcmp+0x1c>
  800c7b:	3a 02                	cmp    (%edx),%al
  800c7d:	74 ef                	je     800c6e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c7f:	0f b6 c0             	movzbl %al,%eax
  800c82:	0f b6 12             	movzbl (%edx),%edx
  800c85:	29 d0                	sub    %edx,%eax
}
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	53                   	push   %ebx
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c93:	89 c3                	mov    %eax,%ebx
  800c95:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c98:	eb 06                	jmp    800ca0 <strncmp+0x17>
		n--, p++, q++;
  800c9a:	83 c0 01             	add    $0x1,%eax
  800c9d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ca0:	39 d8                	cmp    %ebx,%eax
  800ca2:	74 15                	je     800cb9 <strncmp+0x30>
  800ca4:	0f b6 08             	movzbl (%eax),%ecx
  800ca7:	84 c9                	test   %cl,%cl
  800ca9:	74 04                	je     800caf <strncmp+0x26>
  800cab:	3a 0a                	cmp    (%edx),%cl
  800cad:	74 eb                	je     800c9a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800caf:	0f b6 00             	movzbl (%eax),%eax
  800cb2:	0f b6 12             	movzbl (%edx),%edx
  800cb5:	29 d0                	sub    %edx,%eax
  800cb7:	eb 05                	jmp    800cbe <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ccb:	eb 07                	jmp    800cd4 <strchr+0x13>
		if (*s == c)
  800ccd:	38 ca                	cmp    %cl,%dl
  800ccf:	74 0f                	je     800ce0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cd1:	83 c0 01             	add    $0x1,%eax
  800cd4:	0f b6 10             	movzbl (%eax),%edx
  800cd7:	84 d2                	test   %dl,%dl
  800cd9:	75 f2                	jne    800ccd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cec:	eb 03                	jmp    800cf1 <strfind+0xf>
  800cee:	83 c0 01             	add    $0x1,%eax
  800cf1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cf4:	38 ca                	cmp    %cl,%dl
  800cf6:	74 04                	je     800cfc <strfind+0x1a>
  800cf8:	84 d2                	test   %dl,%dl
  800cfa:	75 f2                	jne    800cee <strfind+0xc>
			break;
	return (char *) s;
}
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d0a:	85 c9                	test   %ecx,%ecx
  800d0c:	74 36                	je     800d44 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d14:	75 28                	jne    800d3e <memset+0x40>
  800d16:	f6 c1 03             	test   $0x3,%cl
  800d19:	75 23                	jne    800d3e <memset+0x40>
		c &= 0xFF;
  800d1b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	c1 e3 08             	shl    $0x8,%ebx
  800d24:	89 d6                	mov    %edx,%esi
  800d26:	c1 e6 18             	shl    $0x18,%esi
  800d29:	89 d0                	mov    %edx,%eax
  800d2b:	c1 e0 10             	shl    $0x10,%eax
  800d2e:	09 f0                	or     %esi,%eax
  800d30:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d32:	89 d8                	mov    %ebx,%eax
  800d34:	09 d0                	or     %edx,%eax
  800d36:	c1 e9 02             	shr    $0x2,%ecx
  800d39:	fc                   	cld    
  800d3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800d3c:	eb 06                	jmp    800d44 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d41:	fc                   	cld    
  800d42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d44:	89 f8                	mov    %edi,%eax
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d59:	39 c6                	cmp    %eax,%esi
  800d5b:	73 35                	jae    800d92 <memmove+0x47>
  800d5d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d60:	39 d0                	cmp    %edx,%eax
  800d62:	73 2e                	jae    800d92 <memmove+0x47>
		s += n;
		d += n;
  800d64:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d67:	89 d6                	mov    %edx,%esi
  800d69:	09 fe                	or     %edi,%esi
  800d6b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d71:	75 13                	jne    800d86 <memmove+0x3b>
  800d73:	f6 c1 03             	test   $0x3,%cl
  800d76:	75 0e                	jne    800d86 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d78:	83 ef 04             	sub    $0x4,%edi
  800d7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d7e:	c1 e9 02             	shr    $0x2,%ecx
  800d81:	fd                   	std    
  800d82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d84:	eb 09                	jmp    800d8f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d86:	83 ef 01             	sub    $0x1,%edi
  800d89:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d8c:	fd                   	std    
  800d8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d8f:	fc                   	cld    
  800d90:	eb 1d                	jmp    800daf <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d92:	89 f2                	mov    %esi,%edx
  800d94:	09 c2                	or     %eax,%edx
  800d96:	f6 c2 03             	test   $0x3,%dl
  800d99:	75 0f                	jne    800daa <memmove+0x5f>
  800d9b:	f6 c1 03             	test   $0x3,%cl
  800d9e:	75 0a                	jne    800daa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800da0:	c1 e9 02             	shr    $0x2,%ecx
  800da3:	89 c7                	mov    %eax,%edi
  800da5:	fc                   	cld    
  800da6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da8:	eb 05                	jmp    800daf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800daa:	89 c7                	mov    %eax,%edi
  800dac:	fc                   	cld    
  800dad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800db6:	ff 75 10             	pushl  0x10(%ebp)
  800db9:	ff 75 0c             	pushl  0xc(%ebp)
  800dbc:	ff 75 08             	pushl  0x8(%ebp)
  800dbf:	e8 87 ff ff ff       	call   800d4b <memmove>
}
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    

00800dc6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd1:	89 c6                	mov    %eax,%esi
  800dd3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd6:	eb 1a                	jmp    800df2 <memcmp+0x2c>
		if (*s1 != *s2)
  800dd8:	0f b6 08             	movzbl (%eax),%ecx
  800ddb:	0f b6 1a             	movzbl (%edx),%ebx
  800dde:	38 d9                	cmp    %bl,%cl
  800de0:	74 0a                	je     800dec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800de2:	0f b6 c1             	movzbl %cl,%eax
  800de5:	0f b6 db             	movzbl %bl,%ebx
  800de8:	29 d8                	sub    %ebx,%eax
  800dea:	eb 0f                	jmp    800dfb <memcmp+0x35>
		s1++, s2++;
  800dec:	83 c0 01             	add    $0x1,%eax
  800def:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df2:	39 f0                	cmp    %esi,%eax
  800df4:	75 e2                	jne    800dd8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800df6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	53                   	push   %ebx
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e06:	89 c1                	mov    %eax,%ecx
  800e08:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800e0b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e0f:	eb 0a                	jmp    800e1b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e11:	0f b6 10             	movzbl (%eax),%edx
  800e14:	39 da                	cmp    %ebx,%edx
  800e16:	74 07                	je     800e1f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e18:	83 c0 01             	add    $0x1,%eax
  800e1b:	39 c8                	cmp    %ecx,%eax
  800e1d:	72 f2                	jb     800e11 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e1f:	5b                   	pop    %ebx
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e2e:	eb 03                	jmp    800e33 <strtol+0x11>
		s++;
  800e30:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e33:	0f b6 01             	movzbl (%ecx),%eax
  800e36:	3c 20                	cmp    $0x20,%al
  800e38:	74 f6                	je     800e30 <strtol+0xe>
  800e3a:	3c 09                	cmp    $0x9,%al
  800e3c:	74 f2                	je     800e30 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e3e:	3c 2b                	cmp    $0x2b,%al
  800e40:	75 0a                	jne    800e4c <strtol+0x2a>
		s++;
  800e42:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e45:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4a:	eb 11                	jmp    800e5d <strtol+0x3b>
  800e4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e51:	3c 2d                	cmp    $0x2d,%al
  800e53:	75 08                	jne    800e5d <strtol+0x3b>
		s++, neg = 1;
  800e55:	83 c1 01             	add    $0x1,%ecx
  800e58:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e63:	75 15                	jne    800e7a <strtol+0x58>
  800e65:	80 39 30             	cmpb   $0x30,(%ecx)
  800e68:	75 10                	jne    800e7a <strtol+0x58>
  800e6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e6e:	75 7c                	jne    800eec <strtol+0xca>
		s += 2, base = 16;
  800e70:	83 c1 02             	add    $0x2,%ecx
  800e73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e78:	eb 16                	jmp    800e90 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e7a:	85 db                	test   %ebx,%ebx
  800e7c:	75 12                	jne    800e90 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e83:	80 39 30             	cmpb   $0x30,(%ecx)
  800e86:	75 08                	jne    800e90 <strtol+0x6e>
		s++, base = 8;
  800e88:	83 c1 01             	add    $0x1,%ecx
  800e8b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e90:	b8 00 00 00 00       	mov    $0x0,%eax
  800e95:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e98:	0f b6 11             	movzbl (%ecx),%edx
  800e9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e9e:	89 f3                	mov    %esi,%ebx
  800ea0:	80 fb 09             	cmp    $0x9,%bl
  800ea3:	77 08                	ja     800ead <strtol+0x8b>
			dig = *s - '0';
  800ea5:	0f be d2             	movsbl %dl,%edx
  800ea8:	83 ea 30             	sub    $0x30,%edx
  800eab:	eb 22                	jmp    800ecf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ead:	8d 72 9f             	lea    -0x61(%edx),%esi
  800eb0:	89 f3                	mov    %esi,%ebx
  800eb2:	80 fb 19             	cmp    $0x19,%bl
  800eb5:	77 08                	ja     800ebf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800eb7:	0f be d2             	movsbl %dl,%edx
  800eba:	83 ea 57             	sub    $0x57,%edx
  800ebd:	eb 10                	jmp    800ecf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ebf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ec2:	89 f3                	mov    %esi,%ebx
  800ec4:	80 fb 19             	cmp    $0x19,%bl
  800ec7:	77 16                	ja     800edf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ec9:	0f be d2             	movsbl %dl,%edx
  800ecc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ecf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ed2:	7d 0b                	jge    800edf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ed4:	83 c1 01             	add    $0x1,%ecx
  800ed7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800edb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800edd:	eb b9                	jmp    800e98 <strtol+0x76>

	if (endptr)
  800edf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee3:	74 0d                	je     800ef2 <strtol+0xd0>
		*endptr = (char *) s;
  800ee5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ee8:	89 0e                	mov    %ecx,(%esi)
  800eea:	eb 06                	jmp    800ef2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eec:	85 db                	test   %ebx,%ebx
  800eee:	74 98                	je     800e88 <strtol+0x66>
  800ef0:	eb 9e                	jmp    800e90 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ef2:	89 c2                	mov    %eax,%edx
  800ef4:	f7 da                	neg    %edx
  800ef6:	85 ff                	test   %edi,%edi
  800ef8:	0f 45 c2             	cmovne %edx,%eax
}
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f11:	89 c3                	mov    %eax,%ebx
  800f13:	89 c7                	mov    %eax,%edi
  800f15:	89 c6                	mov    %eax,%esi
  800f17:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f24:	ba 00 00 00 00       	mov    $0x0,%edx
  800f29:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2e:	89 d1                	mov    %edx,%ecx
  800f30:	89 d3                	mov    %edx,%ebx
  800f32:	89 d7                	mov    %edx,%edi
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4b:	b8 03 00 00 00       	mov    $0x3,%eax
  800f50:	8b 55 08             	mov    0x8(%ebp),%edx
  800f53:	89 cb                	mov    %ecx,%ebx
  800f55:	89 cf                	mov    %ecx,%edi
  800f57:	89 ce                	mov    %ecx,%esi
  800f59:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	7e 17                	jle    800f76 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	50                   	push   %eax
  800f63:	6a 03                	push   $0x3
  800f65:	68 9f 2b 80 00       	push   $0x802b9f
  800f6a:	6a 23                	push   $0x23
  800f6c:	68 bc 2b 80 00       	push   $0x802bbc
  800f71:	e8 c7 13 00 00       	call   80233d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f84:	ba 00 00 00 00       	mov    $0x0,%edx
  800f89:	b8 02 00 00 00       	mov    $0x2,%eax
  800f8e:	89 d1                	mov    %edx,%ecx
  800f90:	89 d3                	mov    %edx,%ebx
  800f92:	89 d7                	mov    %edx,%edi
  800f94:	89 d6                	mov    %edx,%esi
  800f96:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <sys_yield>:

void
sys_yield(void)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fad:	89 d1                	mov    %edx,%ecx
  800faf:	89 d3                	mov    %edx,%ebx
  800fb1:	89 d7                	mov    %edx,%edi
  800fb3:	89 d6                	mov    %edx,%esi
  800fb5:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5f                   	pop    %edi
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	57                   	push   %edi
  800fc0:	56                   	push   %esi
  800fc1:	53                   	push   %ebx
  800fc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc5:	be 00 00 00 00       	mov    $0x0,%esi
  800fca:	b8 04 00 00 00       	mov    $0x4,%eax
  800fcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fd8:	89 f7                	mov    %esi,%edi
  800fda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	7e 17                	jle    800ff7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe0:	83 ec 0c             	sub    $0xc,%esp
  800fe3:	50                   	push   %eax
  800fe4:	6a 04                	push   $0x4
  800fe6:	68 9f 2b 80 00       	push   $0x802b9f
  800feb:	6a 23                	push   $0x23
  800fed:	68 bc 2b 80 00       	push   $0x802bbc
  800ff2:	e8 46 13 00 00       	call   80233d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffa:	5b                   	pop    %ebx
  800ffb:	5e                   	pop    %esi
  800ffc:	5f                   	pop    %edi
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	57                   	push   %edi
  801003:	56                   	push   %esi
  801004:	53                   	push   %ebx
  801005:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801008:	b8 05 00 00 00       	mov    $0x5,%eax
  80100d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801010:	8b 55 08             	mov    0x8(%ebp),%edx
  801013:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801016:	8b 7d 14             	mov    0x14(%ebp),%edi
  801019:	8b 75 18             	mov    0x18(%ebp),%esi
  80101c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80101e:	85 c0                	test   %eax,%eax
  801020:	7e 17                	jle    801039 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	50                   	push   %eax
  801026:	6a 05                	push   $0x5
  801028:	68 9f 2b 80 00       	push   $0x802b9f
  80102d:	6a 23                	push   $0x23
  80102f:	68 bc 2b 80 00       	push   $0x802bbc
  801034:	e8 04 13 00 00       	call   80233d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801039:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104f:	b8 06 00 00 00       	mov    $0x6,%eax
  801054:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801057:	8b 55 08             	mov    0x8(%ebp),%edx
  80105a:	89 df                	mov    %ebx,%edi
  80105c:	89 de                	mov    %ebx,%esi
  80105e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801060:	85 c0                	test   %eax,%eax
  801062:	7e 17                	jle    80107b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	50                   	push   %eax
  801068:	6a 06                	push   $0x6
  80106a:	68 9f 2b 80 00       	push   $0x802b9f
  80106f:	6a 23                	push   $0x23
  801071:	68 bc 2b 80 00       	push   $0x802bbc
  801076:	e8 c2 12 00 00       	call   80233d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80107b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107e:	5b                   	pop    %ebx
  80107f:	5e                   	pop    %esi
  801080:	5f                   	pop    %edi
  801081:	5d                   	pop    %ebp
  801082:	c3                   	ret    

00801083 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80108c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801091:	b8 08 00 00 00       	mov    $0x8,%eax
  801096:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801099:	8b 55 08             	mov    0x8(%ebp),%edx
  80109c:	89 df                	mov    %ebx,%edi
  80109e:	89 de                	mov    %ebx,%esi
  8010a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	7e 17                	jle    8010bd <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	50                   	push   %eax
  8010aa:	6a 08                	push   $0x8
  8010ac:	68 9f 2b 80 00       	push   $0x802b9f
  8010b1:	6a 23                	push   $0x23
  8010b3:	68 bc 2b 80 00       	push   $0x802bbc
  8010b8:	e8 80 12 00 00       	call   80233d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c0:	5b                   	pop    %ebx
  8010c1:	5e                   	pop    %esi
  8010c2:	5f                   	pop    %edi
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d3:	b8 09 00 00 00       	mov    $0x9,%eax
  8010d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	89 df                	mov    %ebx,%edi
  8010e0:	89 de                	mov    %ebx,%esi
  8010e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	7e 17                	jle    8010ff <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e8:	83 ec 0c             	sub    $0xc,%esp
  8010eb:	50                   	push   %eax
  8010ec:	6a 09                	push   $0x9
  8010ee:	68 9f 2b 80 00       	push   $0x802b9f
  8010f3:	6a 23                	push   $0x23
  8010f5:	68 bc 2b 80 00       	push   $0x802bbc
  8010fa:	e8 3e 12 00 00       	call   80233d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801110:	bb 00 00 00 00       	mov    $0x0,%ebx
  801115:	b8 0a 00 00 00       	mov    $0xa,%eax
  80111a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111d:	8b 55 08             	mov    0x8(%ebp),%edx
  801120:	89 df                	mov    %ebx,%edi
  801122:	89 de                	mov    %ebx,%esi
  801124:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801126:	85 c0                	test   %eax,%eax
  801128:	7e 17                	jle    801141 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80112a:	83 ec 0c             	sub    $0xc,%esp
  80112d:	50                   	push   %eax
  80112e:	6a 0a                	push   $0xa
  801130:	68 9f 2b 80 00       	push   $0x802b9f
  801135:	6a 23                	push   $0x23
  801137:	68 bc 2b 80 00       	push   $0x802bbc
  80113c:	e8 fc 11 00 00       	call   80233d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801141:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114f:	be 00 00 00 00       	mov    $0x0,%esi
  801154:	b8 0c 00 00 00       	mov    $0xc,%eax
  801159:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115c:	8b 55 08             	mov    0x8(%ebp),%edx
  80115f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801162:	8b 7d 14             	mov    0x14(%ebp),%edi
  801165:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801167:	5b                   	pop    %ebx
  801168:	5e                   	pop    %esi
  801169:	5f                   	pop    %edi
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	57                   	push   %edi
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801175:	b9 00 00 00 00       	mov    $0x0,%ecx
  80117a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80117f:	8b 55 08             	mov    0x8(%ebp),%edx
  801182:	89 cb                	mov    %ecx,%ebx
  801184:	89 cf                	mov    %ecx,%edi
  801186:	89 ce                	mov    %ecx,%esi
  801188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80118a:	85 c0                	test   %eax,%eax
  80118c:	7e 17                	jle    8011a5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118e:	83 ec 0c             	sub    $0xc,%esp
  801191:	50                   	push   %eax
  801192:	6a 0d                	push   $0xd
  801194:	68 9f 2b 80 00       	push   $0x802b9f
  801199:	6a 23                	push   $0x23
  80119b:	68 bc 2b 80 00       	push   $0x802bbc
  8011a0:	e8 98 11 00 00       	call   80233d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a8:	5b                   	pop    %ebx
  8011a9:	5e                   	pop    %esi
  8011aa:	5f                   	pop    %edi
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	57                   	push   %edi
  8011b1:	56                   	push   %esi
  8011b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011bd:	89 d1                	mov    %edx,%ecx
  8011bf:	89 d3                	mov    %edx,%ebx
  8011c1:	89 d7                	mov    %edx,%edi
  8011c3:	89 d6                	mov    %edx,%esi
  8011c5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5f                   	pop    %edi
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	57                   	push   %edi
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011d7:	b8 10 00 00 00       	mov    $0x10,%eax
  8011dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011df:	89 cb                	mov    %ecx,%ebx
  8011e1:	89 cf                	mov    %ecx,%edi
  8011e3:	89 ce                	mov    %ecx,%esi
  8011e5:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801202:	05 00 00 00 30       	add    $0x30000000,%eax
  801207:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80120c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    

00801213 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801219:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80121e:	89 c2                	mov    %eax,%edx
  801220:	c1 ea 16             	shr    $0x16,%edx
  801223:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122a:	f6 c2 01             	test   $0x1,%dl
  80122d:	74 11                	je     801240 <fd_alloc+0x2d>
  80122f:	89 c2                	mov    %eax,%edx
  801231:	c1 ea 0c             	shr    $0xc,%edx
  801234:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123b:	f6 c2 01             	test   $0x1,%dl
  80123e:	75 09                	jne    801249 <fd_alloc+0x36>
			*fd_store = fd;
  801240:	89 01                	mov    %eax,(%ecx)
			return 0;
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
  801247:	eb 17                	jmp    801260 <fd_alloc+0x4d>
  801249:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80124e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801253:	75 c9                	jne    80121e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801255:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80125b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801268:	83 f8 1f             	cmp    $0x1f,%eax
  80126b:	77 36                	ja     8012a3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80126d:	c1 e0 0c             	shl    $0xc,%eax
  801270:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801275:	89 c2                	mov    %eax,%edx
  801277:	c1 ea 16             	shr    $0x16,%edx
  80127a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801281:	f6 c2 01             	test   $0x1,%dl
  801284:	74 24                	je     8012aa <fd_lookup+0x48>
  801286:	89 c2                	mov    %eax,%edx
  801288:	c1 ea 0c             	shr    $0xc,%edx
  80128b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801292:	f6 c2 01             	test   $0x1,%dl
  801295:	74 1a                	je     8012b1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80129a:	89 02                	mov    %eax,(%edx)
	return 0;
  80129c:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a1:	eb 13                	jmp    8012b6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a8:	eb 0c                	jmp    8012b6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012af:	eb 05                	jmp    8012b6 <fd_lookup+0x54>
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c1:	ba 48 2c 80 00       	mov    $0x802c48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012c6:	eb 13                	jmp    8012db <dev_lookup+0x23>
  8012c8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012cb:	39 08                	cmp    %ecx,(%eax)
  8012cd:	75 0c                	jne    8012db <dev_lookup+0x23>
			*dev = devtab[i];
  8012cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012d2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d9:	eb 2e                	jmp    801309 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012db:	8b 02                	mov    (%edx),%eax
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	75 e7                	jne    8012c8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012e1:	a1 18 40 80 00       	mov    0x804018,%eax
  8012e6:	8b 40 48             	mov    0x48(%eax),%eax
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	51                   	push   %ecx
  8012ed:	50                   	push   %eax
  8012ee:	68 cc 2b 80 00       	push   $0x802bcc
  8012f3:	e8 bd f2 ff ff       	call   8005b5 <cprintf>
	*dev = 0;
  8012f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	56                   	push   %esi
  80130f:	53                   	push   %ebx
  801310:	83 ec 10             	sub    $0x10,%esp
  801313:	8b 75 08             	mov    0x8(%ebp),%esi
  801316:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801319:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131c:	50                   	push   %eax
  80131d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801323:	c1 e8 0c             	shr    $0xc,%eax
  801326:	50                   	push   %eax
  801327:	e8 36 ff ff ff       	call   801262 <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 05                	js     801338 <fd_close+0x2d>
	    || fd != fd2)
  801333:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801336:	74 0c                	je     801344 <fd_close+0x39>
		return (must_exist ? r : 0);
  801338:	84 db                	test   %bl,%bl
  80133a:	ba 00 00 00 00       	mov    $0x0,%edx
  80133f:	0f 44 c2             	cmove  %edx,%eax
  801342:	eb 41                	jmp    801385 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	ff 36                	pushl  (%esi)
  80134d:	e8 66 ff ff ff       	call   8012b8 <dev_lookup>
  801352:	89 c3                	mov    %eax,%ebx
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 c0                	test   %eax,%eax
  801359:	78 1a                	js     801375 <fd_close+0x6a>
		if (dev->dev_close)
  80135b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801361:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801366:	85 c0                	test   %eax,%eax
  801368:	74 0b                	je     801375 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	56                   	push   %esi
  80136e:	ff d0                	call   *%eax
  801370:	89 c3                	mov    %eax,%ebx
  801372:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801375:	83 ec 08             	sub    $0x8,%esp
  801378:	56                   	push   %esi
  801379:	6a 00                	push   $0x0
  80137b:	e8 c1 fc ff ff       	call   801041 <sys_page_unmap>
	return r;
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	89 d8                	mov    %ebx,%eax
}
  801385:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801388:	5b                   	pop    %ebx
  801389:	5e                   	pop    %esi
  80138a:	5d                   	pop    %ebp
  80138b:	c3                   	ret    

0080138c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801392:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	ff 75 08             	pushl  0x8(%ebp)
  801399:	e8 c4 fe ff ff       	call   801262 <fd_lookup>
  80139e:	83 c4 08             	add    $0x8,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 10                	js     8013b5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	6a 01                	push   $0x1
  8013aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ad:	e8 59 ff ff ff       	call   80130b <fd_close>
  8013b2:	83 c4 10             	add    $0x10,%esp
}
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <close_all>:

void
close_all(void)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013be:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	e8 c0 ff ff ff       	call   80138c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013cc:	83 c3 01             	add    $0x1,%ebx
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	83 fb 20             	cmp    $0x20,%ebx
  8013d5:	75 ec                	jne    8013c3 <close_all+0xc>
		close(i);
}
  8013d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	57                   	push   %edi
  8013e0:	56                   	push   %esi
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 2c             	sub    $0x2c,%esp
  8013e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	ff 75 08             	pushl  0x8(%ebp)
  8013ef:	e8 6e fe ff ff       	call   801262 <fd_lookup>
  8013f4:	83 c4 08             	add    $0x8,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	0f 88 c1 00 00 00    	js     8014c0 <dup+0xe4>
		return r;
	close(newfdnum);
  8013ff:	83 ec 0c             	sub    $0xc,%esp
  801402:	56                   	push   %esi
  801403:	e8 84 ff ff ff       	call   80138c <close>

	newfd = INDEX2FD(newfdnum);
  801408:	89 f3                	mov    %esi,%ebx
  80140a:	c1 e3 0c             	shl    $0xc,%ebx
  80140d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801413:	83 c4 04             	add    $0x4,%esp
  801416:	ff 75 e4             	pushl  -0x1c(%ebp)
  801419:	e8 de fd ff ff       	call   8011fc <fd2data>
  80141e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801420:	89 1c 24             	mov    %ebx,(%esp)
  801423:	e8 d4 fd ff ff       	call   8011fc <fd2data>
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80142e:	89 f8                	mov    %edi,%eax
  801430:	c1 e8 16             	shr    $0x16,%eax
  801433:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80143a:	a8 01                	test   $0x1,%al
  80143c:	74 37                	je     801475 <dup+0x99>
  80143e:	89 f8                	mov    %edi,%eax
  801440:	c1 e8 0c             	shr    $0xc,%eax
  801443:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80144a:	f6 c2 01             	test   $0x1,%dl
  80144d:	74 26                	je     801475 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	25 07 0e 00 00       	and    $0xe07,%eax
  80145e:	50                   	push   %eax
  80145f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801462:	6a 00                	push   $0x0
  801464:	57                   	push   %edi
  801465:	6a 00                	push   $0x0
  801467:	e8 93 fb ff ff       	call   800fff <sys_page_map>
  80146c:	89 c7                	mov    %eax,%edi
  80146e:	83 c4 20             	add    $0x20,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 2e                	js     8014a3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801475:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801478:	89 d0                	mov    %edx,%eax
  80147a:	c1 e8 0c             	shr    $0xc,%eax
  80147d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801484:	83 ec 0c             	sub    $0xc,%esp
  801487:	25 07 0e 00 00       	and    $0xe07,%eax
  80148c:	50                   	push   %eax
  80148d:	53                   	push   %ebx
  80148e:	6a 00                	push   $0x0
  801490:	52                   	push   %edx
  801491:	6a 00                	push   $0x0
  801493:	e8 67 fb ff ff       	call   800fff <sys_page_map>
  801498:	89 c7                	mov    %eax,%edi
  80149a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80149d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80149f:	85 ff                	test   %edi,%edi
  8014a1:	79 1d                	jns    8014c0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	6a 00                	push   $0x0
  8014a9:	e8 93 fb ff ff       	call   801041 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014ae:	83 c4 08             	add    $0x8,%esp
  8014b1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b4:	6a 00                	push   $0x0
  8014b6:	e8 86 fb ff ff       	call   801041 <sys_page_unmap>
	return r;
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	89 f8                	mov    %edi,%eax
}
  8014c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c3:	5b                   	pop    %ebx
  8014c4:	5e                   	pop    %esi
  8014c5:	5f                   	pop    %edi
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    

008014c8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	53                   	push   %ebx
  8014cc:	83 ec 14             	sub    $0x14,%esp
  8014cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d5:	50                   	push   %eax
  8014d6:	53                   	push   %ebx
  8014d7:	e8 86 fd ff ff       	call   801262 <fd_lookup>
  8014dc:	83 c4 08             	add    $0x8,%esp
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 6d                	js     801552 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ef:	ff 30                	pushl  (%eax)
  8014f1:	e8 c2 fd ff ff       	call   8012b8 <dev_lookup>
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 4c                	js     801549 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801500:	8b 42 08             	mov    0x8(%edx),%eax
  801503:	83 e0 03             	and    $0x3,%eax
  801506:	83 f8 01             	cmp    $0x1,%eax
  801509:	75 21                	jne    80152c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80150b:	a1 18 40 80 00       	mov    0x804018,%eax
  801510:	8b 40 48             	mov    0x48(%eax),%eax
  801513:	83 ec 04             	sub    $0x4,%esp
  801516:	53                   	push   %ebx
  801517:	50                   	push   %eax
  801518:	68 0d 2c 80 00       	push   $0x802c0d
  80151d:	e8 93 f0 ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80152a:	eb 26                	jmp    801552 <read+0x8a>
	}
	if (!dev->dev_read)
  80152c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80152f:	8b 40 08             	mov    0x8(%eax),%eax
  801532:	85 c0                	test   %eax,%eax
  801534:	74 17                	je     80154d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	ff 75 10             	pushl  0x10(%ebp)
  80153c:	ff 75 0c             	pushl  0xc(%ebp)
  80153f:	52                   	push   %edx
  801540:	ff d0                	call   *%eax
  801542:	89 c2                	mov    %eax,%edx
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	eb 09                	jmp    801552 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801549:	89 c2                	mov    %eax,%edx
  80154b:	eb 05                	jmp    801552 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80154d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801552:	89 d0                	mov    %edx,%eax
  801554:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	57                   	push   %edi
  80155d:	56                   	push   %esi
  80155e:	53                   	push   %ebx
  80155f:	83 ec 0c             	sub    $0xc,%esp
  801562:	8b 7d 08             	mov    0x8(%ebp),%edi
  801565:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801568:	bb 00 00 00 00       	mov    $0x0,%ebx
  80156d:	eb 21                	jmp    801590 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80156f:	83 ec 04             	sub    $0x4,%esp
  801572:	89 f0                	mov    %esi,%eax
  801574:	29 d8                	sub    %ebx,%eax
  801576:	50                   	push   %eax
  801577:	89 d8                	mov    %ebx,%eax
  801579:	03 45 0c             	add    0xc(%ebp),%eax
  80157c:	50                   	push   %eax
  80157d:	57                   	push   %edi
  80157e:	e8 45 ff ff ff       	call   8014c8 <read>
		if (m < 0)
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	85 c0                	test   %eax,%eax
  801588:	78 10                	js     80159a <readn+0x41>
			return m;
		if (m == 0)
  80158a:	85 c0                	test   %eax,%eax
  80158c:	74 0a                	je     801598 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80158e:	01 c3                	add    %eax,%ebx
  801590:	39 f3                	cmp    %esi,%ebx
  801592:	72 db                	jb     80156f <readn+0x16>
  801594:	89 d8                	mov    %ebx,%eax
  801596:	eb 02                	jmp    80159a <readn+0x41>
  801598:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80159a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5f                   	pop    %edi
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 14             	sub    $0x14,%esp
  8015a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	53                   	push   %ebx
  8015b1:	e8 ac fc ff ff       	call   801262 <fd_lookup>
  8015b6:	83 c4 08             	add    $0x8,%esp
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 68                	js     801627 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015bf:	83 ec 08             	sub    $0x8,%esp
  8015c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c5:	50                   	push   %eax
  8015c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c9:	ff 30                	pushl  (%eax)
  8015cb:	e8 e8 fc ff ff       	call   8012b8 <dev_lookup>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 47                	js     80161e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015de:	75 21                	jne    801601 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e0:	a1 18 40 80 00       	mov    0x804018,%eax
  8015e5:	8b 40 48             	mov    0x48(%eax),%eax
  8015e8:	83 ec 04             	sub    $0x4,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	50                   	push   %eax
  8015ed:	68 29 2c 80 00       	push   $0x802c29
  8015f2:	e8 be ef ff ff       	call   8005b5 <cprintf>
		return -E_INVAL;
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ff:	eb 26                	jmp    801627 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801601:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801604:	8b 52 0c             	mov    0xc(%edx),%edx
  801607:	85 d2                	test   %edx,%edx
  801609:	74 17                	je     801622 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160b:	83 ec 04             	sub    $0x4,%esp
  80160e:	ff 75 10             	pushl  0x10(%ebp)
  801611:	ff 75 0c             	pushl  0xc(%ebp)
  801614:	50                   	push   %eax
  801615:	ff d2                	call   *%edx
  801617:	89 c2                	mov    %eax,%edx
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	eb 09                	jmp    801627 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161e:	89 c2                	mov    %eax,%edx
  801620:	eb 05                	jmp    801627 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801622:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801627:	89 d0                	mov    %edx,%eax
  801629:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80162c:	c9                   	leave  
  80162d:	c3                   	ret    

0080162e <seek>:

int
seek(int fdnum, off_t offset)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801634:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801637:	50                   	push   %eax
  801638:	ff 75 08             	pushl  0x8(%ebp)
  80163b:	e8 22 fc ff ff       	call   801262 <fd_lookup>
  801640:	83 c4 08             	add    $0x8,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 0e                	js     801655 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801647:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80164a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80164d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801650:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801655:	c9                   	leave  
  801656:	c3                   	ret    

00801657 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	53                   	push   %ebx
  80165b:	83 ec 14             	sub    $0x14,%esp
  80165e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801661:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801664:	50                   	push   %eax
  801665:	53                   	push   %ebx
  801666:	e8 f7 fb ff ff       	call   801262 <fd_lookup>
  80166b:	83 c4 08             	add    $0x8,%esp
  80166e:	89 c2                	mov    %eax,%edx
  801670:	85 c0                	test   %eax,%eax
  801672:	78 65                	js     8016d9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801674:	83 ec 08             	sub    $0x8,%esp
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167e:	ff 30                	pushl  (%eax)
  801680:	e8 33 fc ff ff       	call   8012b8 <dev_lookup>
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	85 c0                	test   %eax,%eax
  80168a:	78 44                	js     8016d0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80168c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801693:	75 21                	jne    8016b6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801695:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80169a:	8b 40 48             	mov    0x48(%eax),%eax
  80169d:	83 ec 04             	sub    $0x4,%esp
  8016a0:	53                   	push   %ebx
  8016a1:	50                   	push   %eax
  8016a2:	68 ec 2b 80 00       	push   $0x802bec
  8016a7:	e8 09 ef ff ff       	call   8005b5 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ac:	83 c4 10             	add    $0x10,%esp
  8016af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016b4:	eb 23                	jmp    8016d9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b9:	8b 52 18             	mov    0x18(%edx),%edx
  8016bc:	85 d2                	test   %edx,%edx
  8016be:	74 14                	je     8016d4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016c0:	83 ec 08             	sub    $0x8,%esp
  8016c3:	ff 75 0c             	pushl  0xc(%ebp)
  8016c6:	50                   	push   %eax
  8016c7:	ff d2                	call   *%edx
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	eb 09                	jmp    8016d9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d0:	89 c2                	mov    %eax,%edx
  8016d2:	eb 05                	jmp    8016d9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016d9:	89 d0                	mov    %edx,%eax
  8016db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	53                   	push   %ebx
  8016e4:	83 ec 14             	sub    $0x14,%esp
  8016e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	ff 75 08             	pushl  0x8(%ebp)
  8016f1:	e8 6c fb ff ff       	call   801262 <fd_lookup>
  8016f6:	83 c4 08             	add    $0x8,%esp
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 58                	js     801757 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ff:	83 ec 08             	sub    $0x8,%esp
  801702:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801705:	50                   	push   %eax
  801706:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801709:	ff 30                	pushl  (%eax)
  80170b:	e8 a8 fb ff ff       	call   8012b8 <dev_lookup>
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	78 37                	js     80174e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801717:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80171e:	74 32                	je     801752 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801720:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801723:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80172a:	00 00 00 
	stat->st_isdir = 0;
  80172d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801734:	00 00 00 
	stat->st_dev = dev;
  801737:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	53                   	push   %ebx
  801741:	ff 75 f0             	pushl  -0x10(%ebp)
  801744:	ff 50 14             	call   *0x14(%eax)
  801747:	89 c2                	mov    %eax,%edx
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	eb 09                	jmp    801757 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174e:	89 c2                	mov    %eax,%edx
  801750:	eb 05                	jmp    801757 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801752:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801757:	89 d0                	mov    %edx,%eax
  801759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175c:	c9                   	leave  
  80175d:	c3                   	ret    

0080175e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	56                   	push   %esi
  801762:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801763:	83 ec 08             	sub    $0x8,%esp
  801766:	6a 00                	push   $0x0
  801768:	ff 75 08             	pushl  0x8(%ebp)
  80176b:	e8 e3 01 00 00       	call   801953 <open>
  801770:	89 c3                	mov    %eax,%ebx
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	85 c0                	test   %eax,%eax
  801777:	78 1b                	js     801794 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801779:	83 ec 08             	sub    $0x8,%esp
  80177c:	ff 75 0c             	pushl  0xc(%ebp)
  80177f:	50                   	push   %eax
  801780:	e8 5b ff ff ff       	call   8016e0 <fstat>
  801785:	89 c6                	mov    %eax,%esi
	close(fd);
  801787:	89 1c 24             	mov    %ebx,(%esp)
  80178a:	e8 fd fb ff ff       	call   80138c <close>
	return r;
  80178f:	83 c4 10             	add    $0x10,%esp
  801792:	89 f0                	mov    %esi,%eax
}
  801794:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801797:	5b                   	pop    %ebx
  801798:	5e                   	pop    %esi
  801799:	5d                   	pop    %ebp
  80179a:	c3                   	ret    

0080179b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
  8017a0:	89 c6                	mov    %eax,%esi
  8017a2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017a4:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  8017ab:	75 12                	jne    8017bf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017ad:	83 ec 0c             	sub    $0xc,%esp
  8017b0:	6a 01                	push   $0x1
  8017b2:	e8 89 0c 00 00       	call   802440 <ipc_find_env>
  8017b7:	a3 10 40 80 00       	mov    %eax,0x804010
  8017bc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017bf:	6a 07                	push   $0x7
  8017c1:	68 00 50 80 00       	push   $0x805000
  8017c6:	56                   	push   %esi
  8017c7:	ff 35 10 40 80 00    	pushl  0x804010
  8017cd:	e8 1a 0c 00 00       	call   8023ec <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017d2:	83 c4 0c             	add    $0xc,%esp
  8017d5:	6a 00                	push   $0x0
  8017d7:	53                   	push   %ebx
  8017d8:	6a 00                	push   $0x0
  8017da:	e8 a4 0b 00 00       	call   802383 <ipc_recv>
}
  8017df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e2:	5b                   	pop    %ebx
  8017e3:	5e                   	pop    %esi
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017fa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801804:	b8 02 00 00 00       	mov    $0x2,%eax
  801809:	e8 8d ff ff ff       	call   80179b <fsipc>
}
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801816:	8b 45 08             	mov    0x8(%ebp),%eax
  801819:	8b 40 0c             	mov    0xc(%eax),%eax
  80181c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801821:	ba 00 00 00 00       	mov    $0x0,%edx
  801826:	b8 06 00 00 00       	mov    $0x6,%eax
  80182b:	e8 6b ff ff ff       	call   80179b <fsipc>
}
  801830:	c9                   	leave  
  801831:	c3                   	ret    

00801832 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	53                   	push   %ebx
  801836:	83 ec 04             	sub    $0x4,%esp
  801839:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	8b 40 0c             	mov    0xc(%eax),%eax
  801842:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801847:	ba 00 00 00 00       	mov    $0x0,%edx
  80184c:	b8 05 00 00 00       	mov    $0x5,%eax
  801851:	e8 45 ff ff ff       	call   80179b <fsipc>
  801856:	85 c0                	test   %eax,%eax
  801858:	78 2c                	js     801886 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	68 00 50 80 00       	push   $0x805000
  801862:	53                   	push   %ebx
  801863:	e8 51 f3 ff ff       	call   800bb9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801868:	a1 80 50 80 00       	mov    0x805080,%eax
  80186d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801873:	a1 84 50 80 00       	mov    0x805084,%eax
  801878:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801889:	c9                   	leave  
  80188a:	c3                   	ret    

0080188b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	8b 45 10             	mov    0x10(%ebp),%eax
  801894:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801899:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80189e:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8018a4:	8b 52 0c             	mov    0xc(%edx),%edx
  8018a7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ad:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018b2:	50                   	push   %eax
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	68 08 50 80 00       	push   $0x805008
  8018bb:	e8 8b f4 ff ff       	call   800d4b <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c5:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ca:	e8 cc fe ff ff       	call   80179b <fsipc>
	//panic("devfile_write not implemented");
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	56                   	push   %esi
  8018d5:	53                   	push   %ebx
  8018d6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018df:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f4:	e8 a2 fe ff ff       	call   80179b <fsipc>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 4b                	js     80194a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ff:	39 c6                	cmp    %eax,%esi
  801901:	73 16                	jae    801919 <devfile_read+0x48>
  801903:	68 5c 2c 80 00       	push   $0x802c5c
  801908:	68 63 2c 80 00       	push   $0x802c63
  80190d:	6a 7c                	push   $0x7c
  80190f:	68 78 2c 80 00       	push   $0x802c78
  801914:	e8 24 0a 00 00       	call   80233d <_panic>
	assert(r <= PGSIZE);
  801919:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80191e:	7e 16                	jle    801936 <devfile_read+0x65>
  801920:	68 83 2c 80 00       	push   $0x802c83
  801925:	68 63 2c 80 00       	push   $0x802c63
  80192a:	6a 7d                	push   $0x7d
  80192c:	68 78 2c 80 00       	push   $0x802c78
  801931:	e8 07 0a 00 00       	call   80233d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	50                   	push   %eax
  80193a:	68 00 50 80 00       	push   $0x805000
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	e8 04 f4 ff ff       	call   800d4b <memmove>
	return r;
  801947:	83 c4 10             	add    $0x10,%esp
}
  80194a:	89 d8                	mov    %ebx,%eax
  80194c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    

00801953 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	53                   	push   %ebx
  801957:	83 ec 20             	sub    $0x20,%esp
  80195a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80195d:	53                   	push   %ebx
  80195e:	e8 1d f2 ff ff       	call   800b80 <strlen>
  801963:	83 c4 10             	add    $0x10,%esp
  801966:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80196b:	7f 67                	jg     8019d4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801973:	50                   	push   %eax
  801974:	e8 9a f8 ff ff       	call   801213 <fd_alloc>
  801979:	83 c4 10             	add    $0x10,%esp
		return r;
  80197c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 57                	js     8019d9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801982:	83 ec 08             	sub    $0x8,%esp
  801985:	53                   	push   %ebx
  801986:	68 00 50 80 00       	push   $0x805000
  80198b:	e8 29 f2 ff ff       	call   800bb9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801990:	8b 45 0c             	mov    0xc(%ebp),%eax
  801993:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801998:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80199b:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a0:	e8 f6 fd ff ff       	call   80179b <fsipc>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	83 c4 10             	add    $0x10,%esp
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	79 14                	jns    8019c2 <open+0x6f>
		fd_close(fd, 0);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	6a 00                	push   $0x0
  8019b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b6:	e8 50 f9 ff ff       	call   80130b <fd_close>
		return r;
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	89 da                	mov    %ebx,%edx
  8019c0:	eb 17                	jmp    8019d9 <open+0x86>
	}

	return fd2num(fd);
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c8:	e8 1f f8 ff ff       	call   8011ec <fd2num>
  8019cd:	89 c2                	mov    %eax,%edx
  8019cf:	83 c4 10             	add    $0x10,%esp
  8019d2:	eb 05                	jmp    8019d9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019d4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019d9:	89 d0                	mov    %edx,%eax
  8019db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f0:	e8 a6 fd ff ff       	call   80179b <fsipc>
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019fd:	68 8f 2c 80 00       	push   $0x802c8f
  801a02:	ff 75 0c             	pushl  0xc(%ebp)
  801a05:	e8 af f1 ff ff       	call   800bb9 <strcpy>
	return 0;
}
  801a0a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a0f:	c9                   	leave  
  801a10:	c3                   	ret    

00801a11 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	53                   	push   %ebx
  801a15:	83 ec 10             	sub    $0x10,%esp
  801a18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a1b:	53                   	push   %ebx
  801a1c:	e8 58 0a 00 00       	call   802479 <pageref>
  801a21:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a29:	83 f8 01             	cmp    $0x1,%eax
  801a2c:	75 10                	jne    801a3e <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff 73 0c             	pushl  0xc(%ebx)
  801a34:	e8 c0 02 00 00       	call   801cf9 <nsipc_close>
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a3e:	89 d0                	mov    %edx,%eax
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a4b:	6a 00                	push   $0x0
  801a4d:	ff 75 10             	pushl  0x10(%ebp)
  801a50:	ff 75 0c             	pushl  0xc(%ebp)
  801a53:	8b 45 08             	mov    0x8(%ebp),%eax
  801a56:	ff 70 0c             	pushl  0xc(%eax)
  801a59:	e8 78 03 00 00       	call   801dd6 <nsipc_send>
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a66:	6a 00                	push   $0x0
  801a68:	ff 75 10             	pushl  0x10(%ebp)
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a71:	ff 70 0c             	pushl  0xc(%eax)
  801a74:	e8 f1 02 00 00       	call   801d6a <nsipc_recv>
}
  801a79:	c9                   	leave  
  801a7a:	c3                   	ret    

00801a7b <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a81:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a84:	52                   	push   %edx
  801a85:	50                   	push   %eax
  801a86:	e8 d7 f7 ff ff       	call   801262 <fd_lookup>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 17                	js     801aa9 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a95:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a9b:	39 08                	cmp    %ecx,(%eax)
  801a9d:	75 05                	jne    801aa4 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a9f:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa2:	eb 05                	jmp    801aa9 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801aa4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801aa9:	c9                   	leave  
  801aaa:	c3                   	ret    

00801aab <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	56                   	push   %esi
  801aaf:	53                   	push   %ebx
  801ab0:	83 ec 1c             	sub    $0x1c,%esp
  801ab3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ab5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab8:	50                   	push   %eax
  801ab9:	e8 55 f7 ff ff       	call   801213 <fd_alloc>
  801abe:	89 c3                	mov    %eax,%ebx
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 1b                	js     801ae2 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	68 07 04 00 00       	push   $0x407
  801acf:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad2:	6a 00                	push   $0x0
  801ad4:	e8 e3 f4 ff ff       	call   800fbc <sys_page_alloc>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	79 10                	jns    801af2 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801ae2:	83 ec 0c             	sub    $0xc,%esp
  801ae5:	56                   	push   %esi
  801ae6:	e8 0e 02 00 00       	call   801cf9 <nsipc_close>
		return r;
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	89 d8                	mov    %ebx,%eax
  801af0:	eb 24                	jmp    801b16 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801af2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b07:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b0a:	83 ec 0c             	sub    $0xc,%esp
  801b0d:	50                   	push   %eax
  801b0e:	e8 d9 f6 ff ff       	call   8011ec <fd2num>
  801b13:	83 c4 10             	add    $0x10,%esp
}
  801b16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b19:	5b                   	pop    %ebx
  801b1a:	5e                   	pop    %esi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b23:	8b 45 08             	mov    0x8(%ebp),%eax
  801b26:	e8 50 ff ff ff       	call   801a7b <fd2sockid>
		return r;
  801b2b:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 1f                	js     801b50 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b31:	83 ec 04             	sub    $0x4,%esp
  801b34:	ff 75 10             	pushl  0x10(%ebp)
  801b37:	ff 75 0c             	pushl  0xc(%ebp)
  801b3a:	50                   	push   %eax
  801b3b:	e8 12 01 00 00       	call   801c52 <nsipc_accept>
  801b40:	83 c4 10             	add    $0x10,%esp
		return r;
  801b43:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b45:	85 c0                	test   %eax,%eax
  801b47:	78 07                	js     801b50 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b49:	e8 5d ff ff ff       	call   801aab <alloc_sockfd>
  801b4e:	89 c1                	mov    %eax,%ecx
}
  801b50:	89 c8                	mov    %ecx,%eax
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	e8 19 ff ff ff       	call   801a7b <fd2sockid>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 12                	js     801b78 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b66:	83 ec 04             	sub    $0x4,%esp
  801b69:	ff 75 10             	pushl  0x10(%ebp)
  801b6c:	ff 75 0c             	pushl  0xc(%ebp)
  801b6f:	50                   	push   %eax
  801b70:	e8 2d 01 00 00       	call   801ca2 <nsipc_bind>
  801b75:	83 c4 10             	add    $0x10,%esp
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <shutdown>:

int
shutdown(int s, int how)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	e8 f3 fe ff ff       	call   801a7b <fd2sockid>
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 0f                	js     801b9b <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	ff 75 0c             	pushl  0xc(%ebp)
  801b92:	50                   	push   %eax
  801b93:	e8 3f 01 00 00       	call   801cd7 <nsipc_shutdown>
  801b98:	83 c4 10             	add    $0x10,%esp
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba6:	e8 d0 fe ff ff       	call   801a7b <fd2sockid>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 12                	js     801bc1 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801baf:	83 ec 04             	sub    $0x4,%esp
  801bb2:	ff 75 10             	pushl  0x10(%ebp)
  801bb5:	ff 75 0c             	pushl  0xc(%ebp)
  801bb8:	50                   	push   %eax
  801bb9:	e8 55 01 00 00       	call   801d13 <nsipc_connect>
  801bbe:	83 c4 10             	add    $0x10,%esp
}
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <listen>:

int
listen(int s, int backlog)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	e8 aa fe ff ff       	call   801a7b <fd2sockid>
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 0f                	js     801be4 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	ff 75 0c             	pushl  0xc(%ebp)
  801bdb:	50                   	push   %eax
  801bdc:	e8 67 01 00 00       	call   801d48 <nsipc_listen>
  801be1:	83 c4 10             	add    $0x10,%esp
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bec:	ff 75 10             	pushl  0x10(%ebp)
  801bef:	ff 75 0c             	pushl  0xc(%ebp)
  801bf2:	ff 75 08             	pushl  0x8(%ebp)
  801bf5:	e8 3a 02 00 00       	call   801e34 <nsipc_socket>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 05                	js     801c06 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c01:	e8 a5 fe ff ff       	call   801aab <alloc_sockfd>
}
  801c06:	c9                   	leave  
  801c07:	c3                   	ret    

00801c08 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c11:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801c18:	75 12                	jne    801c2c <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c1a:	83 ec 0c             	sub    $0xc,%esp
  801c1d:	6a 02                	push   $0x2
  801c1f:	e8 1c 08 00 00       	call   802440 <ipc_find_env>
  801c24:	a3 14 40 80 00       	mov    %eax,0x804014
  801c29:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c2c:	6a 07                	push   $0x7
  801c2e:	68 00 60 80 00       	push   $0x806000
  801c33:	53                   	push   %ebx
  801c34:	ff 35 14 40 80 00    	pushl  0x804014
  801c3a:	e8 ad 07 00 00       	call   8023ec <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c3f:	83 c4 0c             	add    $0xc,%esp
  801c42:	6a 00                	push   $0x0
  801c44:	6a 00                	push   $0x0
  801c46:	6a 00                	push   $0x0
  801c48:	e8 36 07 00 00       	call   802383 <ipc_recv>
}
  801c4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c62:	8b 06                	mov    (%esi),%eax
  801c64:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c69:	b8 01 00 00 00       	mov    $0x1,%eax
  801c6e:	e8 95 ff ff ff       	call   801c08 <nsipc>
  801c73:	89 c3                	mov    %eax,%ebx
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 20                	js     801c99 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c79:	83 ec 04             	sub    $0x4,%esp
  801c7c:	ff 35 10 60 80 00    	pushl  0x806010
  801c82:	68 00 60 80 00       	push   $0x806000
  801c87:	ff 75 0c             	pushl  0xc(%ebp)
  801c8a:	e8 bc f0 ff ff       	call   800d4b <memmove>
		*addrlen = ret->ret_addrlen;
  801c8f:	a1 10 60 80 00       	mov    0x806010,%eax
  801c94:	89 06                	mov    %eax,(%esi)
  801c96:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c99:	89 d8                	mov    %ebx,%eax
  801c9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9e:	5b                   	pop    %ebx
  801c9f:	5e                   	pop    %esi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 08             	sub    $0x8,%esp
  801ca9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cac:	8b 45 08             	mov    0x8(%ebp),%eax
  801caf:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cb4:	53                   	push   %ebx
  801cb5:	ff 75 0c             	pushl  0xc(%ebp)
  801cb8:	68 04 60 80 00       	push   $0x806004
  801cbd:	e8 89 f0 ff ff       	call   800d4b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cc2:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cc8:	b8 02 00 00 00       	mov    $0x2,%eax
  801ccd:	e8 36 ff ff ff       	call   801c08 <nsipc>
}
  801cd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ced:	b8 03 00 00 00       	mov    $0x3,%eax
  801cf2:	e8 11 ff ff ff       	call   801c08 <nsipc>
}
  801cf7:	c9                   	leave  
  801cf8:	c3                   	ret    

00801cf9 <nsipc_close>:

int
nsipc_close(int s)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cff:	8b 45 08             	mov    0x8(%ebp),%eax
  801d02:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d07:	b8 04 00 00 00       	mov    $0x4,%eax
  801d0c:	e8 f7 fe ff ff       	call   801c08 <nsipc>
}
  801d11:	c9                   	leave  
  801d12:	c3                   	ret    

00801d13 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	53                   	push   %ebx
  801d17:	83 ec 08             	sub    $0x8,%esp
  801d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d20:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d25:	53                   	push   %ebx
  801d26:	ff 75 0c             	pushl  0xc(%ebp)
  801d29:	68 04 60 80 00       	push   $0x806004
  801d2e:	e8 18 f0 ff ff       	call   800d4b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d33:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d39:	b8 05 00 00 00       	mov    $0x5,%eax
  801d3e:	e8 c5 fe ff ff       	call   801c08 <nsipc>
}
  801d43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d51:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d59:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d5e:	b8 06 00 00 00       	mov    $0x6,%eax
  801d63:	e8 a0 fe ff ff       	call   801c08 <nsipc>
}
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	56                   	push   %esi
  801d6e:	53                   	push   %ebx
  801d6f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d7a:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d80:	8b 45 14             	mov    0x14(%ebp),%eax
  801d83:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d88:	b8 07 00 00 00       	mov    $0x7,%eax
  801d8d:	e8 76 fe ff ff       	call   801c08 <nsipc>
  801d92:	89 c3                	mov    %eax,%ebx
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 35                	js     801dcd <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d98:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d9d:	7f 04                	jg     801da3 <nsipc_recv+0x39>
  801d9f:	39 c6                	cmp    %eax,%esi
  801da1:	7d 16                	jge    801db9 <nsipc_recv+0x4f>
  801da3:	68 9b 2c 80 00       	push   $0x802c9b
  801da8:	68 63 2c 80 00       	push   $0x802c63
  801dad:	6a 62                	push   $0x62
  801daf:	68 b0 2c 80 00       	push   $0x802cb0
  801db4:	e8 84 05 00 00       	call   80233d <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801db9:	83 ec 04             	sub    $0x4,%esp
  801dbc:	50                   	push   %eax
  801dbd:	68 00 60 80 00       	push   $0x806000
  801dc2:	ff 75 0c             	pushl  0xc(%ebp)
  801dc5:	e8 81 ef ff ff       	call   800d4b <memmove>
  801dca:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dcd:	89 d8                	mov    %ebx,%eax
  801dcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dd2:	5b                   	pop    %ebx
  801dd3:	5e                   	pop    %esi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 04             	sub    $0x4,%esp
  801ddd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801de8:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dee:	7e 16                	jle    801e06 <nsipc_send+0x30>
  801df0:	68 bc 2c 80 00       	push   $0x802cbc
  801df5:	68 63 2c 80 00       	push   $0x802c63
  801dfa:	6a 6d                	push   $0x6d
  801dfc:	68 b0 2c 80 00       	push   $0x802cb0
  801e01:	e8 37 05 00 00       	call   80233d <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e06:	83 ec 04             	sub    $0x4,%esp
  801e09:	53                   	push   %ebx
  801e0a:	ff 75 0c             	pushl  0xc(%ebp)
  801e0d:	68 0c 60 80 00       	push   $0x80600c
  801e12:	e8 34 ef ff ff       	call   800d4b <memmove>
	nsipcbuf.send.req_size = size;
  801e17:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e1d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e20:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e25:	b8 08 00 00 00       	mov    $0x8,%eax
  801e2a:	e8 d9 fd ff ff       	call   801c08 <nsipc>
}
  801e2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e45:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e4d:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e52:	b8 09 00 00 00       	mov    $0x9,%eax
  801e57:	e8 ac fd ff ff       	call   801c08 <nsipc>
}
  801e5c:	c9                   	leave  
  801e5d:	c3                   	ret    

00801e5e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	56                   	push   %esi
  801e62:	53                   	push   %ebx
  801e63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	ff 75 08             	pushl  0x8(%ebp)
  801e6c:	e8 8b f3 ff ff       	call   8011fc <fd2data>
  801e71:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e73:	83 c4 08             	add    $0x8,%esp
  801e76:	68 c8 2c 80 00       	push   $0x802cc8
  801e7b:	53                   	push   %ebx
  801e7c:	e8 38 ed ff ff       	call   800bb9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e81:	8b 46 04             	mov    0x4(%esi),%eax
  801e84:	2b 06                	sub    (%esi),%eax
  801e86:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e8c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e93:	00 00 00 
	stat->st_dev = &devpipe;
  801e96:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e9d:	30 80 00 
	return 0;
}
  801ea0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    

00801eac <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	53                   	push   %ebx
  801eb0:	83 ec 0c             	sub    $0xc,%esp
  801eb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801eb6:	53                   	push   %ebx
  801eb7:	6a 00                	push   $0x0
  801eb9:	e8 83 f1 ff ff       	call   801041 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ebe:	89 1c 24             	mov    %ebx,(%esp)
  801ec1:	e8 36 f3 ff ff       	call   8011fc <fd2data>
  801ec6:	83 c4 08             	add    $0x8,%esp
  801ec9:	50                   	push   %eax
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 70 f1 ff ff       	call   801041 <sys_page_unmap>
}
  801ed1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    

00801ed6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	57                   	push   %edi
  801eda:	56                   	push   %esi
  801edb:	53                   	push   %ebx
  801edc:	83 ec 1c             	sub    $0x1c,%esp
  801edf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ee2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ee4:	a1 18 40 80 00       	mov    0x804018,%eax
  801ee9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	ff 75 e0             	pushl  -0x20(%ebp)
  801ef2:	e8 82 05 00 00       	call   802479 <pageref>
  801ef7:	89 c3                	mov    %eax,%ebx
  801ef9:	89 3c 24             	mov    %edi,(%esp)
  801efc:	e8 78 05 00 00       	call   802479 <pageref>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	39 c3                	cmp    %eax,%ebx
  801f06:	0f 94 c1             	sete   %cl
  801f09:	0f b6 c9             	movzbl %cl,%ecx
  801f0c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f0f:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801f15:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f18:	39 ce                	cmp    %ecx,%esi
  801f1a:	74 1b                	je     801f37 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f1c:	39 c3                	cmp    %eax,%ebx
  801f1e:	75 c4                	jne    801ee4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f20:	8b 42 58             	mov    0x58(%edx),%eax
  801f23:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f26:	50                   	push   %eax
  801f27:	56                   	push   %esi
  801f28:	68 cf 2c 80 00       	push   $0x802ccf
  801f2d:	e8 83 e6 ff ff       	call   8005b5 <cprintf>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	eb ad                	jmp    801ee4 <_pipeisclosed+0xe>
	}
}
  801f37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5f                   	pop    %edi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	57                   	push   %edi
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	83 ec 28             	sub    $0x28,%esp
  801f4b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f4e:	56                   	push   %esi
  801f4f:	e8 a8 f2 ff ff       	call   8011fc <fd2data>
  801f54:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	bf 00 00 00 00       	mov    $0x0,%edi
  801f5e:	eb 4b                	jmp    801fab <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f60:	89 da                	mov    %ebx,%edx
  801f62:	89 f0                	mov    %esi,%eax
  801f64:	e8 6d ff ff ff       	call   801ed6 <_pipeisclosed>
  801f69:	85 c0                	test   %eax,%eax
  801f6b:	75 48                	jne    801fb5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f6d:	e8 2b f0 ff ff       	call   800f9d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f72:	8b 43 04             	mov    0x4(%ebx),%eax
  801f75:	8b 0b                	mov    (%ebx),%ecx
  801f77:	8d 51 20             	lea    0x20(%ecx),%edx
  801f7a:	39 d0                	cmp    %edx,%eax
  801f7c:	73 e2                	jae    801f60 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f81:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f85:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f88:	89 c2                	mov    %eax,%edx
  801f8a:	c1 fa 1f             	sar    $0x1f,%edx
  801f8d:	89 d1                	mov    %edx,%ecx
  801f8f:	c1 e9 1b             	shr    $0x1b,%ecx
  801f92:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f95:	83 e2 1f             	and    $0x1f,%edx
  801f98:	29 ca                	sub    %ecx,%edx
  801f9a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f9e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fa2:	83 c0 01             	add    $0x1,%eax
  801fa5:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa8:	83 c7 01             	add    $0x1,%edi
  801fab:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fae:	75 c2                	jne    801f72 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb3:	eb 05                	jmp    801fba <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbd:	5b                   	pop    %ebx
  801fbe:	5e                   	pop    %esi
  801fbf:	5f                   	pop    %edi
  801fc0:	5d                   	pop    %ebp
  801fc1:	c3                   	ret    

00801fc2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fc2:	55                   	push   %ebp
  801fc3:	89 e5                	mov    %esp,%ebp
  801fc5:	57                   	push   %edi
  801fc6:	56                   	push   %esi
  801fc7:	53                   	push   %ebx
  801fc8:	83 ec 18             	sub    $0x18,%esp
  801fcb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fce:	57                   	push   %edi
  801fcf:	e8 28 f2 ff ff       	call   8011fc <fd2data>
  801fd4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fde:	eb 3d                	jmp    80201d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fe0:	85 db                	test   %ebx,%ebx
  801fe2:	74 04                	je     801fe8 <devpipe_read+0x26>
				return i;
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	eb 44                	jmp    80202c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fe8:	89 f2                	mov    %esi,%edx
  801fea:	89 f8                	mov    %edi,%eax
  801fec:	e8 e5 fe ff ff       	call   801ed6 <_pipeisclosed>
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	75 32                	jne    802027 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ff5:	e8 a3 ef ff ff       	call   800f9d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ffa:	8b 06                	mov    (%esi),%eax
  801ffc:	3b 46 04             	cmp    0x4(%esi),%eax
  801fff:	74 df                	je     801fe0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802001:	99                   	cltd   
  802002:	c1 ea 1b             	shr    $0x1b,%edx
  802005:	01 d0                	add    %edx,%eax
  802007:	83 e0 1f             	and    $0x1f,%eax
  80200a:	29 d0                	sub    %edx,%eax
  80200c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802011:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802014:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802017:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80201a:	83 c3 01             	add    $0x1,%ebx
  80201d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802020:	75 d8                	jne    801ffa <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802022:	8b 45 10             	mov    0x10(%ebp),%eax
  802025:	eb 05                	jmp    80202c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80202c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	56                   	push   %esi
  802038:	53                   	push   %ebx
  802039:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80203c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203f:	50                   	push   %eax
  802040:	e8 ce f1 ff ff       	call   801213 <fd_alloc>
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	89 c2                	mov    %eax,%edx
  80204a:	85 c0                	test   %eax,%eax
  80204c:	0f 88 2c 01 00 00    	js     80217e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802052:	83 ec 04             	sub    $0x4,%esp
  802055:	68 07 04 00 00       	push   $0x407
  80205a:	ff 75 f4             	pushl  -0xc(%ebp)
  80205d:	6a 00                	push   $0x0
  80205f:	e8 58 ef ff ff       	call   800fbc <sys_page_alloc>
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	89 c2                	mov    %eax,%edx
  802069:	85 c0                	test   %eax,%eax
  80206b:	0f 88 0d 01 00 00    	js     80217e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802071:	83 ec 0c             	sub    $0xc,%esp
  802074:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802077:	50                   	push   %eax
  802078:	e8 96 f1 ff ff       	call   801213 <fd_alloc>
  80207d:	89 c3                	mov    %eax,%ebx
  80207f:	83 c4 10             	add    $0x10,%esp
  802082:	85 c0                	test   %eax,%eax
  802084:	0f 88 e2 00 00 00    	js     80216c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208a:	83 ec 04             	sub    $0x4,%esp
  80208d:	68 07 04 00 00       	push   $0x407
  802092:	ff 75 f0             	pushl  -0x10(%ebp)
  802095:	6a 00                	push   $0x0
  802097:	e8 20 ef ff ff       	call   800fbc <sys_page_alloc>
  80209c:	89 c3                	mov    %eax,%ebx
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	0f 88 c3 00 00 00    	js     80216c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8020af:	e8 48 f1 ff ff       	call   8011fc <fd2data>
  8020b4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b6:	83 c4 0c             	add    $0xc,%esp
  8020b9:	68 07 04 00 00       	push   $0x407
  8020be:	50                   	push   %eax
  8020bf:	6a 00                	push   $0x0
  8020c1:	e8 f6 ee ff ff       	call   800fbc <sys_page_alloc>
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	0f 88 89 00 00 00    	js     80215c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d3:	83 ec 0c             	sub    $0xc,%esp
  8020d6:	ff 75 f0             	pushl  -0x10(%ebp)
  8020d9:	e8 1e f1 ff ff       	call   8011fc <fd2data>
  8020de:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020e5:	50                   	push   %eax
  8020e6:	6a 00                	push   $0x0
  8020e8:	56                   	push   %esi
  8020e9:	6a 00                	push   $0x0
  8020eb:	e8 0f ef ff ff       	call   800fff <sys_page_map>
  8020f0:	89 c3                	mov    %eax,%ebx
  8020f2:	83 c4 20             	add    $0x20,%esp
  8020f5:	85 c0                	test   %eax,%eax
  8020f7:	78 55                	js     80214e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020f9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802102:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802104:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802107:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80210e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802114:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802117:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802119:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80211c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802123:	83 ec 0c             	sub    $0xc,%esp
  802126:	ff 75 f4             	pushl  -0xc(%ebp)
  802129:	e8 be f0 ff ff       	call   8011ec <fd2num>
  80212e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802131:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802133:	83 c4 04             	add    $0x4,%esp
  802136:	ff 75 f0             	pushl  -0x10(%ebp)
  802139:	e8 ae f0 ff ff       	call   8011ec <fd2num>
  80213e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802141:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	ba 00 00 00 00       	mov    $0x0,%edx
  80214c:	eb 30                	jmp    80217e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80214e:	83 ec 08             	sub    $0x8,%esp
  802151:	56                   	push   %esi
  802152:	6a 00                	push   $0x0
  802154:	e8 e8 ee ff ff       	call   801041 <sys_page_unmap>
  802159:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80215c:	83 ec 08             	sub    $0x8,%esp
  80215f:	ff 75 f0             	pushl  -0x10(%ebp)
  802162:	6a 00                	push   $0x0
  802164:	e8 d8 ee ff ff       	call   801041 <sys_page_unmap>
  802169:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80216c:	83 ec 08             	sub    $0x8,%esp
  80216f:	ff 75 f4             	pushl  -0xc(%ebp)
  802172:	6a 00                	push   $0x0
  802174:	e8 c8 ee ff ff       	call   801041 <sys_page_unmap>
  802179:	83 c4 10             	add    $0x10,%esp
  80217c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80217e:	89 d0                	mov    %edx,%eax
  802180:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5d                   	pop    %ebp
  802186:	c3                   	ret    

00802187 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802187:	55                   	push   %ebp
  802188:	89 e5                	mov    %esp,%ebp
  80218a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80218d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802190:	50                   	push   %eax
  802191:	ff 75 08             	pushl  0x8(%ebp)
  802194:	e8 c9 f0 ff ff       	call   801262 <fd_lookup>
  802199:	83 c4 10             	add    $0x10,%esp
  80219c:	85 c0                	test   %eax,%eax
  80219e:	78 18                	js     8021b8 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021a0:	83 ec 0c             	sub    $0xc,%esp
  8021a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a6:	e8 51 f0 ff ff       	call   8011fc <fd2data>
	return _pipeisclosed(fd, p);
  8021ab:	89 c2                	mov    %eax,%edx
  8021ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b0:	e8 21 fd ff ff       	call   801ed6 <_pipeisclosed>
  8021b5:	83 c4 10             	add    $0x10,%esp
}
  8021b8:	c9                   	leave  
  8021b9:	c3                   	ret    

008021ba <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    

008021c4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021ca:	68 e7 2c 80 00       	push   $0x802ce7
  8021cf:	ff 75 0c             	pushl  0xc(%ebp)
  8021d2:	e8 e2 e9 ff ff       	call   800bb9 <strcpy>
	return 0;
}
  8021d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8021dc:	c9                   	leave  
  8021dd:	c3                   	ret    

008021de <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021de:	55                   	push   %ebp
  8021df:	89 e5                	mov    %esp,%ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ea:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021f5:	eb 2d                	jmp    802224 <devcons_write+0x46>
		m = n - tot;
  8021f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021fa:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021fc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021ff:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802204:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802207:	83 ec 04             	sub    $0x4,%esp
  80220a:	53                   	push   %ebx
  80220b:	03 45 0c             	add    0xc(%ebp),%eax
  80220e:	50                   	push   %eax
  80220f:	57                   	push   %edi
  802210:	e8 36 eb ff ff       	call   800d4b <memmove>
		sys_cputs(buf, m);
  802215:	83 c4 08             	add    $0x8,%esp
  802218:	53                   	push   %ebx
  802219:	57                   	push   %edi
  80221a:	e8 e1 ec ff ff       	call   800f00 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80221f:	01 de                	add    %ebx,%esi
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	89 f0                	mov    %esi,%eax
  802226:	3b 75 10             	cmp    0x10(%ebp),%esi
  802229:	72 cc                	jb     8021f7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80222b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80222e:	5b                   	pop    %ebx
  80222f:	5e                   	pop    %esi
  802230:	5f                   	pop    %edi
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    

00802233 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802233:	55                   	push   %ebp
  802234:	89 e5                	mov    %esp,%ebp
  802236:	83 ec 08             	sub    $0x8,%esp
  802239:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80223e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802242:	74 2a                	je     80226e <devcons_read+0x3b>
  802244:	eb 05                	jmp    80224b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802246:	e8 52 ed ff ff       	call   800f9d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80224b:	e8 ce ec ff ff       	call   800f1e <sys_cgetc>
  802250:	85 c0                	test   %eax,%eax
  802252:	74 f2                	je     802246 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802254:	85 c0                	test   %eax,%eax
  802256:	78 16                	js     80226e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802258:	83 f8 04             	cmp    $0x4,%eax
  80225b:	74 0c                	je     802269 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80225d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802260:	88 02                	mov    %al,(%edx)
	return 1;
  802262:	b8 01 00 00 00       	mov    $0x1,%eax
  802267:	eb 05                	jmp    80226e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802269:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802276:	8b 45 08             	mov    0x8(%ebp),%eax
  802279:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80227c:	6a 01                	push   $0x1
  80227e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802281:	50                   	push   %eax
  802282:	e8 79 ec ff ff       	call   800f00 <sys_cputs>
}
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	c9                   	leave  
  80228b:	c3                   	ret    

0080228c <getchar>:

int
getchar(void)
{
  80228c:	55                   	push   %ebp
  80228d:	89 e5                	mov    %esp,%ebp
  80228f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802292:	6a 01                	push   $0x1
  802294:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802297:	50                   	push   %eax
  802298:	6a 00                	push   $0x0
  80229a:	e8 29 f2 ff ff       	call   8014c8 <read>
	if (r < 0)
  80229f:	83 c4 10             	add    $0x10,%esp
  8022a2:	85 c0                	test   %eax,%eax
  8022a4:	78 0f                	js     8022b5 <getchar+0x29>
		return r;
	if (r < 1)
  8022a6:	85 c0                	test   %eax,%eax
  8022a8:	7e 06                	jle    8022b0 <getchar+0x24>
		return -E_EOF;
	return c;
  8022aa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8022ae:	eb 05                	jmp    8022b5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8022b0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    

008022b7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c0:	50                   	push   %eax
  8022c1:	ff 75 08             	pushl  0x8(%ebp)
  8022c4:	e8 99 ef ff ff       	call   801262 <fd_lookup>
  8022c9:	83 c4 10             	add    $0x10,%esp
  8022cc:	85 c0                	test   %eax,%eax
  8022ce:	78 11                	js     8022e1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022d9:	39 10                	cmp    %edx,(%eax)
  8022db:	0f 94 c0             	sete   %al
  8022de:	0f b6 c0             	movzbl %al,%eax
}
  8022e1:	c9                   	leave  
  8022e2:	c3                   	ret    

008022e3 <opencons>:

int
opencons(void)
{
  8022e3:	55                   	push   %ebp
  8022e4:	89 e5                	mov    %esp,%ebp
  8022e6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ec:	50                   	push   %eax
  8022ed:	e8 21 ef ff ff       	call   801213 <fd_alloc>
  8022f2:	83 c4 10             	add    $0x10,%esp
		return r;
  8022f5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	78 3e                	js     802339 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022fb:	83 ec 04             	sub    $0x4,%esp
  8022fe:	68 07 04 00 00       	push   $0x407
  802303:	ff 75 f4             	pushl  -0xc(%ebp)
  802306:	6a 00                	push   $0x0
  802308:	e8 af ec ff ff       	call   800fbc <sys_page_alloc>
  80230d:	83 c4 10             	add    $0x10,%esp
		return r;
  802310:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802312:	85 c0                	test   %eax,%eax
  802314:	78 23                	js     802339 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802316:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80231c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802321:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802324:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80232b:	83 ec 0c             	sub    $0xc,%esp
  80232e:	50                   	push   %eax
  80232f:	e8 b8 ee ff ff       	call   8011ec <fd2num>
  802334:	89 c2                	mov    %eax,%edx
  802336:	83 c4 10             	add    $0x10,%esp
}
  802339:	89 d0                	mov    %edx,%eax
  80233b:	c9                   	leave  
  80233c:	c3                   	ret    

0080233d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80233d:	55                   	push   %ebp
  80233e:	89 e5                	mov    %esp,%ebp
  802340:	56                   	push   %esi
  802341:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802342:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802345:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80234b:	e8 2e ec ff ff       	call   800f7e <sys_getenvid>
  802350:	83 ec 0c             	sub    $0xc,%esp
  802353:	ff 75 0c             	pushl  0xc(%ebp)
  802356:	ff 75 08             	pushl  0x8(%ebp)
  802359:	56                   	push   %esi
  80235a:	50                   	push   %eax
  80235b:	68 f4 2c 80 00       	push   $0x802cf4
  802360:	e8 50 e2 ff ff       	call   8005b5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802365:	83 c4 18             	add    $0x18,%esp
  802368:	53                   	push   %ebx
  802369:	ff 75 10             	pushl  0x10(%ebp)
  80236c:	e8 f3 e1 ff ff       	call   800564 <vcprintf>
	cprintf("\n");
  802371:	c7 04 24 e0 2c 80 00 	movl   $0x802ce0,(%esp)
  802378:	e8 38 e2 ff ff       	call   8005b5 <cprintf>
  80237d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802380:	cc                   	int3   
  802381:	eb fd                	jmp    802380 <_panic+0x43>

00802383 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	56                   	push   %esi
  802387:	53                   	push   %ebx
  802388:	8b 75 08             	mov    0x8(%ebp),%esi
  80238b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80238e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  802391:	85 c0                	test   %eax,%eax
  802393:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802398:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80239b:	83 ec 0c             	sub    $0xc,%esp
  80239e:	50                   	push   %eax
  80239f:	e8 c8 ed ff ff       	call   80116c <sys_ipc_recv>
  8023a4:	83 c4 10             	add    $0x10,%esp
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	79 16                	jns    8023c1 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8023ab:	85 f6                	test   %esi,%esi
  8023ad:	74 06                	je     8023b5 <ipc_recv+0x32>
            *from_env_store = 0;
  8023af:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8023b5:	85 db                	test   %ebx,%ebx
  8023b7:	74 2c                	je     8023e5 <ipc_recv+0x62>
            *perm_store = 0;
  8023b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023bf:	eb 24                	jmp    8023e5 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8023c1:	85 f6                	test   %esi,%esi
  8023c3:	74 0a                	je     8023cf <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8023c5:	a1 18 40 80 00       	mov    0x804018,%eax
  8023ca:	8b 40 74             	mov    0x74(%eax),%eax
  8023cd:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8023cf:	85 db                	test   %ebx,%ebx
  8023d1:	74 0a                	je     8023dd <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8023d3:	a1 18 40 80 00       	mov    0x804018,%eax
  8023d8:	8b 40 78             	mov    0x78(%eax),%eax
  8023db:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8023dd:	a1 18 40 80 00       	mov    0x804018,%eax
  8023e2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8023e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    

008023ec <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	57                   	push   %edi
  8023f0:	56                   	push   %esi
  8023f1:	53                   	push   %ebx
  8023f2:	83 ec 0c             	sub    $0xc,%esp
  8023f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8023fe:	85 c0                	test   %eax,%eax
  802400:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802405:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802408:	eb 1c                	jmp    802426 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80240a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80240d:	74 12                	je     802421 <ipc_send+0x35>
  80240f:	50                   	push   %eax
  802410:	68 18 2d 80 00       	push   $0x802d18
  802415:	6a 3b                	push   $0x3b
  802417:	68 2e 2d 80 00       	push   $0x802d2e
  80241c:	e8 1c ff ff ff       	call   80233d <_panic>
		sys_yield();
  802421:	e8 77 eb ff ff       	call   800f9d <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802426:	ff 75 14             	pushl  0x14(%ebp)
  802429:	53                   	push   %ebx
  80242a:	56                   	push   %esi
  80242b:	57                   	push   %edi
  80242c:	e8 18 ed ff ff       	call   801149 <sys_ipc_try_send>
  802431:	83 c4 10             	add    $0x10,%esp
  802434:	85 c0                	test   %eax,%eax
  802436:	78 d2                	js     80240a <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802438:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80243b:	5b                   	pop    %ebx
  80243c:	5e                   	pop    %esi
  80243d:	5f                   	pop    %edi
  80243e:	5d                   	pop    %ebp
  80243f:	c3                   	ret    

00802440 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802446:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80244b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80244e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802454:	8b 52 50             	mov    0x50(%edx),%edx
  802457:	39 ca                	cmp    %ecx,%edx
  802459:	75 0d                	jne    802468 <ipc_find_env+0x28>
			return envs[i].env_id;
  80245b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80245e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802463:	8b 40 48             	mov    0x48(%eax),%eax
  802466:	eb 0f                	jmp    802477 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802468:	83 c0 01             	add    $0x1,%eax
  80246b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802470:	75 d9                	jne    80244b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802472:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    

00802479 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802479:	55                   	push   %ebp
  80247a:	89 e5                	mov    %esp,%ebp
  80247c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80247f:	89 d0                	mov    %edx,%eax
  802481:	c1 e8 16             	shr    $0x16,%eax
  802484:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80248b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802490:	f6 c1 01             	test   $0x1,%cl
  802493:	74 1d                	je     8024b2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802495:	c1 ea 0c             	shr    $0xc,%edx
  802498:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80249f:	f6 c2 01             	test   $0x1,%dl
  8024a2:	74 0e                	je     8024b2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024a4:	c1 ea 0c             	shr    $0xc,%edx
  8024a7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8024ae:	ef 
  8024af:	0f b7 c0             	movzwl %ax,%eax
}
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    
  8024b4:	66 90                	xchg   %ax,%ax
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	66 90                	xchg   %ax,%ax
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__udivdi3>:
  8024c0:	55                   	push   %ebp
  8024c1:	57                   	push   %edi
  8024c2:	56                   	push   %esi
  8024c3:	53                   	push   %ebx
  8024c4:	83 ec 1c             	sub    $0x1c,%esp
  8024c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024d7:	85 f6                	test   %esi,%esi
  8024d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024dd:	89 ca                	mov    %ecx,%edx
  8024df:	89 f8                	mov    %edi,%eax
  8024e1:	75 3d                	jne    802520 <__udivdi3+0x60>
  8024e3:	39 cf                	cmp    %ecx,%edi
  8024e5:	0f 87 c5 00 00 00    	ja     8025b0 <__udivdi3+0xf0>
  8024eb:	85 ff                	test   %edi,%edi
  8024ed:	89 fd                	mov    %edi,%ebp
  8024ef:	75 0b                	jne    8024fc <__udivdi3+0x3c>
  8024f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f6:	31 d2                	xor    %edx,%edx
  8024f8:	f7 f7                	div    %edi
  8024fa:	89 c5                	mov    %eax,%ebp
  8024fc:	89 c8                	mov    %ecx,%eax
  8024fe:	31 d2                	xor    %edx,%edx
  802500:	f7 f5                	div    %ebp
  802502:	89 c1                	mov    %eax,%ecx
  802504:	89 d8                	mov    %ebx,%eax
  802506:	89 cf                	mov    %ecx,%edi
  802508:	f7 f5                	div    %ebp
  80250a:	89 c3                	mov    %eax,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	39 ce                	cmp    %ecx,%esi
  802522:	77 74                	ja     802598 <__udivdi3+0xd8>
  802524:	0f bd fe             	bsr    %esi,%edi
  802527:	83 f7 1f             	xor    $0x1f,%edi
  80252a:	0f 84 98 00 00 00    	je     8025c8 <__udivdi3+0x108>
  802530:	bb 20 00 00 00       	mov    $0x20,%ebx
  802535:	89 f9                	mov    %edi,%ecx
  802537:	89 c5                	mov    %eax,%ebp
  802539:	29 fb                	sub    %edi,%ebx
  80253b:	d3 e6                	shl    %cl,%esi
  80253d:	89 d9                	mov    %ebx,%ecx
  80253f:	d3 ed                	shr    %cl,%ebp
  802541:	89 f9                	mov    %edi,%ecx
  802543:	d3 e0                	shl    %cl,%eax
  802545:	09 ee                	or     %ebp,%esi
  802547:	89 d9                	mov    %ebx,%ecx
  802549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80254d:	89 d5                	mov    %edx,%ebp
  80254f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802553:	d3 ed                	shr    %cl,%ebp
  802555:	89 f9                	mov    %edi,%ecx
  802557:	d3 e2                	shl    %cl,%edx
  802559:	89 d9                	mov    %ebx,%ecx
  80255b:	d3 e8                	shr    %cl,%eax
  80255d:	09 c2                	or     %eax,%edx
  80255f:	89 d0                	mov    %edx,%eax
  802561:	89 ea                	mov    %ebp,%edx
  802563:	f7 f6                	div    %esi
  802565:	89 d5                	mov    %edx,%ebp
  802567:	89 c3                	mov    %eax,%ebx
  802569:	f7 64 24 0c          	mull   0xc(%esp)
  80256d:	39 d5                	cmp    %edx,%ebp
  80256f:	72 10                	jb     802581 <__udivdi3+0xc1>
  802571:	8b 74 24 08          	mov    0x8(%esp),%esi
  802575:	89 f9                	mov    %edi,%ecx
  802577:	d3 e6                	shl    %cl,%esi
  802579:	39 c6                	cmp    %eax,%esi
  80257b:	73 07                	jae    802584 <__udivdi3+0xc4>
  80257d:	39 d5                	cmp    %edx,%ebp
  80257f:	75 03                	jne    802584 <__udivdi3+0xc4>
  802581:	83 eb 01             	sub    $0x1,%ebx
  802584:	31 ff                	xor    %edi,%edi
  802586:	89 d8                	mov    %ebx,%eax
  802588:	89 fa                	mov    %edi,%edx
  80258a:	83 c4 1c             	add    $0x1c,%esp
  80258d:	5b                   	pop    %ebx
  80258e:	5e                   	pop    %esi
  80258f:	5f                   	pop    %edi
  802590:	5d                   	pop    %ebp
  802591:	c3                   	ret    
  802592:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802598:	31 ff                	xor    %edi,%edi
  80259a:	31 db                	xor    %ebx,%ebx
  80259c:	89 d8                	mov    %ebx,%eax
  80259e:	89 fa                	mov    %edi,%edx
  8025a0:	83 c4 1c             	add    $0x1c,%esp
  8025a3:	5b                   	pop    %ebx
  8025a4:	5e                   	pop    %esi
  8025a5:	5f                   	pop    %edi
  8025a6:	5d                   	pop    %ebp
  8025a7:	c3                   	ret    
  8025a8:	90                   	nop
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	89 d8                	mov    %ebx,%eax
  8025b2:	f7 f7                	div    %edi
  8025b4:	31 ff                	xor    %edi,%edi
  8025b6:	89 c3                	mov    %eax,%ebx
  8025b8:	89 d8                	mov    %ebx,%eax
  8025ba:	89 fa                	mov    %edi,%edx
  8025bc:	83 c4 1c             	add    $0x1c,%esp
  8025bf:	5b                   	pop    %ebx
  8025c0:	5e                   	pop    %esi
  8025c1:	5f                   	pop    %edi
  8025c2:	5d                   	pop    %ebp
  8025c3:	c3                   	ret    
  8025c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c8:	39 ce                	cmp    %ecx,%esi
  8025ca:	72 0c                	jb     8025d8 <__udivdi3+0x118>
  8025cc:	31 db                	xor    %ebx,%ebx
  8025ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025d2:	0f 87 34 ff ff ff    	ja     80250c <__udivdi3+0x4c>
  8025d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025dd:	e9 2a ff ff ff       	jmp    80250c <__udivdi3+0x4c>
  8025e2:	66 90                	xchg   %ax,%ax
  8025e4:	66 90                	xchg   %ax,%ax
  8025e6:	66 90                	xchg   %ax,%ax
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__umoddi3>:
  8025f0:	55                   	push   %ebp
  8025f1:	57                   	push   %edi
  8025f2:	56                   	push   %esi
  8025f3:	53                   	push   %ebx
  8025f4:	83 ec 1c             	sub    $0x1c,%esp
  8025f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802603:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802607:	85 d2                	test   %edx,%edx
  802609:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80260d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802611:	89 f3                	mov    %esi,%ebx
  802613:	89 3c 24             	mov    %edi,(%esp)
  802616:	89 74 24 04          	mov    %esi,0x4(%esp)
  80261a:	75 1c                	jne    802638 <__umoddi3+0x48>
  80261c:	39 f7                	cmp    %esi,%edi
  80261e:	76 50                	jbe    802670 <__umoddi3+0x80>
  802620:	89 c8                	mov    %ecx,%eax
  802622:	89 f2                	mov    %esi,%edx
  802624:	f7 f7                	div    %edi
  802626:	89 d0                	mov    %edx,%eax
  802628:	31 d2                	xor    %edx,%edx
  80262a:	83 c4 1c             	add    $0x1c,%esp
  80262d:	5b                   	pop    %ebx
  80262e:	5e                   	pop    %esi
  80262f:	5f                   	pop    %edi
  802630:	5d                   	pop    %ebp
  802631:	c3                   	ret    
  802632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802638:	39 f2                	cmp    %esi,%edx
  80263a:	89 d0                	mov    %edx,%eax
  80263c:	77 52                	ja     802690 <__umoddi3+0xa0>
  80263e:	0f bd ea             	bsr    %edx,%ebp
  802641:	83 f5 1f             	xor    $0x1f,%ebp
  802644:	75 5a                	jne    8026a0 <__umoddi3+0xb0>
  802646:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80264a:	0f 82 e0 00 00 00    	jb     802730 <__umoddi3+0x140>
  802650:	39 0c 24             	cmp    %ecx,(%esp)
  802653:	0f 86 d7 00 00 00    	jbe    802730 <__umoddi3+0x140>
  802659:	8b 44 24 08          	mov    0x8(%esp),%eax
  80265d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802661:	83 c4 1c             	add    $0x1c,%esp
  802664:	5b                   	pop    %ebx
  802665:	5e                   	pop    %esi
  802666:	5f                   	pop    %edi
  802667:	5d                   	pop    %ebp
  802668:	c3                   	ret    
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	85 ff                	test   %edi,%edi
  802672:	89 fd                	mov    %edi,%ebp
  802674:	75 0b                	jne    802681 <__umoddi3+0x91>
  802676:	b8 01 00 00 00       	mov    $0x1,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	f7 f7                	div    %edi
  80267f:	89 c5                	mov    %eax,%ebp
  802681:	89 f0                	mov    %esi,%eax
  802683:	31 d2                	xor    %edx,%edx
  802685:	f7 f5                	div    %ebp
  802687:	89 c8                	mov    %ecx,%eax
  802689:	f7 f5                	div    %ebp
  80268b:	89 d0                	mov    %edx,%eax
  80268d:	eb 99                	jmp    802628 <__umoddi3+0x38>
  80268f:	90                   	nop
  802690:	89 c8                	mov    %ecx,%eax
  802692:	89 f2                	mov    %esi,%edx
  802694:	83 c4 1c             	add    $0x1c,%esp
  802697:	5b                   	pop    %ebx
  802698:	5e                   	pop    %esi
  802699:	5f                   	pop    %edi
  80269a:	5d                   	pop    %ebp
  80269b:	c3                   	ret    
  80269c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	8b 34 24             	mov    (%esp),%esi
  8026a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8026a8:	89 e9                	mov    %ebp,%ecx
  8026aa:	29 ef                	sub    %ebp,%edi
  8026ac:	d3 e0                	shl    %cl,%eax
  8026ae:	89 f9                	mov    %edi,%ecx
  8026b0:	89 f2                	mov    %esi,%edx
  8026b2:	d3 ea                	shr    %cl,%edx
  8026b4:	89 e9                	mov    %ebp,%ecx
  8026b6:	09 c2                	or     %eax,%edx
  8026b8:	89 d8                	mov    %ebx,%eax
  8026ba:	89 14 24             	mov    %edx,(%esp)
  8026bd:	89 f2                	mov    %esi,%edx
  8026bf:	d3 e2                	shl    %cl,%edx
  8026c1:	89 f9                	mov    %edi,%ecx
  8026c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026cb:	d3 e8                	shr    %cl,%eax
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	89 c6                	mov    %eax,%esi
  8026d1:	d3 e3                	shl    %cl,%ebx
  8026d3:	89 f9                	mov    %edi,%ecx
  8026d5:	89 d0                	mov    %edx,%eax
  8026d7:	d3 e8                	shr    %cl,%eax
  8026d9:	89 e9                	mov    %ebp,%ecx
  8026db:	09 d8                	or     %ebx,%eax
  8026dd:	89 d3                	mov    %edx,%ebx
  8026df:	89 f2                	mov    %esi,%edx
  8026e1:	f7 34 24             	divl   (%esp)
  8026e4:	89 d6                	mov    %edx,%esi
  8026e6:	d3 e3                	shl    %cl,%ebx
  8026e8:	f7 64 24 04          	mull   0x4(%esp)
  8026ec:	39 d6                	cmp    %edx,%esi
  8026ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026f2:	89 d1                	mov    %edx,%ecx
  8026f4:	89 c3                	mov    %eax,%ebx
  8026f6:	72 08                	jb     802700 <__umoddi3+0x110>
  8026f8:	75 11                	jne    80270b <__umoddi3+0x11b>
  8026fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026fe:	73 0b                	jae    80270b <__umoddi3+0x11b>
  802700:	2b 44 24 04          	sub    0x4(%esp),%eax
  802704:	1b 14 24             	sbb    (%esp),%edx
  802707:	89 d1                	mov    %edx,%ecx
  802709:	89 c3                	mov    %eax,%ebx
  80270b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80270f:	29 da                	sub    %ebx,%edx
  802711:	19 ce                	sbb    %ecx,%esi
  802713:	89 f9                	mov    %edi,%ecx
  802715:	89 f0                	mov    %esi,%eax
  802717:	d3 e0                	shl    %cl,%eax
  802719:	89 e9                	mov    %ebp,%ecx
  80271b:	d3 ea                	shr    %cl,%edx
  80271d:	89 e9                	mov    %ebp,%ecx
  80271f:	d3 ee                	shr    %cl,%esi
  802721:	09 d0                	or     %edx,%eax
  802723:	89 f2                	mov    %esi,%edx
  802725:	83 c4 1c             	add    $0x1c,%esp
  802728:	5b                   	pop    %ebx
  802729:	5e                   	pop    %esi
  80272a:	5f                   	pop    %edi
  80272b:	5d                   	pop    %ebp
  80272c:	c3                   	ret    
  80272d:	8d 76 00             	lea    0x0(%esi),%esi
  802730:	29 f9                	sub    %edi,%ecx
  802732:	19 d6                	sbb    %edx,%esi
  802734:	89 74 24 04          	mov    %esi,0x4(%esp)
  802738:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80273c:	e9 18 ff ff ff       	jmp    802659 <__umoddi3+0x69>
