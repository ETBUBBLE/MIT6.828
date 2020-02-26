
obj/user/fairness.debug：     文件格式 elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 1d 0b 00 00       	call   800b5d <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 6d 0d 00 00       	call   800dcb <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 40 23 80 00       	push   $0x802340
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 51 23 80 00       	push   $0x802351
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 98 0d 00 00       	call   800e34 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 ac 0a 00 00       	call   800b5d <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
        binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 9a 0f 00 00       	call   80108c <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 20 0a 00 00       	call   800b1c <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 ae 09 00 00       	call   800adf <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 1a 01 00 00       	call   800291 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 53 09 00 00       	call   800adf <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 a4 1e 00 00       	call   8020a0 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 91 1f 00 00       	call   8021d0 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 72 23 80 00 	movsbl 0x802372(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800261:	8b 10                	mov    (%eax),%edx
  800263:	3b 50 04             	cmp    0x4(%eax),%edx
  800266:	73 0a                	jae    800272 <sprintputch+0x1b>
		*b->buf++ = ch;
  800268:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	88 02                	mov    %al,(%edx)
}
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027d:	50                   	push   %eax
  80027e:	ff 75 10             	pushl  0x10(%ebp)
  800281:	ff 75 0c             	pushl  0xc(%ebp)
  800284:	ff 75 08             	pushl  0x8(%ebp)
  800287:	e8 05 00 00 00       	call   800291 <vprintfmt>
	va_end(ap);
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 2c             	sub    $0x2c,%esp
  80029a:	8b 75 08             	mov    0x8(%ebp),%esi
  80029d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a3:	eb 12                	jmp    8002b7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a5:	85 c0                	test   %eax,%eax
  8002a7:	0f 84 42 04 00 00    	je     8006ef <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	53                   	push   %ebx
  8002b1:	50                   	push   %eax
  8002b2:	ff d6                	call   *%esi
  8002b4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b7:	83 c7 01             	add    $0x1,%edi
  8002ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002be:	83 f8 25             	cmp    $0x25,%eax
  8002c1:	75 e2                	jne    8002a5 <vprintfmt+0x14>
  8002c3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e1:	eb 07                	jmp    8002ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ea:	8d 47 01             	lea    0x1(%edi),%eax
  8002ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f0:	0f b6 07             	movzbl (%edi),%eax
  8002f3:	0f b6 d0             	movzbl %al,%edx
  8002f6:	83 e8 23             	sub    $0x23,%eax
  8002f9:	3c 55                	cmp    $0x55,%al
  8002fb:	0f 87 d3 03 00 00    	ja     8006d4 <vprintfmt+0x443>
  800301:	0f b6 c0             	movzbl %al,%eax
  800304:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800312:	eb d6                	jmp    8002ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	b8 00 00 00 00       	mov    $0x0,%eax
  80031c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800322:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800326:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800329:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032c:	83 f9 09             	cmp    $0x9,%ecx
  80032f:	77 3f                	ja     800370 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800331:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800334:	eb e9                	jmp    80031f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8d 40 04             	lea    0x4(%eax),%eax
  800344:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034a:	eb 2a                	jmp    800376 <vprintfmt+0xe5>
  80034c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034f:	85 c0                	test   %eax,%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	0f 49 d0             	cmovns %eax,%edx
  800359:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035f:	eb 89                	jmp    8002ea <vprintfmt+0x59>
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800364:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036b:	e9 7a ff ff ff       	jmp    8002ea <vprintfmt+0x59>
  800370:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800376:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037a:	0f 89 6a ff ff ff    	jns    8002ea <vprintfmt+0x59>
				width = precision, precision = -1;
  800380:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038d:	e9 58 ff ff ff       	jmp    8002ea <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800392:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800398:	e9 4d ff ff ff       	jmp    8002ea <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 78 04             	lea    0x4(%eax),%edi
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	53                   	push   %ebx
  8003a7:	ff 30                	pushl  (%eax)
  8003a9:	ff d6                	call   *%esi
			break;
  8003ab:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b4:	e9 fe fe ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
  8003c2:	31 d0                	xor    %edx,%eax
  8003c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c6:	83 f8 0f             	cmp    $0xf,%eax
  8003c9:	7f 0b                	jg     8003d6 <vprintfmt+0x145>
  8003cb:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	75 1b                	jne    8003f1 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003d6:	50                   	push   %eax
  8003d7:	68 8a 23 80 00       	push   $0x80238a
  8003dc:	53                   	push   %ebx
  8003dd:	56                   	push   %esi
  8003de:	e8 91 fe ff ff       	call   800274 <printfmt>
  8003e3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ec:	e9 c6 fe ff ff       	jmp    8002b7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 75 27 80 00       	push   $0x802775
  8003f7:	53                   	push   %ebx
  8003f8:	56                   	push   %esi
  8003f9:	e8 76 fe ff ff       	call   800274 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800407:	e9 ab fe ff ff       	jmp    8002b7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	83 c0 04             	add    $0x4,%eax
  800412:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041a:	85 ff                	test   %edi,%edi
  80041c:	b8 83 23 80 00       	mov    $0x802383,%eax
  800421:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800424:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800428:	0f 8e 94 00 00 00    	jle    8004c2 <vprintfmt+0x231>
  80042e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800432:	0f 84 98 00 00 00    	je     8004d0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 d0             	pushl  -0x30(%ebp)
  80043e:	57                   	push   %edi
  80043f:	e8 33 03 00 00       	call   800777 <strnlen>
  800444:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800447:	29 c1                	sub    %eax,%ecx
  800449:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80044c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800456:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800459:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	eb 0f                	jmp    80046c <vprintfmt+0x1db>
					putch(padc, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	53                   	push   %ebx
  800461:	ff 75 e0             	pushl  -0x20(%ebp)
  800464:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ef 01             	sub    $0x1,%edi
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	85 ff                	test   %edi,%edi
  80046e:	7f ed                	jg     80045d <vprintfmt+0x1cc>
  800470:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800473:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800476:	85 c9                	test   %ecx,%ecx
  800478:	b8 00 00 00 00       	mov    $0x0,%eax
  80047d:	0f 49 c1             	cmovns %ecx,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 75 08             	mov    %esi,0x8(%ebp)
  800485:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800488:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048b:	89 cb                	mov    %ecx,%ebx
  80048d:	eb 4d                	jmp    8004dc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800493:	74 1b                	je     8004b0 <vprintfmt+0x21f>
  800495:	0f be c0             	movsbl %al,%eax
  800498:	83 e8 20             	sub    $0x20,%eax
  80049b:	83 f8 5e             	cmp    $0x5e,%eax
  80049e:	76 10                	jbe    8004b0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	6a 3f                	push   $0x3f
  8004a8:	ff 55 08             	call   *0x8(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	eb 0d                	jmp    8004bd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	52                   	push   %edx
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bd:	83 eb 01             	sub    $0x1,%ebx
  8004c0:	eb 1a                	jmp    8004dc <vprintfmt+0x24b>
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ce:	eb 0c                	jmp    8004dc <vprintfmt+0x24b>
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dc:	83 c7 01             	add    $0x1,%edi
  8004df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e3:	0f be d0             	movsbl %al,%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	74 23                	je     80050d <vprintfmt+0x27c>
  8004ea:	85 f6                	test   %esi,%esi
  8004ec:	78 a1                	js     80048f <vprintfmt+0x1fe>
  8004ee:	83 ee 01             	sub    $0x1,%esi
  8004f1:	79 9c                	jns    80048f <vprintfmt+0x1fe>
  8004f3:	89 df                	mov    %ebx,%edi
  8004f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fb:	eb 18                	jmp    800515 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	6a 20                	push   $0x20
  800503:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 08                	jmp    800515 <vprintfmt+0x284>
  80050d:	89 df                	mov    %ebx,%edi
  80050f:	8b 75 08             	mov    0x8(%ebp),%esi
  800512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800515:	85 ff                	test   %edi,%edi
  800517:	7f e4                	jg     8004fd <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800522:	e9 90 fd ff ff       	jmp    8002b7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7e 19                	jle    800545 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8b 50 04             	mov    0x4(%eax),%edx
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 40 08             	lea    0x8(%eax),%eax
  800540:	89 45 14             	mov    %eax,0x14(%ebp)
  800543:	eb 38                	jmp    80057d <vprintfmt+0x2ec>
	else if (lflag)
  800545:	85 c9                	test   %ecx,%ecx
  800547:	74 1b                	je     800564 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 c1                	mov    %eax,%ecx
  800553:	c1 f9 1f             	sar    $0x1f,%ecx
  800556:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 40 04             	lea    0x4(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
  800562:	eb 19                	jmp    80057d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	89 c1                	mov    %eax,%ecx
  80056e:	c1 f9 1f             	sar    $0x1f,%ecx
  800571:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800580:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800583:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800588:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058c:	0f 89 0e 01 00 00    	jns    8006a0 <vprintfmt+0x40f>
				putch('-', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	6a 2d                	push   $0x2d
  800598:	ff d6                	call   *%esi
				num = -(long long) num;
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a0:	f7 da                	neg    %edx
  8005a2:	83 d1 00             	adc    $0x0,%ecx
  8005a5:	f7 d9                	neg    %ecx
  8005a7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	e9 ec 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b4:	83 f9 01             	cmp    $0x1,%ecx
  8005b7:	7e 18                	jle    8005d1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c1:	8d 40 08             	lea    0x8(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 cf 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	74 1a                	je     8005ef <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ea:	e9 b1 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 97 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 58                	push   $0x58
  80060f:	ff d6                	call   *%esi
			putch('X', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 58                	push   $0x58
  800617:	ff d6                	call   *%esi
			putch('X', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 58                	push   $0x58
  80061f:	ff d6                	call   *%esi
			break;
  800621:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800627:	e9 8b fc ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 30                	push   $0x30
  800632:	ff d6                	call   *%esi
			putch('x', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 78                	push   $0x78
  80063a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800646:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800654:	eb 4a                	jmp    8006a0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800656:	83 f9 01             	cmp    $0x1,%ecx
  800659:	7e 15                	jle    800670 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	8b 48 04             	mov    0x4(%eax),%ecx
  800663:	8d 40 08             	lea    0x8(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800669:	b8 10 00 00 00       	mov    $0x10,%eax
  80066e:	eb 30                	jmp    8006a0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	74 17                	je     80068b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067e:	8d 40 04             	lea    0x4(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800684:	b8 10 00 00 00       	mov    $0x10,%eax
  800689:	eb 15                	jmp    8006a0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	b9 00 00 00 00       	mov    $0x0,%ecx
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a7:	57                   	push   %edi
  8006a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ab:	50                   	push   %eax
  8006ac:	51                   	push   %ecx
  8006ad:	52                   	push   %edx
  8006ae:	89 da                	mov    %ebx,%edx
  8006b0:	89 f0                	mov    %esi,%eax
  8006b2:	e8 f1 fa ff ff       	call   8001a8 <printnum>
			break;
  8006b7:	83 c4 20             	add    $0x20,%esp
  8006ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bd:	e9 f5 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	52                   	push   %edx
  8006c7:	ff d6                	call   *%esi
			break;
  8006c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cf:	e9 e3 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 25                	push   $0x25
  8006da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 03                	jmp    8006e4 <vprintfmt+0x453>
  8006e1:	83 ef 01             	sub    $0x1,%edi
  8006e4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e8:	75 f7                	jne    8006e1 <vprintfmt+0x450>
  8006ea:	e9 c8 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5e                   	pop    %esi
  8006f4:	5f                   	pop    %edi
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800703:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800706:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 26                	je     80073e <vsnprintf+0x47>
  800718:	85 d2                	test   %edx,%edx
  80071a:	7e 22                	jle    80073e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071c:	ff 75 14             	pushl  0x14(%ebp)
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	68 57 02 80 00       	push   $0x800257
  80072b:	e8 61 fb ff ff       	call   800291 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 05                	jmp    800743 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074e:	50                   	push   %eax
  80074f:	ff 75 10             	pushl  0x10(%ebp)
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	ff 75 08             	pushl  0x8(%ebp)
  800758:	e8 9a ff ff ff       	call   8006f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
  80076a:	eb 03                	jmp    80076f <strlen+0x10>
		n++;
  80076c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800773:	75 f7                	jne    80076c <strlen+0xd>
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
  800785:	eb 03                	jmp    80078a <strnlen+0x13>
		n++;
  800787:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	39 c2                	cmp    %eax,%edx
  80078c:	74 08                	je     800796 <strnlen+0x1f>
  80078e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800792:	75 f3                	jne    800787 <strnlen+0x10>
  800794:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a2:	89 c2                	mov    %eax,%edx
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b1:	84 db                	test   %bl,%bl
  8007b3:	75 ef                	jne    8007a4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bf:	53                   	push   %ebx
  8007c0:	e8 9a ff ff ff       	call   80075f <strlen>
  8007c5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c8:	ff 75 0c             	pushl  0xc(%ebp)
  8007cb:	01 d8                	add    %ebx,%eax
  8007cd:	50                   	push   %eax
  8007ce:	e8 c5 ff ff ff       	call   800798 <strcpy>
	return dst;
}
  8007d3:	89 d8                	mov    %ebx,%eax
  8007d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	89 f3                	mov    %esi,%ebx
  8007e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ea:	89 f2                	mov    %esi,%edx
  8007ec:	eb 0f                	jmp    8007fd <strncpy+0x23>
		*dst++ = *src;
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	39 da                	cmp    %ebx,%edx
  8007ff:	75 ed                	jne    8007ee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800801:	89 f0                	mov    %esi,%eax
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	8b 75 08             	mov    0x8(%ebp),%esi
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800812:	8b 55 10             	mov    0x10(%ebp),%edx
  800815:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800817:	85 d2                	test   %edx,%edx
  800819:	74 21                	je     80083c <strlcpy+0x35>
  80081b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081f:	89 f2                	mov    %esi,%edx
  800821:	eb 09                	jmp    80082c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800823:	83 c2 01             	add    $0x1,%edx
  800826:	83 c1 01             	add    $0x1,%ecx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082c:	39 c2                	cmp    %eax,%edx
  80082e:	74 09                	je     800839 <strlcpy+0x32>
  800830:	0f b6 19             	movzbl (%ecx),%ebx
  800833:	84 db                	test   %bl,%bl
  800835:	75 ec                	jne    800823 <strlcpy+0x1c>
  800837:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800839:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083c:	29 f0                	sub    %esi,%eax
}
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084b:	eb 06                	jmp    800853 <strcmp+0x11>
		p++, q++;
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800853:	0f b6 01             	movzbl (%ecx),%eax
  800856:	84 c0                	test   %al,%al
  800858:	74 04                	je     80085e <strcmp+0x1c>
  80085a:	3a 02                	cmp    (%edx),%al
  80085c:	74 ef                	je     80084d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 c0             	movzbl %al,%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800872:	89 c3                	mov    %eax,%ebx
  800874:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800877:	eb 06                	jmp    80087f <strncmp+0x17>
		n--, p++, q++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087f:	39 d8                	cmp    %ebx,%eax
  800881:	74 15                	je     800898 <strncmp+0x30>
  800883:	0f b6 08             	movzbl (%eax),%ecx
  800886:	84 c9                	test   %cl,%cl
  800888:	74 04                	je     80088e <strncmp+0x26>
  80088a:	3a 0a                	cmp    (%edx),%cl
  80088c:	74 eb                	je     800879 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 00             	movzbl (%eax),%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
  800896:	eb 05                	jmp    80089d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 07                	jmp    8008b3 <strchr+0x13>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0f                	je     8008bf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	0f b6 10             	movzbl (%eax),%edx
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f2                	jne    8008ac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 03                	jmp    8008d0 <strfind+0xf>
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	74 04                	je     8008db <strfind+0x1a>
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f2                	jne    8008cd <strfind+0xc>
			break;
	return (char *) s;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	74 36                	je     800923 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f3:	75 28                	jne    80091d <memset+0x40>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 23                	jne    80091d <memset+0x40>
		c &= 0xFF;
  8008fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fe:	89 d3                	mov    %edx,%ebx
  800900:	c1 e3 08             	shl    $0x8,%ebx
  800903:	89 d6                	mov    %edx,%esi
  800905:	c1 e6 18             	shl    $0x18,%esi
  800908:	89 d0                	mov    %edx,%eax
  80090a:	c1 e0 10             	shl    $0x10,%eax
  80090d:	09 f0                	or     %esi,%eax
  80090f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800911:	89 d8                	mov    %ebx,%eax
  800913:	09 d0                	or     %edx,%eax
  800915:	c1 e9 02             	shr    $0x2,%ecx
  800918:	fc                   	cld    
  800919:	f3 ab                	rep stos %eax,%es:(%edi)
  80091b:	eb 06                	jmp    800923 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800920:	fc                   	cld    
  800921:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800923:	89 f8                	mov    %edi,%eax
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 75 0c             	mov    0xc(%ebp),%esi
  800935:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800938:	39 c6                	cmp    %eax,%esi
  80093a:	73 35                	jae    800971 <memmove+0x47>
  80093c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093f:	39 d0                	cmp    %edx,%eax
  800941:	73 2e                	jae    800971 <memmove+0x47>
		s += n;
		d += n;
  800943:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800946:	89 d6                	mov    %edx,%esi
  800948:	09 fe                	or     %edi,%esi
  80094a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800950:	75 13                	jne    800965 <memmove+0x3b>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 0e                	jne    800965 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800957:	83 ef 04             	sub    $0x4,%edi
  80095a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	fd                   	std    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 09                	jmp    80096e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800965:	83 ef 01             	sub    $0x1,%edi
  800968:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096b:	fd                   	std    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096e:	fc                   	cld    
  80096f:	eb 1d                	jmp    80098e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	89 f2                	mov    %esi,%edx
  800973:	09 c2                	or     %eax,%edx
  800975:	f6 c2 03             	test   $0x3,%dl
  800978:	75 0f                	jne    800989 <memmove+0x5f>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0a                	jne    800989 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097f:	c1 e9 02             	shr    $0x2,%ecx
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800995:	ff 75 10             	pushl  0x10(%ebp)
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	ff 75 08             	pushl  0x8(%ebp)
  80099e:	e8 87 ff ff ff       	call   80092a <memmove>
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	89 c6                	mov    %eax,%esi
  8009b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b5:	eb 1a                	jmp    8009d1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b7:	0f b6 08             	movzbl (%eax),%ecx
  8009ba:	0f b6 1a             	movzbl (%edx),%ebx
  8009bd:	38 d9                	cmp    %bl,%cl
  8009bf:	74 0a                	je     8009cb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c1:	0f b6 c1             	movzbl %cl,%eax
  8009c4:	0f b6 db             	movzbl %bl,%ebx
  8009c7:	29 d8                	sub    %ebx,%eax
  8009c9:	eb 0f                	jmp    8009da <memcmp+0x35>
		s1++, s2++;
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d1:	39 f0                	cmp    %esi,%eax
  8009d3:	75 e2                	jne    8009b7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e5:	89 c1                	mov    %eax,%ecx
  8009e7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ee:	eb 0a                	jmp    8009fa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f0:	0f b6 10             	movzbl (%eax),%edx
  8009f3:	39 da                	cmp    %ebx,%edx
  8009f5:	74 07                	je     8009fe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	39 c8                	cmp    %ecx,%eax
  8009fc:	72 f2                	jb     8009f0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	57                   	push   %edi
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0d:	eb 03                	jmp    800a12 <strtol+0x11>
		s++;
  800a0f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a12:	0f b6 01             	movzbl (%ecx),%eax
  800a15:	3c 20                	cmp    $0x20,%al
  800a17:	74 f6                	je     800a0f <strtol+0xe>
  800a19:	3c 09                	cmp    $0x9,%al
  800a1b:	74 f2                	je     800a0f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1d:	3c 2b                	cmp    $0x2b,%al
  800a1f:	75 0a                	jne    800a2b <strtol+0x2a>
		s++;
  800a21:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	eb 11                	jmp    800a3c <strtol+0x3b>
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a30:	3c 2d                	cmp    $0x2d,%al
  800a32:	75 08                	jne    800a3c <strtol+0x3b>
		s++, neg = 1;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a42:	75 15                	jne    800a59 <strtol+0x58>
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	75 10                	jne    800a59 <strtol+0x58>
  800a49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4d:	75 7c                	jne    800acb <strtol+0xca>
		s += 2, base = 16;
  800a4f:	83 c1 02             	add    $0x2,%ecx
  800a52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a57:	eb 16                	jmp    800a6f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	75 12                	jne    800a6f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 08                	jne    800a6f <strtol+0x6e>
		s++, base = 8;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a77:	0f b6 11             	movzbl (%ecx),%edx
  800a7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 09             	cmp    $0x9,%bl
  800a82:	77 08                	ja     800a8c <strtol+0x8b>
			dig = *s - '0';
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 30             	sub    $0x30,%edx
  800a8a:	eb 22                	jmp    800aae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 57             	sub    $0x57,%edx
  800a9c:	eb 10                	jmp    800aae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa1:	89 f3                	mov    %esi,%ebx
  800aa3:	80 fb 19             	cmp    $0x19,%bl
  800aa6:	77 16                	ja     800abe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa8:	0f be d2             	movsbl %dl,%edx
  800aab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab1:	7d 0b                	jge    800abe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abc:	eb b9                	jmp    800a77 <strtol+0x76>

	if (endptr)
  800abe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac2:	74 0d                	je     800ad1 <strtol+0xd0>
		*endptr = (char *) s;
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac7:	89 0e                	mov    %ecx,(%esi)
  800ac9:	eb 06                	jmp    800ad1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	74 98                	je     800a67 <strtol+0x66>
  800acf:	eb 9e                	jmp    800a6f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad1:	89 c2                	mov    %eax,%edx
  800ad3:	f7 da                	neg    %edx
  800ad5:	85 ff                	test   %edi,%edi
  800ad7:	0f 45 c2             	cmovne %edx,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aed:	8b 55 08             	mov    0x8(%ebp),%edx
  800af0:	89 c3                	mov    %eax,%ebx
  800af2:	89 c7                	mov    %eax,%edi
  800af4:	89 c6                	mov    %eax,%esi
  800af6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cgetc>:

int
sys_cgetc(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	89 cb                	mov    %ecx,%ebx
  800b34:	89 cf                	mov    %ecx,%edi
  800b36:	89 ce                	mov    %ecx,%esi
  800b38:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	7e 17                	jle    800b55 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	50                   	push   %eax
  800b42:	6a 03                	push   $0x3
  800b44:	68 7f 26 80 00       	push   $0x80267f
  800b49:	6a 23                	push   $0x23
  800b4b:	68 9c 26 80 00       	push   $0x80269c
  800b50:	e8 bd 14 00 00       	call   802012 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_yield>:

void
sys_yield(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	be 00 00 00 00       	mov    $0x0,%esi
  800ba9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	89 f7                	mov    %esi,%edi
  800bb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 17                	jle    800bd6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 04                	push   $0x4
  800bc5:	68 7f 26 80 00       	push   $0x80267f
  800bca:	6a 23                	push   $0x23
  800bcc:	68 9c 26 80 00       	push   $0x80269c
  800bd1:	e8 3c 14 00 00       	call   802012 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 05                	push   $0x5
  800c07:	68 7f 26 80 00       	push   $0x80267f
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 9c 26 80 00       	push   $0x80269c
  800c13:	e8 fa 13 00 00       	call   802012 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 df                	mov    %ebx,%edi
  800c3b:	89 de                	mov    %ebx,%esi
  800c3d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 17                	jle    800c5a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 06                	push   $0x6
  800c49:	68 7f 26 80 00       	push   $0x80267f
  800c4e:	6a 23                	push   $0x23
  800c50:	68 9c 26 80 00       	push   $0x80269c
  800c55:	e8 b8 13 00 00       	call   802012 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c70:	b8 08 00 00 00       	mov    $0x8,%eax
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	89 df                	mov    %ebx,%edi
  800c7d:	89 de                	mov    %ebx,%esi
  800c7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 17                	jle    800c9c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	50                   	push   %eax
  800c89:	6a 08                	push   $0x8
  800c8b:	68 7f 26 80 00       	push   $0x80267f
  800c90:	6a 23                	push   $0x23
  800c92:	68 9c 26 80 00       	push   $0x80269c
  800c97:	e8 76 13 00 00       	call   802012 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 09                	push   $0x9
  800ccd:	68 7f 26 80 00       	push   $0x80267f
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 9c 26 80 00       	push   $0x80269c
  800cd9:	e8 34 13 00 00       	call   802012 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 17                	jle    800d20 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	50                   	push   %eax
  800d0d:	6a 0a                	push   $0xa
  800d0f:	68 7f 26 80 00       	push   $0x80267f
  800d14:	6a 23                	push   $0x23
  800d16:	68 9c 26 80 00       	push   $0x80269c
  800d1b:	e8 f2 12 00 00       	call   802012 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d41:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 cb                	mov    %ecx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
  800d65:	89 ce                	mov    %ecx,%esi
  800d67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 0d                	push   $0xd
  800d73:	68 7f 26 80 00       	push   $0x80267f
  800d78:	6a 23                	push   $0x23
  800d7a:	68 9c 26 80 00       	push   $0x80269c
  800d7f:	e8 8e 12 00 00       	call   802012 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d92:	ba 00 00 00 00       	mov    $0x0,%edx
  800d97:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d9c:	89 d1                	mov    %edx,%ecx
  800d9e:	89 d3                	mov    %edx,%ebx
  800da0:	89 d7                	mov    %edx,%edi
  800da2:	89 d6                	mov    %edx,%esi
  800da4:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 cb                	mov    %ecx,%ebx
  800dc0:	89 cf                	mov    %ecx,%edi
  800dc2:	89 ce                	mov    %ecx,%esi
  800dc4:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  800de0:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	50                   	push   %eax
  800de7:	e8 5f ff ff ff       	call   800d4b <sys_ipc_recv>
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 16                	jns    800e09 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  800df3:	85 f6                	test   %esi,%esi
  800df5:	74 06                	je     800dfd <ipc_recv+0x32>
            *from_env_store = 0;
  800df7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  800dfd:	85 db                	test   %ebx,%ebx
  800dff:	74 2c                	je     800e2d <ipc_recv+0x62>
            *perm_store = 0;
  800e01:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e07:	eb 24                	jmp    800e2d <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  800e09:	85 f6                	test   %esi,%esi
  800e0b:	74 0a                	je     800e17 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  800e0d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e12:	8b 40 74             	mov    0x74(%eax),%eax
  800e15:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  800e17:	85 db                	test   %ebx,%ebx
  800e19:	74 0a                	je     800e25 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  800e1b:	a1 08 40 80 00       	mov    0x804008,%eax
  800e20:	8b 40 78             	mov    0x78(%eax),%eax
  800e23:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  800e25:	a1 08 40 80 00       	mov    0x804008,%eax
  800e2a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  800e2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	83 ec 0c             	sub    $0xc,%esp
  800e3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e43:	8b 45 10             	mov    0x10(%ebp),%eax
  800e46:	85 c0                	test   %eax,%eax
  800e48:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800e4d:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  800e50:	eb 1c                	jmp    800e6e <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  800e52:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e55:	74 12                	je     800e69 <ipc_send+0x35>
  800e57:	50                   	push   %eax
  800e58:	68 aa 26 80 00       	push   $0x8026aa
  800e5d:	6a 3b                	push   $0x3b
  800e5f:	68 c0 26 80 00       	push   $0x8026c0
  800e64:	e8 a9 11 00 00       	call   802012 <_panic>
		sys_yield();
  800e69:	e8 0e fd ff ff       	call   800b7c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  800e6e:	ff 75 14             	pushl  0x14(%ebp)
  800e71:	53                   	push   %ebx
  800e72:	56                   	push   %esi
  800e73:	57                   	push   %edi
  800e74:	e8 af fe ff ff       	call   800d28 <sys_ipc_try_send>
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	78 d2                	js     800e52 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e93:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e96:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e9c:	8b 52 50             	mov    0x50(%edx),%edx
  800e9f:	39 ca                	cmp    %ecx,%edx
  800ea1:	75 0d                	jne    800eb0 <ipc_find_env+0x28>
			return envs[i].env_id;
  800ea3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eab:	8b 40 48             	mov    0x48(%eax),%eax
  800eae:	eb 0f                	jmp    800ebf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800eb0:	83 c0 01             	add    $0x1,%eax
  800eb3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800eb8:	75 d9                	jne    800e93 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800eba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	05 00 00 00 30       	add    $0x30000000,%eax
  800ecc:	c1 e8 0c             	shr    $0xc,%eax
}
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	05 00 00 00 30       	add    $0x30000000,%eax
  800edc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ee1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    

00800ee8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ef3:	89 c2                	mov    %eax,%edx
  800ef5:	c1 ea 16             	shr    $0x16,%edx
  800ef8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800eff:	f6 c2 01             	test   $0x1,%dl
  800f02:	74 11                	je     800f15 <fd_alloc+0x2d>
  800f04:	89 c2                	mov    %eax,%edx
  800f06:	c1 ea 0c             	shr    $0xc,%edx
  800f09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f10:	f6 c2 01             	test   $0x1,%dl
  800f13:	75 09                	jne    800f1e <fd_alloc+0x36>
			*fd_store = fd;
  800f15:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f17:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1c:	eb 17                	jmp    800f35 <fd_alloc+0x4d>
  800f1e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f23:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f28:	75 c9                	jne    800ef3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f2a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f30:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f3d:	83 f8 1f             	cmp    $0x1f,%eax
  800f40:	77 36                	ja     800f78 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f42:	c1 e0 0c             	shl    $0xc,%eax
  800f45:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f4a:	89 c2                	mov    %eax,%edx
  800f4c:	c1 ea 16             	shr    $0x16,%edx
  800f4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f56:	f6 c2 01             	test   $0x1,%dl
  800f59:	74 24                	je     800f7f <fd_lookup+0x48>
  800f5b:	89 c2                	mov    %eax,%edx
  800f5d:	c1 ea 0c             	shr    $0xc,%edx
  800f60:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f67:	f6 c2 01             	test   $0x1,%dl
  800f6a:	74 1a                	je     800f86 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6f:	89 02                	mov    %eax,(%edx)
	return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	eb 13                	jmp    800f8b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f7d:	eb 0c                	jmp    800f8b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f84:	eb 05                	jmp    800f8b <fd_lookup+0x54>
  800f86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 08             	sub    $0x8,%esp
  800f93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f96:	ba 48 27 80 00       	mov    $0x802748,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f9b:	eb 13                	jmp    800fb0 <dev_lookup+0x23>
  800f9d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800fa0:	39 08                	cmp    %ecx,(%eax)
  800fa2:	75 0c                	jne    800fb0 <dev_lookup+0x23>
			*dev = devtab[i];
  800fa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fae:	eb 2e                	jmp    800fde <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800fb0:	8b 02                	mov    (%edx),%eax
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	75 e7                	jne    800f9d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb6:	a1 08 40 80 00       	mov    0x804008,%eax
  800fbb:	8b 40 48             	mov    0x48(%eax),%eax
  800fbe:	83 ec 04             	sub    $0x4,%esp
  800fc1:	51                   	push   %ecx
  800fc2:	50                   	push   %eax
  800fc3:	68 cc 26 80 00       	push   $0x8026cc
  800fc8:	e8 c7 f1 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	83 ec 10             	sub    $0x10,%esp
  800fe8:	8b 75 08             	mov    0x8(%ebp),%esi
  800feb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff1:	50                   	push   %eax
  800ff2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ff8:	c1 e8 0c             	shr    $0xc,%eax
  800ffb:	50                   	push   %eax
  800ffc:	e8 36 ff ff ff       	call   800f37 <fd_lookup>
  801001:	83 c4 08             	add    $0x8,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 05                	js     80100d <fd_close+0x2d>
	    || fd != fd2)
  801008:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80100b:	74 0c                	je     801019 <fd_close+0x39>
		return (must_exist ? r : 0);
  80100d:	84 db                	test   %bl,%bl
  80100f:	ba 00 00 00 00       	mov    $0x0,%edx
  801014:	0f 44 c2             	cmove  %edx,%eax
  801017:	eb 41                	jmp    80105a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801019:	83 ec 08             	sub    $0x8,%esp
  80101c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80101f:	50                   	push   %eax
  801020:	ff 36                	pushl  (%esi)
  801022:	e8 66 ff ff ff       	call   800f8d <dev_lookup>
  801027:	89 c3                	mov    %eax,%ebx
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 1a                	js     80104a <fd_close+0x6a>
		if (dev->dev_close)
  801030:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801033:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801036:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	74 0b                	je     80104a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	56                   	push   %esi
  801043:	ff d0                	call   *%eax
  801045:	89 c3                	mov    %eax,%ebx
  801047:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80104a:	83 ec 08             	sub    $0x8,%esp
  80104d:	56                   	push   %esi
  80104e:	6a 00                	push   $0x0
  801050:	e8 cb fb ff ff       	call   800c20 <sys_page_unmap>
	return r;
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	89 d8                	mov    %ebx,%eax
}
  80105a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801067:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	ff 75 08             	pushl  0x8(%ebp)
  80106e:	e8 c4 fe ff ff       	call   800f37 <fd_lookup>
  801073:	83 c4 08             	add    $0x8,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 10                	js     80108a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	6a 01                	push   $0x1
  80107f:	ff 75 f4             	pushl  -0xc(%ebp)
  801082:	e8 59 ff ff ff       	call   800fe0 <fd_close>
  801087:	83 c4 10             	add    $0x10,%esp
}
  80108a:	c9                   	leave  
  80108b:	c3                   	ret    

0080108c <close_all>:

void
close_all(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	53                   	push   %ebx
  801090:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801093:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	53                   	push   %ebx
  80109c:	e8 c0 ff ff ff       	call   801061 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a1:	83 c3 01             	add    $0x1,%ebx
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	83 fb 20             	cmp    $0x20,%ebx
  8010aa:	75 ec                	jne    801098 <close_all+0xc>
		close(i);
}
  8010ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010af:	c9                   	leave  
  8010b0:	c3                   	ret    

008010b1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010b1:	55                   	push   %ebp
  8010b2:	89 e5                	mov    %esp,%ebp
  8010b4:	57                   	push   %edi
  8010b5:	56                   	push   %esi
  8010b6:	53                   	push   %ebx
  8010b7:	83 ec 2c             	sub    $0x2c,%esp
  8010ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	e8 6e fe ff ff       	call   800f37 <fd_lookup>
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	0f 88 c1 00 00 00    	js     801195 <dup+0xe4>
		return r;
	close(newfdnum);
  8010d4:	83 ec 0c             	sub    $0xc,%esp
  8010d7:	56                   	push   %esi
  8010d8:	e8 84 ff ff ff       	call   801061 <close>

	newfd = INDEX2FD(newfdnum);
  8010dd:	89 f3                	mov    %esi,%ebx
  8010df:	c1 e3 0c             	shl    $0xc,%ebx
  8010e2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010e8:	83 c4 04             	add    $0x4,%esp
  8010eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010ee:	e8 de fd ff ff       	call   800ed1 <fd2data>
  8010f3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010f5:	89 1c 24             	mov    %ebx,(%esp)
  8010f8:	e8 d4 fd ff ff       	call   800ed1 <fd2data>
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801103:	89 f8                	mov    %edi,%eax
  801105:	c1 e8 16             	shr    $0x16,%eax
  801108:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110f:	a8 01                	test   $0x1,%al
  801111:	74 37                	je     80114a <dup+0x99>
  801113:	89 f8                	mov    %edi,%eax
  801115:	c1 e8 0c             	shr    $0xc,%eax
  801118:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111f:	f6 c2 01             	test   $0x1,%dl
  801122:	74 26                	je     80114a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801124:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	25 07 0e 00 00       	and    $0xe07,%eax
  801133:	50                   	push   %eax
  801134:	ff 75 d4             	pushl  -0x2c(%ebp)
  801137:	6a 00                	push   $0x0
  801139:	57                   	push   %edi
  80113a:	6a 00                	push   $0x0
  80113c:	e8 9d fa ff ff       	call   800bde <sys_page_map>
  801141:	89 c7                	mov    %eax,%edi
  801143:	83 c4 20             	add    $0x20,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 2e                	js     801178 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80114a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80114d:	89 d0                	mov    %edx,%eax
  80114f:	c1 e8 0c             	shr    $0xc,%eax
  801152:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	25 07 0e 00 00       	and    $0xe07,%eax
  801161:	50                   	push   %eax
  801162:	53                   	push   %ebx
  801163:	6a 00                	push   $0x0
  801165:	52                   	push   %edx
  801166:	6a 00                	push   $0x0
  801168:	e8 71 fa ff ff       	call   800bde <sys_page_map>
  80116d:	89 c7                	mov    %eax,%edi
  80116f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801172:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801174:	85 ff                	test   %edi,%edi
  801176:	79 1d                	jns    801195 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	53                   	push   %ebx
  80117c:	6a 00                	push   $0x0
  80117e:	e8 9d fa ff ff       	call   800c20 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801183:	83 c4 08             	add    $0x8,%esp
  801186:	ff 75 d4             	pushl  -0x2c(%ebp)
  801189:	6a 00                	push   $0x0
  80118b:	e8 90 fa ff ff       	call   800c20 <sys_page_unmap>
	return r;
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	89 f8                	mov    %edi,%eax
}
  801195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 14             	sub    $0x14,%esp
  8011a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	53                   	push   %ebx
  8011ac:	e8 86 fd ff ff       	call   800f37 <fd_lookup>
  8011b1:	83 c4 08             	add    $0x8,%esp
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	78 6d                	js     801227 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c0:	50                   	push   %eax
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	ff 30                	pushl  (%eax)
  8011c6:	e8 c2 fd ff ff       	call   800f8d <dev_lookup>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 4c                	js     80121e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011d2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011d5:	8b 42 08             	mov    0x8(%edx),%eax
  8011d8:	83 e0 03             	and    $0x3,%eax
  8011db:	83 f8 01             	cmp    $0x1,%eax
  8011de:	75 21                	jne    801201 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e5:	8b 40 48             	mov    0x48(%eax),%eax
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	53                   	push   %ebx
  8011ec:	50                   	push   %eax
  8011ed:	68 0d 27 80 00       	push   $0x80270d
  8011f2:	e8 9d ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011ff:	eb 26                	jmp    801227 <read+0x8a>
	}
	if (!dev->dev_read)
  801201:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801204:	8b 40 08             	mov    0x8(%eax),%eax
  801207:	85 c0                	test   %eax,%eax
  801209:	74 17                	je     801222 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	ff 75 10             	pushl  0x10(%ebp)
  801211:	ff 75 0c             	pushl  0xc(%ebp)
  801214:	52                   	push   %edx
  801215:	ff d0                	call   *%eax
  801217:	89 c2                	mov    %eax,%edx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	eb 09                	jmp    801227 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121e:	89 c2                	mov    %eax,%edx
  801220:	eb 05                	jmp    801227 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801222:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801227:	89 d0                	mov    %edx,%eax
  801229:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    

0080122e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	53                   	push   %ebx
  801234:	83 ec 0c             	sub    $0xc,%esp
  801237:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	eb 21                	jmp    801265 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801244:	83 ec 04             	sub    $0x4,%esp
  801247:	89 f0                	mov    %esi,%eax
  801249:	29 d8                	sub    %ebx,%eax
  80124b:	50                   	push   %eax
  80124c:	89 d8                	mov    %ebx,%eax
  80124e:	03 45 0c             	add    0xc(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	57                   	push   %edi
  801253:	e8 45 ff ff ff       	call   80119d <read>
		if (m < 0)
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 10                	js     80126f <readn+0x41>
			return m;
		if (m == 0)
  80125f:	85 c0                	test   %eax,%eax
  801261:	74 0a                	je     80126d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801263:	01 c3                	add    %eax,%ebx
  801265:	39 f3                	cmp    %esi,%ebx
  801267:	72 db                	jb     801244 <readn+0x16>
  801269:	89 d8                	mov    %ebx,%eax
  80126b:	eb 02                	jmp    80126f <readn+0x41>
  80126d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80126f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801272:	5b                   	pop    %ebx
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	53                   	push   %ebx
  80127b:	83 ec 14             	sub    $0x14,%esp
  80127e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801281:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	53                   	push   %ebx
  801286:	e8 ac fc ff ff       	call   800f37 <fd_lookup>
  80128b:	83 c4 08             	add    $0x8,%esp
  80128e:	89 c2                	mov    %eax,%edx
  801290:	85 c0                	test   %eax,%eax
  801292:	78 68                	js     8012fc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801294:	83 ec 08             	sub    $0x8,%esp
  801297:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129a:	50                   	push   %eax
  80129b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129e:	ff 30                	pushl  (%eax)
  8012a0:	e8 e8 fc ff ff       	call   800f8d <dev_lookup>
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 47                	js     8012f3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012b3:	75 21                	jne    8012d6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012ba:	8b 40 48             	mov    0x48(%eax),%eax
  8012bd:	83 ec 04             	sub    $0x4,%esp
  8012c0:	53                   	push   %ebx
  8012c1:	50                   	push   %eax
  8012c2:	68 29 27 80 00       	push   $0x802729
  8012c7:	e8 c8 ee ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012d4:	eb 26                	jmp    8012fc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d9:	8b 52 0c             	mov    0xc(%edx),%edx
  8012dc:	85 d2                	test   %edx,%edx
  8012de:	74 17                	je     8012f7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	ff 75 10             	pushl  0x10(%ebp)
  8012e6:	ff 75 0c             	pushl  0xc(%ebp)
  8012e9:	50                   	push   %eax
  8012ea:	ff d2                	call   *%edx
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	eb 09                	jmp    8012fc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	eb 05                	jmp    8012fc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012fc:	89 d0                	mov    %edx,%eax
  8012fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <seek>:

int
seek(int fdnum, off_t offset)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801309:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	ff 75 08             	pushl  0x8(%ebp)
  801310:	e8 22 fc ff ff       	call   800f37 <fd_lookup>
  801315:	83 c4 08             	add    $0x8,%esp
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 0e                	js     80132a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80131c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80131f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801322:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801325:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	53                   	push   %ebx
  801330:	83 ec 14             	sub    $0x14,%esp
  801333:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801336:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	53                   	push   %ebx
  80133b:	e8 f7 fb ff ff       	call   800f37 <fd_lookup>
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	89 c2                	mov    %eax,%edx
  801345:	85 c0                	test   %eax,%eax
  801347:	78 65                	js     8013ae <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801349:	83 ec 08             	sub    $0x8,%esp
  80134c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134f:	50                   	push   %eax
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	ff 30                	pushl  (%eax)
  801355:	e8 33 fc ff ff       	call   800f8d <dev_lookup>
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 44                	js     8013a5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801361:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801364:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801368:	75 21                	jne    80138b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80136a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80136f:	8b 40 48             	mov    0x48(%eax),%eax
  801372:	83 ec 04             	sub    $0x4,%esp
  801375:	53                   	push   %ebx
  801376:	50                   	push   %eax
  801377:	68 ec 26 80 00       	push   $0x8026ec
  80137c:	e8 13 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801389:	eb 23                	jmp    8013ae <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80138b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80138e:	8b 52 18             	mov    0x18(%edx),%edx
  801391:	85 d2                	test   %edx,%edx
  801393:	74 14                	je     8013a9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	ff 75 0c             	pushl  0xc(%ebp)
  80139b:	50                   	push   %eax
  80139c:	ff d2                	call   *%edx
  80139e:	89 c2                	mov    %eax,%edx
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	eb 09                	jmp    8013ae <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a5:	89 c2                	mov    %eax,%edx
  8013a7:	eb 05                	jmp    8013ae <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013a9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013ae:	89 d0                	mov    %edx,%eax
  8013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b3:	c9                   	leave  
  8013b4:	c3                   	ret    

008013b5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	53                   	push   %ebx
  8013b9:	83 ec 14             	sub    $0x14,%esp
  8013bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 08             	pushl  0x8(%ebp)
  8013c6:	e8 6c fb ff ff       	call   800f37 <fd_lookup>
  8013cb:	83 c4 08             	add    $0x8,%esp
  8013ce:	89 c2                	mov    %eax,%edx
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 58                	js     80142c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013de:	ff 30                	pushl  (%eax)
  8013e0:	e8 a8 fb ff ff       	call   800f8d <dev_lookup>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 37                	js     801423 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013f3:	74 32                	je     801427 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ff:	00 00 00 
	stat->st_isdir = 0;
  801402:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801409:	00 00 00 
	stat->st_dev = dev;
  80140c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	53                   	push   %ebx
  801416:	ff 75 f0             	pushl  -0x10(%ebp)
  801419:	ff 50 14             	call   *0x14(%eax)
  80141c:	89 c2                	mov    %eax,%edx
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	eb 09                	jmp    80142c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801423:	89 c2                	mov    %eax,%edx
  801425:	eb 05                	jmp    80142c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801427:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80142c:	89 d0                	mov    %edx,%eax
  80142e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	56                   	push   %esi
  801437:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	6a 00                	push   $0x0
  80143d:	ff 75 08             	pushl  0x8(%ebp)
  801440:	e8 e3 01 00 00       	call   801628 <open>
  801445:	89 c3                	mov    %eax,%ebx
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 1b                	js     801469 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80144e:	83 ec 08             	sub    $0x8,%esp
  801451:	ff 75 0c             	pushl  0xc(%ebp)
  801454:	50                   	push   %eax
  801455:	e8 5b ff ff ff       	call   8013b5 <fstat>
  80145a:	89 c6                	mov    %eax,%esi
	close(fd);
  80145c:	89 1c 24             	mov    %ebx,(%esp)
  80145f:	e8 fd fb ff ff       	call   801061 <close>
	return r;
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	89 f0                	mov    %esi,%eax
}
  801469:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146c:	5b                   	pop    %ebx
  80146d:	5e                   	pop    %esi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
  801475:	89 c6                	mov    %eax,%esi
  801477:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801479:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801480:	75 12                	jne    801494 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801482:	83 ec 0c             	sub    $0xc,%esp
  801485:	6a 01                	push   $0x1
  801487:	e8 fc f9 ff ff       	call   800e88 <ipc_find_env>
  80148c:	a3 00 40 80 00       	mov    %eax,0x804000
  801491:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801494:	6a 07                	push   $0x7
  801496:	68 00 50 80 00       	push   $0x805000
  80149b:	56                   	push   %esi
  80149c:	ff 35 00 40 80 00    	pushl  0x804000
  8014a2:	e8 8d f9 ff ff       	call   800e34 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014a7:	83 c4 0c             	add    $0xc,%esp
  8014aa:	6a 00                	push   $0x0
  8014ac:	53                   	push   %ebx
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 17 f9 ff ff       	call   800dcb <ipc_recv>
}
  8014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8014de:	e8 8d ff ff ff       	call   801470 <fsipc>
}
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801500:	e8 6b ff ff ff       	call   801470 <fsipc>
}
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	53                   	push   %ebx
  80150b:	83 ec 04             	sub    $0x4,%esp
  80150e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	8b 40 0c             	mov    0xc(%eax),%eax
  801517:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80151c:	ba 00 00 00 00       	mov    $0x0,%edx
  801521:	b8 05 00 00 00       	mov    $0x5,%eax
  801526:	e8 45 ff ff ff       	call   801470 <fsipc>
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 2c                	js     80155b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80152f:	83 ec 08             	sub    $0x8,%esp
  801532:	68 00 50 80 00       	push   $0x805000
  801537:	53                   	push   %ebx
  801538:	e8 5b f2 ff ff       	call   800798 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80153d:	a1 80 50 80 00       	mov    0x805080,%eax
  801542:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801548:	a1 84 50 80 00       	mov    0x805084,%eax
  80154d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80155b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
  801563:	83 ec 0c             	sub    $0xc,%esp
  801566:	8b 45 10             	mov    0x10(%ebp),%eax
  801569:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80156e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801573:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801576:	8b 55 08             	mov    0x8(%ebp),%edx
  801579:	8b 52 0c             	mov    0xc(%edx),%edx
  80157c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801582:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801587:	50                   	push   %eax
  801588:	ff 75 0c             	pushl  0xc(%ebp)
  80158b:	68 08 50 80 00       	push   $0x805008
  801590:	e8 95 f3 ff ff       	call   80092a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801595:	ba 00 00 00 00       	mov    $0x0,%edx
  80159a:	b8 04 00 00 00       	mov    $0x4,%eax
  80159f:	e8 cc fe ff ff       	call   801470 <fsipc>
	//panic("devfile_write not implemented");
}
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	56                   	push   %esi
  8015aa:	53                   	push   %ebx
  8015ab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015b9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8015c9:	e8 a2 fe ff ff       	call   801470 <fsipc>
  8015ce:	89 c3                	mov    %eax,%ebx
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	78 4b                	js     80161f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015d4:	39 c6                	cmp    %eax,%esi
  8015d6:	73 16                	jae    8015ee <devfile_read+0x48>
  8015d8:	68 5c 27 80 00       	push   $0x80275c
  8015dd:	68 63 27 80 00       	push   $0x802763
  8015e2:	6a 7c                	push   $0x7c
  8015e4:	68 78 27 80 00       	push   $0x802778
  8015e9:	e8 24 0a 00 00       	call   802012 <_panic>
	assert(r <= PGSIZE);
  8015ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015f3:	7e 16                	jle    80160b <devfile_read+0x65>
  8015f5:	68 83 27 80 00       	push   $0x802783
  8015fa:	68 63 27 80 00       	push   $0x802763
  8015ff:	6a 7d                	push   $0x7d
  801601:	68 78 27 80 00       	push   $0x802778
  801606:	e8 07 0a 00 00       	call   802012 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80160b:	83 ec 04             	sub    $0x4,%esp
  80160e:	50                   	push   %eax
  80160f:	68 00 50 80 00       	push   $0x805000
  801614:	ff 75 0c             	pushl  0xc(%ebp)
  801617:	e8 0e f3 ff ff       	call   80092a <memmove>
	return r;
  80161c:	83 c4 10             	add    $0x10,%esp
}
  80161f:	89 d8                	mov    %ebx,%eax
  801621:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801624:	5b                   	pop    %ebx
  801625:	5e                   	pop    %esi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    

00801628 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	53                   	push   %ebx
  80162c:	83 ec 20             	sub    $0x20,%esp
  80162f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801632:	53                   	push   %ebx
  801633:	e8 27 f1 ff ff       	call   80075f <strlen>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801640:	7f 67                	jg     8016a9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801648:	50                   	push   %eax
  801649:	e8 9a f8 ff ff       	call   800ee8 <fd_alloc>
  80164e:	83 c4 10             	add    $0x10,%esp
		return r;
  801651:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801653:	85 c0                	test   %eax,%eax
  801655:	78 57                	js     8016ae <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	53                   	push   %ebx
  80165b:	68 00 50 80 00       	push   $0x805000
  801660:	e8 33 f1 ff ff       	call   800798 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801665:	8b 45 0c             	mov    0xc(%ebp),%eax
  801668:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80166d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801670:	b8 01 00 00 00       	mov    $0x1,%eax
  801675:	e8 f6 fd ff ff       	call   801470 <fsipc>
  80167a:	89 c3                	mov    %eax,%ebx
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	79 14                	jns    801697 <open+0x6f>
		fd_close(fd, 0);
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	6a 00                	push   $0x0
  801688:	ff 75 f4             	pushl  -0xc(%ebp)
  80168b:	e8 50 f9 ff ff       	call   800fe0 <fd_close>
		return r;
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	89 da                	mov    %ebx,%edx
  801695:	eb 17                	jmp    8016ae <open+0x86>
	}

	return fd2num(fd);
  801697:	83 ec 0c             	sub    $0xc,%esp
  80169a:	ff 75 f4             	pushl  -0xc(%ebp)
  80169d:	e8 1f f8 ff ff       	call   800ec1 <fd2num>
  8016a2:	89 c2                	mov    %eax,%edx
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	eb 05                	jmp    8016ae <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016a9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016ae:	89 d0                	mov    %edx,%eax
  8016b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c5:	e8 a6 fd ff ff       	call   801470 <fsipc>
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8016d2:	68 8f 27 80 00       	push   $0x80278f
  8016d7:	ff 75 0c             	pushl  0xc(%ebp)
  8016da:	e8 b9 f0 ff ff       	call   800798 <strcpy>
	return 0;
}
  8016df:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 10             	sub    $0x10,%esp
  8016ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8016f0:	53                   	push   %ebx
  8016f1:	e8 62 09 00 00       	call   802058 <pageref>
  8016f6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8016fe:	83 f8 01             	cmp    $0x1,%eax
  801701:	75 10                	jne    801713 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801703:	83 ec 0c             	sub    $0xc,%esp
  801706:	ff 73 0c             	pushl  0xc(%ebx)
  801709:	e8 c0 02 00 00       	call   8019ce <nsipc_close>
  80170e:	89 c2                	mov    %eax,%edx
  801710:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801713:	89 d0                	mov    %edx,%eax
  801715:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801718:	c9                   	leave  
  801719:	c3                   	ret    

0080171a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801720:	6a 00                	push   $0x0
  801722:	ff 75 10             	pushl  0x10(%ebp)
  801725:	ff 75 0c             	pushl  0xc(%ebp)
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	ff 70 0c             	pushl  0xc(%eax)
  80172e:	e8 78 03 00 00       	call   801aab <nsipc_send>
}
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80173b:	6a 00                	push   $0x0
  80173d:	ff 75 10             	pushl  0x10(%ebp)
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	ff 70 0c             	pushl  0xc(%eax)
  801749:	e8 f1 02 00 00       	call   801a3f <nsipc_recv>
}
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801756:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801759:	52                   	push   %edx
  80175a:	50                   	push   %eax
  80175b:	e8 d7 f7 ff ff       	call   800f37 <fd_lookup>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 17                	js     80177e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801770:	39 08                	cmp    %ecx,(%eax)
  801772:	75 05                	jne    801779 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801774:	8b 40 0c             	mov    0xc(%eax),%eax
  801777:	eb 05                	jmp    80177e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801779:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	83 ec 1c             	sub    $0x1c,%esp
  801788:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	e8 55 f7 ff ff       	call   800ee8 <fd_alloc>
  801793:	89 c3                	mov    %eax,%ebx
  801795:	83 c4 10             	add    $0x10,%esp
  801798:	85 c0                	test   %eax,%eax
  80179a:	78 1b                	js     8017b7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80179c:	83 ec 04             	sub    $0x4,%esp
  80179f:	68 07 04 00 00       	push   $0x407
  8017a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a7:	6a 00                	push   $0x0
  8017a9:	e8 ed f3 ff ff       	call   800b9b <sys_page_alloc>
  8017ae:	89 c3                	mov    %eax,%ebx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	79 10                	jns    8017c7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  8017b7:	83 ec 0c             	sub    $0xc,%esp
  8017ba:	56                   	push   %esi
  8017bb:	e8 0e 02 00 00       	call   8019ce <nsipc_close>
		return r;
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	89 d8                	mov    %ebx,%eax
  8017c5:	eb 24                	jmp    8017eb <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8017c7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8017d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8017dc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8017df:	83 ec 0c             	sub    $0xc,%esp
  8017e2:	50                   	push   %eax
  8017e3:	e8 d9 f6 ff ff       	call   800ec1 <fd2num>
  8017e8:	83 c4 10             	add    $0x10,%esp
}
  8017eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017ee:	5b                   	pop    %ebx
  8017ef:	5e                   	pop    %esi
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	e8 50 ff ff ff       	call   801750 <fd2sockid>
		return r;
  801800:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801802:	85 c0                	test   %eax,%eax
  801804:	78 1f                	js     801825 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801806:	83 ec 04             	sub    $0x4,%esp
  801809:	ff 75 10             	pushl  0x10(%ebp)
  80180c:	ff 75 0c             	pushl  0xc(%ebp)
  80180f:	50                   	push   %eax
  801810:	e8 12 01 00 00       	call   801927 <nsipc_accept>
  801815:	83 c4 10             	add    $0x10,%esp
		return r;
  801818:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 07                	js     801825 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80181e:	e8 5d ff ff ff       	call   801780 <alloc_sockfd>
  801823:	89 c1                	mov    %eax,%ecx
}
  801825:	89 c8                	mov    %ecx,%eax
  801827:	c9                   	leave  
  801828:	c3                   	ret    

00801829 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80182f:	8b 45 08             	mov    0x8(%ebp),%eax
  801832:	e8 19 ff ff ff       	call   801750 <fd2sockid>
  801837:	85 c0                	test   %eax,%eax
  801839:	78 12                	js     80184d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  80183b:	83 ec 04             	sub    $0x4,%esp
  80183e:	ff 75 10             	pushl  0x10(%ebp)
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	50                   	push   %eax
  801845:	e8 2d 01 00 00       	call   801977 <nsipc_bind>
  80184a:	83 c4 10             	add    $0x10,%esp
}
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <shutdown>:

int
shutdown(int s, int how)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801855:	8b 45 08             	mov    0x8(%ebp),%eax
  801858:	e8 f3 fe ff ff       	call   801750 <fd2sockid>
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 0f                	js     801870 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	ff 75 0c             	pushl  0xc(%ebp)
  801867:	50                   	push   %eax
  801868:	e8 3f 01 00 00       	call   8019ac <nsipc_shutdown>
  80186d:	83 c4 10             	add    $0x10,%esp
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	e8 d0 fe ff ff       	call   801750 <fd2sockid>
  801880:	85 c0                	test   %eax,%eax
  801882:	78 12                	js     801896 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	ff 75 10             	pushl  0x10(%ebp)
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	50                   	push   %eax
  80188e:	e8 55 01 00 00       	call   8019e8 <nsipc_connect>
  801893:	83 c4 10             	add    $0x10,%esp
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <listen>:

int
listen(int s, int backlog)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80189e:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a1:	e8 aa fe ff ff       	call   801750 <fd2sockid>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 0f                	js     8018b9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	ff 75 0c             	pushl  0xc(%ebp)
  8018b0:	50                   	push   %eax
  8018b1:	e8 67 01 00 00       	call   801a1d <nsipc_listen>
  8018b6:	83 c4 10             	add    $0x10,%esp
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8018c1:	ff 75 10             	pushl  0x10(%ebp)
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	ff 75 08             	pushl  0x8(%ebp)
  8018ca:	e8 3a 02 00 00       	call   801b09 <nsipc_socket>
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 05                	js     8018db <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8018d6:	e8 a5 fe ff ff       	call   801780 <alloc_sockfd>
}
  8018db:	c9                   	leave  
  8018dc:	c3                   	ret    

008018dd <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	53                   	push   %ebx
  8018e1:	83 ec 04             	sub    $0x4,%esp
  8018e4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8018e6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8018ed:	75 12                	jne    801901 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8018ef:	83 ec 0c             	sub    $0xc,%esp
  8018f2:	6a 02                	push   $0x2
  8018f4:	e8 8f f5 ff ff       	call   800e88 <ipc_find_env>
  8018f9:	a3 04 40 80 00       	mov    %eax,0x804004
  8018fe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801901:	6a 07                	push   $0x7
  801903:	68 00 60 80 00       	push   $0x806000
  801908:	53                   	push   %ebx
  801909:	ff 35 04 40 80 00    	pushl  0x804004
  80190f:	e8 20 f5 ff ff       	call   800e34 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801914:	83 c4 0c             	add    $0xc,%esp
  801917:	6a 00                	push   $0x0
  801919:	6a 00                	push   $0x0
  80191b:	6a 00                	push   $0x0
  80191d:	e8 a9 f4 ff ff       	call   800dcb <ipc_recv>
}
  801922:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	56                   	push   %esi
  80192b:	53                   	push   %ebx
  80192c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80192f:	8b 45 08             	mov    0x8(%ebp),%eax
  801932:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801937:	8b 06                	mov    (%esi),%eax
  801939:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80193e:	b8 01 00 00 00       	mov    $0x1,%eax
  801943:	e8 95 ff ff ff       	call   8018dd <nsipc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 20                	js     80196e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80194e:	83 ec 04             	sub    $0x4,%esp
  801951:	ff 35 10 60 80 00    	pushl  0x806010
  801957:	68 00 60 80 00       	push   $0x806000
  80195c:	ff 75 0c             	pushl  0xc(%ebp)
  80195f:	e8 c6 ef ff ff       	call   80092a <memmove>
		*addrlen = ret->ret_addrlen;
  801964:	a1 10 60 80 00       	mov    0x806010,%eax
  801969:	89 06                	mov    %eax,(%esi)
  80196b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  80196e:	89 d8                	mov    %ebx,%eax
  801970:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801973:	5b                   	pop    %ebx
  801974:	5e                   	pop    %esi
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	53                   	push   %ebx
  80197b:	83 ec 08             	sub    $0x8,%esp
  80197e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801981:	8b 45 08             	mov    0x8(%ebp),%eax
  801984:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801989:	53                   	push   %ebx
  80198a:	ff 75 0c             	pushl  0xc(%ebp)
  80198d:	68 04 60 80 00       	push   $0x806004
  801992:	e8 93 ef ff ff       	call   80092a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801997:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80199d:	b8 02 00 00 00       	mov    $0x2,%eax
  8019a2:	e8 36 ff ff ff       	call   8018dd <nsipc>
}
  8019a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8019ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8019c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c7:	e8 11 ff ff ff       	call   8018dd <nsipc>
}
  8019cc:	c9                   	leave  
  8019cd:	c3                   	ret    

008019ce <nsipc_close>:

int
nsipc_close(int s)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8019d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d7:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8019dc:	b8 04 00 00 00       	mov    $0x4,%eax
  8019e1:	e8 f7 fe ff ff       	call   8018dd <nsipc>
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8019f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8019fa:	53                   	push   %ebx
  8019fb:	ff 75 0c             	pushl  0xc(%ebp)
  8019fe:	68 04 60 80 00       	push   $0x806004
  801a03:	e8 22 ef ff ff       	call   80092a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a08:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801a0e:	b8 05 00 00 00       	mov    $0x5,%eax
  801a13:	e8 c5 fe ff ff       	call   8018dd <nsipc>
}
  801a18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801a33:	b8 06 00 00 00       	mov    $0x6,%eax
  801a38:	e8 a0 fe ff ff       	call   8018dd <nsipc>
}
  801a3d:	c9                   	leave  
  801a3e:	c3                   	ret    

00801a3f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a47:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801a4f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801a55:	8b 45 14             	mov    0x14(%ebp),%eax
  801a58:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801a5d:	b8 07 00 00 00       	mov    $0x7,%eax
  801a62:	e8 76 fe ff ff       	call   8018dd <nsipc>
  801a67:	89 c3                	mov    %eax,%ebx
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	78 35                	js     801aa2 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801a6d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801a72:	7f 04                	jg     801a78 <nsipc_recv+0x39>
  801a74:	39 c6                	cmp    %eax,%esi
  801a76:	7d 16                	jge    801a8e <nsipc_recv+0x4f>
  801a78:	68 9b 27 80 00       	push   $0x80279b
  801a7d:	68 63 27 80 00       	push   $0x802763
  801a82:	6a 62                	push   $0x62
  801a84:	68 b0 27 80 00       	push   $0x8027b0
  801a89:	e8 84 05 00 00       	call   802012 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801a8e:	83 ec 04             	sub    $0x4,%esp
  801a91:	50                   	push   %eax
  801a92:	68 00 60 80 00       	push   $0x806000
  801a97:	ff 75 0c             	pushl  0xc(%ebp)
  801a9a:	e8 8b ee ff ff       	call   80092a <memmove>
  801a9f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801aa2:	89 d8                	mov    %ebx,%eax
  801aa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	53                   	push   %ebx
  801aaf:	83 ec 04             	sub    $0x4,%esp
  801ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801abd:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ac3:	7e 16                	jle    801adb <nsipc_send+0x30>
  801ac5:	68 bc 27 80 00       	push   $0x8027bc
  801aca:	68 63 27 80 00       	push   $0x802763
  801acf:	6a 6d                	push   $0x6d
  801ad1:	68 b0 27 80 00       	push   $0x8027b0
  801ad6:	e8 37 05 00 00       	call   802012 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801adb:	83 ec 04             	sub    $0x4,%esp
  801ade:	53                   	push   %ebx
  801adf:	ff 75 0c             	pushl  0xc(%ebp)
  801ae2:	68 0c 60 80 00       	push   $0x80600c
  801ae7:	e8 3e ee ff ff       	call   80092a <memmove>
	nsipcbuf.send.req_size = size;
  801aec:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801af2:	8b 45 14             	mov    0x14(%ebp),%eax
  801af5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801afa:	b8 08 00 00 00       	mov    $0x8,%eax
  801aff:	e8 d9 fd ff ff       	call   8018dd <nsipc>
}
  801b04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b12:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b22:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801b27:	b8 09 00 00 00       	mov    $0x9,%eax
  801b2c:	e8 ac fd ff ff       	call   8018dd <nsipc>
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b3b:	83 ec 0c             	sub    $0xc,%esp
  801b3e:	ff 75 08             	pushl  0x8(%ebp)
  801b41:	e8 8b f3 ff ff       	call   800ed1 <fd2data>
  801b46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b48:	83 c4 08             	add    $0x8,%esp
  801b4b:	68 c8 27 80 00       	push   $0x8027c8
  801b50:	53                   	push   %ebx
  801b51:	e8 42 ec ff ff       	call   800798 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b56:	8b 46 04             	mov    0x4(%esi),%eax
  801b59:	2b 06                	sub    (%esi),%eax
  801b5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b68:	00 00 00 
	stat->st_dev = &devpipe;
  801b6b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801b72:	30 80 00 
	return 0;
}
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b7d:	5b                   	pop    %ebx
  801b7e:	5e                   	pop    %esi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	53                   	push   %ebx
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b8b:	53                   	push   %ebx
  801b8c:	6a 00                	push   $0x0
  801b8e:	e8 8d f0 ff ff       	call   800c20 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b93:	89 1c 24             	mov    %ebx,(%esp)
  801b96:	e8 36 f3 ff ff       	call   800ed1 <fd2data>
  801b9b:	83 c4 08             	add    $0x8,%esp
  801b9e:	50                   	push   %eax
  801b9f:	6a 00                	push   $0x0
  801ba1:	e8 7a f0 ff ff       	call   800c20 <sys_page_unmap>
}
  801ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba9:	c9                   	leave  
  801baa:	c3                   	ret    

00801bab <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 1c             	sub    $0x1c,%esp
  801bb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bb7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bb9:	a1 08 40 80 00       	mov    0x804008,%eax
  801bbe:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bc1:	83 ec 0c             	sub    $0xc,%esp
  801bc4:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc7:	e8 8c 04 00 00       	call   802058 <pageref>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	89 3c 24             	mov    %edi,(%esp)
  801bd1:	e8 82 04 00 00       	call   802058 <pageref>
  801bd6:	83 c4 10             	add    $0x10,%esp
  801bd9:	39 c3                	cmp    %eax,%ebx
  801bdb:	0f 94 c1             	sete   %cl
  801bde:	0f b6 c9             	movzbl %cl,%ecx
  801be1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801be4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801bea:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bed:	39 ce                	cmp    %ecx,%esi
  801bef:	74 1b                	je     801c0c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bf1:	39 c3                	cmp    %eax,%ebx
  801bf3:	75 c4                	jne    801bb9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bf5:	8b 42 58             	mov    0x58(%edx),%eax
  801bf8:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bfb:	50                   	push   %eax
  801bfc:	56                   	push   %esi
  801bfd:	68 cf 27 80 00       	push   $0x8027cf
  801c02:	e8 8d e5 ff ff       	call   800194 <cprintf>
  801c07:	83 c4 10             	add    $0x10,%esp
  801c0a:	eb ad                	jmp    801bb9 <_pipeisclosed+0xe>
	}
}
  801c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	57                   	push   %edi
  801c1b:	56                   	push   %esi
  801c1c:	53                   	push   %ebx
  801c1d:	83 ec 28             	sub    $0x28,%esp
  801c20:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c23:	56                   	push   %esi
  801c24:	e8 a8 f2 ff ff       	call   800ed1 <fd2data>
  801c29:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c33:	eb 4b                	jmp    801c80 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c35:	89 da                	mov    %ebx,%edx
  801c37:	89 f0                	mov    %esi,%eax
  801c39:	e8 6d ff ff ff       	call   801bab <_pipeisclosed>
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	75 48                	jne    801c8a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c42:	e8 35 ef ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c47:	8b 43 04             	mov    0x4(%ebx),%eax
  801c4a:	8b 0b                	mov    (%ebx),%ecx
  801c4c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c4f:	39 d0                	cmp    %edx,%eax
  801c51:	73 e2                	jae    801c35 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c56:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c5a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c5d:	89 c2                	mov    %eax,%edx
  801c5f:	c1 fa 1f             	sar    $0x1f,%edx
  801c62:	89 d1                	mov    %edx,%ecx
  801c64:	c1 e9 1b             	shr    $0x1b,%ecx
  801c67:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c6a:	83 e2 1f             	and    $0x1f,%edx
  801c6d:	29 ca                	sub    %ecx,%edx
  801c6f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c77:	83 c0 01             	add    $0x1,%eax
  801c7a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c7d:	83 c7 01             	add    $0x1,%edi
  801c80:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c83:	75 c2                	jne    801c47 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c85:	8b 45 10             	mov    0x10(%ebp),%eax
  801c88:	eb 05                	jmp    801c8f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c8a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5f                   	pop    %edi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 18             	sub    $0x18,%esp
  801ca0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801ca3:	57                   	push   %edi
  801ca4:	e8 28 f2 ff ff       	call   800ed1 <fd2data>
  801ca9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cb3:	eb 3d                	jmp    801cf2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cb5:	85 db                	test   %ebx,%ebx
  801cb7:	74 04                	je     801cbd <devpipe_read+0x26>
				return i;
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	eb 44                	jmp    801d01 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cbd:	89 f2                	mov    %esi,%edx
  801cbf:	89 f8                	mov    %edi,%eax
  801cc1:	e8 e5 fe ff ff       	call   801bab <_pipeisclosed>
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	75 32                	jne    801cfc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cca:	e8 ad ee ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ccf:	8b 06                	mov    (%esi),%eax
  801cd1:	3b 46 04             	cmp    0x4(%esi),%eax
  801cd4:	74 df                	je     801cb5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd6:	99                   	cltd   
  801cd7:	c1 ea 1b             	shr    $0x1b,%edx
  801cda:	01 d0                	add    %edx,%eax
  801cdc:	83 e0 1f             	and    $0x1f,%eax
  801cdf:	29 d0                	sub    %edx,%eax
  801ce1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cec:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cef:	83 c3 01             	add    $0x1,%ebx
  801cf2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf5:	75 d8                	jne    801ccf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf7:	8b 45 10             	mov    0x10(%ebp),%eax
  801cfa:	eb 05                	jmp    801d01 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cfc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	56                   	push   %esi
  801d0d:	53                   	push   %ebx
  801d0e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d14:	50                   	push   %eax
  801d15:	e8 ce f1 ff ff       	call   800ee8 <fd_alloc>
  801d1a:	83 c4 10             	add    $0x10,%esp
  801d1d:	89 c2                	mov    %eax,%edx
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	0f 88 2c 01 00 00    	js     801e53 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	68 07 04 00 00       	push   $0x407
  801d2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d32:	6a 00                	push   $0x0
  801d34:	e8 62 ee ff ff       	call   800b9b <sys_page_alloc>
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	89 c2                	mov    %eax,%edx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	0f 88 0d 01 00 00    	js     801e53 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d46:	83 ec 0c             	sub    $0xc,%esp
  801d49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d4c:	50                   	push   %eax
  801d4d:	e8 96 f1 ff ff       	call   800ee8 <fd_alloc>
  801d52:	89 c3                	mov    %eax,%ebx
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	0f 88 e2 00 00 00    	js     801e41 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5f:	83 ec 04             	sub    $0x4,%esp
  801d62:	68 07 04 00 00       	push   $0x407
  801d67:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 2a ee ff ff       	call   800b9b <sys_page_alloc>
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 c3 00 00 00    	js     801e41 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff 75 f4             	pushl  -0xc(%ebp)
  801d84:	e8 48 f1 ff ff       	call   800ed1 <fd2data>
  801d89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d8b:	83 c4 0c             	add    $0xc,%esp
  801d8e:	68 07 04 00 00       	push   $0x407
  801d93:	50                   	push   %eax
  801d94:	6a 00                	push   $0x0
  801d96:	e8 00 ee ff ff       	call   800b9b <sys_page_alloc>
  801d9b:	89 c3                	mov    %eax,%ebx
  801d9d:	83 c4 10             	add    $0x10,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	0f 88 89 00 00 00    	js     801e31 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da8:	83 ec 0c             	sub    $0xc,%esp
  801dab:	ff 75 f0             	pushl  -0x10(%ebp)
  801dae:	e8 1e f1 ff ff       	call   800ed1 <fd2data>
  801db3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dba:	50                   	push   %eax
  801dbb:	6a 00                	push   $0x0
  801dbd:	56                   	push   %esi
  801dbe:	6a 00                	push   $0x0
  801dc0:	e8 19 ee ff ff       	call   800bde <sys_page_map>
  801dc5:	89 c3                	mov    %eax,%ebx
  801dc7:	83 c4 20             	add    $0x20,%esp
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 55                	js     801e23 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dce:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801de3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df8:	83 ec 0c             	sub    $0xc,%esp
  801dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfe:	e8 be f0 ff ff       	call   800ec1 <fd2num>
  801e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e06:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e08:	83 c4 04             	add    $0x4,%esp
  801e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0e:	e8 ae f0 ff ff       	call   800ec1 <fd2num>
  801e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e16:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e21:	eb 30                	jmp    801e53 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e23:	83 ec 08             	sub    $0x8,%esp
  801e26:	56                   	push   %esi
  801e27:	6a 00                	push   $0x0
  801e29:	e8 f2 ed ff ff       	call   800c20 <sys_page_unmap>
  801e2e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e31:	83 ec 08             	sub    $0x8,%esp
  801e34:	ff 75 f0             	pushl  -0x10(%ebp)
  801e37:	6a 00                	push   $0x0
  801e39:	e8 e2 ed ff ff       	call   800c20 <sys_page_unmap>
  801e3e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e41:	83 ec 08             	sub    $0x8,%esp
  801e44:	ff 75 f4             	pushl  -0xc(%ebp)
  801e47:	6a 00                	push   $0x0
  801e49:	e8 d2 ed ff ff       	call   800c20 <sys_page_unmap>
  801e4e:	83 c4 10             	add    $0x10,%esp
  801e51:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e53:	89 d0                	mov    %edx,%eax
  801e55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5e                   	pop    %esi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    

00801e5c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e65:	50                   	push   %eax
  801e66:	ff 75 08             	pushl  0x8(%ebp)
  801e69:	e8 c9 f0 ff ff       	call   800f37 <fd_lookup>
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	85 c0                	test   %eax,%eax
  801e73:	78 18                	js     801e8d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e75:	83 ec 0c             	sub    $0xc,%esp
  801e78:	ff 75 f4             	pushl  -0xc(%ebp)
  801e7b:	e8 51 f0 ff ff       	call   800ed1 <fd2data>
	return _pipeisclosed(fd, p);
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	e8 21 fd ff ff       	call   801bab <_pipeisclosed>
  801e8a:	83 c4 10             	add    $0x10,%esp
}
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e92:	b8 00 00 00 00       	mov    $0x0,%eax
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e9f:	68 e7 27 80 00       	push   $0x8027e7
  801ea4:	ff 75 0c             	pushl  0xc(%ebp)
  801ea7:	e8 ec e8 ff ff       	call   800798 <strcpy>
	return 0;
}
  801eac:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb1:	c9                   	leave  
  801eb2:	c3                   	ret    

00801eb3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	57                   	push   %edi
  801eb7:	56                   	push   %esi
  801eb8:	53                   	push   %ebx
  801eb9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eca:	eb 2d                	jmp    801ef9 <devcons_write+0x46>
		m = n - tot;
  801ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ecf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ed1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ed4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ed9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801edc:	83 ec 04             	sub    $0x4,%esp
  801edf:	53                   	push   %ebx
  801ee0:	03 45 0c             	add    0xc(%ebp),%eax
  801ee3:	50                   	push   %eax
  801ee4:	57                   	push   %edi
  801ee5:	e8 40 ea ff ff       	call   80092a <memmove>
		sys_cputs(buf, m);
  801eea:	83 c4 08             	add    $0x8,%esp
  801eed:	53                   	push   %ebx
  801eee:	57                   	push   %edi
  801eef:	e8 eb eb ff ff       	call   800adf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef4:	01 de                	add    %ebx,%esi
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	89 f0                	mov    %esi,%eax
  801efb:	3b 75 10             	cmp    0x10(%ebp),%esi
  801efe:	72 cc                	jb     801ecc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	83 ec 08             	sub    $0x8,%esp
  801f0e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f17:	74 2a                	je     801f43 <devcons_read+0x3b>
  801f19:	eb 05                	jmp    801f20 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f1b:	e8 5c ec ff ff       	call   800b7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f20:	e8 d8 eb ff ff       	call   800afd <sys_cgetc>
  801f25:	85 c0                	test   %eax,%eax
  801f27:	74 f2                	je     801f1b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 16                	js     801f43 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f2d:	83 f8 04             	cmp    $0x4,%eax
  801f30:	74 0c                	je     801f3e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f32:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f35:	88 02                	mov    %al,(%edx)
	return 1;
  801f37:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3c:	eb 05                	jmp    801f43 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f3e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f43:	c9                   	leave  
  801f44:	c3                   	ret    

00801f45 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801f45:	55                   	push   %ebp
  801f46:	89 e5                	mov    %esp,%ebp
  801f48:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f51:	6a 01                	push   $0x1
  801f53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f56:	50                   	push   %eax
  801f57:	e8 83 eb ff ff       	call   800adf <sys_cputs>
}
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <getchar>:

int
getchar(void)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f67:	6a 01                	push   $0x1
  801f69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6c:	50                   	push   %eax
  801f6d:	6a 00                	push   $0x0
  801f6f:	e8 29 f2 ff ff       	call   80119d <read>
	if (r < 0)
  801f74:	83 c4 10             	add    $0x10,%esp
  801f77:	85 c0                	test   %eax,%eax
  801f79:	78 0f                	js     801f8a <getchar+0x29>
		return r;
	if (r < 1)
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	7e 06                	jle    801f85 <getchar+0x24>
		return -E_EOF;
	return c;
  801f7f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f83:	eb 05                	jmp    801f8a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f85:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f8a:	c9                   	leave  
  801f8b:	c3                   	ret    

00801f8c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f8c:	55                   	push   %ebp
  801f8d:	89 e5                	mov    %esp,%ebp
  801f8f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f95:	50                   	push   %eax
  801f96:	ff 75 08             	pushl  0x8(%ebp)
  801f99:	e8 99 ef ff ff       	call   800f37 <fd_lookup>
  801f9e:	83 c4 10             	add    $0x10,%esp
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	78 11                	js     801fb6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fae:	39 10                	cmp    %edx,(%eax)
  801fb0:	0f 94 c0             	sete   %al
  801fb3:	0f b6 c0             	movzbl %al,%eax
}
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <opencons>:

int
opencons(void)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc1:	50                   	push   %eax
  801fc2:	e8 21 ef ff ff       	call   800ee8 <fd_alloc>
  801fc7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fca:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	78 3e                	js     80200e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fd0:	83 ec 04             	sub    $0x4,%esp
  801fd3:	68 07 04 00 00       	push   $0x407
  801fd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdb:	6a 00                	push   $0x0
  801fdd:	e8 b9 eb ff ff       	call   800b9b <sys_page_alloc>
  801fe2:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	78 23                	js     80200e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801feb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802000:	83 ec 0c             	sub    $0xc,%esp
  802003:	50                   	push   %eax
  802004:	e8 b8 ee ff ff       	call   800ec1 <fd2num>
  802009:	89 c2                	mov    %eax,%edx
  80200b:	83 c4 10             	add    $0x10,%esp
}
  80200e:	89 d0                	mov    %edx,%eax
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	56                   	push   %esi
  802016:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802017:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80201a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  802020:	e8 38 eb ff ff       	call   800b5d <sys_getenvid>
  802025:	83 ec 0c             	sub    $0xc,%esp
  802028:	ff 75 0c             	pushl  0xc(%ebp)
  80202b:	ff 75 08             	pushl  0x8(%ebp)
  80202e:	56                   	push   %esi
  80202f:	50                   	push   %eax
  802030:	68 f4 27 80 00       	push   $0x8027f4
  802035:	e8 5a e1 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80203a:	83 c4 18             	add    $0x18,%esp
  80203d:	53                   	push   %ebx
  80203e:	ff 75 10             	pushl  0x10(%ebp)
  802041:	e8 fd e0 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  802046:	c7 04 24 e0 27 80 00 	movl   $0x8027e0,(%esp)
  80204d:	e8 42 e1 ff ff       	call   800194 <cprintf>
  802052:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802055:	cc                   	int3   
  802056:	eb fd                	jmp    802055 <_panic+0x43>

00802058 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802058:	55                   	push   %ebp
  802059:	89 e5                	mov    %esp,%ebp
  80205b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205e:	89 d0                	mov    %edx,%eax
  802060:	c1 e8 16             	shr    $0x16,%eax
  802063:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80206a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206f:	f6 c1 01             	test   $0x1,%cl
  802072:	74 1d                	je     802091 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802074:	c1 ea 0c             	shr    $0xc,%edx
  802077:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80207e:	f6 c2 01             	test   $0x1,%dl
  802081:	74 0e                	je     802091 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802083:	c1 ea 0c             	shr    $0xc,%edx
  802086:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80208d:	ef 
  80208e:	0f b7 c0             	movzwl %ax,%eax
}
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    
  802093:	66 90                	xchg   %ax,%ax
  802095:	66 90                	xchg   %ax,%ax
  802097:	66 90                	xchg   %ax,%ax
  802099:	66 90                	xchg   %ax,%ax
  80209b:	66 90                	xchg   %ax,%ax
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 f6                	test   %esi,%esi
  8020b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020bd:	89 ca                	mov    %ecx,%edx
  8020bf:	89 f8                	mov    %edi,%eax
  8020c1:	75 3d                	jne    802100 <__udivdi3+0x60>
  8020c3:	39 cf                	cmp    %ecx,%edi
  8020c5:	0f 87 c5 00 00 00    	ja     802190 <__udivdi3+0xf0>
  8020cb:	85 ff                	test   %edi,%edi
  8020cd:	89 fd                	mov    %edi,%ebp
  8020cf:	75 0b                	jne    8020dc <__udivdi3+0x3c>
  8020d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d6:	31 d2                	xor    %edx,%edx
  8020d8:	f7 f7                	div    %edi
  8020da:	89 c5                	mov    %eax,%ebp
  8020dc:	89 c8                	mov    %ecx,%eax
  8020de:	31 d2                	xor    %edx,%edx
  8020e0:	f7 f5                	div    %ebp
  8020e2:	89 c1                	mov    %eax,%ecx
  8020e4:	89 d8                	mov    %ebx,%eax
  8020e6:	89 cf                	mov    %ecx,%edi
  8020e8:	f7 f5                	div    %ebp
  8020ea:	89 c3                	mov    %eax,%ebx
  8020ec:	89 d8                	mov    %ebx,%eax
  8020ee:	89 fa                	mov    %edi,%edx
  8020f0:	83 c4 1c             	add    $0x1c,%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    
  8020f8:	90                   	nop
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	39 ce                	cmp    %ecx,%esi
  802102:	77 74                	ja     802178 <__udivdi3+0xd8>
  802104:	0f bd fe             	bsr    %esi,%edi
  802107:	83 f7 1f             	xor    $0x1f,%edi
  80210a:	0f 84 98 00 00 00    	je     8021a8 <__udivdi3+0x108>
  802110:	bb 20 00 00 00       	mov    $0x20,%ebx
  802115:	89 f9                	mov    %edi,%ecx
  802117:	89 c5                	mov    %eax,%ebp
  802119:	29 fb                	sub    %edi,%ebx
  80211b:	d3 e6                	shl    %cl,%esi
  80211d:	89 d9                	mov    %ebx,%ecx
  80211f:	d3 ed                	shr    %cl,%ebp
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e0                	shl    %cl,%eax
  802125:	09 ee                	or     %ebp,%esi
  802127:	89 d9                	mov    %ebx,%ecx
  802129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80212d:	89 d5                	mov    %edx,%ebp
  80212f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802133:	d3 ed                	shr    %cl,%ebp
  802135:	89 f9                	mov    %edi,%ecx
  802137:	d3 e2                	shl    %cl,%edx
  802139:	89 d9                	mov    %ebx,%ecx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	09 c2                	or     %eax,%edx
  80213f:	89 d0                	mov    %edx,%eax
  802141:	89 ea                	mov    %ebp,%edx
  802143:	f7 f6                	div    %esi
  802145:	89 d5                	mov    %edx,%ebp
  802147:	89 c3                	mov    %eax,%ebx
  802149:	f7 64 24 0c          	mull   0xc(%esp)
  80214d:	39 d5                	cmp    %edx,%ebp
  80214f:	72 10                	jb     802161 <__udivdi3+0xc1>
  802151:	8b 74 24 08          	mov    0x8(%esp),%esi
  802155:	89 f9                	mov    %edi,%ecx
  802157:	d3 e6                	shl    %cl,%esi
  802159:	39 c6                	cmp    %eax,%esi
  80215b:	73 07                	jae    802164 <__udivdi3+0xc4>
  80215d:	39 d5                	cmp    %edx,%ebp
  80215f:	75 03                	jne    802164 <__udivdi3+0xc4>
  802161:	83 eb 01             	sub    $0x1,%ebx
  802164:	31 ff                	xor    %edi,%edi
  802166:	89 d8                	mov    %ebx,%eax
  802168:	89 fa                	mov    %edi,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	31 ff                	xor    %edi,%edi
  80217a:	31 db                	xor    %ebx,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	89 d8                	mov    %ebx,%eax
  802192:	f7 f7                	div    %edi
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 c3                	mov    %eax,%ebx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 fa                	mov    %edi,%edx
  80219c:	83 c4 1c             	add    $0x1c,%esp
  80219f:	5b                   	pop    %ebx
  8021a0:	5e                   	pop    %esi
  8021a1:	5f                   	pop    %edi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	39 ce                	cmp    %ecx,%esi
  8021aa:	72 0c                	jb     8021b8 <__udivdi3+0x118>
  8021ac:	31 db                	xor    %ebx,%ebx
  8021ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021b2:	0f 87 34 ff ff ff    	ja     8020ec <__udivdi3+0x4c>
  8021b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021bd:	e9 2a ff ff ff       	jmp    8020ec <__udivdi3+0x4c>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8021df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021e7:	85 d2                	test   %edx,%edx
  8021e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021f1:	89 f3                	mov    %esi,%ebx
  8021f3:	89 3c 24             	mov    %edi,(%esp)
  8021f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021fa:	75 1c                	jne    802218 <__umoddi3+0x48>
  8021fc:	39 f7                	cmp    %esi,%edi
  8021fe:	76 50                	jbe    802250 <__umoddi3+0x80>
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	f7 f7                	div    %edi
  802206:	89 d0                	mov    %edx,%eax
  802208:	31 d2                	xor    %edx,%edx
  80220a:	83 c4 1c             	add    $0x1c,%esp
  80220d:	5b                   	pop    %ebx
  80220e:	5e                   	pop    %esi
  80220f:	5f                   	pop    %edi
  802210:	5d                   	pop    %ebp
  802211:	c3                   	ret    
  802212:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802218:	39 f2                	cmp    %esi,%edx
  80221a:	89 d0                	mov    %edx,%eax
  80221c:	77 52                	ja     802270 <__umoddi3+0xa0>
  80221e:	0f bd ea             	bsr    %edx,%ebp
  802221:	83 f5 1f             	xor    $0x1f,%ebp
  802224:	75 5a                	jne    802280 <__umoddi3+0xb0>
  802226:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80222a:	0f 82 e0 00 00 00    	jb     802310 <__umoddi3+0x140>
  802230:	39 0c 24             	cmp    %ecx,(%esp)
  802233:	0f 86 d7 00 00 00    	jbe    802310 <__umoddi3+0x140>
  802239:	8b 44 24 08          	mov    0x8(%esp),%eax
  80223d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	85 ff                	test   %edi,%edi
  802252:	89 fd                	mov    %edi,%ebp
  802254:	75 0b                	jne    802261 <__umoddi3+0x91>
  802256:	b8 01 00 00 00       	mov    $0x1,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f7                	div    %edi
  80225f:	89 c5                	mov    %eax,%ebp
  802261:	89 f0                	mov    %esi,%eax
  802263:	31 d2                	xor    %edx,%edx
  802265:	f7 f5                	div    %ebp
  802267:	89 c8                	mov    %ecx,%eax
  802269:	f7 f5                	div    %ebp
  80226b:	89 d0                	mov    %edx,%eax
  80226d:	eb 99                	jmp    802208 <__umoddi3+0x38>
  80226f:	90                   	nop
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    
  80227c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802280:	8b 34 24             	mov    (%esp),%esi
  802283:	bf 20 00 00 00       	mov    $0x20,%edi
  802288:	89 e9                	mov    %ebp,%ecx
  80228a:	29 ef                	sub    %ebp,%edi
  80228c:	d3 e0                	shl    %cl,%eax
  80228e:	89 f9                	mov    %edi,%ecx
  802290:	89 f2                	mov    %esi,%edx
  802292:	d3 ea                	shr    %cl,%edx
  802294:	89 e9                	mov    %ebp,%ecx
  802296:	09 c2                	or     %eax,%edx
  802298:	89 d8                	mov    %ebx,%eax
  80229a:	89 14 24             	mov    %edx,(%esp)
  80229d:	89 f2                	mov    %esi,%edx
  80229f:	d3 e2                	shl    %cl,%edx
  8022a1:	89 f9                	mov    %edi,%ecx
  8022a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	89 c6                	mov    %eax,%esi
  8022b1:	d3 e3                	shl    %cl,%ebx
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 d0                	mov    %edx,%eax
  8022b7:	d3 e8                	shr    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	09 d8                	or     %ebx,%eax
  8022bd:	89 d3                	mov    %edx,%ebx
  8022bf:	89 f2                	mov    %esi,%edx
  8022c1:	f7 34 24             	divl   (%esp)
  8022c4:	89 d6                	mov    %edx,%esi
  8022c6:	d3 e3                	shl    %cl,%ebx
  8022c8:	f7 64 24 04          	mull   0x4(%esp)
  8022cc:	39 d6                	cmp    %edx,%esi
  8022ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022d2:	89 d1                	mov    %edx,%ecx
  8022d4:	89 c3                	mov    %eax,%ebx
  8022d6:	72 08                	jb     8022e0 <__umoddi3+0x110>
  8022d8:	75 11                	jne    8022eb <__umoddi3+0x11b>
  8022da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8022de:	73 0b                	jae    8022eb <__umoddi3+0x11b>
  8022e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022e4:	1b 14 24             	sbb    (%esp),%edx
  8022e7:	89 d1                	mov    %edx,%ecx
  8022e9:	89 c3                	mov    %eax,%ebx
  8022eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022ef:	29 da                	sub    %ebx,%edx
  8022f1:	19 ce                	sbb    %ecx,%esi
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 f0                	mov    %esi,%eax
  8022f7:	d3 e0                	shl    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	89 e9                	mov    %ebp,%ecx
  8022ff:	d3 ee                	shr    %cl,%esi
  802301:	09 d0                	or     %edx,%eax
  802303:	89 f2                	mov    %esi,%edx
  802305:	83 c4 1c             	add    $0x1c,%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    
  80230d:	8d 76 00             	lea    0x0(%esi),%esi
  802310:	29 f9                	sub    %edi,%ecx
  802312:	19 d6                	sbb    %edx,%esi
  802314:	89 74 24 04          	mov    %esi,0x4(%esp)
  802318:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80231c:	e9 18 ff ff ff       	jmp    802239 <__umoddi3+0x69>
