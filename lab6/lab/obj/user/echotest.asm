
obj/user/echotest.debug：     文件格式 elf32-i386


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
  80002c:	e8 79 04 00 00       	call   8004aa <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("%s\n", m);
  800039:	50                   	push   %eax
  80003a:	68 40 27 80 00       	push   $0x802740
  80003f:	e8 59 05 00 00       	call   80059d <cprintf>
	exit();
  800044:	e8 a7 04 00 00       	call   8004f0 <exit>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <umain>:

void umain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 58             	sub    $0x58,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  800057:	68 44 27 80 00       	push   $0x802744
  80005c:	e8 3c 05 00 00       	call   80059d <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800061:	c7 04 24 54 27 80 00 	movl   $0x802754,(%esp)
  800068:	e8 0b 04 00 00       	call   800478 <inet_addr>
  80006d:	83 c4 0c             	add    $0xc,%esp
  800070:	50                   	push   %eax
  800071:	68 54 27 80 00       	push   $0x802754
  800076:	68 5e 27 80 00       	push   $0x80275e
  80007b:	e8 1d 05 00 00       	call   80059d <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800080:	83 c4 0c             	add    $0xc,%esp
  800083:	6a 06                	push   $0x6
  800085:	6a 01                	push   $0x1
  800087:	6a 02                	push   $0x2
  800089:	e8 40 1b 00 00       	call   801bce <socket>
  80008e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	79 0a                	jns    8000a2 <umain+0x54>
		die("Failed to create socket");
  800098:	b8 73 27 80 00       	mov    $0x802773,%eax
  80009d:	e8 91 ff ff ff       	call   800033 <die>

	cprintf("opened socket\n");
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	68 8b 27 80 00       	push   $0x80278b
  8000aa:	e8 ee 04 00 00       	call   80059d <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 10                	push   $0x10
  8000b4:	6a 00                	push   $0x0
  8000b6:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000b9:	53                   	push   %ebx
  8000ba:	e8 27 0c 00 00       	call   800ce6 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000bf:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000c3:	c7 04 24 54 27 80 00 	movl   $0x802754,(%esp)
  8000ca:	e8 a9 03 00 00       	call   800478 <inet_addr>
  8000cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000d2:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000d9:	e8 81 01 00 00       	call   80025f <htons>
  8000de:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  8000e2:	c7 04 24 9a 27 80 00 	movl   $0x80279a,(%esp)
  8000e9:	e8 af 04 00 00       	call   80059d <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  8000ee:	83 c4 0c             	add    $0xc,%esp
  8000f1:	6a 10                	push   $0x10
  8000f3:	53                   	push   %ebx
  8000f4:	ff 75 b4             	pushl  -0x4c(%ebp)
  8000f7:	e8 89 1a 00 00       	call   801b85 <connect>
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	85 c0                	test   %eax,%eax
  800101:	79 0a                	jns    80010d <umain+0xbf>
		die("Failed to connect with server");
  800103:	b8 b7 27 80 00       	mov    $0x8027b7,%eax
  800108:	e8 26 ff ff ff       	call   800033 <die>

	cprintf("connected to server\n");
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	68 d5 27 80 00       	push   $0x8027d5
  800115:	e8 83 04 00 00       	call   80059d <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80011a:	83 c4 04             	add    $0x4,%esp
  80011d:	ff 35 00 30 80 00    	pushl  0x803000
  800123:	e8 40 0a 00 00       	call   800b68 <strlen>
  800128:	89 c7                	mov    %eax,%edi
  80012a:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80012d:	83 c4 0c             	add    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	ff 35 00 30 80 00    	pushl  0x803000
  800137:	ff 75 b4             	pushl  -0x4c(%ebp)
  80013a:	e8 4b 14 00 00       	call   80158a <write>
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	39 c7                	cmp    %eax,%edi
  800144:	74 0a                	je     800150 <umain+0x102>
		die("Mismatch in number of sent bytes");
  800146:	b8 04 28 80 00       	mov    $0x802804,%eax
  80014b:	e8 e3 fe ff ff       	call   800033 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	68 ea 27 80 00       	push   $0x8027ea
  800158:	e8 40 04 00 00       	call   80059d <cprintf>
	while (received < echolen) {
  80015d:	83 c4 10             	add    $0x10,%esp
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800160:	be 00 00 00 00       	mov    $0x0,%esi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800165:	8d 7d b8             	lea    -0x48(%ebp),%edi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800168:	eb 34                	jmp    80019e <umain+0x150>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80016a:	83 ec 04             	sub    $0x4,%esp
  80016d:	6a 1f                	push   $0x1f
  80016f:	57                   	push   %edi
  800170:	ff 75 b4             	pushl  -0x4c(%ebp)
  800173:	e8 38 13 00 00       	call   8014b0 <read>
  800178:	89 c3                	mov    %eax,%ebx
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	7f 0a                	jg     80018b <umain+0x13d>
			die("Failed to receive bytes from server");
  800181:	b8 28 28 80 00       	mov    $0x802828,%eax
  800186:	e8 a8 fe ff ff       	call   800033 <die>
		}
		received += bytes;
  80018b:	01 de                	add    %ebx,%esi
		buffer[bytes] = '\0';        // Assure null terminated string
  80018d:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	57                   	push   %edi
  800196:	e8 02 04 00 00       	call   80059d <cprintf>
  80019b:	83 c4 10             	add    $0x10,%esp
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  80019e:	39 75 b0             	cmp    %esi,-0x50(%ebp)
  8001a1:	77 c7                	ja     80016a <umain+0x11c>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	68 f4 27 80 00       	push   $0x8027f4
  8001ab:	e8 ed 03 00 00       	call   80059d <cprintf>

	close(sock);
  8001b0:	83 c4 04             	add    $0x4,%esp
  8001b3:	ff 75 b4             	pushl  -0x4c(%ebp)
  8001b6:	e8 b9 11 00 00       	call   801374 <close>
}
  8001bb:	83 c4 10             	add    $0x10,%esp
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 14             	sub    $0x14,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001d5:	8d 7d f0             	lea    -0x10(%ebp),%edi
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001d8:	c7 45 e0 00 40 80 00 	movl   $0x804000,-0x20(%ebp)
  8001df:	0f b6 0f             	movzbl (%edi),%ecx
  8001e2:	ba 00 00 00 00       	mov    $0x0,%edx
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8001e7:	0f b6 d9             	movzbl %cl,%ebx
  8001ea:	8d 04 9b             	lea    (%ebx,%ebx,4),%eax
  8001ed:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
  8001f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001f3:	66 c1 e8 0b          	shr    $0xb,%ax
  8001f7:	89 c3                	mov    %eax,%ebx
  8001f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8001fc:	01 c0                	add    %eax,%eax
  8001fe:	29 c1                	sub    %eax,%ecx
  800200:	89 c8                	mov    %ecx,%eax
      *ap /= (u8_t)10;
  800202:	89 d9                	mov    %ebx,%ecx
      inv[i++] = '0' + rem;
  800204:	8d 72 01             	lea    0x1(%edx),%esi
  800207:	0f b6 d2             	movzbl %dl,%edx
  80020a:	83 c0 30             	add    $0x30,%eax
  80020d:	88 44 15 ed          	mov    %al,-0x13(%ebp,%edx,1)
  800211:	89 f2                	mov    %esi,%edx
    } while(*ap);
  800213:	84 db                	test   %bl,%bl
  800215:	75 d0                	jne    8001e7 <inet_ntoa+0x21>
  800217:	c6 07 00             	movb   $0x0,(%edi)
  80021a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80021d:	eb 0d                	jmp    80022c <inet_ntoa+0x66>
    while(i--)
      *rp++ = inv[i];
  80021f:	0f b6 c2             	movzbl %dl,%eax
  800222:	0f b6 44 05 ed       	movzbl -0x13(%ebp,%eax,1),%eax
  800227:	88 01                	mov    %al,(%ecx)
  800229:	83 c1 01             	add    $0x1,%ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80022c:	83 ea 01             	sub    $0x1,%edx
  80022f:	80 fa ff             	cmp    $0xff,%dl
  800232:	75 eb                	jne    80021f <inet_ntoa+0x59>
  800234:	89 f0                	mov    %esi,%eax
  800236:	0f b6 f0             	movzbl %al,%esi
  800239:	03 75 e0             	add    -0x20(%ebp),%esi
      *rp++ = inv[i];
    *rp++ = '.';
  80023c:	8d 46 01             	lea    0x1(%esi),%eax
  80023f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800242:	c6 06 2e             	movb   $0x2e,(%esi)
    ap++;
  800245:	83 c7 01             	add    $0x1,%edi
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800248:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80024b:	39 c7                	cmp    %eax,%edi
  80024d:	75 90                	jne    8001df <inet_ntoa+0x19>
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  }
  *--rp = 0;
  80024f:	c6 06 00             	movb   $0x0,(%esi)
  return str;
}
  800252:	b8 00 40 80 00       	mov    $0x804000,%eax
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800262:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800266:	66 c1 c0 08          	rol    $0x8,%ax
}
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  return htons(n);
  80026f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800273:	66 c1 c0 08          	rol    $0x8,%ax
}
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
  80027f:	89 d1                	mov    %edx,%ecx
  800281:	c1 e1 18             	shl    $0x18,%ecx
  800284:	89 d0                	mov    %edx,%eax
  800286:	c1 e8 18             	shr    $0x18,%eax
  800289:	09 c8                	or     %ecx,%eax
  80028b:	89 d1                	mov    %edx,%ecx
  80028d:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800293:	c1 e1 08             	shl    $0x8,%ecx
  800296:	09 c8                	or     %ecx,%eax
  800298:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80029e:	c1 ea 08             	shr    $0x8,%edx
  8002a1:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 20             	sub    $0x20,%esp
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002b1:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002b4:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  8002b7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002ba:	0f b6 ca             	movzbl %dl,%ecx
  8002bd:	83 e9 30             	sub    $0x30,%ecx
  8002c0:	83 f9 09             	cmp    $0x9,%ecx
  8002c3:	0f 87 94 01 00 00    	ja     80045d <inet_aton+0x1b8>
      return (0);
    val = 0;
    base = 10;
  8002c9:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
    if (c == '0') {
  8002d0:	83 fa 30             	cmp    $0x30,%edx
  8002d3:	75 2b                	jne    800300 <inet_aton+0x5b>
      c = *++cp;
  8002d5:	0f b6 50 01          	movzbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  8002d9:	89 d1                	mov    %edx,%ecx
  8002db:	83 e1 df             	and    $0xffffffdf,%ecx
  8002de:	80 f9 58             	cmp    $0x58,%cl
  8002e1:	74 0f                	je     8002f2 <inet_aton+0x4d>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  8002e3:	83 c0 01             	add    $0x1,%eax
  8002e6:	0f be d2             	movsbl %dl,%edx
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  8002e9:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  8002f0:	eb 0e                	jmp    800300 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  8002f2:	0f be 50 02          	movsbl 0x2(%eax),%edx
  8002f6:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  8002f9:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
  800300:	83 c0 01             	add    $0x1,%eax
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	eb 03                	jmp    80030d <inet_aton+0x68>
  80030a:	83 c0 01             	add    $0x1,%eax
  80030d:	8d 58 ff             	lea    -0x1(%eax),%ebx
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800310:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800313:	0f b6 fa             	movzbl %dl,%edi
  800316:	8d 4f d0             	lea    -0x30(%edi),%ecx
  800319:	83 f9 09             	cmp    $0x9,%ecx
  80031c:	77 0d                	ja     80032b <inet_aton+0x86>
        val = (val * base) + (int)(c - '0');
  80031e:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800322:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800326:	0f be 10             	movsbl (%eax),%edx
  800329:	eb df                	jmp    80030a <inet_aton+0x65>
      } else if (base == 16 && isxdigit(c)) {
  80032b:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80032f:	75 32                	jne    800363 <inet_aton+0xbe>
  800331:	8d 4f 9f             	lea    -0x61(%edi),%ecx
  800334:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800337:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80033a:	81 e1 df 00 00 00    	and    $0xdf,%ecx
  800340:	83 e9 41             	sub    $0x41,%ecx
  800343:	83 f9 05             	cmp    $0x5,%ecx
  800346:	77 1b                	ja     800363 <inet_aton+0xbe>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800348:	c1 e6 04             	shl    $0x4,%esi
  80034b:	83 c2 0a             	add    $0xa,%edx
  80034e:	83 7d d8 1a          	cmpl   $0x1a,-0x28(%ebp)
  800352:	19 c9                	sbb    %ecx,%ecx
  800354:	83 e1 20             	and    $0x20,%ecx
  800357:	83 c1 41             	add    $0x41,%ecx
  80035a:	29 ca                	sub    %ecx,%edx
  80035c:	09 d6                	or     %edx,%esi
        c = *++cp;
  80035e:	0f be 10             	movsbl (%eax),%edx
  800361:	eb a7                	jmp    80030a <inet_aton+0x65>
      } else
        break;
    }
    if (c == '.') {
  800363:	83 fa 2e             	cmp    $0x2e,%edx
  800366:	75 23                	jne    80038b <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	8d 7d f0             	lea    -0x10(%ebp),%edi
  80036e:	39 f8                	cmp    %edi,%eax
  800370:	0f 84 ee 00 00 00    	je     800464 <inet_aton+0x1bf>
        return (0);
      *pp++ = val;
  800376:	83 c0 04             	add    $0x4,%eax
  800379:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80037c:	89 70 fc             	mov    %esi,-0x4(%eax)
      c = *++cp;
  80037f:	8d 43 01             	lea    0x1(%ebx),%eax
  800382:	0f be 53 01          	movsbl 0x1(%ebx),%edx
    } else
      break;
  }
  800386:	e9 2f ff ff ff       	jmp    8002ba <inet_aton+0x15>
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 25                	je     8003b4 <inet_aton+0x10f>
  80038f:	8d 4f e0             	lea    -0x20(%edi),%ecx
    return (0);
  800392:	b8 00 00 00 00       	mov    $0x0,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800397:	83 f9 5f             	cmp    $0x5f,%ecx
  80039a:	0f 87 d0 00 00 00    	ja     800470 <inet_aton+0x1cb>
  8003a0:	83 fa 20             	cmp    $0x20,%edx
  8003a3:	74 0f                	je     8003b4 <inet_aton+0x10f>
  8003a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a8:	83 ea 09             	sub    $0x9,%edx
  8003ab:	83 fa 04             	cmp    $0x4,%edx
  8003ae:	0f 87 bc 00 00 00    	ja     800470 <inet_aton+0x1cb>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8003b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003ba:	29 c2                	sub    %eax,%edx
  8003bc:	c1 fa 02             	sar    $0x2,%edx
  8003bf:	83 c2 01             	add    $0x1,%edx
  8003c2:	83 fa 02             	cmp    $0x2,%edx
  8003c5:	74 20                	je     8003e7 <inet_aton+0x142>
  8003c7:	83 fa 02             	cmp    $0x2,%edx
  8003ca:	7f 0f                	jg     8003db <inet_aton+0x136>

  case 0:
    return (0);       /* initial nondigit */
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	0f 84 97 00 00 00    	je     800470 <inet_aton+0x1cb>
  8003d9:	eb 67                	jmp    800442 <inet_aton+0x19d>
  8003db:	83 fa 03             	cmp    $0x3,%edx
  8003de:	74 1e                	je     8003fe <inet_aton+0x159>
  8003e0:	83 fa 04             	cmp    $0x4,%edx
  8003e3:	74 38                	je     80041d <inet_aton+0x178>
  8003e5:	eb 5b                	jmp    800442 <inet_aton+0x19d>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  8003ec:	81 fe ff ff ff 00    	cmp    $0xffffff,%esi
  8003f2:	77 7c                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= parts[0] << 24;
  8003f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003f7:	c1 e0 18             	shl    $0x18,%eax
  8003fa:	09 c6                	or     %eax,%esi
    break;
  8003fc:	eb 44                	jmp    800442 <inet_aton+0x19d>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800403:	81 fe ff ff 00 00    	cmp    $0xffff,%esi
  800409:	77 65                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	c1 e2 18             	shl    $0x18,%edx
  800411:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800414:	c1 e0 10             	shl    $0x10,%eax
  800417:	09 d0                	or     %edx,%eax
  800419:	09 c6                	or     %eax,%esi
    break;
  80041b:	eb 25                	jmp    800442 <inet_aton+0x19d>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800422:	81 fe ff 00 00 00    	cmp    $0xff,%esi
  800428:	77 46                	ja     800470 <inet_aton+0x1cb>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80042a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042d:	c1 e2 18             	shl    $0x18,%edx
  800430:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800433:	c1 e0 10             	shl    $0x10,%eax
  800436:	09 c2                	or     %eax,%edx
  800438:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80043b:	c1 e0 08             	shl    $0x8,%eax
  80043e:	09 d0                	or     %edx,%eax
  800440:	09 c6                	or     %eax,%esi
    break;
  }
  if (addr)
  800442:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800446:	74 23                	je     80046b <inet_aton+0x1c6>
    addr->s_addr = htonl(val);
  800448:	56                   	push   %esi
  800449:	e8 2b fe ff ff       	call   800279 <htonl>
  80044e:	83 c4 04             	add    $0x4,%esp
  800451:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800454:	89 03                	mov    %eax,(%ebx)
  return (1);
  800456:	b8 01 00 00 00       	mov    $0x1,%eax
  80045b:	eb 13                	jmp    800470 <inet_aton+0x1cb>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	eb 0c                	jmp    800470 <inet_aton+0x1cb>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800464:	b8 00 00 00 00       	mov    $0x0,%eax
  800469:	eb 05                	jmp    800470 <inet_aton+0x1cb>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80046b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800473:	5b                   	pop    %ebx
  800474:	5e                   	pop    %esi
  800475:	5f                   	pop    %edi
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    

00800478 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 10             	sub    $0x10,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80047e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800481:	50                   	push   %eax
  800482:	ff 75 08             	pushl  0x8(%ebp)
  800485:	e8 1b fe ff ff       	call   8002a5 <inet_aton>
  80048a:	83 c4 08             	add    $0x8,%esp
    return (val.s_addr);
  80048d:	85 c0                	test   %eax,%eax
  80048f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800494:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
  }
  return (INADDR_NONE);
}
  800498:	c9                   	leave  
  800499:	c3                   	ret    

0080049a <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  return htonl(n);
  80049d:	ff 75 08             	pushl  0x8(%ebp)
  8004a0:	e8 d4 fd ff ff       	call   800279 <htonl>
  8004a5:	83 c4 04             	add    $0x4,%esp
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    

008004aa <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	56                   	push   %esi
  8004ae:	53                   	push   %ebx
  8004af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b2:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8004b5:	e8 ac 0a 00 00       	call   800f66 <sys_getenvid>
  8004ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004c7:	a3 18 40 80 00       	mov    %eax,0x804018

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8004cc:	85 db                	test   %ebx,%ebx
  8004ce:	7e 07                	jle    8004d7 <libmain+0x2d>
        binaryname = argv[0];
  8004d0:	8b 06                	mov    (%esi),%eax
  8004d2:	a3 04 30 80 00       	mov    %eax,0x803004

    // call user main routine
    umain(argc, argv);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
  8004dc:	e8 6d fb ff ff       	call   80004e <umain>

    // exit gracefully
    exit();
  8004e1:	e8 0a 00 00 00       	call   8004f0 <exit>
}
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004ec:	5b                   	pop    %ebx
  8004ed:	5e                   	pop    %esi
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004f6:	e8 a4 0e 00 00       	call   80139f <close_all>
	sys_env_destroy(0);
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	6a 00                	push   $0x0
  800500:	e8 20 0a 00 00       	call   800f25 <sys_env_destroy>
}
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	c9                   	leave  
  800509:	c3                   	ret    

0080050a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	53                   	push   %ebx
  80050e:	83 ec 04             	sub    $0x4,%esp
  800511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800514:	8b 13                	mov    (%ebx),%edx
  800516:	8d 42 01             	lea    0x1(%edx),%eax
  800519:	89 03                	mov    %eax,(%ebx)
  80051b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80051e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800522:	3d ff 00 00 00       	cmp    $0xff,%eax
  800527:	75 1a                	jne    800543 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	68 ff 00 00 00       	push   $0xff
  800531:	8d 43 08             	lea    0x8(%ebx),%eax
  800534:	50                   	push   %eax
  800535:	e8 ae 09 00 00       	call   800ee8 <sys_cputs>
		b->idx = 0;
  80053a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800540:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800543:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800555:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80055c:	00 00 00 
	b.cnt = 0;
  80055f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800566:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800569:	ff 75 0c             	pushl  0xc(%ebp)
  80056c:	ff 75 08             	pushl  0x8(%ebp)
  80056f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800575:	50                   	push   %eax
  800576:	68 0a 05 80 00       	push   $0x80050a
  80057b:	e8 1a 01 00 00       	call   80069a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800580:	83 c4 08             	add    $0x8,%esp
  800583:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800589:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80058f:	50                   	push   %eax
  800590:	e8 53 09 00 00       	call   800ee8 <sys_cputs>

	return b.cnt;
}
  800595:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80059b:	c9                   	leave  
  80059c:	c3                   	ret    

0080059d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
  8005a0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005a6:	50                   	push   %eax
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 9d ff ff ff       	call   80054c <vcprintf>
	va_end(ap);

	return cnt;
}
  8005af:	c9                   	leave  
  8005b0:	c3                   	ret    

008005b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b1:	55                   	push   %ebp
  8005b2:	89 e5                	mov    %esp,%ebp
  8005b4:	57                   	push   %edi
  8005b5:	56                   	push   %esi
  8005b6:	53                   	push   %ebx
  8005b7:	83 ec 1c             	sub    $0x1c,%esp
  8005ba:	89 c7                	mov    %eax,%edi
  8005bc:	89 d6                	mov    %edx,%esi
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005d5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005d8:	39 d3                	cmp    %edx,%ebx
  8005da:	72 05                	jb     8005e1 <printnum+0x30>
  8005dc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8005df:	77 45                	ja     800626 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005e1:	83 ec 0c             	sub    $0xc,%esp
  8005e4:	ff 75 18             	pushl  0x18(%ebp)
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005ed:	53                   	push   %ebx
  8005ee:	ff 75 10             	pushl  0x10(%ebp)
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8005fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800600:	e8 9b 1e 00 00       	call   8024a0 <__udivdi3>
  800605:	83 c4 18             	add    $0x18,%esp
  800608:	52                   	push   %edx
  800609:	50                   	push   %eax
  80060a:	89 f2                	mov    %esi,%edx
  80060c:	89 f8                	mov    %edi,%eax
  80060e:	e8 9e ff ff ff       	call   8005b1 <printnum>
  800613:	83 c4 20             	add    $0x20,%esp
  800616:	eb 18                	jmp    800630 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	56                   	push   %esi
  80061c:	ff 75 18             	pushl  0x18(%ebp)
  80061f:	ff d7                	call   *%edi
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	eb 03                	jmp    800629 <printnum+0x78>
  800626:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800629:	83 eb 01             	sub    $0x1,%ebx
  80062c:	85 db                	test   %ebx,%ebx
  80062e:	7f e8                	jg     800618 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	83 ec 04             	sub    $0x4,%esp
  800637:	ff 75 e4             	pushl  -0x1c(%ebp)
  80063a:	ff 75 e0             	pushl  -0x20(%ebp)
  80063d:	ff 75 dc             	pushl  -0x24(%ebp)
  800640:	ff 75 d8             	pushl  -0x28(%ebp)
  800643:	e8 88 1f 00 00       	call   8025d0 <__umoddi3>
  800648:	83 c4 14             	add    $0x14,%esp
  80064b:	0f be 80 56 28 80 00 	movsbl 0x802856(%eax),%eax
  800652:	50                   	push   %eax
  800653:	ff d7                	call   *%edi
}
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065b:	5b                   	pop    %ebx
  80065c:	5e                   	pop    %esi
  80065d:	5f                   	pop    %edi
  80065e:	5d                   	pop    %ebp
  80065f:	c3                   	ret    

00800660 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800666:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	3b 50 04             	cmp    0x4(%eax),%edx
  80066f:	73 0a                	jae    80067b <sprintputch+0x1b>
		*b->buf++ = ch;
  800671:	8d 4a 01             	lea    0x1(%edx),%ecx
  800674:	89 08                	mov    %ecx,(%eax)
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	88 02                	mov    %al,(%edx)
}
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800686:	50                   	push   %eax
  800687:	ff 75 10             	pushl  0x10(%ebp)
  80068a:	ff 75 0c             	pushl  0xc(%ebp)
  80068d:	ff 75 08             	pushl  0x8(%ebp)
  800690:	e8 05 00 00 00       	call   80069a <vprintfmt>
	va_end(ap);
}
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	c9                   	leave  
  800699:	c3                   	ret    

0080069a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	57                   	push   %edi
  80069e:	56                   	push   %esi
  80069f:	53                   	push   %ebx
  8006a0:	83 ec 2c             	sub    $0x2c,%esp
  8006a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006ac:	eb 12                	jmp    8006c0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	0f 84 42 04 00 00    	je     800af8 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	50                   	push   %eax
  8006bb:	ff d6                	call   *%esi
  8006bd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c0:	83 c7 01             	add    $0x1,%edi
  8006c3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c7:	83 f8 25             	cmp    $0x25,%eax
  8006ca:	75 e2                	jne    8006ae <vprintfmt+0x14>
  8006cc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8006d0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006d7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006de:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ea:	eb 07                	jmp    8006f3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8006ef:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f3:	8d 47 01             	lea    0x1(%edi),%eax
  8006f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f9:	0f b6 07             	movzbl (%edi),%eax
  8006fc:	0f b6 d0             	movzbl %al,%edx
  8006ff:	83 e8 23             	sub    $0x23,%eax
  800702:	3c 55                	cmp    $0x55,%al
  800704:	0f 87 d3 03 00 00    	ja     800add <vprintfmt+0x443>
  80070a:	0f b6 c0             	movzbl %al,%eax
  80070d:	ff 24 85 a0 29 80 00 	jmp    *0x8029a0(,%eax,4)
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800717:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80071b:	eb d6                	jmp    8006f3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800720:	b8 00 00 00 00       	mov    $0x0,%eax
  800725:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800728:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80072b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80072f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800732:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800735:	83 f9 09             	cmp    $0x9,%ecx
  800738:	77 3f                	ja     800779 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80073a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80073d:	eb e9                	jmp    800728 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	8b 00                	mov    (%eax),%eax
  800744:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800750:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800753:	eb 2a                	jmp    80077f <vprintfmt+0xe5>
  800755:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800758:	85 c0                	test   %eax,%eax
  80075a:	ba 00 00 00 00       	mov    $0x0,%edx
  80075f:	0f 49 d0             	cmovns %eax,%edx
  800762:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800768:	eb 89                	jmp    8006f3 <vprintfmt+0x59>
  80076a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80076d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800774:	e9 7a ff ff ff       	jmp    8006f3 <vprintfmt+0x59>
  800779:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80077c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80077f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800783:	0f 89 6a ff ff ff    	jns    8006f3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800789:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80078c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80078f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800796:	e9 58 ff ff ff       	jmp    8006f3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80079b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8007a1:	e9 4d ff ff ff       	jmp    8006f3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 78 04             	lea    0x4(%eax),%edi
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	53                   	push   %ebx
  8007b0:	ff 30                	pushl  (%eax)
  8007b2:	ff d6                	call   *%esi
			break;
  8007b4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007b7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8007bd:	e9 fe fe ff ff       	jmp    8006c0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 78 04             	lea    0x4(%eax),%edi
  8007c8:	8b 00                	mov    (%eax),%eax
  8007ca:	99                   	cltd   
  8007cb:	31 d0                	xor    %edx,%eax
  8007cd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007cf:	83 f8 0f             	cmp    $0xf,%eax
  8007d2:	7f 0b                	jg     8007df <vprintfmt+0x145>
  8007d4:	8b 14 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%edx
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	75 1b                	jne    8007fa <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8007df:	50                   	push   %eax
  8007e0:	68 6e 28 80 00       	push   $0x80286e
  8007e5:	53                   	push   %ebx
  8007e6:	56                   	push   %esi
  8007e7:	e8 91 fe ff ff       	call   80067d <printfmt>
  8007ec:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ef:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8007f5:	e9 c6 fe ff ff       	jmp    8006c0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8007fa:	52                   	push   %edx
  8007fb:	68 35 2c 80 00       	push   $0x802c35
  800800:	53                   	push   %ebx
  800801:	56                   	push   %esi
  800802:	e8 76 fe ff ff       	call   80067d <printfmt>
  800807:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800810:	e9 ab fe ff ff       	jmp    8006c0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	83 c0 04             	add    $0x4,%eax
  80081b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800823:	85 ff                	test   %edi,%edi
  800825:	b8 67 28 80 00       	mov    $0x802867,%eax
  80082a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80082d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800831:	0f 8e 94 00 00 00    	jle    8008cb <vprintfmt+0x231>
  800837:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80083b:	0f 84 98 00 00 00    	je     8008d9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	ff 75 d0             	pushl  -0x30(%ebp)
  800847:	57                   	push   %edi
  800848:	e8 33 03 00 00       	call   800b80 <strnlen>
  80084d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800850:	29 c1                	sub    %eax,%ecx
  800852:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800855:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800858:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80085c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80085f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800862:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800864:	eb 0f                	jmp    800875 <vprintfmt+0x1db>
					putch(padc, putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	ff 75 e0             	pushl  -0x20(%ebp)
  80086d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80086f:	83 ef 01             	sub    $0x1,%edi
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	85 ff                	test   %edi,%edi
  800877:	7f ed                	jg     800866 <vprintfmt+0x1cc>
  800879:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80087c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80087f:	85 c9                	test   %ecx,%ecx
  800881:	b8 00 00 00 00       	mov    $0x0,%eax
  800886:	0f 49 c1             	cmovns %ecx,%eax
  800889:	29 c1                	sub    %eax,%ecx
  80088b:	89 75 08             	mov    %esi,0x8(%ebp)
  80088e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800891:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800894:	89 cb                	mov    %ecx,%ebx
  800896:	eb 4d                	jmp    8008e5 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800898:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80089c:	74 1b                	je     8008b9 <vprintfmt+0x21f>
  80089e:	0f be c0             	movsbl %al,%eax
  8008a1:	83 e8 20             	sub    $0x20,%eax
  8008a4:	83 f8 5e             	cmp    $0x5e,%eax
  8008a7:	76 10                	jbe    8008b9 <vprintfmt+0x21f>
					putch('?', putdat);
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	6a 3f                	push   $0x3f
  8008b1:	ff 55 08             	call   *0x8(%ebp)
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 0d                	jmp    8008c6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8008b9:	83 ec 08             	sub    $0x8,%esp
  8008bc:	ff 75 0c             	pushl  0xc(%ebp)
  8008bf:	52                   	push   %edx
  8008c0:	ff 55 08             	call   *0x8(%ebp)
  8008c3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c6:	83 eb 01             	sub    $0x1,%ebx
  8008c9:	eb 1a                	jmp    8008e5 <vprintfmt+0x24b>
  8008cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8008ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008d7:	eb 0c                	jmp    8008e5 <vprintfmt+0x24b>
  8008d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8008dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8008e5:	83 c7 01             	add    $0x1,%edi
  8008e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ec:	0f be d0             	movsbl %al,%edx
  8008ef:	85 d2                	test   %edx,%edx
  8008f1:	74 23                	je     800916 <vprintfmt+0x27c>
  8008f3:	85 f6                	test   %esi,%esi
  8008f5:	78 a1                	js     800898 <vprintfmt+0x1fe>
  8008f7:	83 ee 01             	sub    $0x1,%esi
  8008fa:	79 9c                	jns    800898 <vprintfmt+0x1fe>
  8008fc:	89 df                	mov    %ebx,%edi
  8008fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800901:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800904:	eb 18                	jmp    80091e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	53                   	push   %ebx
  80090a:	6a 20                	push   $0x20
  80090c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80090e:	83 ef 01             	sub    $0x1,%edi
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	eb 08                	jmp    80091e <vprintfmt+0x284>
  800916:	89 df                	mov    %ebx,%edi
  800918:	8b 75 08             	mov    0x8(%ebp),%esi
  80091b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80091e:	85 ff                	test   %edi,%edi
  800920:	7f e4                	jg     800906 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800922:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800925:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800928:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092b:	e9 90 fd ff ff       	jmp    8006c0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800930:	83 f9 01             	cmp    $0x1,%ecx
  800933:	7e 19                	jle    80094e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800935:	8b 45 14             	mov    0x14(%ebp),%eax
  800938:	8b 50 04             	mov    0x4(%eax),%edx
  80093b:	8b 00                	mov    (%eax),%eax
  80093d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800940:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800943:	8b 45 14             	mov    0x14(%ebp),%eax
  800946:	8d 40 08             	lea    0x8(%eax),%eax
  800949:	89 45 14             	mov    %eax,0x14(%ebp)
  80094c:	eb 38                	jmp    800986 <vprintfmt+0x2ec>
	else if (lflag)
  80094e:	85 c9                	test   %ecx,%ecx
  800950:	74 1b                	je     80096d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800952:	8b 45 14             	mov    0x14(%ebp),%eax
  800955:	8b 00                	mov    (%eax),%eax
  800957:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80095a:	89 c1                	mov    %eax,%ecx
  80095c:	c1 f9 1f             	sar    $0x1f,%ecx
  80095f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	8d 40 04             	lea    0x4(%eax),%eax
  800968:	89 45 14             	mov    %eax,0x14(%ebp)
  80096b:	eb 19                	jmp    800986 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80096d:	8b 45 14             	mov    0x14(%ebp),%eax
  800970:	8b 00                	mov    (%eax),%eax
  800972:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800975:	89 c1                	mov    %eax,%ecx
  800977:	c1 f9 1f             	sar    $0x1f,%ecx
  80097a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80097d:	8b 45 14             	mov    0x14(%ebp),%eax
  800980:	8d 40 04             	lea    0x4(%eax),%eax
  800983:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800986:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800989:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80098c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800991:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800995:	0f 89 0e 01 00 00    	jns    800aa9 <vprintfmt+0x40f>
				putch('-', putdat);
  80099b:	83 ec 08             	sub    $0x8,%esp
  80099e:	53                   	push   %ebx
  80099f:	6a 2d                	push   $0x2d
  8009a1:	ff d6                	call   *%esi
				num = -(long long) num;
  8009a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009a9:	f7 da                	neg    %edx
  8009ab:	83 d1 00             	adc    $0x0,%ecx
  8009ae:	f7 d9                	neg    %ecx
  8009b0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8009b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b8:	e9 ec 00 00 00       	jmp    800aa9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009bd:	83 f9 01             	cmp    $0x1,%ecx
  8009c0:	7e 18                	jle    8009da <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8b 10                	mov    (%eax),%edx
  8009c7:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ca:	8d 40 08             	lea    0x8(%eax),%eax
  8009cd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8009d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d5:	e9 cf 00 00 00       	jmp    800aa9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	74 1a                	je     8009f8 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8009de:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e1:	8b 10                	mov    (%eax),%edx
  8009e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e8:	8d 40 04             	lea    0x4(%eax),%eax
  8009eb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8009ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f3:	e9 b1 00 00 00       	jmp    800aa9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8009f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fb:	8b 10                	mov    (%eax),%edx
  8009fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a02:	8d 40 04             	lea    0x4(%eax),%eax
  800a05:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800a08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0d:	e9 97 00 00 00       	jmp    800aa9 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a12:	83 ec 08             	sub    $0x8,%esp
  800a15:	53                   	push   %ebx
  800a16:	6a 58                	push   $0x58
  800a18:	ff d6                	call   *%esi
			putch('X', putdat);
  800a1a:	83 c4 08             	add    $0x8,%esp
  800a1d:	53                   	push   %ebx
  800a1e:	6a 58                	push   $0x58
  800a20:	ff d6                	call   *%esi
			putch('X', putdat);
  800a22:	83 c4 08             	add    $0x8,%esp
  800a25:	53                   	push   %ebx
  800a26:	6a 58                	push   $0x58
  800a28:	ff d6                	call   *%esi
			break;
  800a2a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800a30:	e9 8b fc ff ff       	jmp    8006c0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800a35:	83 ec 08             	sub    $0x8,%esp
  800a38:	53                   	push   %ebx
  800a39:	6a 30                	push   $0x30
  800a3b:	ff d6                	call   *%esi
			putch('x', putdat);
  800a3d:	83 c4 08             	add    $0x8,%esp
  800a40:	53                   	push   %ebx
  800a41:	6a 78                	push   $0x78
  800a43:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a45:	8b 45 14             	mov    0x14(%ebp),%eax
  800a48:	8b 10                	mov    (%eax),%edx
  800a4a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a4f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a52:	8d 40 04             	lea    0x4(%eax),%eax
  800a55:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a58:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a5d:	eb 4a                	jmp    800aa9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a5f:	83 f9 01             	cmp    $0x1,%ecx
  800a62:	7e 15                	jle    800a79 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800a64:	8b 45 14             	mov    0x14(%ebp),%eax
  800a67:	8b 10                	mov    (%eax),%edx
  800a69:	8b 48 04             	mov    0x4(%eax),%ecx
  800a6c:	8d 40 08             	lea    0x8(%eax),%eax
  800a6f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a72:	b8 10 00 00 00       	mov    $0x10,%eax
  800a77:	eb 30                	jmp    800aa9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	74 17                	je     800a94 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800a7d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a80:	8b 10                	mov    (%eax),%edx
  800a82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a87:	8d 40 04             	lea    0x4(%eax),%eax
  800a8a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800a8d:	b8 10 00 00 00       	mov    $0x10,%eax
  800a92:	eb 15                	jmp    800aa9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800a94:	8b 45 14             	mov    0x14(%ebp),%eax
  800a97:	8b 10                	mov    (%eax),%edx
  800a99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9e:	8d 40 04             	lea    0x4(%eax),%eax
  800aa1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800aa4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800ab0:	57                   	push   %edi
  800ab1:	ff 75 e0             	pushl  -0x20(%ebp)
  800ab4:	50                   	push   %eax
  800ab5:	51                   	push   %ecx
  800ab6:	52                   	push   %edx
  800ab7:	89 da                	mov    %ebx,%edx
  800ab9:	89 f0                	mov    %esi,%eax
  800abb:	e8 f1 fa ff ff       	call   8005b1 <printnum>
			break;
  800ac0:	83 c4 20             	add    $0x20,%esp
  800ac3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ac6:	e9 f5 fb ff ff       	jmp    8006c0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800acb:	83 ec 08             	sub    $0x8,%esp
  800ace:	53                   	push   %ebx
  800acf:	52                   	push   %edx
  800ad0:	ff d6                	call   *%esi
			break;
  800ad2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ad5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ad8:	e9 e3 fb ff ff       	jmp    8006c0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800add:	83 ec 08             	sub    $0x8,%esp
  800ae0:	53                   	push   %ebx
  800ae1:	6a 25                	push   $0x25
  800ae3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae5:	83 c4 10             	add    $0x10,%esp
  800ae8:	eb 03                	jmp    800aed <vprintfmt+0x453>
  800aea:	83 ef 01             	sub    $0x1,%edi
  800aed:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800af1:	75 f7                	jne    800aea <vprintfmt+0x450>
  800af3:	e9 c8 fb ff ff       	jmp    8006c0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	83 ec 18             	sub    $0x18,%esp
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b0f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b13:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	74 26                	je     800b47 <vsnprintf+0x47>
  800b21:	85 d2                	test   %edx,%edx
  800b23:	7e 22                	jle    800b47 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b25:	ff 75 14             	pushl  0x14(%ebp)
  800b28:	ff 75 10             	pushl  0x10(%ebp)
  800b2b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b2e:	50                   	push   %eax
  800b2f:	68 60 06 80 00       	push   $0x800660
  800b34:	e8 61 fb ff ff       	call   80069a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b39:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b3c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	eb 05                	jmp    800b4c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b54:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b57:	50                   	push   %eax
  800b58:	ff 75 10             	pushl  0x10(%ebp)
  800b5b:	ff 75 0c             	pushl  0xc(%ebp)
  800b5e:	ff 75 08             	pushl  0x8(%ebp)
  800b61:	e8 9a ff ff ff       	call   800b00 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b73:	eb 03                	jmp    800b78 <strlen+0x10>
		n++;
  800b75:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b78:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b7c:	75 f7                	jne    800b75 <strlen+0xd>
		n++;
	return n;
}
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b86:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b89:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8e:	eb 03                	jmp    800b93 <strnlen+0x13>
		n++;
  800b90:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b93:	39 c2                	cmp    %eax,%edx
  800b95:	74 08                	je     800b9f <strnlen+0x1f>
  800b97:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b9b:	75 f3                	jne    800b90 <strnlen+0x10>
  800b9d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	53                   	push   %ebx
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bab:	89 c2                	mov    %eax,%edx
  800bad:	83 c2 01             	add    $0x1,%edx
  800bb0:	83 c1 01             	add    $0x1,%ecx
  800bb3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800bb7:	88 5a ff             	mov    %bl,-0x1(%edx)
  800bba:	84 db                	test   %bl,%bl
  800bbc:	75 ef                	jne    800bad <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	53                   	push   %ebx
  800bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bc8:	53                   	push   %ebx
  800bc9:	e8 9a ff ff ff       	call   800b68 <strlen>
  800bce:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800bd1:	ff 75 0c             	pushl  0xc(%ebp)
  800bd4:	01 d8                	add    %ebx,%eax
  800bd6:	50                   	push   %eax
  800bd7:	e8 c5 ff ff ff       	call   800ba1 <strcpy>
	return dst;
}
  800bdc:	89 d8                	mov    %ebx,%eax
  800bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 75 08             	mov    0x8(%ebp),%esi
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	89 f3                	mov    %esi,%ebx
  800bf0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf3:	89 f2                	mov    %esi,%edx
  800bf5:	eb 0f                	jmp    800c06 <strncpy+0x23>
		*dst++ = *src;
  800bf7:	83 c2 01             	add    $0x1,%edx
  800bfa:	0f b6 01             	movzbl (%ecx),%eax
  800bfd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c00:	80 39 01             	cmpb   $0x1,(%ecx)
  800c03:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c06:	39 da                	cmp    %ebx,%edx
  800c08:	75 ed                	jne    800bf7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c0a:	89 f0                	mov    %esi,%eax
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	8b 75 08             	mov    0x8(%ebp),%esi
  800c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1b:	8b 55 10             	mov    0x10(%ebp),%edx
  800c1e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c20:	85 d2                	test   %edx,%edx
  800c22:	74 21                	je     800c45 <strlcpy+0x35>
  800c24:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c28:	89 f2                	mov    %esi,%edx
  800c2a:	eb 09                	jmp    800c35 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c2c:	83 c2 01             	add    $0x1,%edx
  800c2f:	83 c1 01             	add    $0x1,%ecx
  800c32:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c35:	39 c2                	cmp    %eax,%edx
  800c37:	74 09                	je     800c42 <strlcpy+0x32>
  800c39:	0f b6 19             	movzbl (%ecx),%ebx
  800c3c:	84 db                	test   %bl,%bl
  800c3e:	75 ec                	jne    800c2c <strlcpy+0x1c>
  800c40:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c42:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c45:	29 f0                	sub    %esi,%eax
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c51:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c54:	eb 06                	jmp    800c5c <strcmp+0x11>
		p++, q++;
  800c56:	83 c1 01             	add    $0x1,%ecx
  800c59:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c5c:	0f b6 01             	movzbl (%ecx),%eax
  800c5f:	84 c0                	test   %al,%al
  800c61:	74 04                	je     800c67 <strcmp+0x1c>
  800c63:	3a 02                	cmp    (%edx),%al
  800c65:	74 ef                	je     800c56 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c67:	0f b6 c0             	movzbl %al,%eax
  800c6a:	0f b6 12             	movzbl (%edx),%edx
  800c6d:	29 d0                	sub    %edx,%eax
}
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	53                   	push   %ebx
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7b:	89 c3                	mov    %eax,%ebx
  800c7d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c80:	eb 06                	jmp    800c88 <strncmp+0x17>
		n--, p++, q++;
  800c82:	83 c0 01             	add    $0x1,%eax
  800c85:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c88:	39 d8                	cmp    %ebx,%eax
  800c8a:	74 15                	je     800ca1 <strncmp+0x30>
  800c8c:	0f b6 08             	movzbl (%eax),%ecx
  800c8f:	84 c9                	test   %cl,%cl
  800c91:	74 04                	je     800c97 <strncmp+0x26>
  800c93:	3a 0a                	cmp    (%edx),%cl
  800c95:	74 eb                	je     800c82 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c97:	0f b6 00             	movzbl (%eax),%eax
  800c9a:	0f b6 12             	movzbl (%edx),%edx
  800c9d:	29 d0                	sub    %edx,%eax
  800c9f:	eb 05                	jmp    800ca6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cb3:	eb 07                	jmp    800cbc <strchr+0x13>
		if (*s == c)
  800cb5:	38 ca                	cmp    %cl,%dl
  800cb7:	74 0f                	je     800cc8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cb9:	83 c0 01             	add    $0x1,%eax
  800cbc:	0f b6 10             	movzbl (%eax),%edx
  800cbf:	84 d2                	test   %dl,%dl
  800cc1:	75 f2                	jne    800cb5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd4:	eb 03                	jmp    800cd9 <strfind+0xf>
  800cd6:	83 c0 01             	add    $0x1,%eax
  800cd9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cdc:	38 ca                	cmp    %cl,%dl
  800cde:	74 04                	je     800ce4 <strfind+0x1a>
  800ce0:	84 d2                	test   %dl,%dl
  800ce2:	75 f2                	jne    800cd6 <strfind+0xc>
			break;
	return (char *) s;
}
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cf2:	85 c9                	test   %ecx,%ecx
  800cf4:	74 36                	je     800d2c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cf6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cfc:	75 28                	jne    800d26 <memset+0x40>
  800cfe:	f6 c1 03             	test   $0x3,%cl
  800d01:	75 23                	jne    800d26 <memset+0x40>
		c &= 0xFF;
  800d03:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d07:	89 d3                	mov    %edx,%ebx
  800d09:	c1 e3 08             	shl    $0x8,%ebx
  800d0c:	89 d6                	mov    %edx,%esi
  800d0e:	c1 e6 18             	shl    $0x18,%esi
  800d11:	89 d0                	mov    %edx,%eax
  800d13:	c1 e0 10             	shl    $0x10,%eax
  800d16:	09 f0                	or     %esi,%eax
  800d18:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800d1a:	89 d8                	mov    %ebx,%eax
  800d1c:	09 d0                	or     %edx,%eax
  800d1e:	c1 e9 02             	shr    $0x2,%ecx
  800d21:	fc                   	cld    
  800d22:	f3 ab                	rep stos %eax,%es:(%edi)
  800d24:	eb 06                	jmp    800d2c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d29:	fc                   	cld    
  800d2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d2c:	89 f8                	mov    %edi,%eax
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d41:	39 c6                	cmp    %eax,%esi
  800d43:	73 35                	jae    800d7a <memmove+0x47>
  800d45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d48:	39 d0                	cmp    %edx,%eax
  800d4a:	73 2e                	jae    800d7a <memmove+0x47>
		s += n;
		d += n;
  800d4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	09 fe                	or     %edi,%esi
  800d53:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d59:	75 13                	jne    800d6e <memmove+0x3b>
  800d5b:	f6 c1 03             	test   $0x3,%cl
  800d5e:	75 0e                	jne    800d6e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800d60:	83 ef 04             	sub    $0x4,%edi
  800d63:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d66:	c1 e9 02             	shr    $0x2,%ecx
  800d69:	fd                   	std    
  800d6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d6c:	eb 09                	jmp    800d77 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d6e:	83 ef 01             	sub    $0x1,%edi
  800d71:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d74:	fd                   	std    
  800d75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d77:	fc                   	cld    
  800d78:	eb 1d                	jmp    800d97 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d7a:	89 f2                	mov    %esi,%edx
  800d7c:	09 c2                	or     %eax,%edx
  800d7e:	f6 c2 03             	test   $0x3,%dl
  800d81:	75 0f                	jne    800d92 <memmove+0x5f>
  800d83:	f6 c1 03             	test   $0x3,%cl
  800d86:	75 0a                	jne    800d92 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800d88:	c1 e9 02             	shr    $0x2,%ecx
  800d8b:	89 c7                	mov    %eax,%edi
  800d8d:	fc                   	cld    
  800d8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d90:	eb 05                	jmp    800d97 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d92:	89 c7                	mov    %eax,%edi
  800d94:	fc                   	cld    
  800d95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d9e:	ff 75 10             	pushl  0x10(%ebp)
  800da1:	ff 75 0c             	pushl  0xc(%ebp)
  800da4:	ff 75 08             	pushl  0x8(%ebp)
  800da7:	e8 87 ff ff ff       	call   800d33 <memmove>
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db9:	89 c6                	mov    %eax,%esi
  800dbb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbe:	eb 1a                	jmp    800dda <memcmp+0x2c>
		if (*s1 != *s2)
  800dc0:	0f b6 08             	movzbl (%eax),%ecx
  800dc3:	0f b6 1a             	movzbl (%edx),%ebx
  800dc6:	38 d9                	cmp    %bl,%cl
  800dc8:	74 0a                	je     800dd4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800dca:	0f b6 c1             	movzbl %cl,%eax
  800dcd:	0f b6 db             	movzbl %bl,%ebx
  800dd0:	29 d8                	sub    %ebx,%eax
  800dd2:	eb 0f                	jmp    800de3 <memcmp+0x35>
		s1++, s2++;
  800dd4:	83 c0 01             	add    $0x1,%eax
  800dd7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dda:	39 f0                	cmp    %esi,%eax
  800ddc:	75 e2                	jne    800dc0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800dde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	53                   	push   %ebx
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dee:	89 c1                	mov    %eax,%ecx
  800df0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800df3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800df7:	eb 0a                	jmp    800e03 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800df9:	0f b6 10             	movzbl (%eax),%edx
  800dfc:	39 da                	cmp    %ebx,%edx
  800dfe:	74 07                	je     800e07 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e00:	83 c0 01             	add    $0x1,%eax
  800e03:	39 c8                	cmp    %ecx,%eax
  800e05:	72 f2                	jb     800df9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e07:	5b                   	pop    %ebx
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e16:	eb 03                	jmp    800e1b <strtol+0x11>
		s++;
  800e18:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1b:	0f b6 01             	movzbl (%ecx),%eax
  800e1e:	3c 20                	cmp    $0x20,%al
  800e20:	74 f6                	je     800e18 <strtol+0xe>
  800e22:	3c 09                	cmp    $0x9,%al
  800e24:	74 f2                	je     800e18 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e26:	3c 2b                	cmp    $0x2b,%al
  800e28:	75 0a                	jne    800e34 <strtol+0x2a>
		s++;
  800e2a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e2d:	bf 00 00 00 00       	mov    $0x0,%edi
  800e32:	eb 11                	jmp    800e45 <strtol+0x3b>
  800e34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e39:	3c 2d                	cmp    $0x2d,%al
  800e3b:	75 08                	jne    800e45 <strtol+0x3b>
		s++, neg = 1;
  800e3d:	83 c1 01             	add    $0x1,%ecx
  800e40:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e45:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e4b:	75 15                	jne    800e62 <strtol+0x58>
  800e4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800e50:	75 10                	jne    800e62 <strtol+0x58>
  800e52:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e56:	75 7c                	jne    800ed4 <strtol+0xca>
		s += 2, base = 16;
  800e58:	83 c1 02             	add    $0x2,%ecx
  800e5b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e60:	eb 16                	jmp    800e78 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800e62:	85 db                	test   %ebx,%ebx
  800e64:	75 12                	jne    800e78 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e66:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800e6e:	75 08                	jne    800e78 <strtol+0x6e>
		s++, base = 8;
  800e70:	83 c1 01             	add    $0x1,%ecx
  800e73:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e80:	0f b6 11             	movzbl (%ecx),%edx
  800e83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e86:	89 f3                	mov    %esi,%ebx
  800e88:	80 fb 09             	cmp    $0x9,%bl
  800e8b:	77 08                	ja     800e95 <strtol+0x8b>
			dig = *s - '0';
  800e8d:	0f be d2             	movsbl %dl,%edx
  800e90:	83 ea 30             	sub    $0x30,%edx
  800e93:	eb 22                	jmp    800eb7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800e95:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e98:	89 f3                	mov    %esi,%ebx
  800e9a:	80 fb 19             	cmp    $0x19,%bl
  800e9d:	77 08                	ja     800ea7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800e9f:	0f be d2             	movsbl %dl,%edx
  800ea2:	83 ea 57             	sub    $0x57,%edx
  800ea5:	eb 10                	jmp    800eb7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ea7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eaa:	89 f3                	mov    %esi,%ebx
  800eac:	80 fb 19             	cmp    $0x19,%bl
  800eaf:	77 16                	ja     800ec7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800eb1:	0f be d2             	movsbl %dl,%edx
  800eb4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800eb7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800eba:	7d 0b                	jge    800ec7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ebc:	83 c1 01             	add    $0x1,%ecx
  800ebf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ec3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ec5:	eb b9                	jmp    800e80 <strtol+0x76>

	if (endptr)
  800ec7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ecb:	74 0d                	je     800eda <strtol+0xd0>
		*endptr = (char *) s;
  800ecd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed0:	89 0e                	mov    %ecx,(%esi)
  800ed2:	eb 06                	jmp    800eda <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ed4:	85 db                	test   %ebx,%ebx
  800ed6:	74 98                	je     800e70 <strtol+0x66>
  800ed8:	eb 9e                	jmp    800e78 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	f7 da                	neg    %edx
  800ede:	85 ff                	test   %edi,%edi
  800ee0:	0f 45 c2             	cmovne %edx,%eax
}
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef9:	89 c3                	mov    %eax,%ebx
  800efb:	89 c7                	mov    %eax,%edi
  800efd:	89 c6                	mov    %eax,%esi
  800eff:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f11:	b8 01 00 00 00       	mov    $0x1,%eax
  800f16:	89 d1                	mov    %edx,%ecx
  800f18:	89 d3                	mov    %edx,%ebx
  800f1a:	89 d7                	mov    %edx,%edi
  800f1c:	89 d6                	mov    %edx,%esi
  800f1e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	57                   	push   %edi
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f33:	b8 03 00 00 00       	mov    $0x3,%eax
  800f38:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3b:	89 cb                	mov    %ecx,%ebx
  800f3d:	89 cf                	mov    %ecx,%edi
  800f3f:	89 ce                	mov    %ecx,%esi
  800f41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f43:	85 c0                	test   %eax,%eax
  800f45:	7e 17                	jle    800f5e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	50                   	push   %eax
  800f4b:	6a 03                	push   $0x3
  800f4d:	68 5f 2b 80 00       	push   $0x802b5f
  800f52:	6a 23                	push   $0x23
  800f54:	68 7c 2b 80 00       	push   $0x802b7c
  800f59:	e8 c7 13 00 00       	call   802325 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f61:	5b                   	pop    %ebx
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f71:	b8 02 00 00 00       	mov    $0x2,%eax
  800f76:	89 d1                	mov    %edx,%ecx
  800f78:	89 d3                	mov    %edx,%ebx
  800f7a:	89 d7                	mov    %edx,%edi
  800f7c:	89 d6                	mov    %edx,%esi
  800f7e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <sys_yield>:

void
sys_yield(void)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	57                   	push   %edi
  800f89:	56                   	push   %esi
  800f8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f90:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f95:	89 d1                	mov    %edx,%ecx
  800f97:	89 d3                	mov    %edx,%ebx
  800f99:	89 d7                	mov    %edx,%edi
  800f9b:	89 d6                	mov    %edx,%esi
  800f9d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	57                   	push   %edi
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fad:	be 00 00 00 00       	mov    $0x0,%esi
  800fb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fba:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fc0:	89 f7                	mov    %esi,%edi
  800fc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	7e 17                	jle    800fdf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc8:	83 ec 0c             	sub    $0xc,%esp
  800fcb:	50                   	push   %eax
  800fcc:	6a 04                	push   $0x4
  800fce:	68 5f 2b 80 00       	push   $0x802b5f
  800fd3:	6a 23                	push   $0x23
  800fd5:	68 7c 2b 80 00       	push   $0x802b7c
  800fda:	e8 46 13 00 00       	call   802325 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ff5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ffe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801001:	8b 75 18             	mov    0x18(%ebp),%esi
  801004:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801006:	85 c0                	test   %eax,%eax
  801008:	7e 17                	jle    801021 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	50                   	push   %eax
  80100e:	6a 05                	push   $0x5
  801010:	68 5f 2b 80 00       	push   $0x802b5f
  801015:	6a 23                	push   $0x23
  801017:	68 7c 2b 80 00       	push   $0x802b7c
  80101c:	e8 04 13 00 00       	call   802325 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801021:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801024:	5b                   	pop    %ebx
  801025:	5e                   	pop    %esi
  801026:	5f                   	pop    %edi
  801027:	5d                   	pop    %ebp
  801028:	c3                   	ret    

00801029 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	57                   	push   %edi
  80102d:	56                   	push   %esi
  80102e:	53                   	push   %ebx
  80102f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801032:	bb 00 00 00 00       	mov    $0x0,%ebx
  801037:	b8 06 00 00 00       	mov    $0x6,%eax
  80103c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80103f:	8b 55 08             	mov    0x8(%ebp),%edx
  801042:	89 df                	mov    %ebx,%edi
  801044:	89 de                	mov    %ebx,%esi
  801046:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801048:	85 c0                	test   %eax,%eax
  80104a:	7e 17                	jle    801063 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	50                   	push   %eax
  801050:	6a 06                	push   $0x6
  801052:	68 5f 2b 80 00       	push   $0x802b5f
  801057:	6a 23                	push   $0x23
  801059:	68 7c 2b 80 00       	push   $0x802b7c
  80105e:	e8 c2 12 00 00       	call   802325 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801063:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	bb 00 00 00 00       	mov    $0x0,%ebx
  801079:	b8 08 00 00 00       	mov    $0x8,%eax
  80107e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801081:	8b 55 08             	mov    0x8(%ebp),%edx
  801084:	89 df                	mov    %ebx,%edi
  801086:	89 de                	mov    %ebx,%esi
  801088:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108a:	85 c0                	test   %eax,%eax
  80108c:	7e 17                	jle    8010a5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	50                   	push   %eax
  801092:	6a 08                	push   $0x8
  801094:	68 5f 2b 80 00       	push   $0x802b5f
  801099:	6a 23                	push   $0x23
  80109b:	68 7c 2b 80 00       	push   $0x802b7c
  8010a0:	e8 80 12 00 00       	call   802325 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5f                   	pop    %edi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	57                   	push   %edi
  8010b1:	56                   	push   %esi
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bb:	b8 09 00 00 00       	mov    $0x9,%eax
  8010c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c6:	89 df                	mov    %ebx,%edi
  8010c8:	89 de                	mov    %ebx,%esi
  8010ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	7e 17                	jle    8010e7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	50                   	push   %eax
  8010d4:	6a 09                	push   $0x9
  8010d6:	68 5f 2b 80 00       	push   $0x802b5f
  8010db:	6a 23                	push   $0x23
  8010dd:	68 7c 2b 80 00       	push   $0x802b7c
  8010e2:	e8 3e 12 00 00       	call   802325 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8010e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5e                   	pop    %esi
  8010ec:	5f                   	pop    %edi
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	57                   	push   %edi
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
  8010f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  801102:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801105:	8b 55 08             	mov    0x8(%ebp),%edx
  801108:	89 df                	mov    %ebx,%edi
  80110a:	89 de                	mov    %ebx,%esi
  80110c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80110e:	85 c0                	test   %eax,%eax
  801110:	7e 17                	jle    801129 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	50                   	push   %eax
  801116:	6a 0a                	push   $0xa
  801118:	68 5f 2b 80 00       	push   $0x802b5f
  80111d:	6a 23                	push   $0x23
  80111f:	68 7c 2b 80 00       	push   $0x802b7c
  801124:	e8 fc 11 00 00       	call   802325 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801137:	be 00 00 00 00       	mov    $0x0,%esi
  80113c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801144:	8b 55 08             	mov    0x8(%ebp),%edx
  801147:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80114a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80114f:	5b                   	pop    %ebx
  801150:	5e                   	pop    %esi
  801151:	5f                   	pop    %edi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	57                   	push   %edi
  801158:	56                   	push   %esi
  801159:	53                   	push   %ebx
  80115a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80115d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801162:	b8 0d 00 00 00       	mov    $0xd,%eax
  801167:	8b 55 08             	mov    0x8(%ebp),%edx
  80116a:	89 cb                	mov    %ecx,%ebx
  80116c:	89 cf                	mov    %ecx,%edi
  80116e:	89 ce                	mov    %ecx,%esi
  801170:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801172:	85 c0                	test   %eax,%eax
  801174:	7e 17                	jle    80118d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	50                   	push   %eax
  80117a:	6a 0d                	push   $0xd
  80117c:	68 5f 2b 80 00       	push   $0x802b5f
  801181:	6a 23                	push   $0x23
  801183:	68 7c 2b 80 00       	push   $0x802b7c
  801188:	e8 98 11 00 00       	call   802325 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80118d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801190:	5b                   	pop    %ebx
  801191:	5e                   	pop    %esi
  801192:	5f                   	pop    %edi
  801193:	5d                   	pop    %ebp
  801194:	c3                   	ret    

00801195 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801195:	55                   	push   %ebp
  801196:	89 e5                	mov    %esp,%ebp
  801198:	57                   	push   %edi
  801199:	56                   	push   %esi
  80119a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80119b:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8011a5:	89 d1                	mov    %edx,%ecx
  8011a7:	89 d3                	mov    %edx,%ebx
  8011a9:	89 d7                	mov    %edx,%edi
  8011ab:	89 d6                	mov    %edx,%esi
  8011ad:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8011af:	5b                   	pop    %ebx
  8011b0:	5e                   	pop    %esi
  8011b1:	5f                   	pop    %edi
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	57                   	push   %edi
  8011b8:	56                   	push   %esi
  8011b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011bf:	b8 10 00 00 00       	mov    $0x10,%eax
  8011c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c7:	89 cb                	mov    %ecx,%ebx
  8011c9:	89 cf                	mov    %ecx,%edi
  8011cb:	89 ce                	mov    %ecx,%esi
  8011cd:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  8011cf:	5b                   	pop    %ebx
  8011d0:	5e                   	pop    %esi
  8011d1:	5f                   	pop    %edi
  8011d2:	5d                   	pop    %ebp
  8011d3:	c3                   	ret    

008011d4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011da:	05 00 00 00 30       	add    $0x30000000,%eax
  8011df:	c1 e8 0c             	shr    $0xc,%eax
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ef:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011f4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    

008011fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801201:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 16             	shr    $0x16,%edx
  80120b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 11                	je     801228 <fd_alloc+0x2d>
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 0c             	shr    $0xc,%edx
  80121c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	75 09                	jne    801231 <fd_alloc+0x36>
			*fd_store = fd;
  801228:	89 01                	mov    %eax,(%ecx)
			return 0;
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
  80122f:	eb 17                	jmp    801248 <fd_alloc+0x4d>
  801231:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801236:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123b:	75 c9                	jne    801206 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801243:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801250:	83 f8 1f             	cmp    $0x1f,%eax
  801253:	77 36                	ja     80128b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801255:	c1 e0 0c             	shl    $0xc,%eax
  801258:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	c1 ea 16             	shr    $0x16,%edx
  801262:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	74 24                	je     801292 <fd_lookup+0x48>
  80126e:	89 c2                	mov    %eax,%edx
  801270:	c1 ea 0c             	shr    $0xc,%edx
  801273:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	74 1a                	je     801299 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80127f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801282:	89 02                	mov    %eax,(%edx)
	return 0;
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
  801289:	eb 13                	jmp    80129e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80128b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801290:	eb 0c                	jmp    80129e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801297:	eb 05                	jmp    80129e <fd_lookup+0x54>
  801299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a9:	ba 08 2c 80 00       	mov    $0x802c08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ae:	eb 13                	jmp    8012c3 <dev_lookup+0x23>
  8012b0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012b3:	39 08                	cmp    %ecx,(%eax)
  8012b5:	75 0c                	jne    8012c3 <dev_lookup+0x23>
			*dev = devtab[i];
  8012b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c1:	eb 2e                	jmp    8012f1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c3:	8b 02                	mov    (%edx),%eax
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	75 e7                	jne    8012b0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c9:	a1 18 40 80 00       	mov    0x804018,%eax
  8012ce:	8b 40 48             	mov    0x48(%eax),%eax
  8012d1:	83 ec 04             	sub    $0x4,%esp
  8012d4:	51                   	push   %ecx
  8012d5:	50                   	push   %eax
  8012d6:	68 8c 2b 80 00       	push   $0x802b8c
  8012db:	e8 bd f2 ff ff       	call   80059d <cprintf>
	*dev = 0;
  8012e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f1:	c9                   	leave  
  8012f2:	c3                   	ret    

008012f3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 10             	sub    $0x10,%esp
  8012fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80130b:	c1 e8 0c             	shr    $0xc,%eax
  80130e:	50                   	push   %eax
  80130f:	e8 36 ff ff ff       	call   80124a <fd_lookup>
  801314:	83 c4 08             	add    $0x8,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 05                	js     801320 <fd_close+0x2d>
	    || fd != fd2)
  80131b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80131e:	74 0c                	je     80132c <fd_close+0x39>
		return (must_exist ? r : 0);
  801320:	84 db                	test   %bl,%bl
  801322:	ba 00 00 00 00       	mov    $0x0,%edx
  801327:	0f 44 c2             	cmove  %edx,%eax
  80132a:	eb 41                	jmp    80136d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80132c:	83 ec 08             	sub    $0x8,%esp
  80132f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 36                	pushl  (%esi)
  801335:	e8 66 ff ff ff       	call   8012a0 <dev_lookup>
  80133a:	89 c3                	mov    %eax,%ebx
  80133c:	83 c4 10             	add    $0x10,%esp
  80133f:	85 c0                	test   %eax,%eax
  801341:	78 1a                	js     80135d <fd_close+0x6a>
		if (dev->dev_close)
  801343:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801346:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801349:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80134e:	85 c0                	test   %eax,%eax
  801350:	74 0b                	je     80135d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801352:	83 ec 0c             	sub    $0xc,%esp
  801355:	56                   	push   %esi
  801356:	ff d0                	call   *%eax
  801358:	89 c3                	mov    %eax,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	56                   	push   %esi
  801361:	6a 00                	push   $0x0
  801363:	e8 c1 fc ff ff       	call   801029 <sys_page_unmap>
	return r;
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	89 d8                	mov    %ebx,%eax
}
  80136d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	ff 75 08             	pushl  0x8(%ebp)
  801381:	e8 c4 fe ff ff       	call   80124a <fd_lookup>
  801386:	83 c4 08             	add    $0x8,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 10                	js     80139d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	6a 01                	push   $0x1
  801392:	ff 75 f4             	pushl  -0xc(%ebp)
  801395:	e8 59 ff ff ff       	call   8012f3 <fd_close>
  80139a:	83 c4 10             	add    $0x10,%esp
}
  80139d:	c9                   	leave  
  80139e:	c3                   	ret    

0080139f <close_all>:

void
close_all(void)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	53                   	push   %ebx
  8013af:	e8 c0 ff ff ff       	call   801374 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b4:	83 c3 01             	add    $0x1,%ebx
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	83 fb 20             	cmp    $0x20,%ebx
  8013bd:	75 ec                	jne    8013ab <close_all+0xc>
		close(i);
}
  8013bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c2:	c9                   	leave  
  8013c3:	c3                   	ret    

008013c4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	57                   	push   %edi
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 2c             	sub    $0x2c,%esp
  8013cd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	ff 75 08             	pushl  0x8(%ebp)
  8013d7:	e8 6e fe ff ff       	call   80124a <fd_lookup>
  8013dc:	83 c4 08             	add    $0x8,%esp
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	0f 88 c1 00 00 00    	js     8014a8 <dup+0xe4>
		return r;
	close(newfdnum);
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	56                   	push   %esi
  8013eb:	e8 84 ff ff ff       	call   801374 <close>

	newfd = INDEX2FD(newfdnum);
  8013f0:	89 f3                	mov    %esi,%ebx
  8013f2:	c1 e3 0c             	shl    $0xc,%ebx
  8013f5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013fb:	83 c4 04             	add    $0x4,%esp
  8013fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801401:	e8 de fd ff ff       	call   8011e4 <fd2data>
  801406:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801408:	89 1c 24             	mov    %ebx,(%esp)
  80140b:	e8 d4 fd ff ff       	call   8011e4 <fd2data>
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801416:	89 f8                	mov    %edi,%eax
  801418:	c1 e8 16             	shr    $0x16,%eax
  80141b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801422:	a8 01                	test   $0x1,%al
  801424:	74 37                	je     80145d <dup+0x99>
  801426:	89 f8                	mov    %edi,%eax
  801428:	c1 e8 0c             	shr    $0xc,%eax
  80142b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801432:	f6 c2 01             	test   $0x1,%dl
  801435:	74 26                	je     80145d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801437:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80143e:	83 ec 0c             	sub    $0xc,%esp
  801441:	25 07 0e 00 00       	and    $0xe07,%eax
  801446:	50                   	push   %eax
  801447:	ff 75 d4             	pushl  -0x2c(%ebp)
  80144a:	6a 00                	push   $0x0
  80144c:	57                   	push   %edi
  80144d:	6a 00                	push   $0x0
  80144f:	e8 93 fb ff ff       	call   800fe7 <sys_page_map>
  801454:	89 c7                	mov    %eax,%edi
  801456:	83 c4 20             	add    $0x20,%esp
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 2e                	js     80148b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80145d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801460:	89 d0                	mov    %edx,%eax
  801462:	c1 e8 0c             	shr    $0xc,%eax
  801465:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80146c:	83 ec 0c             	sub    $0xc,%esp
  80146f:	25 07 0e 00 00       	and    $0xe07,%eax
  801474:	50                   	push   %eax
  801475:	53                   	push   %ebx
  801476:	6a 00                	push   $0x0
  801478:	52                   	push   %edx
  801479:	6a 00                	push   $0x0
  80147b:	e8 67 fb ff ff       	call   800fe7 <sys_page_map>
  801480:	89 c7                	mov    %eax,%edi
  801482:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801485:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801487:	85 ff                	test   %edi,%edi
  801489:	79 1d                	jns    8014a8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	53                   	push   %ebx
  80148f:	6a 00                	push   $0x0
  801491:	e8 93 fb ff ff       	call   801029 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801496:	83 c4 08             	add    $0x8,%esp
  801499:	ff 75 d4             	pushl  -0x2c(%ebp)
  80149c:	6a 00                	push   $0x0
  80149e:	e8 86 fb ff ff       	call   801029 <sys_page_unmap>
	return r;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	89 f8                	mov    %edi,%eax
}
  8014a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ab:	5b                   	pop    %ebx
  8014ac:	5e                   	pop    %esi
  8014ad:	5f                   	pop    %edi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 14             	sub    $0x14,%esp
  8014b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	53                   	push   %ebx
  8014bf:	e8 86 fd ff ff       	call   80124a <fd_lookup>
  8014c4:	83 c4 08             	add    $0x8,%esp
  8014c7:	89 c2                	mov    %eax,%edx
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 6d                	js     80153a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d3:	50                   	push   %eax
  8014d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d7:	ff 30                	pushl  (%eax)
  8014d9:	e8 c2 fd ff ff       	call   8012a0 <dev_lookup>
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 4c                	js     801531 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e8:	8b 42 08             	mov    0x8(%edx),%eax
  8014eb:	83 e0 03             	and    $0x3,%eax
  8014ee:	83 f8 01             	cmp    $0x1,%eax
  8014f1:	75 21                	jne    801514 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f3:	a1 18 40 80 00       	mov    0x804018,%eax
  8014f8:	8b 40 48             	mov    0x48(%eax),%eax
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	53                   	push   %ebx
  8014ff:	50                   	push   %eax
  801500:	68 cd 2b 80 00       	push   $0x802bcd
  801505:	e8 93 f0 ff ff       	call   80059d <cprintf>
		return -E_INVAL;
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801512:	eb 26                	jmp    80153a <read+0x8a>
	}
	if (!dev->dev_read)
  801514:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801517:	8b 40 08             	mov    0x8(%eax),%eax
  80151a:	85 c0                	test   %eax,%eax
  80151c:	74 17                	je     801535 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80151e:	83 ec 04             	sub    $0x4,%esp
  801521:	ff 75 10             	pushl  0x10(%ebp)
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	52                   	push   %edx
  801528:	ff d0                	call   *%eax
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb 09                	jmp    80153a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801531:	89 c2                	mov    %eax,%edx
  801533:	eb 05                	jmp    80153a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801535:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80153a:	89 d0                	mov    %edx,%eax
  80153c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	57                   	push   %edi
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 0c             	sub    $0xc,%esp
  80154a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801550:	bb 00 00 00 00       	mov    $0x0,%ebx
  801555:	eb 21                	jmp    801578 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	89 f0                	mov    %esi,%eax
  80155c:	29 d8                	sub    %ebx,%eax
  80155e:	50                   	push   %eax
  80155f:	89 d8                	mov    %ebx,%eax
  801561:	03 45 0c             	add    0xc(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	57                   	push   %edi
  801566:	e8 45 ff ff ff       	call   8014b0 <read>
		if (m < 0)
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 10                	js     801582 <readn+0x41>
			return m;
		if (m == 0)
  801572:	85 c0                	test   %eax,%eax
  801574:	74 0a                	je     801580 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801576:	01 c3                	add    %eax,%ebx
  801578:	39 f3                	cmp    %esi,%ebx
  80157a:	72 db                	jb     801557 <readn+0x16>
  80157c:	89 d8                	mov    %ebx,%eax
  80157e:	eb 02                	jmp    801582 <readn+0x41>
  801580:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801582:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801585:	5b                   	pop    %ebx
  801586:	5e                   	pop    %esi
  801587:	5f                   	pop    %edi
  801588:	5d                   	pop    %ebp
  801589:	c3                   	ret    

0080158a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	53                   	push   %ebx
  80158e:	83 ec 14             	sub    $0x14,%esp
  801591:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801594:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	53                   	push   %ebx
  801599:	e8 ac fc ff ff       	call   80124a <fd_lookup>
  80159e:	83 c4 08             	add    $0x8,%esp
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 68                	js     80160f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ad:	50                   	push   %eax
  8015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b1:	ff 30                	pushl  (%eax)
  8015b3:	e8 e8 fc ff ff       	call   8012a0 <dev_lookup>
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	85 c0                	test   %eax,%eax
  8015bd:	78 47                	js     801606 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015c6:	75 21                	jne    8015e9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c8:	a1 18 40 80 00       	mov    0x804018,%eax
  8015cd:	8b 40 48             	mov    0x48(%eax),%eax
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	53                   	push   %ebx
  8015d4:	50                   	push   %eax
  8015d5:	68 e9 2b 80 00       	push   $0x802be9
  8015da:	e8 be ef ff ff       	call   80059d <cprintf>
		return -E_INVAL;
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015e7:	eb 26                	jmp    80160f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ec:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ef:	85 d2                	test   %edx,%edx
  8015f1:	74 17                	je     80160a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015f3:	83 ec 04             	sub    $0x4,%esp
  8015f6:	ff 75 10             	pushl  0x10(%ebp)
  8015f9:	ff 75 0c             	pushl  0xc(%ebp)
  8015fc:	50                   	push   %eax
  8015fd:	ff d2                	call   *%edx
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	eb 09                	jmp    80160f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801606:	89 c2                	mov    %eax,%edx
  801608:	eb 05                	jmp    80160f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80160a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80160f:	89 d0                	mov    %edx,%eax
  801611:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <seek>:

int
seek(int fdnum, off_t offset)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80161c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	ff 75 08             	pushl  0x8(%ebp)
  801623:	e8 22 fc ff ff       	call   80124a <fd_lookup>
  801628:	83 c4 08             	add    $0x8,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 0e                	js     80163d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80162f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801632:	8b 55 0c             	mov    0xc(%ebp),%edx
  801635:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801638:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 14             	sub    $0x14,%esp
  801646:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801649:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164c:	50                   	push   %eax
  80164d:	53                   	push   %ebx
  80164e:	e8 f7 fb ff ff       	call   80124a <fd_lookup>
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	89 c2                	mov    %eax,%edx
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 65                	js     8016c1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165c:	83 ec 08             	sub    $0x8,%esp
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	50                   	push   %eax
  801663:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801666:	ff 30                	pushl  (%eax)
  801668:	e8 33 fc ff ff       	call   8012a0 <dev_lookup>
  80166d:	83 c4 10             	add    $0x10,%esp
  801670:	85 c0                	test   %eax,%eax
  801672:	78 44                	js     8016b8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801674:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801677:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80167b:	75 21                	jne    80169e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80167d:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801682:	8b 40 48             	mov    0x48(%eax),%eax
  801685:	83 ec 04             	sub    $0x4,%esp
  801688:	53                   	push   %ebx
  801689:	50                   	push   %eax
  80168a:	68 ac 2b 80 00       	push   $0x802bac
  80168f:	e8 09 ef ff ff       	call   80059d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80169c:	eb 23                	jmp    8016c1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80169e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a1:	8b 52 18             	mov    0x18(%edx),%edx
  8016a4:	85 d2                	test   %edx,%edx
  8016a6:	74 14                	je     8016bc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	50                   	push   %eax
  8016af:	ff d2                	call   *%edx
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	eb 09                	jmp    8016c1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	eb 05                	jmp    8016c1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c1:	89 d0                	mov    %edx,%eax
  8016c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 14             	sub    $0x14,%esp
  8016cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d5:	50                   	push   %eax
  8016d6:	ff 75 08             	pushl  0x8(%ebp)
  8016d9:	e8 6c fb ff ff       	call   80124a <fd_lookup>
  8016de:	83 c4 08             	add    $0x8,%esp
  8016e1:	89 c2                	mov    %eax,%edx
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 58                	js     80173f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ed:	50                   	push   %eax
  8016ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f1:	ff 30                	pushl  (%eax)
  8016f3:	e8 a8 fb ff ff       	call   8012a0 <dev_lookup>
  8016f8:	83 c4 10             	add    $0x10,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 37                	js     801736 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801702:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801706:	74 32                	je     80173a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801708:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80170b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801712:	00 00 00 
	stat->st_isdir = 0;
  801715:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80171c:	00 00 00 
	stat->st_dev = dev;
  80171f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801725:	83 ec 08             	sub    $0x8,%esp
  801728:	53                   	push   %ebx
  801729:	ff 75 f0             	pushl  -0x10(%ebp)
  80172c:	ff 50 14             	call   *0x14(%eax)
  80172f:	89 c2                	mov    %eax,%edx
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	eb 09                	jmp    80173f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801736:	89 c2                	mov    %eax,%edx
  801738:	eb 05                	jmp    80173f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80173a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80173f:	89 d0                	mov    %edx,%eax
  801741:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801744:	c9                   	leave  
  801745:	c3                   	ret    

00801746 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801746:	55                   	push   %ebp
  801747:	89 e5                	mov    %esp,%ebp
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	6a 00                	push   $0x0
  801750:	ff 75 08             	pushl  0x8(%ebp)
  801753:	e8 e3 01 00 00       	call   80193b <open>
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 1b                	js     80177c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	ff 75 0c             	pushl  0xc(%ebp)
  801767:	50                   	push   %eax
  801768:	e8 5b ff ff ff       	call   8016c8 <fstat>
  80176d:	89 c6                	mov    %eax,%esi
	close(fd);
  80176f:	89 1c 24             	mov    %ebx,(%esp)
  801772:	e8 fd fb ff ff       	call   801374 <close>
	return r;
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	89 f0                	mov    %esi,%eax
}
  80177c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80177f:	5b                   	pop    %ebx
  801780:	5e                   	pop    %esi
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	56                   	push   %esi
  801787:	53                   	push   %ebx
  801788:	89 c6                	mov    %eax,%esi
  80178a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80178c:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  801793:	75 12                	jne    8017a7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801795:	83 ec 0c             	sub    $0xc,%esp
  801798:	6a 01                	push   $0x1
  80179a:	e8 89 0c 00 00       	call   802428 <ipc_find_env>
  80179f:	a3 10 40 80 00       	mov    %eax,0x804010
  8017a4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017a7:	6a 07                	push   $0x7
  8017a9:	68 00 50 80 00       	push   $0x805000
  8017ae:	56                   	push   %esi
  8017af:	ff 35 10 40 80 00    	pushl  0x804010
  8017b5:	e8 1a 0c 00 00       	call   8023d4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ba:	83 c4 0c             	add    $0xc,%esp
  8017bd:	6a 00                	push   $0x0
  8017bf:	53                   	push   %ebx
  8017c0:	6a 00                	push   $0x0
  8017c2:	e8 a4 0b 00 00       	call   80236b <ipc_recv>
}
  8017c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ca:	5b                   	pop    %ebx
  8017cb:	5e                   	pop    %esi
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017da:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f1:	e8 8d ff ff ff       	call   801783 <fsipc>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	8b 40 0c             	mov    0xc(%eax),%eax
  801804:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801809:	ba 00 00 00 00       	mov    $0x0,%edx
  80180e:	b8 06 00 00 00       	mov    $0x6,%eax
  801813:	e8 6b ff ff ff       	call   801783 <fsipc>
}
  801818:	c9                   	leave  
  801819:	c3                   	ret    

0080181a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	53                   	push   %ebx
  80181e:	83 ec 04             	sub    $0x4,%esp
  801821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 40 0c             	mov    0xc(%eax),%eax
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 05 00 00 00       	mov    $0x5,%eax
  801839:	e8 45 ff ff ff       	call   801783 <fsipc>
  80183e:	85 c0                	test   %eax,%eax
  801840:	78 2c                	js     80186e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801842:	83 ec 08             	sub    $0x8,%esp
  801845:	68 00 50 80 00       	push   $0x805000
  80184a:	53                   	push   %ebx
  80184b:	e8 51 f3 ff ff       	call   800ba1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801850:	a1 80 50 80 00       	mov    0x805080,%eax
  801855:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80185b:	a1 84 50 80 00       	mov    0x805084,%eax
  801860:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80186e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 0c             	sub    $0xc,%esp
  801879:	8b 45 10             	mov    0x10(%ebp),%eax
  80187c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801881:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801886:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801889:	8b 55 08             	mov    0x8(%ebp),%edx
  80188c:	8b 52 0c             	mov    0xc(%edx),%edx
  80188f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801895:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80189a:	50                   	push   %eax
  80189b:	ff 75 0c             	pushl  0xc(%ebp)
  80189e:	68 08 50 80 00       	push   $0x805008
  8018a3:	e8 8b f4 ff ff       	call   800d33 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ad:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b2:	e8 cc fe ff ff       	call   801783 <fsipc>
	//panic("devfile_write not implemented");
}
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	56                   	push   %esi
  8018bd:	53                   	push   %ebx
  8018be:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018cc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8018dc:	e8 a2 fe ff ff       	call   801783 <fsipc>
  8018e1:	89 c3                	mov    %eax,%ebx
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 4b                	js     801932 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018e7:	39 c6                	cmp    %eax,%esi
  8018e9:	73 16                	jae    801901 <devfile_read+0x48>
  8018eb:	68 1c 2c 80 00       	push   $0x802c1c
  8018f0:	68 23 2c 80 00       	push   $0x802c23
  8018f5:	6a 7c                	push   $0x7c
  8018f7:	68 38 2c 80 00       	push   $0x802c38
  8018fc:	e8 24 0a 00 00       	call   802325 <_panic>
	assert(r <= PGSIZE);
  801901:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801906:	7e 16                	jle    80191e <devfile_read+0x65>
  801908:	68 43 2c 80 00       	push   $0x802c43
  80190d:	68 23 2c 80 00       	push   $0x802c23
  801912:	6a 7d                	push   $0x7d
  801914:	68 38 2c 80 00       	push   $0x802c38
  801919:	e8 07 0a 00 00       	call   802325 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80191e:	83 ec 04             	sub    $0x4,%esp
  801921:	50                   	push   %eax
  801922:	68 00 50 80 00       	push   $0x805000
  801927:	ff 75 0c             	pushl  0xc(%ebp)
  80192a:	e8 04 f4 ff ff       	call   800d33 <memmove>
	return r;
  80192f:	83 c4 10             	add    $0x10,%esp
}
  801932:	89 d8                	mov    %ebx,%eax
  801934:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801937:	5b                   	pop    %ebx
  801938:	5e                   	pop    %esi
  801939:	5d                   	pop    %ebp
  80193a:	c3                   	ret    

0080193b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80193b:	55                   	push   %ebp
  80193c:	89 e5                	mov    %esp,%ebp
  80193e:	53                   	push   %ebx
  80193f:	83 ec 20             	sub    $0x20,%esp
  801942:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801945:	53                   	push   %ebx
  801946:	e8 1d f2 ff ff       	call   800b68 <strlen>
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801953:	7f 67                	jg     8019bc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801955:	83 ec 0c             	sub    $0xc,%esp
  801958:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195b:	50                   	push   %eax
  80195c:	e8 9a f8 ff ff       	call   8011fb <fd_alloc>
  801961:	83 c4 10             	add    $0x10,%esp
		return r;
  801964:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801966:	85 c0                	test   %eax,%eax
  801968:	78 57                	js     8019c1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	53                   	push   %ebx
  80196e:	68 00 50 80 00       	push   $0x805000
  801973:	e8 29 f2 ff ff       	call   800ba1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801980:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801983:	b8 01 00 00 00       	mov    $0x1,%eax
  801988:	e8 f6 fd ff ff       	call   801783 <fsipc>
  80198d:	89 c3                	mov    %eax,%ebx
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	85 c0                	test   %eax,%eax
  801994:	79 14                	jns    8019aa <open+0x6f>
		fd_close(fd, 0);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	6a 00                	push   $0x0
  80199b:	ff 75 f4             	pushl  -0xc(%ebp)
  80199e:	e8 50 f9 ff ff       	call   8012f3 <fd_close>
		return r;
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	89 da                	mov    %ebx,%edx
  8019a8:	eb 17                	jmp    8019c1 <open+0x86>
	}

	return fd2num(fd);
  8019aa:	83 ec 0c             	sub    $0xc,%esp
  8019ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b0:	e8 1f f8 ff ff       	call   8011d4 <fd2num>
  8019b5:	89 c2                	mov    %eax,%edx
  8019b7:	83 c4 10             	add    $0x10,%esp
  8019ba:	eb 05                	jmp    8019c1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019bc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c1:	89 d0                	mov    %edx,%eax
  8019c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    

008019c8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d3:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d8:	e8 a6 fd ff ff       	call   801783 <fsipc>
}
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    

008019df <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019e5:	68 4f 2c 80 00       	push   $0x802c4f
  8019ea:	ff 75 0c             	pushl  0xc(%ebp)
  8019ed:	e8 af f1 ff ff       	call   800ba1 <strcpy>
	return 0;
}
  8019f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 10             	sub    $0x10,%esp
  801a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a03:	53                   	push   %ebx
  801a04:	e8 58 0a 00 00       	call   802461 <pageref>
  801a09:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a0c:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801a11:	83 f8 01             	cmp    $0x1,%eax
  801a14:	75 10                	jne    801a26 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801a16:	83 ec 0c             	sub    $0xc,%esp
  801a19:	ff 73 0c             	pushl  0xc(%ebx)
  801a1c:	e8 c0 02 00 00       	call   801ce1 <nsipc_close>
  801a21:	89 c2                	mov    %eax,%edx
  801a23:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a26:	89 d0                	mov    %edx,%eax
  801a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a33:	6a 00                	push   $0x0
  801a35:	ff 75 10             	pushl  0x10(%ebp)
  801a38:	ff 75 0c             	pushl  0xc(%ebp)
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	ff 70 0c             	pushl  0xc(%eax)
  801a41:	e8 78 03 00 00       	call   801dbe <nsipc_send>
}
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a4e:	6a 00                	push   $0x0
  801a50:	ff 75 10             	pushl  0x10(%ebp)
  801a53:	ff 75 0c             	pushl  0xc(%ebp)
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	ff 70 0c             	pushl  0xc(%eax)
  801a5c:	e8 f1 02 00 00       	call   801d52 <nsipc_recv>
}
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a69:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a6c:	52                   	push   %edx
  801a6d:	50                   	push   %eax
  801a6e:	e8 d7 f7 ff ff       	call   80124a <fd_lookup>
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 17                	js     801a91 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7d:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801a83:	39 08                	cmp    %ecx,(%eax)
  801a85:	75 05                	jne    801a8c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a87:	8b 40 0c             	mov    0xc(%eax),%eax
  801a8a:	eb 05                	jmp    801a91 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a8c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    

00801a93 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	83 ec 1c             	sub    $0x1c,%esp
  801a9b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa0:	50                   	push   %eax
  801aa1:	e8 55 f7 ff ff       	call   8011fb <fd_alloc>
  801aa6:	89 c3                	mov    %eax,%ebx
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	85 c0                	test   %eax,%eax
  801aad:	78 1b                	js     801aca <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801aaf:	83 ec 04             	sub    $0x4,%esp
  801ab2:	68 07 04 00 00       	push   $0x407
  801ab7:	ff 75 f4             	pushl  -0xc(%ebp)
  801aba:	6a 00                	push   $0x0
  801abc:	e8 e3 f4 ff ff       	call   800fa4 <sys_page_alloc>
  801ac1:	89 c3                	mov    %eax,%ebx
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	79 10                	jns    801ada <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	56                   	push   %esi
  801ace:	e8 0e 02 00 00       	call   801ce1 <nsipc_close>
		return r;
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	89 d8                	mov    %ebx,%eax
  801ad8:	eb 24                	jmp    801afe <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ada:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801aef:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801af2:	83 ec 0c             	sub    $0xc,%esp
  801af5:	50                   	push   %eax
  801af6:	e8 d9 f6 ff ff       	call   8011d4 <fd2num>
  801afb:	83 c4 10             	add    $0x10,%esp
}
  801afe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b01:	5b                   	pop    %ebx
  801b02:	5e                   	pop    %esi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    

00801b05 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	e8 50 ff ff ff       	call   801a63 <fd2sockid>
		return r;
  801b13:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 1f                	js     801b38 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b19:	83 ec 04             	sub    $0x4,%esp
  801b1c:	ff 75 10             	pushl  0x10(%ebp)
  801b1f:	ff 75 0c             	pushl  0xc(%ebp)
  801b22:	50                   	push   %eax
  801b23:	e8 12 01 00 00       	call   801c3a <nsipc_accept>
  801b28:	83 c4 10             	add    $0x10,%esp
		return r;
  801b2b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b2d:	85 c0                	test   %eax,%eax
  801b2f:	78 07                	js     801b38 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b31:	e8 5d ff ff ff       	call   801a93 <alloc_sockfd>
  801b36:	89 c1                	mov    %eax,%ecx
}
  801b38:	89 c8                	mov    %ecx,%eax
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	e8 19 ff ff ff       	call   801a63 <fd2sockid>
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 12                	js     801b60 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b4e:	83 ec 04             	sub    $0x4,%esp
  801b51:	ff 75 10             	pushl  0x10(%ebp)
  801b54:	ff 75 0c             	pushl  0xc(%ebp)
  801b57:	50                   	push   %eax
  801b58:	e8 2d 01 00 00       	call   801c8a <nsipc_bind>
  801b5d:	83 c4 10             	add    $0x10,%esp
}
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <shutdown>:

int
shutdown(int s, int how)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b68:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6b:	e8 f3 fe ff ff       	call   801a63 <fd2sockid>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 0f                	js     801b83 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b74:	83 ec 08             	sub    $0x8,%esp
  801b77:	ff 75 0c             	pushl  0xc(%ebp)
  801b7a:	50                   	push   %eax
  801b7b:	e8 3f 01 00 00       	call   801cbf <nsipc_shutdown>
  801b80:	83 c4 10             	add    $0x10,%esp
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	e8 d0 fe ff ff       	call   801a63 <fd2sockid>
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 12                	js     801ba9 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b97:	83 ec 04             	sub    $0x4,%esp
  801b9a:	ff 75 10             	pushl  0x10(%ebp)
  801b9d:	ff 75 0c             	pushl  0xc(%ebp)
  801ba0:	50                   	push   %eax
  801ba1:	e8 55 01 00 00       	call   801cfb <nsipc_connect>
  801ba6:	83 c4 10             	add    $0x10,%esp
}
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <listen>:

int
listen(int s, int backlog)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	e8 aa fe ff ff       	call   801a63 <fd2sockid>
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	78 0f                	js     801bcc <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bbd:	83 ec 08             	sub    $0x8,%esp
  801bc0:	ff 75 0c             	pushl  0xc(%ebp)
  801bc3:	50                   	push   %eax
  801bc4:	e8 67 01 00 00       	call   801d30 <nsipc_listen>
  801bc9:	83 c4 10             	add    $0x10,%esp
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bd4:	ff 75 10             	pushl  0x10(%ebp)
  801bd7:	ff 75 0c             	pushl  0xc(%ebp)
  801bda:	ff 75 08             	pushl  0x8(%ebp)
  801bdd:	e8 3a 02 00 00       	call   801e1c <nsipc_socket>
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 05                	js     801bee <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801be9:	e8 a5 fe ff ff       	call   801a93 <alloc_sockfd>
}
  801bee:	c9                   	leave  
  801bef:	c3                   	ret    

00801bf0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bf0:	55                   	push   %ebp
  801bf1:	89 e5                	mov    %esp,%ebp
  801bf3:	53                   	push   %ebx
  801bf4:	83 ec 04             	sub    $0x4,%esp
  801bf7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bf9:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801c00:	75 12                	jne    801c14 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	6a 02                	push   $0x2
  801c07:	e8 1c 08 00 00       	call   802428 <ipc_find_env>
  801c0c:	a3 14 40 80 00       	mov    %eax,0x804014
  801c11:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c14:	6a 07                	push   $0x7
  801c16:	68 00 60 80 00       	push   $0x806000
  801c1b:	53                   	push   %ebx
  801c1c:	ff 35 14 40 80 00    	pushl  0x804014
  801c22:	e8 ad 07 00 00       	call   8023d4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c27:	83 c4 0c             	add    $0xc,%esp
  801c2a:	6a 00                	push   $0x0
  801c2c:	6a 00                	push   $0x0
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 36 07 00 00       	call   80236b <ipc_recv>
}
  801c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	56                   	push   %esi
  801c3e:	53                   	push   %ebx
  801c3f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c4a:	8b 06                	mov    (%esi),%eax
  801c4c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	e8 95 ff ff ff       	call   801bf0 <nsipc>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 20                	js     801c81 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c61:	83 ec 04             	sub    $0x4,%esp
  801c64:	ff 35 10 60 80 00    	pushl  0x806010
  801c6a:	68 00 60 80 00       	push   $0x806000
  801c6f:	ff 75 0c             	pushl  0xc(%ebp)
  801c72:	e8 bc f0 ff ff       	call   800d33 <memmove>
		*addrlen = ret->ret_addrlen;
  801c77:	a1 10 60 80 00       	mov    0x806010,%eax
  801c7c:	89 06                	mov    %eax,(%esi)
  801c7e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c81:	89 d8                	mov    %ebx,%eax
  801c83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c86:	5b                   	pop    %ebx
  801c87:	5e                   	pop    %esi
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    

00801c8a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	53                   	push   %ebx
  801c8e:	83 ec 08             	sub    $0x8,%esp
  801c91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c9c:	53                   	push   %ebx
  801c9d:	ff 75 0c             	pushl  0xc(%ebp)
  801ca0:	68 04 60 80 00       	push   $0x806004
  801ca5:	e8 89 f0 ff ff       	call   800d33 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801caa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801cb0:	b8 02 00 00 00       	mov    $0x2,%eax
  801cb5:	e8 36 ff ff ff       	call   801bf0 <nsipc>
}
  801cba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ccd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801cd5:	b8 03 00 00 00       	mov    $0x3,%eax
  801cda:	e8 11 ff ff ff       	call   801bf0 <nsipc>
}
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <nsipc_close>:

int
nsipc_close(int s)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cea:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cef:	b8 04 00 00 00       	mov    $0x4,%eax
  801cf4:	e8 f7 fe ff ff       	call   801bf0 <nsipc>
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	53                   	push   %ebx
  801cff:	83 ec 08             	sub    $0x8,%esp
  801d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d05:	8b 45 08             	mov    0x8(%ebp),%eax
  801d08:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d0d:	53                   	push   %ebx
  801d0e:	ff 75 0c             	pushl  0xc(%ebp)
  801d11:	68 04 60 80 00       	push   $0x806004
  801d16:	e8 18 f0 ff ff       	call   800d33 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d1b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801d21:	b8 05 00 00 00       	mov    $0x5,%eax
  801d26:	e8 c5 fe ff ff       	call   801bf0 <nsipc>
}
  801d2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d2e:	c9                   	leave  
  801d2f:	c3                   	ret    

00801d30 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d36:	8b 45 08             	mov    0x8(%ebp),%eax
  801d39:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d41:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d46:	b8 06 00 00 00       	mov    $0x6,%eax
  801d4b:	e8 a0 fe ff ff       	call   801bf0 <nsipc>
}
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	56                   	push   %esi
  801d56:	53                   	push   %ebx
  801d57:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d62:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d68:	8b 45 14             	mov    0x14(%ebp),%eax
  801d6b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d70:	b8 07 00 00 00       	mov    $0x7,%eax
  801d75:	e8 76 fe ff ff       	call   801bf0 <nsipc>
  801d7a:	89 c3                	mov    %eax,%ebx
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	78 35                	js     801db5 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d80:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d85:	7f 04                	jg     801d8b <nsipc_recv+0x39>
  801d87:	39 c6                	cmp    %eax,%esi
  801d89:	7d 16                	jge    801da1 <nsipc_recv+0x4f>
  801d8b:	68 5b 2c 80 00       	push   $0x802c5b
  801d90:	68 23 2c 80 00       	push   $0x802c23
  801d95:	6a 62                	push   $0x62
  801d97:	68 70 2c 80 00       	push   $0x802c70
  801d9c:	e8 84 05 00 00       	call   802325 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	50                   	push   %eax
  801da5:	68 00 60 80 00       	push   $0x806000
  801daa:	ff 75 0c             	pushl  0xc(%ebp)
  801dad:	e8 81 ef ff ff       	call   800d33 <memmove>
  801db2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801db5:	89 d8                	mov    %ebx,%eax
  801db7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	53                   	push   %ebx
  801dc2:	83 ec 04             	sub    $0x4,%esp
  801dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801dd0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dd6:	7e 16                	jle    801dee <nsipc_send+0x30>
  801dd8:	68 7c 2c 80 00       	push   $0x802c7c
  801ddd:	68 23 2c 80 00       	push   $0x802c23
  801de2:	6a 6d                	push   $0x6d
  801de4:	68 70 2c 80 00       	push   $0x802c70
  801de9:	e8 37 05 00 00       	call   802325 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dee:	83 ec 04             	sub    $0x4,%esp
  801df1:	53                   	push   %ebx
  801df2:	ff 75 0c             	pushl  0xc(%ebp)
  801df5:	68 0c 60 80 00       	push   $0x80600c
  801dfa:	e8 34 ef ff ff       	call   800d33 <memmove>
	nsipcbuf.send.req_size = size;
  801dff:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e05:	8b 45 14             	mov    0x14(%ebp),%eax
  801e08:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e0d:	b8 08 00 00 00       	mov    $0x8,%eax
  801e12:	e8 d9 fd ff ff       	call   801bf0 <nsipc>
}
  801e17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e32:	8b 45 10             	mov    0x10(%ebp),%eax
  801e35:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e3a:	b8 09 00 00 00       	mov    $0x9,%eax
  801e3f:	e8 ac fd ff ff       	call   801bf0 <nsipc>
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	56                   	push   %esi
  801e4a:	53                   	push   %ebx
  801e4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e4e:	83 ec 0c             	sub    $0xc,%esp
  801e51:	ff 75 08             	pushl  0x8(%ebp)
  801e54:	e8 8b f3 ff ff       	call   8011e4 <fd2data>
  801e59:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e5b:	83 c4 08             	add    $0x8,%esp
  801e5e:	68 88 2c 80 00       	push   $0x802c88
  801e63:	53                   	push   %ebx
  801e64:	e8 38 ed ff ff       	call   800ba1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e69:	8b 46 04             	mov    0x4(%esi),%eax
  801e6c:	2b 06                	sub    (%esi),%eax
  801e6e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e74:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e7b:	00 00 00 
	stat->st_dev = &devpipe;
  801e7e:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801e85:	30 80 00 
	return 0;
}
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    

00801e94 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	53                   	push   %ebx
  801e98:	83 ec 0c             	sub    $0xc,%esp
  801e9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e9e:	53                   	push   %ebx
  801e9f:	6a 00                	push   $0x0
  801ea1:	e8 83 f1 ff ff       	call   801029 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ea6:	89 1c 24             	mov    %ebx,(%esp)
  801ea9:	e8 36 f3 ff ff       	call   8011e4 <fd2data>
  801eae:	83 c4 08             	add    $0x8,%esp
  801eb1:	50                   	push   %eax
  801eb2:	6a 00                	push   $0x0
  801eb4:	e8 70 f1 ff ff       	call   801029 <sys_page_unmap>
}
  801eb9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    

00801ebe <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	83 ec 1c             	sub    $0x1c,%esp
  801ec7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801eca:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ecc:	a1 18 40 80 00       	mov    0x804018,%eax
  801ed1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ed4:	83 ec 0c             	sub    $0xc,%esp
  801ed7:	ff 75 e0             	pushl  -0x20(%ebp)
  801eda:	e8 82 05 00 00       	call   802461 <pageref>
  801edf:	89 c3                	mov    %eax,%ebx
  801ee1:	89 3c 24             	mov    %edi,(%esp)
  801ee4:	e8 78 05 00 00       	call   802461 <pageref>
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	39 c3                	cmp    %eax,%ebx
  801eee:	0f 94 c1             	sete   %cl
  801ef1:	0f b6 c9             	movzbl %cl,%ecx
  801ef4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ef7:	8b 15 18 40 80 00    	mov    0x804018,%edx
  801efd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f00:	39 ce                	cmp    %ecx,%esi
  801f02:	74 1b                	je     801f1f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f04:	39 c3                	cmp    %eax,%ebx
  801f06:	75 c4                	jne    801ecc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f08:	8b 42 58             	mov    0x58(%edx),%eax
  801f0b:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f0e:	50                   	push   %eax
  801f0f:	56                   	push   %esi
  801f10:	68 8f 2c 80 00       	push   $0x802c8f
  801f15:	e8 83 e6 ff ff       	call   80059d <cprintf>
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	eb ad                	jmp    801ecc <_pipeisclosed+0xe>
	}
}
  801f1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f25:	5b                   	pop    %ebx
  801f26:	5e                   	pop    %esi
  801f27:	5f                   	pop    %edi
  801f28:	5d                   	pop    %ebp
  801f29:	c3                   	ret    

00801f2a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f2a:	55                   	push   %ebp
  801f2b:	89 e5                	mov    %esp,%ebp
  801f2d:	57                   	push   %edi
  801f2e:	56                   	push   %esi
  801f2f:	53                   	push   %ebx
  801f30:	83 ec 28             	sub    $0x28,%esp
  801f33:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f36:	56                   	push   %esi
  801f37:	e8 a8 f2 ff ff       	call   8011e4 <fd2data>
  801f3c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3e:	83 c4 10             	add    $0x10,%esp
  801f41:	bf 00 00 00 00       	mov    $0x0,%edi
  801f46:	eb 4b                	jmp    801f93 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f48:	89 da                	mov    %ebx,%edx
  801f4a:	89 f0                	mov    %esi,%eax
  801f4c:	e8 6d ff ff ff       	call   801ebe <_pipeisclosed>
  801f51:	85 c0                	test   %eax,%eax
  801f53:	75 48                	jne    801f9d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f55:	e8 2b f0 ff ff       	call   800f85 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f5a:	8b 43 04             	mov    0x4(%ebx),%eax
  801f5d:	8b 0b                	mov    (%ebx),%ecx
  801f5f:	8d 51 20             	lea    0x20(%ecx),%edx
  801f62:	39 d0                	cmp    %edx,%eax
  801f64:	73 e2                	jae    801f48 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f69:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f6d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f70:	89 c2                	mov    %eax,%edx
  801f72:	c1 fa 1f             	sar    $0x1f,%edx
  801f75:	89 d1                	mov    %edx,%ecx
  801f77:	c1 e9 1b             	shr    $0x1b,%ecx
  801f7a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f7d:	83 e2 1f             	and    $0x1f,%edx
  801f80:	29 ca                	sub    %ecx,%edx
  801f82:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f86:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f8a:	83 c0 01             	add    $0x1,%eax
  801f8d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f90:	83 c7 01             	add    $0x1,%edi
  801f93:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f96:	75 c2                	jne    801f5a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f98:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9b:	eb 05                	jmp    801fa2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f9d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fa2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa5:	5b                   	pop    %ebx
  801fa6:	5e                   	pop    %esi
  801fa7:	5f                   	pop    %edi
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	57                   	push   %edi
  801fae:	56                   	push   %esi
  801faf:	53                   	push   %ebx
  801fb0:	83 ec 18             	sub    $0x18,%esp
  801fb3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fb6:	57                   	push   %edi
  801fb7:	e8 28 f2 ff ff       	call   8011e4 <fd2data>
  801fbc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc6:	eb 3d                	jmp    802005 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fc8:	85 db                	test   %ebx,%ebx
  801fca:	74 04                	je     801fd0 <devpipe_read+0x26>
				return i;
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	eb 44                	jmp    802014 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fd0:	89 f2                	mov    %esi,%edx
  801fd2:	89 f8                	mov    %edi,%eax
  801fd4:	e8 e5 fe ff ff       	call   801ebe <_pipeisclosed>
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	75 32                	jne    80200f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fdd:	e8 a3 ef ff ff       	call   800f85 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fe2:	8b 06                	mov    (%esi),%eax
  801fe4:	3b 46 04             	cmp    0x4(%esi),%eax
  801fe7:	74 df                	je     801fc8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fe9:	99                   	cltd   
  801fea:	c1 ea 1b             	shr    $0x1b,%edx
  801fed:	01 d0                	add    %edx,%eax
  801fef:	83 e0 1f             	and    $0x1f,%eax
  801ff2:	29 d0                	sub    %edx,%eax
  801ff4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ff9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ffc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fff:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802002:	83 c3 01             	add    $0x1,%ebx
  802005:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802008:	75 d8                	jne    801fe2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80200a:	8b 45 10             	mov    0x10(%ebp),%eax
  80200d:	eb 05                	jmp    802014 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802014:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802017:	5b                   	pop    %ebx
  802018:	5e                   	pop    %esi
  802019:	5f                   	pop    %edi
  80201a:	5d                   	pop    %ebp
  80201b:	c3                   	ret    

0080201c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	56                   	push   %esi
  802020:	53                   	push   %ebx
  802021:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802024:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802027:	50                   	push   %eax
  802028:	e8 ce f1 ff ff       	call   8011fb <fd_alloc>
  80202d:	83 c4 10             	add    $0x10,%esp
  802030:	89 c2                	mov    %eax,%edx
  802032:	85 c0                	test   %eax,%eax
  802034:	0f 88 2c 01 00 00    	js     802166 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80203a:	83 ec 04             	sub    $0x4,%esp
  80203d:	68 07 04 00 00       	push   $0x407
  802042:	ff 75 f4             	pushl  -0xc(%ebp)
  802045:	6a 00                	push   $0x0
  802047:	e8 58 ef ff ff       	call   800fa4 <sys_page_alloc>
  80204c:	83 c4 10             	add    $0x10,%esp
  80204f:	89 c2                	mov    %eax,%edx
  802051:	85 c0                	test   %eax,%eax
  802053:	0f 88 0d 01 00 00    	js     802166 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802059:	83 ec 0c             	sub    $0xc,%esp
  80205c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80205f:	50                   	push   %eax
  802060:	e8 96 f1 ff ff       	call   8011fb <fd_alloc>
  802065:	89 c3                	mov    %eax,%ebx
  802067:	83 c4 10             	add    $0x10,%esp
  80206a:	85 c0                	test   %eax,%eax
  80206c:	0f 88 e2 00 00 00    	js     802154 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802072:	83 ec 04             	sub    $0x4,%esp
  802075:	68 07 04 00 00       	push   $0x407
  80207a:	ff 75 f0             	pushl  -0x10(%ebp)
  80207d:	6a 00                	push   $0x0
  80207f:	e8 20 ef ff ff       	call   800fa4 <sys_page_alloc>
  802084:	89 c3                	mov    %eax,%ebx
  802086:	83 c4 10             	add    $0x10,%esp
  802089:	85 c0                	test   %eax,%eax
  80208b:	0f 88 c3 00 00 00    	js     802154 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802091:	83 ec 0c             	sub    $0xc,%esp
  802094:	ff 75 f4             	pushl  -0xc(%ebp)
  802097:	e8 48 f1 ff ff       	call   8011e4 <fd2data>
  80209c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209e:	83 c4 0c             	add    $0xc,%esp
  8020a1:	68 07 04 00 00       	push   $0x407
  8020a6:	50                   	push   %eax
  8020a7:	6a 00                	push   $0x0
  8020a9:	e8 f6 ee ff ff       	call   800fa4 <sys_page_alloc>
  8020ae:	89 c3                	mov    %eax,%ebx
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	0f 88 89 00 00 00    	js     802144 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020bb:	83 ec 0c             	sub    $0xc,%esp
  8020be:	ff 75 f0             	pushl  -0x10(%ebp)
  8020c1:	e8 1e f1 ff ff       	call   8011e4 <fd2data>
  8020c6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020cd:	50                   	push   %eax
  8020ce:	6a 00                	push   $0x0
  8020d0:	56                   	push   %esi
  8020d1:	6a 00                	push   $0x0
  8020d3:	e8 0f ef ff ff       	call   800fe7 <sys_page_map>
  8020d8:	89 c3                	mov    %eax,%ebx
  8020da:	83 c4 20             	add    $0x20,%esp
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	78 55                	js     802136 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020e1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ea:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ef:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020f6:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ff:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802101:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802104:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80210b:	83 ec 0c             	sub    $0xc,%esp
  80210e:	ff 75 f4             	pushl  -0xc(%ebp)
  802111:	e8 be f0 ff ff       	call   8011d4 <fd2num>
  802116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802119:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80211b:	83 c4 04             	add    $0x4,%esp
  80211e:	ff 75 f0             	pushl  -0x10(%ebp)
  802121:	e8 ae f0 ff ff       	call   8011d4 <fd2num>
  802126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802129:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	ba 00 00 00 00       	mov    $0x0,%edx
  802134:	eb 30                	jmp    802166 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802136:	83 ec 08             	sub    $0x8,%esp
  802139:	56                   	push   %esi
  80213a:	6a 00                	push   $0x0
  80213c:	e8 e8 ee ff ff       	call   801029 <sys_page_unmap>
  802141:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802144:	83 ec 08             	sub    $0x8,%esp
  802147:	ff 75 f0             	pushl  -0x10(%ebp)
  80214a:	6a 00                	push   $0x0
  80214c:	e8 d8 ee ff ff       	call   801029 <sys_page_unmap>
  802151:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802154:	83 ec 08             	sub    $0x8,%esp
  802157:	ff 75 f4             	pushl  -0xc(%ebp)
  80215a:	6a 00                	push   $0x0
  80215c:	e8 c8 ee ff ff       	call   801029 <sys_page_unmap>
  802161:	83 c4 10             	add    $0x10,%esp
  802164:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802166:	89 d0                	mov    %edx,%eax
  802168:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80216b:	5b                   	pop    %ebx
  80216c:	5e                   	pop    %esi
  80216d:	5d                   	pop    %ebp
  80216e:	c3                   	ret    

0080216f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80216f:	55                   	push   %ebp
  802170:	89 e5                	mov    %esp,%ebp
  802172:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802175:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802178:	50                   	push   %eax
  802179:	ff 75 08             	pushl  0x8(%ebp)
  80217c:	e8 c9 f0 ff ff       	call   80124a <fd_lookup>
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	85 c0                	test   %eax,%eax
  802186:	78 18                	js     8021a0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802188:	83 ec 0c             	sub    $0xc,%esp
  80218b:	ff 75 f4             	pushl  -0xc(%ebp)
  80218e:	e8 51 f0 ff ff       	call   8011e4 <fd2data>
	return _pipeisclosed(fd, p);
  802193:	89 c2                	mov    %eax,%edx
  802195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802198:	e8 21 fd ff ff       	call   801ebe <_pipeisclosed>
  80219d:	83 c4 10             	add    $0x10,%esp
}
  8021a0:	c9                   	leave  
  8021a1:	c3                   	ret    

008021a2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8021a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    

008021ac <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021b2:	68 a7 2c 80 00       	push   $0x802ca7
  8021b7:	ff 75 0c             	pushl  0xc(%ebp)
  8021ba:	e8 e2 e9 ff ff       	call   800ba1 <strcpy>
	return 0;
}
  8021bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8021c4:	c9                   	leave  
  8021c5:	c3                   	ret    

008021c6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	57                   	push   %edi
  8021ca:	56                   	push   %esi
  8021cb:	53                   	push   %ebx
  8021cc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021d2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021d7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021dd:	eb 2d                	jmp    80220c <devcons_write+0x46>
		m = n - tot;
  8021df:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021e2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021e4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021e7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021ec:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021ef:	83 ec 04             	sub    $0x4,%esp
  8021f2:	53                   	push   %ebx
  8021f3:	03 45 0c             	add    0xc(%ebp),%eax
  8021f6:	50                   	push   %eax
  8021f7:	57                   	push   %edi
  8021f8:	e8 36 eb ff ff       	call   800d33 <memmove>
		sys_cputs(buf, m);
  8021fd:	83 c4 08             	add    $0x8,%esp
  802200:	53                   	push   %ebx
  802201:	57                   	push   %edi
  802202:	e8 e1 ec ff ff       	call   800ee8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802207:	01 de                	add    %ebx,%esi
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	89 f0                	mov    %esi,%eax
  80220e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802211:	72 cc                	jb     8021df <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802216:	5b                   	pop    %ebx
  802217:	5e                   	pop    %esi
  802218:	5f                   	pop    %edi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    

0080221b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80221b:	55                   	push   %ebp
  80221c:	89 e5                	mov    %esp,%ebp
  80221e:	83 ec 08             	sub    $0x8,%esp
  802221:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802226:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80222a:	74 2a                	je     802256 <devcons_read+0x3b>
  80222c:	eb 05                	jmp    802233 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80222e:	e8 52 ed ff ff       	call   800f85 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802233:	e8 ce ec ff ff       	call   800f06 <sys_cgetc>
  802238:	85 c0                	test   %eax,%eax
  80223a:	74 f2                	je     80222e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80223c:	85 c0                	test   %eax,%eax
  80223e:	78 16                	js     802256 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802240:	83 f8 04             	cmp    $0x4,%eax
  802243:	74 0c                	je     802251 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802245:	8b 55 0c             	mov    0xc(%ebp),%edx
  802248:	88 02                	mov    %al,(%edx)
	return 1;
  80224a:	b8 01 00 00 00       	mov    $0x1,%eax
  80224f:	eb 05                	jmp    802256 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802251:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80225e:	8b 45 08             	mov    0x8(%ebp),%eax
  802261:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802264:	6a 01                	push   $0x1
  802266:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802269:	50                   	push   %eax
  80226a:	e8 79 ec ff ff       	call   800ee8 <sys_cputs>
}
  80226f:	83 c4 10             	add    $0x10,%esp
  802272:	c9                   	leave  
  802273:	c3                   	ret    

00802274 <getchar>:

int
getchar(void)
{
  802274:	55                   	push   %ebp
  802275:	89 e5                	mov    %esp,%ebp
  802277:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80227a:	6a 01                	push   $0x1
  80227c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80227f:	50                   	push   %eax
  802280:	6a 00                	push   $0x0
  802282:	e8 29 f2 ff ff       	call   8014b0 <read>
	if (r < 0)
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	85 c0                	test   %eax,%eax
  80228c:	78 0f                	js     80229d <getchar+0x29>
		return r;
	if (r < 1)
  80228e:	85 c0                	test   %eax,%eax
  802290:	7e 06                	jle    802298 <getchar+0x24>
		return -E_EOF;
	return c;
  802292:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802296:	eb 05                	jmp    80229d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802298:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80229d:	c9                   	leave  
  80229e:	c3                   	ret    

0080229f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a8:	50                   	push   %eax
  8022a9:	ff 75 08             	pushl  0x8(%ebp)
  8022ac:	e8 99 ef ff ff       	call   80124a <fd_lookup>
  8022b1:	83 c4 10             	add    $0x10,%esp
  8022b4:	85 c0                	test   %eax,%eax
  8022b6:	78 11                	js     8022c9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8022b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022bb:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8022c1:	39 10                	cmp    %edx,(%eax)
  8022c3:	0f 94 c0             	sete   %al
  8022c6:	0f b6 c0             	movzbl %al,%eax
}
  8022c9:	c9                   	leave  
  8022ca:	c3                   	ret    

008022cb <opencons>:

int
opencons(void)
{
  8022cb:	55                   	push   %ebp
  8022cc:	89 e5                	mov    %esp,%ebp
  8022ce:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022d4:	50                   	push   %eax
  8022d5:	e8 21 ef ff ff       	call   8011fb <fd_alloc>
  8022da:	83 c4 10             	add    $0x10,%esp
		return r;
  8022dd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	78 3e                	js     802321 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022e3:	83 ec 04             	sub    $0x4,%esp
  8022e6:	68 07 04 00 00       	push   $0x407
  8022eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ee:	6a 00                	push   $0x0
  8022f0:	e8 af ec ff ff       	call   800fa4 <sys_page_alloc>
  8022f5:	83 c4 10             	add    $0x10,%esp
		return r;
  8022f8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022fa:	85 c0                	test   %eax,%eax
  8022fc:	78 23                	js     802321 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022fe:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  802304:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802307:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802309:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802313:	83 ec 0c             	sub    $0xc,%esp
  802316:	50                   	push   %eax
  802317:	e8 b8 ee ff ff       	call   8011d4 <fd2num>
  80231c:	89 c2                	mov    %eax,%edx
  80231e:	83 c4 10             	add    $0x10,%esp
}
  802321:	89 d0                	mov    %edx,%eax
  802323:	c9                   	leave  
  802324:	c3                   	ret    

00802325 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802325:	55                   	push   %ebp
  802326:	89 e5                	mov    %esp,%ebp
  802328:	56                   	push   %esi
  802329:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80232a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80232d:	8b 35 04 30 80 00    	mov    0x803004,%esi
  802333:	e8 2e ec ff ff       	call   800f66 <sys_getenvid>
  802338:	83 ec 0c             	sub    $0xc,%esp
  80233b:	ff 75 0c             	pushl  0xc(%ebp)
  80233e:	ff 75 08             	pushl  0x8(%ebp)
  802341:	56                   	push   %esi
  802342:	50                   	push   %eax
  802343:	68 b4 2c 80 00       	push   $0x802cb4
  802348:	e8 50 e2 ff ff       	call   80059d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80234d:	83 c4 18             	add    $0x18,%esp
  802350:	53                   	push   %ebx
  802351:	ff 75 10             	pushl  0x10(%ebp)
  802354:	e8 f3 e1 ff ff       	call   80054c <vcprintf>
	cprintf("\n");
  802359:	c7 04 24 f4 27 80 00 	movl   $0x8027f4,(%esp)
  802360:	e8 38 e2 ff ff       	call   80059d <cprintf>
  802365:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802368:	cc                   	int3   
  802369:	eb fd                	jmp    802368 <_panic+0x43>

0080236b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80236b:	55                   	push   %ebp
  80236c:	89 e5                	mov    %esp,%ebp
  80236e:	56                   	push   %esi
  80236f:	53                   	push   %ebx
  802370:	8b 75 08             	mov    0x8(%ebp),%esi
  802373:	8b 45 0c             	mov    0xc(%ebp),%eax
  802376:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  802379:	85 c0                	test   %eax,%eax
  80237b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802380:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  802383:	83 ec 0c             	sub    $0xc,%esp
  802386:	50                   	push   %eax
  802387:	e8 c8 ed ff ff       	call   801154 <sys_ipc_recv>
  80238c:	83 c4 10             	add    $0x10,%esp
  80238f:	85 c0                	test   %eax,%eax
  802391:	79 16                	jns    8023a9 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  802393:	85 f6                	test   %esi,%esi
  802395:	74 06                	je     80239d <ipc_recv+0x32>
            *from_env_store = 0;
  802397:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  80239d:	85 db                	test   %ebx,%ebx
  80239f:	74 2c                	je     8023cd <ipc_recv+0x62>
            *perm_store = 0;
  8023a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8023a7:	eb 24                	jmp    8023cd <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8023a9:	85 f6                	test   %esi,%esi
  8023ab:	74 0a                	je     8023b7 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8023ad:	a1 18 40 80 00       	mov    0x804018,%eax
  8023b2:	8b 40 74             	mov    0x74(%eax),%eax
  8023b5:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8023b7:	85 db                	test   %ebx,%ebx
  8023b9:	74 0a                	je     8023c5 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8023bb:	a1 18 40 80 00       	mov    0x804018,%eax
  8023c0:	8b 40 78             	mov    0x78(%eax),%eax
  8023c3:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8023c5:	a1 18 40 80 00       	mov    0x804018,%eax
  8023ca:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8023cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    

008023d4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	57                   	push   %edi
  8023d8:	56                   	push   %esi
  8023d9:	53                   	push   %ebx
  8023da:	83 ec 0c             	sub    $0xc,%esp
  8023dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8023e6:	85 c0                	test   %eax,%eax
  8023e8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8023ed:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8023f0:	eb 1c                	jmp    80240e <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  8023f2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8023f5:	74 12                	je     802409 <ipc_send+0x35>
  8023f7:	50                   	push   %eax
  8023f8:	68 d8 2c 80 00       	push   $0x802cd8
  8023fd:	6a 3b                	push   $0x3b
  8023ff:	68 ee 2c 80 00       	push   $0x802cee
  802404:	e8 1c ff ff ff       	call   802325 <_panic>
		sys_yield();
  802409:	e8 77 eb ff ff       	call   800f85 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80240e:	ff 75 14             	pushl  0x14(%ebp)
  802411:	53                   	push   %ebx
  802412:	56                   	push   %esi
  802413:	57                   	push   %edi
  802414:	e8 18 ed ff ff       	call   801131 <sys_ipc_try_send>
  802419:	83 c4 10             	add    $0x10,%esp
  80241c:	85 c0                	test   %eax,%eax
  80241e:	78 d2                	js     8023f2 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802420:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802423:	5b                   	pop    %ebx
  802424:	5e                   	pop    %esi
  802425:	5f                   	pop    %edi
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    

00802428 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802428:	55                   	push   %ebp
  802429:	89 e5                	mov    %esp,%ebp
  80242b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80242e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802433:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802436:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80243c:	8b 52 50             	mov    0x50(%edx),%edx
  80243f:	39 ca                	cmp    %ecx,%edx
  802441:	75 0d                	jne    802450 <ipc_find_env+0x28>
			return envs[i].env_id;
  802443:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802446:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80244b:	8b 40 48             	mov    0x48(%eax),%eax
  80244e:	eb 0f                	jmp    80245f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802450:	83 c0 01             	add    $0x1,%eax
  802453:	3d 00 04 00 00       	cmp    $0x400,%eax
  802458:	75 d9                	jne    802433 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80245a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80245f:	5d                   	pop    %ebp
  802460:	c3                   	ret    

00802461 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802461:	55                   	push   %ebp
  802462:	89 e5                	mov    %esp,%ebp
  802464:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802467:	89 d0                	mov    %edx,%eax
  802469:	c1 e8 16             	shr    $0x16,%eax
  80246c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802473:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802478:	f6 c1 01             	test   $0x1,%cl
  80247b:	74 1d                	je     80249a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80247d:	c1 ea 0c             	shr    $0xc,%edx
  802480:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802487:	f6 c2 01             	test   $0x1,%dl
  80248a:	74 0e                	je     80249a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80248c:	c1 ea 0c             	shr    $0xc,%edx
  80248f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802496:	ef 
  802497:	0f b7 c0             	movzwl %ax,%eax
}
  80249a:	5d                   	pop    %ebp
  80249b:	c3                   	ret    
  80249c:	66 90                	xchg   %ax,%ax
  80249e:	66 90                	xchg   %ax,%ax

008024a0 <__udivdi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	57                   	push   %edi
  8024a2:	56                   	push   %esi
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 1c             	sub    $0x1c,%esp
  8024a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024b7:	85 f6                	test   %esi,%esi
  8024b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024bd:	89 ca                	mov    %ecx,%edx
  8024bf:	89 f8                	mov    %edi,%eax
  8024c1:	75 3d                	jne    802500 <__udivdi3+0x60>
  8024c3:	39 cf                	cmp    %ecx,%edi
  8024c5:	0f 87 c5 00 00 00    	ja     802590 <__udivdi3+0xf0>
  8024cb:	85 ff                	test   %edi,%edi
  8024cd:	89 fd                	mov    %edi,%ebp
  8024cf:	75 0b                	jne    8024dc <__udivdi3+0x3c>
  8024d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d6:	31 d2                	xor    %edx,%edx
  8024d8:	f7 f7                	div    %edi
  8024da:	89 c5                	mov    %eax,%ebp
  8024dc:	89 c8                	mov    %ecx,%eax
  8024de:	31 d2                	xor    %edx,%edx
  8024e0:	f7 f5                	div    %ebp
  8024e2:	89 c1                	mov    %eax,%ecx
  8024e4:	89 d8                	mov    %ebx,%eax
  8024e6:	89 cf                	mov    %ecx,%edi
  8024e8:	f7 f5                	div    %ebp
  8024ea:	89 c3                	mov    %eax,%ebx
  8024ec:	89 d8                	mov    %ebx,%eax
  8024ee:	89 fa                	mov    %edi,%edx
  8024f0:	83 c4 1c             	add    $0x1c,%esp
  8024f3:	5b                   	pop    %ebx
  8024f4:	5e                   	pop    %esi
  8024f5:	5f                   	pop    %edi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
  8024f8:	90                   	nop
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	39 ce                	cmp    %ecx,%esi
  802502:	77 74                	ja     802578 <__udivdi3+0xd8>
  802504:	0f bd fe             	bsr    %esi,%edi
  802507:	83 f7 1f             	xor    $0x1f,%edi
  80250a:	0f 84 98 00 00 00    	je     8025a8 <__udivdi3+0x108>
  802510:	bb 20 00 00 00       	mov    $0x20,%ebx
  802515:	89 f9                	mov    %edi,%ecx
  802517:	89 c5                	mov    %eax,%ebp
  802519:	29 fb                	sub    %edi,%ebx
  80251b:	d3 e6                	shl    %cl,%esi
  80251d:	89 d9                	mov    %ebx,%ecx
  80251f:	d3 ed                	shr    %cl,%ebp
  802521:	89 f9                	mov    %edi,%ecx
  802523:	d3 e0                	shl    %cl,%eax
  802525:	09 ee                	or     %ebp,%esi
  802527:	89 d9                	mov    %ebx,%ecx
  802529:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80252d:	89 d5                	mov    %edx,%ebp
  80252f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802533:	d3 ed                	shr    %cl,%ebp
  802535:	89 f9                	mov    %edi,%ecx
  802537:	d3 e2                	shl    %cl,%edx
  802539:	89 d9                	mov    %ebx,%ecx
  80253b:	d3 e8                	shr    %cl,%eax
  80253d:	09 c2                	or     %eax,%edx
  80253f:	89 d0                	mov    %edx,%eax
  802541:	89 ea                	mov    %ebp,%edx
  802543:	f7 f6                	div    %esi
  802545:	89 d5                	mov    %edx,%ebp
  802547:	89 c3                	mov    %eax,%ebx
  802549:	f7 64 24 0c          	mull   0xc(%esp)
  80254d:	39 d5                	cmp    %edx,%ebp
  80254f:	72 10                	jb     802561 <__udivdi3+0xc1>
  802551:	8b 74 24 08          	mov    0x8(%esp),%esi
  802555:	89 f9                	mov    %edi,%ecx
  802557:	d3 e6                	shl    %cl,%esi
  802559:	39 c6                	cmp    %eax,%esi
  80255b:	73 07                	jae    802564 <__udivdi3+0xc4>
  80255d:	39 d5                	cmp    %edx,%ebp
  80255f:	75 03                	jne    802564 <__udivdi3+0xc4>
  802561:	83 eb 01             	sub    $0x1,%ebx
  802564:	31 ff                	xor    %edi,%edi
  802566:	89 d8                	mov    %ebx,%eax
  802568:	89 fa                	mov    %edi,%edx
  80256a:	83 c4 1c             	add    $0x1c,%esp
  80256d:	5b                   	pop    %ebx
  80256e:	5e                   	pop    %esi
  80256f:	5f                   	pop    %edi
  802570:	5d                   	pop    %ebp
  802571:	c3                   	ret    
  802572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802578:	31 ff                	xor    %edi,%edi
  80257a:	31 db                	xor    %ebx,%ebx
  80257c:	89 d8                	mov    %ebx,%eax
  80257e:	89 fa                	mov    %edi,%edx
  802580:	83 c4 1c             	add    $0x1c,%esp
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    
  802588:	90                   	nop
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	89 d8                	mov    %ebx,%eax
  802592:	f7 f7                	div    %edi
  802594:	31 ff                	xor    %edi,%edi
  802596:	89 c3                	mov    %eax,%ebx
  802598:	89 d8                	mov    %ebx,%eax
  80259a:	89 fa                	mov    %edi,%edx
  80259c:	83 c4 1c             	add    $0x1c,%esp
  80259f:	5b                   	pop    %ebx
  8025a0:	5e                   	pop    %esi
  8025a1:	5f                   	pop    %edi
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    
  8025a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	39 ce                	cmp    %ecx,%esi
  8025aa:	72 0c                	jb     8025b8 <__udivdi3+0x118>
  8025ac:	31 db                	xor    %ebx,%ebx
  8025ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025b2:	0f 87 34 ff ff ff    	ja     8024ec <__udivdi3+0x4c>
  8025b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025bd:	e9 2a ff ff ff       	jmp    8024ec <__udivdi3+0x4c>
  8025c2:	66 90                	xchg   %ax,%ax
  8025c4:	66 90                	xchg   %ax,%ax
  8025c6:	66 90                	xchg   %ax,%ax
  8025c8:	66 90                	xchg   %ax,%ax
  8025ca:	66 90                	xchg   %ax,%ax
  8025cc:	66 90                	xchg   %ax,%ax
  8025ce:	66 90                	xchg   %ax,%ax

008025d0 <__umoddi3>:
  8025d0:	55                   	push   %ebp
  8025d1:	57                   	push   %edi
  8025d2:	56                   	push   %esi
  8025d3:	53                   	push   %ebx
  8025d4:	83 ec 1c             	sub    $0x1c,%esp
  8025d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025e7:	85 d2                	test   %edx,%edx
  8025e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025f1:	89 f3                	mov    %esi,%ebx
  8025f3:	89 3c 24             	mov    %edi,(%esp)
  8025f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025fa:	75 1c                	jne    802618 <__umoddi3+0x48>
  8025fc:	39 f7                	cmp    %esi,%edi
  8025fe:	76 50                	jbe    802650 <__umoddi3+0x80>
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	f7 f7                	div    %edi
  802606:	89 d0                	mov    %edx,%eax
  802608:	31 d2                	xor    %edx,%edx
  80260a:	83 c4 1c             	add    $0x1c,%esp
  80260d:	5b                   	pop    %ebx
  80260e:	5e                   	pop    %esi
  80260f:	5f                   	pop    %edi
  802610:	5d                   	pop    %ebp
  802611:	c3                   	ret    
  802612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802618:	39 f2                	cmp    %esi,%edx
  80261a:	89 d0                	mov    %edx,%eax
  80261c:	77 52                	ja     802670 <__umoddi3+0xa0>
  80261e:	0f bd ea             	bsr    %edx,%ebp
  802621:	83 f5 1f             	xor    $0x1f,%ebp
  802624:	75 5a                	jne    802680 <__umoddi3+0xb0>
  802626:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80262a:	0f 82 e0 00 00 00    	jb     802710 <__umoddi3+0x140>
  802630:	39 0c 24             	cmp    %ecx,(%esp)
  802633:	0f 86 d7 00 00 00    	jbe    802710 <__umoddi3+0x140>
  802639:	8b 44 24 08          	mov    0x8(%esp),%eax
  80263d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802641:	83 c4 1c             	add    $0x1c,%esp
  802644:	5b                   	pop    %ebx
  802645:	5e                   	pop    %esi
  802646:	5f                   	pop    %edi
  802647:	5d                   	pop    %ebp
  802648:	c3                   	ret    
  802649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802650:	85 ff                	test   %edi,%edi
  802652:	89 fd                	mov    %edi,%ebp
  802654:	75 0b                	jne    802661 <__umoddi3+0x91>
  802656:	b8 01 00 00 00       	mov    $0x1,%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	f7 f7                	div    %edi
  80265f:	89 c5                	mov    %eax,%ebp
  802661:	89 f0                	mov    %esi,%eax
  802663:	31 d2                	xor    %edx,%edx
  802665:	f7 f5                	div    %ebp
  802667:	89 c8                	mov    %ecx,%eax
  802669:	f7 f5                	div    %ebp
  80266b:	89 d0                	mov    %edx,%eax
  80266d:	eb 99                	jmp    802608 <__umoddi3+0x38>
  80266f:	90                   	nop
  802670:	89 c8                	mov    %ecx,%eax
  802672:	89 f2                	mov    %esi,%edx
  802674:	83 c4 1c             	add    $0x1c,%esp
  802677:	5b                   	pop    %ebx
  802678:	5e                   	pop    %esi
  802679:	5f                   	pop    %edi
  80267a:	5d                   	pop    %ebp
  80267b:	c3                   	ret    
  80267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802680:	8b 34 24             	mov    (%esp),%esi
  802683:	bf 20 00 00 00       	mov    $0x20,%edi
  802688:	89 e9                	mov    %ebp,%ecx
  80268a:	29 ef                	sub    %ebp,%edi
  80268c:	d3 e0                	shl    %cl,%eax
  80268e:	89 f9                	mov    %edi,%ecx
  802690:	89 f2                	mov    %esi,%edx
  802692:	d3 ea                	shr    %cl,%edx
  802694:	89 e9                	mov    %ebp,%ecx
  802696:	09 c2                	or     %eax,%edx
  802698:	89 d8                	mov    %ebx,%eax
  80269a:	89 14 24             	mov    %edx,(%esp)
  80269d:	89 f2                	mov    %esi,%edx
  80269f:	d3 e2                	shl    %cl,%edx
  8026a1:	89 f9                	mov    %edi,%ecx
  8026a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026ab:	d3 e8                	shr    %cl,%eax
  8026ad:	89 e9                	mov    %ebp,%ecx
  8026af:	89 c6                	mov    %eax,%esi
  8026b1:	d3 e3                	shl    %cl,%ebx
  8026b3:	89 f9                	mov    %edi,%ecx
  8026b5:	89 d0                	mov    %edx,%eax
  8026b7:	d3 e8                	shr    %cl,%eax
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	09 d8                	or     %ebx,%eax
  8026bd:	89 d3                	mov    %edx,%ebx
  8026bf:	89 f2                	mov    %esi,%edx
  8026c1:	f7 34 24             	divl   (%esp)
  8026c4:	89 d6                	mov    %edx,%esi
  8026c6:	d3 e3                	shl    %cl,%ebx
  8026c8:	f7 64 24 04          	mull   0x4(%esp)
  8026cc:	39 d6                	cmp    %edx,%esi
  8026ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026d2:	89 d1                	mov    %edx,%ecx
  8026d4:	89 c3                	mov    %eax,%ebx
  8026d6:	72 08                	jb     8026e0 <__umoddi3+0x110>
  8026d8:	75 11                	jne    8026eb <__umoddi3+0x11b>
  8026da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026de:	73 0b                	jae    8026eb <__umoddi3+0x11b>
  8026e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026e4:	1b 14 24             	sbb    (%esp),%edx
  8026e7:	89 d1                	mov    %edx,%ecx
  8026e9:	89 c3                	mov    %eax,%ebx
  8026eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026ef:	29 da                	sub    %ebx,%edx
  8026f1:	19 ce                	sbb    %ecx,%esi
  8026f3:	89 f9                	mov    %edi,%ecx
  8026f5:	89 f0                	mov    %esi,%eax
  8026f7:	d3 e0                	shl    %cl,%eax
  8026f9:	89 e9                	mov    %ebp,%ecx
  8026fb:	d3 ea                	shr    %cl,%edx
  8026fd:	89 e9                	mov    %ebp,%ecx
  8026ff:	d3 ee                	shr    %cl,%esi
  802701:	09 d0                	or     %edx,%eax
  802703:	89 f2                	mov    %esi,%edx
  802705:	83 c4 1c             	add    $0x1c,%esp
  802708:	5b                   	pop    %ebx
  802709:	5e                   	pop    %esi
  80270a:	5f                   	pop    %edi
  80270b:	5d                   	pop    %ebp
  80270c:	c3                   	ret    
  80270d:	8d 76 00             	lea    0x0(%esi),%esi
  802710:	29 f9                	sub    %edi,%ecx
  802712:	19 d6                	sbb    %edx,%esi
  802714:	89 74 24 04          	mov    %esi,0x4(%esp)
  802718:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80271c:	e9 18 ff ff ff       	jmp    802639 <__umoddi3+0x69>
